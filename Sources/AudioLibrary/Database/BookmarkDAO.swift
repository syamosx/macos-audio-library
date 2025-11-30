//
//  BookmarkDAO.swift
//  AudioLibrary
//
//  Data Access Object for Bookmark operations
//

import Foundation
import GRDB

class BookmarkDAO {
    private let db: DatabaseQueue
    
    init(database: DatabaseQueue = DatabaseManager.shared.database) {
        self.db = database
    }
    
    // MARK: - Create
    
    func insert(_ bookmark: Bookmark) throws -> Bookmark {
        var mutableBookmark = bookmark
        try db.write { db in
            try mutableBookmark.insert(db)
        }
        return mutableBookmark
    }
    
    // MARK: - Read
    
    func fetchAll(forBook contentHash: String) throws -> [Bookmark] {
        try db.read { db in
            try Bookmark
                .filter(Bookmark.Columns.bookContentHash == contentHash)
                .order(Bookmark.Columns.positionSeconds)
                .fetchAll(db)
        }
    }
    
    func fetchByID(_ id: Int64) throws -> Bookmark? {
        try db.read { db in
            try Bookmark.fetchOne(db, key: id)
        }
    }
    
    // MARK: - Update
    
    func update(_ bookmark: Bookmark) throws {
        var mutableBookmark = bookmark
        mutableBookmark.updatedAt = Date()
        try db.write { db in
            try mutableBookmark.update(db)
        }
    }
    
    // MARK: - Delete
    
    func delete(id: Int64) throws {
        _ = try db.write { db in
            try Bookmark.deleteOne(db, key: id)
        }
    }
}
