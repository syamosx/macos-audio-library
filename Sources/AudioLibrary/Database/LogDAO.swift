//
//  LogDAO.swift
//  AudioLibrary
//
//  Data Access Object for logging events
//

import Foundation
import GRDB

class LogDAO {
    private let db: DatabaseQueue
    
    init(database: DatabaseQueue = DatabaseManager.shared.database) {
        self.db = database
    }
    
    // MARK: - Create
    
    func log(type: String, bookContentHash: String? = nil, payload: [String: Any]? = nil) throws {
        var log = Log(
            id: nil,
            timestamp: Date(),
            type: type,
            bookContentHash: bookContentHash,
            payloadJSON: nil
        )
        
        if let payload = payload,
           let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            log.payloadJSON = jsonString
        }
        
        try db.write { db in
            try log.insert(db)
        }
    }
    
    // MARK: - Read
    
    func fetchRecent(limit: Int = 100) throws -> [Log] {
        try db.read { db in
            try Log
                .order(Log.Columns.timestamp.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
    
    func fetchForBook(_ contentHash: String, limit: Int = 50) throws -> [Log] {
        try db.read { db in
            try Log
                .filter(Log.Columns.bookContentHash == contentHash)
                .order(Log.Columns.timestamp.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
}
