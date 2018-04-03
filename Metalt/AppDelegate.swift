//
//  AppDelegate.swift
//  Metalt
//
//  Created by Habib Alamin on 31/03/2018.
//  Copyright © 2018 Alaminium. All rights reserved.
//

import Cocoa

import AppKit

import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var statusBarItemMenu: NSMenu!

  let statusBarItem = NSStatusBar.system
    .statusItem(withLength: NSStatusItem.variableLength)

  func applicationDidFinishLaunching(_ aNotification: Notification)
  {
    statusBarItem.title = "⌥"
    statusBarItem.menu = statusBarItemMenu

    let accessibilityCheckOptions = [
      kAXTrustedCheckOptionPrompt.takeRetainedValue() : kCFBooleanTrue
    ] as CFDictionary

    if (!AXIsProcessTrustedWithOptions(accessibilityCheckOptions))
    {
      // AX prompt remains after app termination.
      NSApplication.shared.terminate(self)
    } else
    {
      let tap = CGEvent
        .tapCreate(tap: .cgAnnotatedSessionEventTap,
                   place: .tailAppendEventTap,
                   options: .defaultTap,
                   eventsOfInterest:
                     CGEventMask(1 << CGEventType.keyDown.rawValue),
                   callback: altToMetaTransformer,
                   userInfo: nil)
      // TODO: handle `tap == nil`

      let runLoopSource =
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

      CFRunLoopAddSource(CFRunLoopGetCurrent(),
                         runLoopSource,
                         .commonModes)
      CFRunLoopRun()
    }
  }

  func applicationWillTerminate(_ aNotification: Notification)
  {
  }
}
