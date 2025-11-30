//
//  Bookmark.swift
//  AudioLibrary
//
//  Model representing a bookmark within an audiobook with GRDB persistence
//

import Foundation
import GRDB

struct Bookmark: Identifiable, Hashable {
    var id: Int64?
    var bookContentHash: String
    var positionSeconds: Double
    var label: String
    var note: String?
    var createdAt: Date
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

// MARK: - GRDB Conformance

extension Bookmark: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let bookContentHash = Column(CodingKeys.bookContentHash)
        static let positionSeconds = Column(CodingKeys.positionSeconds)
        static let label = Column(CodingKeys.label)
        static let note = Column(CodingKeys.note)
        static let createdAt = Column(CodingKeys.createdAt)
        static let updatedAt = Column(CodingKeys.updatedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookContentHash = "book_content_hash"
        case positionSeconds = "position_seconds"
        case label
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static let databaseTableName = "bookmarks"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
