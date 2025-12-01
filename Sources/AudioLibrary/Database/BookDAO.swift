//
//  BookDAO.swift
//  AudioLibrary
//
//  Data Access Object for Book operations
//

import Foundation
import GRDB

class BookDAO {
    private let db: DatabaseQueue
    
    init(database: DatabaseQueue = DatabaseManager.shared.database) {
        self.db = database
    }
    
    // MARK: - Create
    
    func insert(_ book: Book) throws -> Book {
        var mutableBook = book
        try db.write { db in
            try mutableBook.insert(db)
        }
        return mutableBook
    }
    
    // MARK: - Read
    
    func fetchAll() throws -> [Book] {
        try db.read { db in
            try Book
                .filter(Book.Columns.status == Book.BookStatus.active.rawValue)
                .order(Book.Columns.lastTimePlayed.desc)
                .fetchAll(db)
        }
    }
    
    func fetchPrivate() throws -> [Book] {
        try db.read { db in
            try Book
                .filter(Book.Columns.status == Book.BookStatus.private_.rawValue)
                .order(Book.Columns.lastTimePlayed.desc)
                .fetchAll(db)
        }
    }
    
    func fetchByContentHash(_ contentHash: String) throws -> Book? {
        try db.read { db in
            try Book
                .filter(Book.Columns.contentHash == contentHash)
                .fetchOne(db)
        }
    }
    
    func fetchRecentlyPlayed(limit: Int = 50) throws -> [Book] {
        try db.read { db in
            try Book
                .filter(Book.Columns.status == Book.BookStatus.active.rawValue)
                .filter(Book.Columns.lastTimePlayed != nil)
                .order(Book.Columns.lastTimePlayed.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
    
    func search(query: String) throws -> [Book] {
        try db.read { db in
            let pattern = "%\(query)%"
            return try Book
                .filter(Book.Columns.status == Book.BookStatus.active.rawValue)
                .filter(Book.Columns.title.like(pattern) || Book.Columns.tags.like(pattern))
                .order(Book.Columns.title)
                .fetchAll(db)
        }
    }
    
    // MARK: - Update
    
    func update(_ book: Book) throws {
        var mutableBook = book
        mutableBook.updatedAt = Date()
        try db.write { db in
            try mutableBook.update(db)
        }
    }
    
    func updatePosition(contentHash: String, position: Double) throws {
        try db.write { db in
            if var book = try Book
                .filter(Book.Columns.contentHash == contentHash)
                .fetchOne(db) {
                book.lastPositionSeconds = position
                book.lastTimePlayed = Date()
                book.updatedAt = Date()
                try book.update(db)
                print("✅ BookDAO: Updated position for '\(book.title)' to \(position)")
            } else {
                print("❌ BookDAO: Failed to find book with hash \(contentHash) to update position")
            }
        }
    }
    
    // MARK: - Delete
    
    func delete(contentHash: String) throws {
        try db.write { db in
            if var book = try Book
                .filter(Book.Columns.contentHash == contentHash)
                .fetchOne(db) {
                book.status = .deleted
                book.updatedAt = Date()
                try book.update(db)
            }
        }
    }
    
    func permanentlyDelete(contentHash: String) throws {
        _ = try db.write { db in
            try Book
                .filter(Book.Columns.contentHash == contentHash)
                .deleteAll(db)
        }
    }
}
