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

    func sendPush() {
        print("BundleID: \(bundleId)")
        print("Token: \(token)")
        print("Payload: \(payload)")
        print("SandboxModeOn: \(sandboxModeOn)")
        print("Priority: \(priorityFromSelection)")
        print("Expiry: \(expiryFromSelection)")
    }
}
