//
//  AppDelegate.swift
//  OpenUXKit-Example-Swift
//
//  Hosts the showcase. The single window pulls its content view controller
//  from the storyboard, so AppKit hooks (main menu, window restoration, etc.)
//  still flow through Interface Builder while every OpenUXKit object below
//  it is constructed in code.
//

import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {}

    func applicationWillTerminate(_ notification: Notification) {}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_ application: NSApplication) -> Bool {
        true
    }
}
