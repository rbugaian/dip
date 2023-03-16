//
//  AppDelegate.swift
//  Beamer
//
//  Created by Roman Bugaian on 08.03.23.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
