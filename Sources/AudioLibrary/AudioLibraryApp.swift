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
            // 1. App Menu (Standard)
            // 2. File Menu (Import)
            CommandGroup(replacing: .newItem) {
                Button("Import Files...") {
                    libraryViewModel.importFiles()
                }
                .keyboardShortcut("i", modifiers: .command)
            }
            
            // 3. View Menu (Sidebar)
            SidebarCommands()
            
            // 4. Library Menu (Refresh, etc)
            CommandMenu("Library") {
                Button("Refresh Library") {
                    libraryViewModel.refreshBooks()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("Recalculate All Colors") {
                    // Future feature
                }
                .disabled(true)
            }
            
            // 5. Settings / Tools
            CommandMenu("Settings") {
                Button("Set Gemini API Key...") {
                    let alert = NSAlert()
                    alert.messageText = "Enter Gemini API Key"
                    alert.informativeText = "Get your key from Google AI Studio. It will be saved securely in Application Support."
                    alert.addButton(withTitle: "Save")
                    alert.addButton(withTitle: "Cancel")
                    
                    let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
                    input.placeholderString = "AIza..."
                    alert.accessoryView = input
                    
                    if alert.runModal() == .alertFirstButtonReturn {
                        let key = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !key.isEmpty {
                            GeminiColorService.shared.setApiKey(key)
                        }
                    }
                }
            }
        }
    }
}
