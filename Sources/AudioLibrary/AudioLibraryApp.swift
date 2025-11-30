//
//  main.swift
//  AudioLibrary
//
//  Entry point for SPM executable
//

import SwiftUI

@main
struct AudioLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)
    }
}
