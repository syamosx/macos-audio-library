//
//  LibraryViewModel.swift
//  AudioLibrary
//
//  ViewModel for managing library state (Phase 1: Mock Data)
//

import Foundation
import Observation

@Observable
class LibraryViewModel {
    var books: [Book] = []
    var recentlyPlayed: [Book] = []
    var selectedBook: Book?
    
    init() {
        loadMockData()
    }
    
    // MARK: - Mock Data (Phase 1)
    
    private func loadMockData() {
        let now = Date()
        
        books = [
            Book(
                id: 1,
                contentHash: "abc123def456",
                originalFilename: "Foundation.m4b",
                title: "Foundation",
                status: .active,
                fileSizeBytes: 425_984_000,
                durationSeconds: 14_280, // 3h 58m
                tags: ["Sci-Fi", "Classic"],
                lastPositionSeconds: 3_600,
                lastTimePlayed: now.addingTimeInterval(-7200),
                notes: "Asimov's masterpiece about psychohistory",
                createdAt: now.addingTimeInterval(-86400 * 30),
                updatedAt: now.addingTimeInterval(-7200)
            ),
            Book(
                id: 2,
                contentHash: "ghi789jkl012",
                originalFilename: "Project Hail Mary.m4b",
                title: "Project Hail Mary",
                status: .active,
                fileSizeBytes: 612_350_000,
                durationSeconds: 16_020, // 4h 27m
                tags: ["Sci-Fi", "Adventure"],
                lastPositionSeconds: 8_400,
                lastTimePlayed: now.addingTimeInterval(-3600),
                notes: "Andy Weir's follow-up to The Martian",
                createdAt: now.addingTimeInterval(-86400 * 15),
                updatedAt: now.addingTimeInterval(-3600)
            ),
            Book(
                id: 3,
                contentHash: "mno345pqr678",
                originalFilename: "Dune.m4b",
                title: "Dune",
                status: .active,
                fileSizeBytes: 721_420_000,
                durationSeconds: 21_240, // 5h 54m
                tags: ["Sci-Fi", "Epic", "Classic"],
                lastPositionSeconds: 120,
                lastTimePlayed: now.addingTimeInterval(-86400 * 2),
                notes: "Frank Herbert's masterwork",
                createdAt: now.addingTimeInterval(-86400 * 60),
                updatedAt: now.addingTimeInterval(-86400 * 2)
            ),
            Book(
                id: 4,
                contentHash: "stu901vwx234",
                originalFilename: "The Three-Body Problem.m4b",
                title: "The Three-Body Problem",
                status: .active,
                fileSizeBytes: 405_120_000,
                durationSeconds: 13_140, // 3h 39m
                tags: ["Sci-Fi", "Hard SF"],
                lastPositionSeconds: 0,
                lastTimePlayed: nil,
                notes: "Liu Cixin's award-winning novel",
                createdAt: now.addingTimeInterval(-86400 * 5),
                updatedAt: now.addingTimeInterval(-86400 * 5)
            ),
            Book(
                id: 5,
                contentHash: "yza567bcd890",
                originalFilename: "Neuromancer.m4b",
                title: "Neuromancer",
                status: .active,
                fileSizeBytes: 365_840_000,
                durationSeconds: 11_880, // 3h 18m
                tags: ["Sci-Fi", "Cyberpunk", "Classic"],
                lastPositionSeconds: 11_880,
                lastTimePlayed: now.addingTimeInterval(-86400 * 10),
                notes: "William Gibson's cyberpunk classic",
                createdAt: now.addingTimeInterval(-86400 * 90),
                updatedAt: now.addingTimeInterval(-86400 * 10)
            )
        ]
        
        // Recently played are the books with recent lastTimePlayed
        recentlyPlayed = books
            .filter { $0.lastTimePlayed != nil }
            .sorted { ($0.lastTimePlayed ?? .distantPast) > ($1.lastTimePlayed ?? .distantPast) }
    }
    
    // MARK: - Future DB Methods (Phase 2+)
    
    func refreshBooks() {
        // Phase 2: Load from database
        print("Refresh books from database")
    }
    
    func addBook(_ book: Book) {
        // Phase 3: Add to database and scan file
        books.append(book)
    }
    
    func updateBook(_ book: Book) {
        // Phase 2: Update in database
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
        }
    }
    
    func deleteBook(_ book: Book) {
        // Phase 2: Mark as deleted in database
        books.removeAll { $0.id == book.id }
    }
}
