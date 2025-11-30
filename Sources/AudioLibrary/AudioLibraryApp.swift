//
//  main.swift
//  AudioLibrary
//
//  Entry point for SPM executable
//

import SwiftUI

@main
struct AudioLibraryApp: App {
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, idealWidth: 1200, minHeight: 600, idealHeight: 800)
                .environmentObject(audioPlayer)
        }
        .commands {
            SidebarCommands()
            
            CommandGroup(replacing: .importExport) {
                Button("Export Database...") {
                    _ = ExportManager.shared.exportDatabase()
                }
                .keyboardShortcut("E", modifiers: [.command, .shift])
                
                Button("Import Database...") {
                    _ = ExportManager.shared.importDatabase()
                }
                .keyboardShortcut("I", modifiers: [.command, .shift])
            }
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)
    }
}
