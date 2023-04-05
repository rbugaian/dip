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
    
    func importP12Certificate(fromUrl url: URL, withPassword password: String) -> PKS12Certificate? {
        let certificateData = try? Data(contentsOf: url) as CFData
        guard let certificateData = certificateData else {
            logger.error("Could not get certificate data.")
            return nil
        }
        
        var items: CFArray?
        var options: [String: String] = [:]
        let key = kSecImportExportPassphrase as String
        options[key] = password

        let importResult: OSStatus = SecPKCS12Import(certificateData, options as CFDictionary, &items)
        logger.debug("Import result: \(importResult)")
        if importResult != 0 || items == nil {
            logger.error("Error importing certificate.")
            return nil
        }
        
        let identityDict = unsafeBitCast(CFArrayGetValueAtIndex(items, 0), to: CFDictionary.self) as NSDictionary
        let identity = identityDict["identity"] as! SecIdentity
        let trustRef = identityDict["trust"] as! SecTrust
        let label = identityDict["label"] as! String
        
        let certificate = PKS12Certificate(identity: identity, trust: trustRef, label: label)
        return certificate
    }
}

class CertificateHelper {
    let certificateData: CFData?
    let certificatePassword: String

    private var certificateItems: CFArray?
    
    var pks12Content: PKS12Certificate?

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
            
            self.pks12Content = PKS12Certificate(identity: identity, trust: trustRef, label: label)
            print("Loaded pks12..")
        }
    }
}

struct PKS12Certificate {
    let identity: SecIdentity
    let trust: SecTrust
    let label: String
}
