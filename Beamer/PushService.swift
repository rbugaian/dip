//
//  PushService.swift
//  Beamer
//
//  Created by Roman Bugaian on 21.03.23.
//

import Foundation

class PushService: NSObject {
    let pks12Content: PKS12Certificate

    private var _urlSession: URLSession?
    var urlSession: URLSession {
        if let _urlSession = _urlSession {
            return _urlSession
        } else {
            let session = URLSession(
                configuration: .default,
                delegate: self,
                delegateQueue: .current
            )
            _urlSession = session
            return session
        }
    }

    init(withPKS12Content pksContent: PKS12Certificate) {
        pks12Content = pksContent
        super.init()
    }

    func sendPush(
        toToken token: String,
        withContent content: String,
        isSandbox: Bool,
        expiry: Int = 0,
        priority: Int = 1,
        bundleId: String? = nil
    ) async -> PushResult? {
        let url = url(forToken: token, isSandbox: isSandbox)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("\(priority)", forHTTPHeaderField: "apns-priority")
        urlRequest.addValue("\(expiry)", forHTTPHeaderField: "apns-expiration")
        
        if let bundleId = bundleId {
            urlRequest.addValue(bundleId, forHTTPHeaderField: "apns-topic")
        }

        urlRequest.httpBody = content.data(using: .utf8)

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            let bodyContent = String(data: data, encoding: .utf8)
            return PushResult(response: response, body: bodyContent)
        } catch {
            print("Error sending request: \(error)")
        }
        return nil
    }

    func getUrlCredential() -> URLCredential? {
        var cert: SecCertificate?
        SecIdentityCopyCertificate(pks12Content.identity, &cert)

        if let cert = cert {
            return URLCredential(
                identity: pks12Content.identity,
                certificates: [cert],
                persistence: .forSession
            )
        } else {
            return nil
        }
    }

    func url(forToken token: String, isSandbox: Bool) -> URL? {
        var url: URL?
        if isSandbox {
            url = URL(string: "https://api.sandbox.push.apple.com/3/device/\(token)")!
        } else {
            url = URL(string: "https://api.push.apple.com/3/device/\(token)")!
        }
        return url
    }
}

extension PushService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.useCredential, getUrlCredential())
    }
}

struct PushResult {
    let response: URLResponse
    let body: String?
}
