//
//  ImportManager.swift
//  AudioLibrary
//
//  Manages file import and audio library organization
//

import Foundation
import AppKit

@Observable
class ImportManager {
    static let shared = ImportManager()
    
    private let bookDAO: BookDAO
    private let logDAO: LogDAO
    
    var isImporting: Bool = false
    var importProgress: Double = 0
    var importStatus: String = ""
    
    // Supported audio formats
    private let supportedExtensions = ["m4b", "m4a", "mp3", "aac", "mp4"]
    
    init(bookDAO: BookDAO = BookDAO(), logDAO: LogDAO = LogDAO()) {
        self.bookDAO = bookDAO
        self.logDAO = logDAO
    }
    
    // MARK: - File Selection
    
    func selectFiles() -> [URL]? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.audio, .mp3, .mpeg4Audio]
        panel.message = "Select audio files to import"
        
        if panel.runModal() == .OK {
            return panel.urls.filter { url in
                supportedExtensions.contains(url.pathExtension.lowercased())
            }
        }
        
        return nil
    }
    
    func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Select folder containing audio files"
        
        if panel.runModal() == .OK {
            return panel.urls.first
        }
        
        return nil
    }
    
    // MARK: - Folder Scanning
    
    func scanFolder(_ folderURL: URL) -> [URL] {
        var audioFiles: [URL] = []
        let fileManager = FileManager.default
        
        let enumerator = fileManager.enumerator(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  let isFile = resourceValues.isRegularFile,
                  isFile else { continue }
            
            if supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                audioFiles.append(fileURL)
            }
        }
        
        return audioFiles
    }
    
    // MARK: - Import
    
    func importFiles(_ urls: [URL]) async {
        await MainActor.run {
            isImporting = true
            importProgress = 0
        }
        
        let total = urls.count
        var imported = 0
        var skipped = 0
        var failed = 0
        
        for (index, url) in urls.enumerated() {
            await MainActor.run {
                importProgress = Double(index) / Double(total)
                importStatus = "Processing \(url.lastPathComponent)..."
            }
            
            do {
                let result = try await importFile(url)
                if result {
                    imported += 1
                } else {
                    skipped += 1
                }
            } catch {
                print("❌ Failed to import \(url.lastPathComponent): \(error)")
                failed += 1
            }
        }
        
        await MainActor.run {
            isImporting = false
            importProgress = 1.0
            importStatus = "Import complete: \(imported) imported, \(skipped) skipped, \(failed) failed"
        }
        
        // Log import
        try? logDAO.log(
            type: "import_completed",
            payload: [
                "total": total,
                "imported": imported,
                "skipped": skipped,
                "failed": failed
            ]
        )
        
        print("✅ Import complete: \(imported)/\(total) imported")
    }
    
    private func importFile(_ fileURL: URL) async throws -> Bool {
        // Compute content hash
        let contentHash = try FileHasher.sha256(of: fileURL)
        
        // Check if already exists
        if let existingBook = try bookDAO.fetchByContentHash(contentHash) {
            print("⏭️ Skipping duplicate: \(fileURL.lastPathComponent) (already exists as \(existingBook.title))")
            
            // Update device state with current path
            try updateDeviceState(contentHash: contentHash, path: fileURL.path, status: .good)
            
            return false
        }
        
        // Extract metadata
        let metadata = try await AudioMetadata.extract(from: fileURL)
        
        // Save artwork if present
        var artworkPath: String? = nil
        if let artworkData = metadata.artworkData {
            artworkPath = try saveArtwork(artworkData, contentHash: contentHash)
        }
        
        // Create book record
        let book = Book(
            id: nil,
            contentHash: contentHash,
            originalFilename: fileURL.lastPathComponent,
            title: metadata.title ?? fileURL.deletingPathExtension().lastPathComponent,
            author: metadata.artist ?? "Unknown Author",
            artworkPath: artworkPath,
            status: .active,
            fileSizeBytes: metadata.fileSize,
            durationSeconds: metadata.duration,
            tags: [],
            lastPositionSeconds: 0,
            lastTimePlayed: nil,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Save to database
        _ = try bookDAO.insert(book)
        
        // Create device state entry
        try createDeviceState(contentHash: contentHash, path: fileURL.path)
        
        // Log import
        try logDAO.log(type: "file_imported", bookContentHash: contentHash, payload: [
            "filename": book.originalFilename ?? "unknown",
            "title": book.title,
            "duration": metadata.duration,
            "size": metadata.fileSize
        ])
        
        ConsoleManager.shared.log("✅ Imported: \(book.title) (\(formatDuration(metadata.duration)))")
        
        return true
    }
    
    // MARK: - Artwork Management
    
    private func saveArtwork(_ artworkData: Data, contentHash: String) throws -> String {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let artworkFolder = appSupport.appendingPathComponent("AudioLibrary/Artwork", isDirectory: true)
        try fileManager.createDirectory(at: artworkFolder, withIntermediateDirectories: true)
        
        let artworkFile = artworkFolder.appendingPathComponent("\(contentHash).jpg")
        try artworkData.write(to: artworkFile)
        
        return artworkFile.path
    }
    
    // MARK: - Device State Management
    
    private func createDeviceState(contentHash: String, path: String) throws {
        var deviceState = DeviceState(
            id: nil,
            bookContentHash: contentHash,
            deviceID: "mac",
            status: .good,
            path: path,
            lastCheckedAt: Date()
        )
        
        try DatabaseManager.shared.database.write { db in
            try deviceState.insert(db)
        }
    }
    
    private func updateDeviceState(contentHash: String, path: String, status: DeviceState.DeviceStatus) throws {
        try DatabaseManager.shared.database.write { db in
            // Try to find existing device state
            if var existing = try DeviceState
                .filter(sql: "book_content_hash = ? AND device_id = ?", arguments: [contentHash, "mac"])
                .fetchOne(db) {
                
                existing.path = path
                existing.status = status
                existing.lastCheckedAt = Date()
                try existing.update(db)
            } else {
                // Create new one
                var newState = DeviceState(
                    id: nil,
                    bookContentHash: contentHash,
                    deviceID: "mac",
                    status: status,
                    path: path,
                    lastCheckedAt: Date()
                )
                try newState.insert(db)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
