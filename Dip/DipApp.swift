//
//  BeamerApp.swift
//  Beamer
//
//  Created by Roman Bugaian on 06.03.23.
//

import Logging
import SwiftUI

@main
struct DipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(
                replacing: CommandGroupPlacement.newItem
            ) { }
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
}
