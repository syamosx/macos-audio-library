//
//  DatabaseManager.swift
//  AudioLibrary
//
//  Manages SQLite database with GRDB
//

import Foundation
import GRDB

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var dbQueue: DatabaseQueue?
    
    private init() {}
    
    // MARK: - Setup
    
    func setup() throws {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let dbFolder = appSupport.appendingPathComponent("AudioLibrary", isDirectory: true)
        try fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
        
        let dbPath = dbFolder.appendingPathComponent("library.db").path
        
        dbQueue = try DatabaseQueue(path: dbPath)
        
        try migrator.migrate(dbQueue!)
    }
    
    // MARK: - Database Queue
    
    var database: DatabaseQueue {
        guard let dbQueue = dbQueue else {
            fatalError("Database not initialized. Call setup() first.")
        }
        return dbQueue
    }
    
    // MARK: - Migrations
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration v1: Initial schema
        migrator.registerMigration("v1_initial_schema") { db in
            // Books table
            try db.create(table: "books") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content_hash", .text).notNull().unique()
                t.column("original_filename", .text)
                t.column("title", .text).notNull()
                t.column("status", .text).notNull().defaults(to: "active")
                    .check(sql: "status IN ('active', 'deleted')")
                t.column("file_size_bytes", .integer)
                t.column("duration_seconds", .double)
                t.column("tags", .text) // JSON array
                t.column("last_position_seconds", .double).defaults(to: 0)
                t.column("last_time_played", .datetime)
                t.column("notes", .text)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            // Bookmarks table
            try db.create(table: "bookmarks") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("book_content_hash", .text).notNull()
                    .references("books", column: "content_hash", onDelete: .cascade)
                t.column("position_seconds", .double).notNull()
                t.column("label", .text).notNull()
                t.column("note", .text)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }
            
            // Logs table
            try db.create(table: "logs") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("timestamp", .datetime).notNull()
                t.column("type", .text).notNull()
                t.column("book_content_hash", .text)
                t.column("payload_json", .text)
            }
            
            // Device state table (local only, not synced)
            try db.create(table: "device_state") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("book_content_hash", .text).notNull()
                t.column("device_id", .text).notNull().defaults(to: "mac")
                t.column("status", .text).notNull()
                    .check(sql: "status IN ('good', 'bad', 'unknown')")
                t.column("path", .text).notNull()
                t.column("last_checked_at", .datetime).notNull()
                
                // Unique constraint on book + device
                t.uniqueKey(["book_content_hash", "device_id"])
            }
            
            // Create indexes
            try db.create(index: "idx_books_status", on: "books", columns: ["status"])
            try db.create(index: "idx_books_last_time_played", on: "books", columns: ["last_time_played"])
            try db.create(index: "idx_bookmarks_book", on: "bookmarks", columns: ["book_content_hash"])
            try db.create(index: "idx_logs_timestamp", on: "logs", columns: ["timestamp"])
            try db.create(index: "idx_device_state_book", on: "device_state", columns: ["book_content_hash"])
        }
        
        return migrator
    }
}
