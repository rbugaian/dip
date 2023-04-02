//
//  CertificateRepository.swift
//  Beamer
//
//  Created by Roman Bugaian on 21.03.23.
//

import Foundation
import Security

class CertificateRepository {
    
    func importCertificate() {
        let fileUrl = Bundle.main.url(forResource: "mobile_apns_tester_cert", withExtension: "p12")
        if let fileUrl = fileUrl {
            print("URL: \(fileUrl)")

            let p12Data = try? Data(contentsOf: fileUrl)
            let key = kSecImportExportPassphrase as String
            let options = [key: "Qwertyui92"]
            var items: CFArray?

            let securityError: OSStatus = SecPKCS12Import(p12Data! as CFData, options as CFDictionary, &items)
            print("import status: \(securityError)")
            print("items: \(items)")
        } else {
            print("Missing file")
        }
    }
}

class CertificateHelper {
    let certificateData: CFData?
    let certificatePassword: String

    private var certificateItems: CFArray?
    
    var pks12Content: PKS12Content?

    init(certificateUrl: URL, password: String) {
        certificateData = try? Data(contentsOf: certificateUrl) as CFData
        certificatePassword = password
    }

    func load() async {
        let key = kSecImportExportPassphrase as String
        let options = [key: certificatePassword]
        var items: CFArray?
        if let certificateData = certificateData {
            
            let importResult: OSStatus = SecPKCS12Import(certificateData, options as CFDictionary, &items)
            print("Import result: \(importResult)")
            
            let identityDict = unsafeBitCast(CFArrayGetValueAtIndex(items, 0), to: CFDictionary.self) as NSDictionary
            let identity = identityDict["identity"] as! SecIdentity
            let trustRef = identityDict["trust"] as! SecTrust
            let label = identityDict["label"] as! String
            
            self.pks12Content = PKS12Content(identity: identity, trust: trustRef, label: label)
            print("Loaded pks12..")
        }
    }
}

struct PKS12Content {
    let identity: SecIdentity
    let trust: SecTrust
    let label: String
}
