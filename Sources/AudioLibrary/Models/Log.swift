//
//  Log.swift
//  AudioLibrary
//
//  Model for event logging with GRDB persistence
//

import Foundation
import GRDB

struct Log: Identifiable {
    var id: Int64?
    var timestamp: Date
    var type: String
    var bookContentHash: String?
    var payloadJSON: String?
}

// MARK: - GRDB Conformance

extension Log: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let timestamp = Column(CodingKeys.timestamp)
        static let type = Column(CodingKeys.type)
        static let bookContentHash = Column(CodingKeys.bookContentHash)
        static let payloadJSON = Column(CodingKeys.payloadJSON)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case type
        case bookContentHash = "book_content_hash"
        case payloadJSON = "payload_json"
    }
    
    static let databaseTableName = "logs"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
