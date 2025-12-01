//
//  LibraryViewModel.swift
//  AudioLibrary
//
//  ViewModel for managing library state with database persistence
//

import Foundation
import SwiftUI
import Combine
import AppKit
import Observation
import GRDB

@Observable
class LibraryViewModel {
    // MARK: - UI State
    var isSidebarVisible: Bool = true
    var backgroundGlow: Color = Color(red: 0.2, green: 0.2, blue: 0.22)
    
    // MARK: - Data
    var books: [Book] = []
    var privateBooks: [Book] = []
    var recentBooks: [Book] = []
    
    // MARK: - Configuration
    private let sidebarWidth: CGFloat = 250
    private let animDuration: Double = 0.35
    
    private let bookDAO: BookDAO
    private let logDAO: LogDAO
    
    init(bookDAO: BookDAO? = nil) {
        // Initialize database first
        do {
            try DatabaseManager.shared.setup()
        } catch {
            print("❌ Database initialization failed: \(error)")
        }
        
        // Initialize DAOs after DB setup
        self.bookDAO = bookDAO ?? BookDAO()
        self.logDAO = LogDAO()
        
        // Load initial data
        Task {
            await loadLibrary()
        }
    }
    
    // MARK: - Window Management
    
    /// Handles the complex window resizing logic
    func toggleSidebar() {
        guard let window = NSApp.keyWindow, let screen = window.screen else { return }
        
        let currentFrame = window.frame
        var newFrame = currentFrame
        
        if isSidebarVisible {
            // CLOSING: Shrink width
            newFrame.size.width -= sidebarWidth
            if newFrame.size.width < 350 { newFrame.size.width = 350 }
        } else {
            // OPENING: Expand width
            newFrame.size.width += sidebarWidth
            
            // Screen Bounds Check: If expanding pushes off-screen, shift left.
            let screenRightEdge = screen.visibleFrame.maxX
            let proposedRightEdge = newFrame.origin.x + newFrame.size.width
            
            if proposedRightEdge > screenRightEdge {
                newFrame.origin.x -= sidebarWidth
            }
        }
        
        // Synced Animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }
        
        withAnimation(.easeInOut(duration: animDuration)) {
            self.isSidebarVisible.toggle()
        }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    func loadLibrary() async {
        do {
            books = try bookDAO.fetchAll()
            privateBooks = try bookDAO.fetchPrivate()
            recentBooks = try bookDAO.fetchRecentlyPlayed()
            try logDAO.log(type: "library_loaded", payload: ["count": books.count, "private_count": privateBooks.count])
        } catch {
            print("❌ Failed to load books: \(error)")
            // Load sample data if database is empty
            if books.isEmpty && privateBooks.isEmpty {
                await loadSampleData()
            }
        }
    }
    
    @MainActor
    private func loadSampleData() async {
        let now = Date()
        let sampleBooks = [
            Book(
                id: nil,
                contentHash: "abc123def456",
                originalFilename: "Foundation.m4b",
                title: "Foundation",
                author: "Isaac Asimov",
                artworkPath: nil,
                status: .active,
                fileSizeBytes: 425_984_000,
                durationSeconds: 14_280,
                tags: ["Sci-Fi", "Classic"],
                lastPositionSeconds: 3_600,
                lastTimePlayed: now.addingTimeInterval(-7200),
                notes: "Asimov's masterpiece about psychohistory",
                createdAt: now.addingTimeInterval(-86400 * 30),
                updatedAt: now.addingTimeInterval(-7200)
            ),
            Book(
                id: nil,
                contentHash: "ghi789jkl012",
                originalFilename: "Project Hail Mary.m4b",
                title: "Project Hail Mary",
                author: "Andy Weir",
                artworkPath: nil,
                status: .active,
                fileSizeBytes: 612_350_000,
                durationSeconds: 16_020,
                tags: ["Sci-Fi", "Adventure"],
                lastPositionSeconds: 8_400,
                lastTimePlayed: now.addingTimeInterval(-3600),
                notes: "Andy Weir's follow-up to The Martian",
                createdAt: now.addingTimeInterval(-86400 * 15),
                updatedAt: now.addingTimeInterval(-3600)
            ),
            Book(
                id: nil,
                contentHash: "mno345pqr678",
                originalFilename: "Dune.m4b",
                title: "Dune",
                author: "Frank Herbert",
                artworkPath: nil,
                status: .active,
                fileSizeBytes: 721_420_000,
                durationSeconds: 21_240,
                tags: ["Sci-Fi", "Epic", "Classic"],
                lastPositionSeconds: 120,
                lastTimePlayed: now.addingTimeInterval(-86400 * 2),
                notes: "Frank Herbert's masterwork",
                createdAt: now.addingTimeInterval(-86400 * 60),
                updatedAt: now.addingTimeInterval(-86400 * 2)
            ),
            Book(
                id: nil,
                contentHash: "stu901vwx234",
                originalFilename: "The Three-Body Problem.m4b",
                title: "The Three-Body Problem",
                author: "Liu Cixin",
                artworkPath: nil,
                status: .active,
                fileSizeBytes: 405_120_000,
                durationSeconds: 13_140,
                tags: ["Sci-Fi", "Hard SF"],
                lastPositionSeconds: 0,
                lastTimePlayed: nil,
                notes: "Liu Cixin's award-winning novel",
                createdAt: now.addingTimeInterval(-86400 * 5),
                updatedAt: now.addingTimeInterval(-86400 * 5)
            ),
            Book(
                id: nil,
                contentHash: "yza567bcd890",
                originalFilename: "Neuromancer.m4b",
                title: "Neuromancer",
                author: "William Gibson",
                artworkPath: nil,
                status: .active,
                fileSizeBytes: 365_840_000,
                durationSeconds: 11_880,
                tags: ["Sci-Fi", "Cyberpunk", "Classic"],
                lastPositionSeconds: 11_880,
                lastTimePlayed: now.addingTimeInterval(-86400 * 10),
                notes: "William Gibson's cyberpunk classic",
                createdAt: now.addingTimeInterval(-86400 * 90),
                updatedAt: now.addingTimeInterval(-86400 * 10)
            )
        ]
        
        do {
            for book in sampleBooks {
                _ = try bookDAO.insert(book)
            }
            try logDAO.log(type: "sample_data_loaded", payload: ["count": sampleBooks.count])
            await loadLibrary()
        } catch {
            print("❌ Failed to load sample data: \(error)")
        }
    }

    // ... (Skipping sample data for now in this thought process)
    
    // MARK: - Actions
    
    func refreshBooks() {
        Task {
            await loadLibrary()
        }
    }
    
    func addBook(_ book: Book) {
        Task {
            do {
                _ = try bookDAO.insert(book)
                try logDAO.log(type: "book_added", bookContentHash: book.contentHash)
                await loadLibrary()
            } catch {
                print("❌ Failed to add book: \(error)")
            }
        }
    }
    
    func updateBook(_ book: Book) {
        Task {
            do {
                try bookDAO.update(book)
                try logDAO.log(type: "book_updated", bookContentHash: book.contentHash)
                await loadLibrary()
            } catch {
                print("❌ Failed to update book: \(error)")
            }
        }
    }
    
    func togglePrivate(for book: Book) {
        var updatedBook = book
        updatedBook.status = (book.status == .active) ? .private_ : .active
        updateBook(updatedBook)
    }
    
    func recalculateColor(for book: Book) {
        guard let artworkPath = book.artworkPath,
              let artworkData = try? Data(contentsOf: URL(fileURLWithPath: artworkPath)) else {
            return
        }
        
        Task {
            if let newColor = await GeminiColorService.shared.analyze(artworkData: artworkData) {
                var updatedBook = book
                updatedBook.dominantColor = newColor
                self.updateBook(updatedBook)
            }
        }
    }
    
    func deleteBook(_ book: Book) {
        Task {
            do {
                try bookDAO.delete(contentHash: book.contentHash)
                try logDAO.log(type: "book_deleted", bookContentHash: book.contentHash)
                await loadLibrary()
            } catch {
                print("❌ Failed to delete book: \(error)")
            }
        }
    }
    
    func updatePosition(for book: Book, position: Double) {
        Task {
            do {
                try bookDAO.updatePosition(contentHash: book.contentHash, position: position)
                try logDAO.log(
                    type: "position_updated",
                    bookContentHash: book.contentHash,
                    payload: ["position": position]
                )
            } catch {
                print("❌ Failed to update position: \(error)")
            }
        }
    }
    
    // MARK: - Import
    
    @MainActor
    func importFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.message = "Select Audiobooks to Import"
        
        panel.begin { response in
            if response == .OK {
                let urls = panel.urls
                Task {
                    for url in urls {
                        await ImportManager.shared.importFiles([url])
                    }
                    await self.loadLibrary()
                }
            }
        }
    }
}
