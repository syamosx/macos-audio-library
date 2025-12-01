//
//  Book.swift
//  AudioLibrary
//
//  Model representing an audiobook with GRDB persistence
//

import Foundation
import GRDB

struct Book: Identifiable, Hashable {
    var id: Int64?
    var contentHash: String
    var originalFilename: String?
    var title: String
    var author: String
    var artworkPath: String?
    var dominantColor: String? // Hex code from Gemini
    var status: BookStatus
    var fileSizeBytes: Int64?
    var durationSeconds: Double?
    var tags: [String]
    
    // Playback state
    var lastPositionSeconds: Double
    var lastTimePlayed: Date?
    
    // User metadata
    var notes: String?
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    
    enum BookStatus: String, Codable {
        case active
        case deleted
        case private_ = "private"
    }
    
    // Computed properties for display
    var formattedDuration: String {
        guard let duration = durationSeconds else { return "--:--" }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedFileSize: String {
        guard let size = fileSizeBytes else { return "Unknown" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var progress: Double {
        guard let duration = durationSeconds, duration > 0 else { return 0 }
        return lastPositionSeconds / duration
    }
}

// MARK: - GRDB Conformance

extension Book: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let contentHash = Column(CodingKeys.contentHash)
        static let originalFilename = Column(CodingKeys.originalFilename)
        static let title = Column(CodingKeys.title)
        static let author = Column(CodingKeys.author)
        static let artworkPath = Column(CodingKeys.artworkPath)
        static let dominantColor = Column(CodingKeys.dominantColor)
        static let status = Column(CodingKeys.status)
        static let fileSizeBytes = Column(CodingKeys.fileSizeBytes)
        static let durationSeconds = Column(CodingKeys.durationSeconds)
        static let tags = Column(CodingKeys.tags)
        static let lastPositionSeconds = Column(CodingKeys.lastPositionSeconds)
        static let lastTimePlayed = Column(CodingKeys.lastTimePlayed)
        static let notes = Column(CodingKeys.notes)
        static let createdAt = Column(CodingKeys.createdAt)
        static let updatedAt = Column(CodingKeys.updatedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case contentHash = "content_hash"
        case originalFilename = "original_filename"
        case title
        case author
        case artworkPath = "artwork_path"
        case dominantColor = "dominant_color"
        case status
        case fileSizeBytes = "file_size_bytes"
        case durationSeconds = "duration_seconds"
        case tags
        case lastPositionSeconds = "last_position_seconds"
        case lastTimePlayed = "last_time_played"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Persistence
    static let databaseTableName = "books"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    // Custom encoding/decoding for tags array
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        contentHash = try container.decode(String.self, forKey: .contentHash)
        originalFilename = try container.decodeIfPresent(String.self, forKey: .originalFilename)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decodeIfPresent(String.self, forKey: .author) ?? "Unknown Author"
        artworkPath = try container.decodeIfPresent(String.self, forKey: .artworkPath)
        dominantColor = try container.decodeIfPresent(String.self, forKey: .dominantColor)
        status = try container.decode(BookStatus.self, forKey: .status)
        fileSizeBytes = try container.decodeIfPresent(Int64.self, forKey: .fileSizeBytes)
        durationSeconds = try container.decodeIfPresent(Double.self, forKey: .durationSeconds)
        lastPositionSeconds = try container.decode(Double.self, forKey: .lastPositionSeconds)
        lastTimePlayed = try container.decodeIfPresent(Date.self, forKey: .lastTimePlayed)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode tags from JSON string
        if let tagsString = try container.decodeIfPresent(String.self, forKey: .tags),
           let tagsData = tagsString.data(using: .utf8) {
            tags = (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
        } else {
            tags = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(contentHash, forKey: .contentHash)
        try container.encodeIfPresent(originalFilename, forKey: .originalFilename)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encodeIfPresent(artworkPath, forKey: .artworkPath)
        try container.encodeIfPresent(dominantColor, forKey: .dominantColor)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(fileSizeBytes, forKey: .fileSizeBytes)
        try container.encodeIfPresent(durationSeconds, forKey: .durationSeconds)
        try container.encode(lastPositionSeconds, forKey: .lastPositionSeconds)
        try container.encodeIfPresent(lastTimePlayed, forKey: .lastTimePlayed)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode tags as JSON string
        if !tags.isEmpty,
           let tagsData = try? JSONEncoder().encode(tags),
           let tagsString = String(data: tagsData, encoding: .utf8) {
            try container.encode(tagsString, forKey: .tags)
        } else {
            try container.encodeNil(forKey: .tags)
        }
    }
}
