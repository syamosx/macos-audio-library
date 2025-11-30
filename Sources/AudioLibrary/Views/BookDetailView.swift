//
//  BookDetailView.swift
//  AudioLibrary
//
//  Detailed view of a book with real playback controls (Phase 3)
//

import SwiftUI
import GRDB

struct BookDetailView: View {
    let book: Book
    @Bindable var viewModel: LibraryViewModel
    
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var bookmarkManager = BookmarkManager()
    @State private var fileURL: URL?
    @State private var loadError: String?
    @State private var showingAddBookmark = false
    @State private var showingEditBookmark = false
    @State private var bookmarkToEdit: Bookmark?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Album Artwork
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .overlay {
                        Image(systemName: "headphones.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                
                // Title and metadata
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        Label(book.formattedDuration, systemImage: "clock")
                        Label(book.formattedFileSize, systemImage: "doc")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                // Tags
                if !book.tags.isEmpty {
                    HStack {
                        ForEach(book.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Load error display
                if let error = loadError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button("Locate File") {
                        locateFile()
                    }
                }
                
                // Playback controls
                VStack(spacing: 16) {
                    // Progress slider
                    VStack(alignment: .leading, spacing: 4) {
                        Slider(value: Binding(
                            get: { audioPlayer.currentPosition },
                            set: { newValue in
                                audioPlayer.seek(to: newValue)
                            }
                        ), in: 0...(book.durationSeconds ?? 1000))
                        .disabled(fileURL == nil)
                        
                        HStack {
                            Text(formatTime(audioPlayer.currentPosition))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text(formatTime(audioPlayer.duration))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    
                    // Play/Pause and skip buttons
                    HStack(spacing: 40) {
                        Button {
                            audioPlayer.skipBackward()
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                        }
                        .disabled(fileURL == nil)
                        
                        Button {
                            audioPlayer.togglePlayPause()
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        .buttonStyle(.plain)
                        .disabled(fileURL == nil)
                        
                        Button {
                            audioPlayer.skipForward()
                        } label: {
                            Image(systemName: "goforward.15")
                                .font(.title)
                        }
                        .disabled(fileURL == nil)
                    }
                    
                    // Speed control
                    HStack {
                        Text("Speed:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Speed", selection: $audioPlayer.playbackSpeed) {
                            Text("0.5×").tag(0.5)
                            Text("0.75×").tag(0.75)
                            Text("1.0×").tag(1.0)
                            Text("1.25×").tag(1.25)
                            Text("1.5×").tag(1.5)
                            Text("2.0×").tag(2.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        .disabled(fileURL == nil)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Notes section
                if let notes = book.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Bookmarks section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bookmarks")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showingAddBookmark = true
                        } label: {
                            Label("Add Bookmark", systemImage: "bookmark.fill")
                        }
                        .disabled(fileURL == nil)
                    }
                    
                    if bookmarkManager.bookmarks.isEmpty {
                        Text("No bookmarks yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        VStack(spacing: 8) {
                            ForEach(bookmarkManager.bookmarks) { bookmark in
                                BookmarkRowView(bookmark: bookmark, onJump: {
                                    audioPlayer.seek(to: bookmark.positionSeconds)
                                }, onEdit: {
                                    bookmarkToEdit = bookmark
                                    showingEditBookmark = true
                                })
                            }
                        }
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .frame(minWidth: 500, idealWidth: 600)
        .navigationTitle(book.title)
        .task {
            await loadAudio()
            await bookmarkManager.loadBookmarks(for: book)
        }
        .sheet(isPresented: $showingAddBookmark) {
            AddBookmarkView(
                isPresented: $showingAddBookmark,
                position: audioPlayer.currentPosition
            ) { label, note in
                Task {
                    await bookmarkManager.addBookmark(
                        for: book,
                        position: audioPlayer.currentPosition,
                        label: label,
                        note: note
                    )
                }
            }
        }
        .sheet(isPresented: $showingEditBookmark) {
            if let bookmark = bookmarkToEdit {
                EditBookmarkView(
                    isPresented: $showingEditBookmark,
                    bookmark: bookmark,
                    onSave: { label, note in
                        Task {
                            await bookmarkManager.updateBookmark(bookmark, label: label, note: note)
                        }
                    },
                    onDelete: {
                        Task {
                            await bookmarkManager.deleteBookmark(bookmark)
                        }
                    }
                )
            }
        }
        .onDisappear {
            // Save position immediately when navigating away
            let currentPos = audioPlayer.currentPosition
            if currentPos > 0 {
                // Use synchronous save to ensure it completes
                Task.detached(priority: .high) {
                    try? await DatabaseManager.shared.database.write { db in
                        if var freshBook = try Book
                            .filter(Book.Columns.contentHash == book.contentHash)
                            .fetchOne(db) {
                            freshBook.lastPositionSeconds = currentPos
                            freshBook.lastTimePlayed = Date()
                            freshBook.updatedAt = Date()
                            try freshBook.update(db)
                        }
                    }
                }
            }
            // Stop playback
            audioPlayer.stop()
        }
        .onChange(of: audioPlayer.currentPosition) { _, newPosition in
            // Save position periodically while playing
            if Int(newPosition) % 10 == 0 && newPosition > 0 {
                savePosition(newPosition)
            }
        }
    }
    
    // MARK: - Position Saving
    
    private func savePosition(_ position: Double) {
        Task(priority: .utility) {
            try? await DatabaseManager.shared.database.write { db in
                if var freshBook = try Book
                    .filter(Book.Columns.contentHash == book.contentHash)
                    .fetchOne(db) {
                    freshBook.lastPositionSeconds = position
                    freshBook.lastTimePlayed = Date()
                    freshBook.updatedAt = Date()
                    try freshBook.update(db)
                }
            }
        }
    }
    
    private func savePositionImmediately(_ position: Double) {
        // Use detached task with high priority for immediate save
        Task.detached(priority: .high) {
            try? await DatabaseManager.shared.database.write { db in
                if var freshBook = try Book
                    .filter(Book.Columns.contentHash == book.contentHash)
                    .fetchOne(db) {
                    freshBook.lastPositionSeconds = position
                    freshBook.lastTimePlayed = Date()
                    freshBook.updatedAt = Date()
                    try freshBook.update(db)
                }
            }
        }
    }
    
    // MARK: - Audio Loading
    
    private func loadAudio() async {
        // Find file path from device_state
        do {
            let db = DatabaseManager.shared.database
            
            // Fetch fresh book data from database to get latest position
            let freshBook = try await db.read { db in
                try Book
                    .filter(Book.Columns.contentHash == book.contentHash)
                    .fetchOne(db)
            }
            
            guard let freshBook = freshBook else {
                await MainActor.run {
                    loadError = "Book not found in database"
                }
                return
            }
            
            let deviceState = try await db.read { db in
                try DeviceState
                    .filter(DeviceState.Columns.bookContentHash == book.contentHash)
                    .filter(DeviceState.Columns.deviceID == "mac")
                    .fetchOne(db)
            }
            
            guard let deviceState = deviceState else {
                await MainActor.run {
                    loadError = "File location not found"
                }
                return
            }
            
            let url = URL(fileURLWithPath: deviceState.path)
            
            // Verify file exists
            guard FileManager.default.fileExists(atPath: url.path) else {
                await MainActor.run {
                    loadError = "File not found at \(deviceState.path)"
                }
                return
            }
            
            // Load audio with fresh book data (includes latest saved position)
            try audioPlayer.load(book: freshBook, fileURL: url)
            
            // Hook up immediate position save callback
            audioPlayer.onPositionSave = { [book = book.contentHash] position in
                Task.detached(priority: .high) {
                    try? await DatabaseManager.shared.database.write { db in
                        if var freshBook = try Book
                            .filter(Book.Columns.contentHash == book)
                            .fetchOne(db) {
                            freshBook.lastPositionSeconds = position
                            freshBook.lastTimePlayed = Date()
                            freshBook.updatedAt = Date()
                            try freshBook.update(db)
                        }
                    }
                }
            }
            
            await MainActor.run {
                fileURL = url
                loadError = nil
            }
            
        } catch {
            await MainActor.run {
                loadError = "Failed to load: \(error.localizedDescription)"
            }
        }
    }
    
    private func locateFile() {
        let panel = NSOpenPanel()
        panel.message = "Locate \(book.title)"
        panel.prompt = "Select"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.urls.first {
            Task {
                // Verify hash matches
                do {
                    let hash = try FileHasher.sha256(of: url)
                    if hash == book.contentHash {
                        // Update device state
                        try await DatabaseManager.shared.database.write { db in
                            if var state = try DeviceState
                                .filter(DeviceState.Columns.bookContentHash == book.contentHash)
                                .filter(DeviceState.Columns.deviceID == "mac")
                                .fetchOne(db) {
                                state.path = url.path
                                state.status = .good
                                state.lastCheckedAt = Date()
                                try state.update(db)
                            }
                        }
                        
                        await loadAudio()
                    } else {
                        await MainActor.run {
                            loadError = "File hash doesn't match - this is a different file"
                        }
                    }
                } catch {
                    await MainActor.run {
                        loadError = "Failed to verify file: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
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
