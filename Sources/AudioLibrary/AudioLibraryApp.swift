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
    @State private var libraryViewModel = LibraryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(libraryViewModel)
                .frame(minWidth: libraryViewModel.isSidebarVisible ? 600 : 350, minHeight: 450)
                .background(Color(red: 0.12, green: 0.12, blue: 0.13))
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            SidebarCommands() // Standard sidebar commands
            
            CommandMenu("Library") {
                Button("Refresh Library") {
                    libraryViewModel.refreshBooks()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("Import Files...") {
                    libraryViewModel.importFiles()
                }
                .keyboardShortcut("i", modifiers: .command)
            }
        }
    }
}
