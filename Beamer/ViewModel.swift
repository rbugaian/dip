//
//  ViewModel.swift
//  Beamer
//
//  Created by Roman Bugaian on 03.04.23.
//

import Foundation
import SwiftUI

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
        CertificatePickerItem(
            id: -3,
            text: "Import .p8 certificate..",
            p12Certificate: nil
        ),
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

    func importP8Certificate() { }

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
}

struct CertificatePickerItem: Identifiable {
    var id: Int
    var text: String
    var p12Certificate: PKS12Certificate?
}