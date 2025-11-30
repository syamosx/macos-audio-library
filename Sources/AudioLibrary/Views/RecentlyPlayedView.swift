//
//  RecentlyPlayedView.swift
//  AudioLibrary
//
//  Shows recently played books sorted by last played time
//

import SwiftUI

struct RecentlyPlayedView: View {
    @Bindable var viewModel: LibraryViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recentlyPlayed.isEmpty {
                    ContentUnavailableView(
                        "No Recent Books",
                        systemImage: "clock",
                        description: Text("Books you've listened to will appear here")
                    )
                } else {
                    List(viewModel.recentlyPlayed) { book in
                        NavigationLink(value: book) {
                            RecentlyPlayedRowView(book: book)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book, viewModel: viewModel)
            }
            .navigationTitle("Recently Played")
        }
    }
}

struct RecentlyPlayedRowView: View {
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
                
                if let lastPlayed = book.lastTimePlayed {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                        
                        Text("Played \(lastPlayed, style: .relative) ago")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                
                // Progress bar
                HStack(spacing: 6) {
                    ProgressView(value: book.progress)
                        .progressViewStyle(.linear)
                        .frame(maxWidth: 200)
                    
                    Text("\(Int(book.progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                
                Text(formatPosition(book.lastPositionSeconds, of: book.durationSeconds ?? 0))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatPosition(_ position: Double, of duration: Double) -> String {
        let posHours = Int(position) / 3600
        let posMinutes = (Int(position) % 3600) / 60
        let durHours = Int(duration) / 3600
        let durMinutes = (Int(duration) % 3600) / 60
        
        if durHours > 0 {
            return "\(posHours)h \(posMinutes)m of \(durHours)h \(durMinutes)m"
        } else {
            return "\(posMinutes)m of \(durMinutes)m"
        }
    }
}

