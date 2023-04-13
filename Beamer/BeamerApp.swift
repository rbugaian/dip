//
//  BeamerApp.swift
//  Beamer
//
//  Created by Roman Bugaian on 06.03.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct BeamerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
}
