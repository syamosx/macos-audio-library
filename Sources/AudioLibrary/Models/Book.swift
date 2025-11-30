//
//  Book.swift
//  AudioLibrary
//
//  Model representing an audiobook
//

import Foundation

struct Book: Identifiable, Hashable {
    let id: Int
    let contentHash: String
    let originalFilename: String
    var title: String
    var status: BookStatus
    var fileSizeBytes: Int64
    var durationSeconds: Double
    var tags: [String]
    var lastPositionSeconds: Double
    var lastTimePlayed: Date?
    var notes: String
    let createdAt: Date
    var updatedAt: Date
    
    enum BookStatus: String {
        case active
        case deleted
    }
    
    // Computed properties for display
    var formattedDuration: String {
        let hours = Int(durationSeconds) / 3600
        let minutes = (Int(durationSeconds) % 3600) / 60
        let seconds = Int(durationSeconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSizeBytes)
    }
    
    var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return lastPositionSeconds / durationSeconds
    }
}
