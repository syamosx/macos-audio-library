//
//  ExportManager.swift
//  AudioLibrary
//
//  Manages database export and backup
//

import Foundation
import AppKit

class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    /// Export database to a backup file
    func exportDatabase() -> Bool {
        let savePanel = NSSavePanel()
        savePanel.title = "Export AudioLibrary Database"
        savePanel.message = "Choose where to save your library backup"
        savePanel.nameFieldStringValue = "AudioLibrary-\(dateFormatter.string(from: Date())).db"
        savePanel.allowedContentTypes = [.database]
        savePanel.canCreateDirectories = true
        
        guard savePanel.runModal() == .OK, let destinationURL = savePanel.url else {
            return false
        }
        
        do {
            let fileManager = FileManager.default
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let dbPath = appSupport
                .appendingPathComponent("AudioLibrary", isDirectory: true)
                .appendingPathComponent("library.db")
            
            // Copy database file
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: dbPath, to: destinationURL)
            
            print("✅ Database exported to: \(destinationURL.path)")
            return true
            
        } catch {
            print("❌ Export failed: \(error)")
            return false
        }
    }
    
    /// Import database from a backup file
    func importDatabase() -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import AudioLibrary Database"
        openPanel.message = "Choose a backup database file to restore"
        openPanel.allowedContentTypes = [.database]
        openPanel.allowsMultipleSelection = false
        
        guard openPanel.runModal() == .OK, let sourceURL = openPanel.urls.first else {
            return false
        }
        
        // Show confirmation alert
        let alert = NSAlert()
        alert.messageText = "Import Database?"
        alert.informativeText = "This will replace your current library with the backup. This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Import")
        alert.addButton(withTitle: "Cancel")
        
        guard alert.runModal() == .alertFirstButtonReturn else {
            return false
        }
        
        do {
            let fileManager = FileManager.default
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let dbFolder = appSupport.appendingPathComponent("AudioLibrary", isDirectory: true)
            try fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
            
            let dbPath = dbFolder.appendingPathComponent("library.db")
            
            // Backup current database first
            if fileManager.fileExists(atPath: dbPath.path) {
                let backupPath = dbFolder.appendingPathComponent("library-backup-\(dateFormatter.string(from: Date())).db")
                try fileManager.copyItem(at: dbPath, to: backupPath)
                try fileManager.removeItem(at: dbPath)
            }
            
            // Copy imported database
            try fileManager.copyItem(at: sourceURL, to: dbPath)
            
            print("✅ Database imported from: \(sourceURL.path)")
            
            // Show restart required alert
            let restartAlert = NSAlert()
            restartAlert.messageText = "Import Successful"
            restartAlert.informativeText = "Please restart the app for changes to take effect."
            restartAlert.alertStyle = .informational
            restartAlert.addButton(withTitle: "OK")
            restartAlert.runModal()
            
            return true
            
        } catch {
            print("❌ Import failed: \(error)")
            return false
        }
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
