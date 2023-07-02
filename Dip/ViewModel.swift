//
//  ViewModel.swift
//  Beamer
//
//  Created by Roman Bugaian on 03.04.23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class ViewModel: ObservableObject {
    @Published var bundleId: String = ""
    @Published var token: String = ""
    @Published var payload: String = "{ \"aps\": { \"alert\":\"Hello\" } }"
    @Published var sandboxModeOn: Bool = true

    @Published var selectedPriority = 1
    @Published var selectedExpiry = 1

    @Published var certificateSelection = -1

    let certificateRepository = CertificateRepository()
    var pushService: PushService?

    @Published var passwordSheetShown = false

    var pendingP12CertificateTransaction: P12CertificateImportTransaction?
    var pendingP8CertificateTransaction: P8CertificateImportTransaction?

    @Published var p8CredentialsRequired = false
     
    @Published var teamId: String = "" {
        didSet {
            let index = certificatePickerItems.firstIndex(
                where: { $0.id == selectedPickerItemId }
            )
            if let index = index {
                self.certificatePickerItems[index].p8Certificate?.teamId = teamId
            }
        }
    }
    
    @Published var keyId: String = "" {
        didSet {
            let index = certificatePickerItems.firstIndex(
                where: { $0.id == selectedPickerItemId }
            )
            if let index = index {
                self.certificatePickerItems[index].p8Certificate?.keyId = keyId
            }
        }
    }

    @Published var certificatePickerItems: [CertificatePickerItem] = [
        CertificatePickerItem(
            id: -1,
            text: "Select push certificate",
            p12Certificate: nil
        ),
        CertificatePickerItem(
            id: -2,
            text: "Import .p12 certificate..",
            p12Certificate: nil
        ),
//        CertificatePickerItem(
//            id: -3,
//            text: "Import .p8 certificate..",
//            p12Certificate: nil
//        ),
    ]

    var priorityFromSelection: Int {
        switch selectedPriority {
        case 2: return 1
        case 3: return 5
        case 4: return 10
        default:
            return 1
        }
    }

    var expiryFromSelection: TimeInterval {
        switch selectedExpiry {
        case 2: return 0.0
        case 3: return 60.0
        default:
            return 0.0
        }
    }

    var selectedP12Certificate: PKS12Certificate? {
        let selectedItem = certificatePickerItems.first(where: { $0.id == certificateSelection })
        return selectedItem?.p12Certificate
    }
    
    var selectedPickerItem: CertificatePickerItem?
    var selectedPickerItemId: Int = -1

    func handlePickerSelection(_ itemId: Int) {
        logger.debug("PickerChanged: \(itemId)")
        switch itemId {
        case -2: startP12CertificateImport()
        case -3: startP8CertificateImport()
        default: break // do nothing
        }
        
        selectedPickerItem = certificatePickerItems.first(where: { $0.id == itemId })
        selectedPickerItemId = itemId
        
        if itemId == -3 || selectedPickerItem?.p8Certificate != nil {
            p8CredentialsRequired = true
        } else {
            p8CredentialsRequired = false
        }
        
        if let p8Item = selectedPickerItem?.p8Certificate {
            self.keyId = p8Item.keyId ?? ""
            self.teamId = p8Item.teamId ?? ""
        }
    }

    func startP12CertificateImport() {
        pendingP12CertificateTransaction = P12CertificateImportTransaction()

        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.pkcs12]

        if panel.runModal() == .OK {
            pendingP12CertificateTransaction?.certificateURL = panel.url

            if let fileUrl = pendingP12CertificateTransaction?.certificateURL {
                logger.debug("Selected file URL: \(fileUrl)")
                passwordSheetShown.toggle()
            } else {
                logger.error("Missing import URL.")

                pendingP12CertificateTransaction = nil
            }
        } else {
            certificateSelection = -1
            pendingP12CertificateTransaction = nil
        }
    }

    func finalizeP12CertificateImport() {
        guard let importTransaction = pendingP12CertificateTransaction else {
            logger.error("Could not finalize P12 import transaction. Missing transaction.")
            return
        }

        guard let certificateUrl = importTransaction.certificateURL else {
            logger.error("Illegal transaction state. Missing certificate URL.")
            return
        }

        guard let certificatePassword = importTransaction.certificatePassword else {
            logger.error("Illegal transaction state. Missing certificate password.")
            return
        }

        let certificate = certificateRepository.importP12Certificate(
            fromUrl: certificateUrl,
            withPassword: certificatePassword
        )

        if let certificate = certificate {
            let certificateItem = CertificatePickerItem(
                id: certificatePickerItems.count + 1,
                text: certificate.label,
                p12Certificate: certificate
            )
            certificatePickerItems.insert(certificateItem, at: certificatePickerItems.count - 2)
            certificateSelection = certificateItem.id

            logger.debug("Initialised push service.")
            pushService = PushService(withPKS12Content: certificate)
        } else {
            certificateSelection = -1
        }
    }

    func startP8CertificateImport() {
        pendingP8CertificateTransaction = P8CertificateImportTransaction()
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        let p8Type = UTType("dev.rbugaian.p8")
        guard let p8Type = p8Type else {
            logger.error("Could not parse UTType.")
            return
        }

        panel.allowedContentTypes = [p8Type]
        if panel.runModal() == .OK {
            pendingP8CertificateTransaction?.certificateURL = panel.url
            logger.debug("Selected P8 file url: \(pendingP8CertificateTransaction?.certificateURL)")

            var certificateItem = CertificatePickerItem(
                id: certificatePickerItems.count + 1,
                text: "P8 Key: \(pendingP8CertificateTransaction?.certificateURL?.lastPathComponent ?? "null")"
            )
            
            if let url = pendingP8CertificateTransaction?.certificateURL {
                var certificate = P8Certificate(certificateUrl: url)
                certificateItem.p8Certificate = certificate
            }
            
            certificatePickerItems.insert(certificateItem, at: certificatePickerItems.count - 2)
            certificateSelection = certificateItem.id

            p8CredentialsRequired = true
        } else {
            logger.debug("P8 file selection cancelled.")
            pendingP8CertificateTransaction = nil
            p8CredentialsRequired = false
            certificateSelection = -1
        }
    }

    func sendPush() {
        logger.debug("BundleID: \(bundleId)")
        logger.debug("Token: \(token)")
        logger.debug("Payload: \(payload)")
        logger.debug("SandboxModeOn: \(sandboxModeOn)")
        logger.debug("Priority: \(priorityFromSelection)")
        logger.debug("Expiry: \(expiryFromSelection)")
        logger.debug("Selected certificate: \(String(describing: selectedP12Certificate))")

        Task {
            let pushResult = await self.pushService?.sendPush(
                toToken: token,
                withContent: payload,
                isSandbox: sandboxModeOn,
                expiry: Int(selectedExpiry),
                priority: selectedPriority,
                bundleId: bundleId
            )
            logger.debug("Push result: \(String(describing: pushResult))")
        }
    }
}

struct P12CertificateImportTransaction {
    var certificatePassword: String?
    var certificateURL: URL?
    var p8Certificate: P8Certificate?
}

struct CertificatePickerItem: Identifiable {
    var id: Int
    var text: String
    var p12Certificate: PKS12Certificate?
    var p8Certificate: P8Certificate?
}
