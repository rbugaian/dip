//
//  PushService.swift
//  Beamer
//
//  Created by Roman Bugaian on 21.03.23.
//

import Foundation

class PushService: NSObject {
    var certificate: PKS12Content?

    func sendPush(toToken token: String, withContent content: String, authorizedWith certificate: PKS12Content) async {
        self.certificate = certificate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .current)

        let url = URL(string: "https://api.sandbox.push.apple.com/3/device/\(token)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("10", forHTTPHeaderField: "apns-priority")
        urlRequest.addValue("dev.rbugaian.MobileApnsTester", forHTTPHeaderField: "apns-topic")

        urlRequest.httpBody = content.data(using: .utf8)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            let bodyContent = String(data: data, encoding: .utf8)

            print("Push response: \(response)")
            print("Body: \(bodyContent)")
        } catch {
            print("Error sending request: \(error)")
        }
    }

    func getClientUrlCredential() -> URLCredential? {
        guard let certificate = certificate else {
            print("Error: missing certificate.")
            return nil
        }
        var cert: SecCertificate?
        SecIdentityCopyCertificate(certificate.identity, &cert)
        let credentials = URLCredential(
            identity: certificate.identity,
            certificates: [cert!],
            persistence: .forSession
        )
        return credentials
    }
}

extension PushService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.useCredential, getClientUrlCredential())
    }
}
