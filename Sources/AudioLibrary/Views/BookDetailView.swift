//
//  BookDetailView.swift
//  AudioLibrary
//
//  Detailed view of a book with playback controls (Phase 1: UI only)
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    @Bindable var viewModel: LibraryViewModel
    
    @State private var isPlaying = false
    @State private var currentPosition: Double = 0
    @State private var playbackSpeed: Double = 1.0
    
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
                
                // Playback controls
                VStack(spacing: 16) {
                    // Progress slider
                    VStack(alignment: .leading, spacing: 4) {
                        Slider(value: Binding(
                            get: { currentPosition },
                            set: { newValue in
                                currentPosition = newValue
                                // Phase 3: Seek audio player
                            }
                        ), in: 0...book.durationSeconds)
                        
                        HStack {
                            Text(formatTime(currentPosition))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text(formatTime(book.durationSeconds))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    
                    // Play/Pause and skip buttons
                    HStack(spacing: 40) {
                        Button {
                            // Phase 3: Skip backward
                            currentPosition = max(0, currentPosition - 15)
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                        }
                        
                        Button {
                            isPlaying.toggle()
                            // Phase 3: Toggle audio playback
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // Phase 3: Skip forward
                            currentPosition = min(book.durationSeconds, currentPosition + 15)
                        } label: {
                            Image(systemName: "goforward.15")
                                .font(.title)
                        }
                    }
                    
                    // Speed control
                    HStack {
                        Text("Speed:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Speed", selection: $playbackSpeed) {
                            Text("0.5×").tag(0.5)
                            Text("0.75×").tag(0.75)
                            Text("1.0×").tag(1.0)
                            Text("1.25×").tag(1.25)
                            Text("1.5×").tag(1.5)
                            Text("2.0×").tag(2.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Notes section
                if !book.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(book.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Bookmarks section (Phase 4)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bookmarks")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            // Phase 4: Add bookmark
                            print("Add bookmark tapped")
                        } label: {
                            Label("Add Bookmark", systemImage: "bookmark.fill")
                        }
                    }
                    
                    Text("No bookmarks yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .frame(minWidth: 500, idealWidth: 600)
        .navigationTitle(book.title)
        .onAppear {
            currentPosition = book.lastPositionSeconds
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

