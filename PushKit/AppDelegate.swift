//
//  AppDelegate.swift
//  Beamer
//
//  Created by Roman Bugaian on 08.03.23.
//

import Foundation
import AppKit
import Logging

var logger = Logger(label: "dev.rbugaian.beamer-logger")

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.logLevel = .debug
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
