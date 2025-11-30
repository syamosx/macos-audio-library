//
//  Bookmark.swift
//  AudioLibrary
//
//  Model representing a bookmark within an audiobook
//

import Foundation

struct Bookmark: Identifiable, Hashable {
    let id: Int
    let bookContentHash: String
    var positionSeconds: Double
    var label: String
    var note: String
    let createdAt: Date
    var updatedAt: Date
    
    // Computed property for formatted timestamp
    var formattedPosition: String {
        let hours = Int(positionSeconds) / 3600
        let minutes = (Int(positionSeconds) % 3600) / 60
        let seconds = Int(positionSeconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
