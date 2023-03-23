//
//  PushService.swift
//  Beamer
//
//  Created by Roman Bugaian on 21.03.23.
//

import Foundation

class PushService: NSObject {
    func makeRequest() {
        let token = "66ae50eb15cf536f31f01005a09f8be4c3b254d7a863ad2e5fa2d6555d170543"
        
    }
    
    func getClientUrlCredential() -> URLCredential? {
        return nil
    }
}

extension PushService: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        
        if authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            return (.useCredential, getClientUrlCredential())
        } else {
            return (.performDefaultHandling, nil)
        }
    }
    
}
