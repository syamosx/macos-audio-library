//
//  BookmarkManager.swift
//  AudioLibrary
//
//  Manages bookmark operations for audiobooks
//

import Foundation
import Combine

class BookmarkManager: ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    
    private let bookmarkDAO: BookmarkDAO
    private let logDAO: LogDAO
    
    init(bookmarkDAO: BookmarkDAO = BookmarkDAO(), logDAO: LogDAO = LogDAO()) {
        self.bookmarkDAO = bookmarkDAO
        self.logDAO = logDAO
    }
    
    // MARK: - Load
    
    func loadBookmarks(for book: Book) async {
        do {
            let fetched = try bookmarkDAO.fetchAll(forBook: book.contentHash)
            await MainActor.run {
                bookmarks = fetched
            }
        } catch {
            print("❌ Failed to load bookmarks: \(error)")
        }
    }
    
    // MARK: - Create
    
    func addBookmark(for book: Book, position: Double, label: String, note: String? = nil) async {
        let bookmark = Bookmark(
            id: nil,
            bookContentHash: book.contentHash,
            positionSeconds: position,
            label: label,
            note: note,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let saved = try bookmarkDAO.insert(bookmark)
            
            try logDAO.log(
                type: "bookmark_added",
                bookContentHash: book.contentHash,
                payload: [
                    "position": position,
                    "label": label
                ]
            )
            
            await loadBookmarks(for: book)
            
            print("✅ Bookmark added: \(label) at \(formatTime(position))")
        } catch {
            print("❌ Failed to add bookmark: \(error)")
        }
    }
    
    // MARK: - Update
    
    func updateBookmark(_ bookmark: Bookmark, label: String, note: String?) async {
        var updated = bookmark
        updated.label = label
        updated.note = note
        updated.updatedAt = Date()
        
        do {
            try bookmarkDAO.update(updated)
            
            try logDAO.log(
                type: "bookmark_updated",
                bookContentHash: bookmark.bookContentHash,
                payload: [
                    "bookmark_id": bookmark.id ?? 0,
                    "label": label
                ]
            )
            
            if let book = try? BookDAO().fetchByContentHash(bookmark.bookContentHash) {
                await loadBookmarks(for: book)
            }
            
            print("✅ Bookmark updated: \(label)")
        } catch {
            print("❌ Failed to update bookmark: \(error)")
        }
    }
    
    // MARK: - Delete
    
    func deleteBookmark(_ bookmark: Bookmark) async {
        guard let id = bookmark.id else { return }
        
        do {
            try bookmarkDAO.delete(id: id)
            
            try logDAO.log(
                type: "bookmark_deleted",
                bookContentHash: bookmark.bookContentHash,
                payload: [
                    "bookmark_id": id,
                    "label": bookmark.label
                ]
            )
            
            if let book = try? BookDAO().fetchByContentHash(bookmark.bookContentHash) {
                await loadBookmarks(for: book)
            }
            
            print("✅ Bookmark deleted: \(bookmark.label)")
        } catch {
            print("❌ Failed to delete bookmark: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}
