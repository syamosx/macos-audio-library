//
//  DeviceState.swift
//  AudioLibrary
//
//  Model for tracking local file paths with GRDB persistence
//

import Foundation
import GRDB

struct DeviceState: Identifiable {
    var id: Int64?
    var bookContentHash: String
    var deviceID: String
    var status: DeviceStatus
    var path: String
    var lastCheckedAt: Date
    
    enum DeviceStatus: String, Codable {
        case good
        case bad
        case unknown
    }
}

// MARK: - GRDB Conformance

extension DeviceState: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let bookContentHash = Column(CodingKeys.bookContentHash)
        static let deviceID = Column(CodingKeys.deviceID)
        static let status = Column(CodingKeys.status)
        static let path = Column(CodingKeys.path)
        static let lastCheckedAt = Column(CodingKeys.lastCheckedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookContentHash = "book_content_hash"
        case deviceID = "device_id"
        case status
        case path
        case lastCheckedAt = "last_checked_at"
    }
    
    static let databaseTableName = "device_state"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
