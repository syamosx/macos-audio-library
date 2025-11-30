//
//  BooksListView.swift
//  AudioLibrary
//
//  List view showing all books with NavigationStack for detail navigation
//

import SwiftUI

struct BooksListView: View {
    @Bindable var viewModel: LibraryViewModel
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .recentlyPlayed
    @State private var importManager = ImportManager()
    @State private var showingImportSheet = false
    
    enum SortOrder: String, CaseIterable {
        case recentlyPlayed = "Recently Played"
        case title = "Title"
        case dateAdded = "Date Added"
    }
    
    var filteredBooks: [Book] {
        var books = viewModel.books
        
        // Filter by search
        if !searchText.isEmpty {
            books = books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort
        switch sortOrder {
        case .recentlyPlayed:
            books.sort { ($0.lastTimePlayed ?? .distantPast) > ($1.lastTimePlayed ?? .distantPast) }
        case .title:
            books.sort { $0.title < $1.title }
        case .dateAdded:
            books.sort { $0.createdAt > $1.createdAt }
        }
        
        return books
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredBooks.isEmpty {
                    ContentUnavailableView(
                        "No Books",
                        systemImage: "book.closed",
                        description: Text(searchText.isEmpty ? "Import your first audiobook to get started" : "No books match your search")
                    )
                } else {
                    List(filteredBooks, selection: $viewModel.selectedBook) { book in
                        NavigationLink(value: book) {
                            BookRowView(book: book)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search books...")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            importFiles()
                        } label: {
                            Label("Import Files", systemImage: "doc.badge.plus")
                        }
                        
                        Button {
                            importFolder()
                        } label: {
                            Label("Import Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Label("Import", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.refreshBooks()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .navigationTitle("Books")
            .sheet(isPresented: $showingImportSheet) {
                ImportProgressView(importManager: importManager, isPresented: $showingImportSheet)
            }
        }
    }
    
    // MARK: - Import Actions
    
    private func importFiles() {
        guard let urls = importManager.selectFiles(), !urls.isEmpty else { return }
        showingImportSheet = true
        Task {
            await importManager.importFiles(urls)
            viewModel.refreshBooks()
        }
    }
    
    private func importFolder() {
        guard let folderURL = importManager.selectFolder() else { return }
        let audioFiles = importManager.scanFolder(folderURL)
        
        guard !audioFiles.isEmpty else {
            print("No audio files found in folder")
            return
        }
        
        showingImportSheet = true
        Task {
            await importManager.importFiles(audioFiles)
            viewModel.refreshBooks()
        }
    }
}

// MARK: - Book Row View

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Album artwork placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "headphones")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(book.formattedDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !book.tags.isEmpty {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(book.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Progress bar
                if book.progress > 0 {
                    HStack(spacing: 6) {
                        ProgressView(value: book.progress)
                            .progressViewStyle(.linear)
                            .frame(maxWidth: 150)
                        
                        Text("\(Int(book.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
            
            Spacer()
            
            // Last played indicator
            if let lastPlayed = book.lastTimePlayed {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(lastPlayed, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

