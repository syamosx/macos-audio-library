//
//  PlayerMainView.swift
//  AudioLibrary
//
//  Persistent player view - the main stage of the app
//

import SwiftUI

struct PlayerMainView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Bindable var viewModel: LibraryViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let book = audioPlayer.currentBook {
                // Player with loaded book
                PlayerContentView(book: book, viewModel: viewModel)
            } else {
                // Ready state
                PlayerReadyState()
            }
            
            // Tech Console at bottom
            MiniConsoleView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Player Content (When book is loaded)

struct PlayerContentView: View {
    let book: Book
    @Bindable var viewModel: LibraryViewModel
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Album  Artwork
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.3, blue: 0.5),
                        Color(red: 0.3, green: 0.4, blue: 0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 300, height: 300)
                .shadow(radius: 20)
            
            // Metadata
            VStack(spacing: 8) {
                Text(book.title)
                    .font(.title.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if let filename = book.originalFilename {
                    Text(filename)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 40)
            
            // Progress Scrubber
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { audioPlayer.currentPosition },
                        set: { audioPlayer.seek(to: $0) }
                    ),
                    in: 0...max(audioPlayer.duration, 1)
                )
                .disabled(audioPlayer.duration == 0)
                
                HStack {
                    Text(formatTime(audioPlayer.currentPosition))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(audioPlayer.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 80)
            
            // Playback Controls
            HStack(spacing: 50) {
                Button {
                    audioPlayer.skipBackward(15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip backward 15 seconds")
                
                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 80))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(audioPlayer.isPlaying ? "Pause" : "Play")
                
                Button {
                    audioPlayer.skipForward(15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Skip forward 15 seconds")
            }
            
            // Speed Control
            Menu {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { speed in
                    Button {
                        audioPlayer.playbackSpeed = speed
                    } label: {
                        HStack {
                            Text("\(speed, specifier: "%.2f")×")
                            if audioPlayer.playbackSpeed == speed {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Label("Speed: \(audioPlayer.playbackSpeed, specifier: "%.2f")×", systemImage: "gauge")
            }
            .menuStyle(.borderlessButton)
            
            Spacer()
        }
        .padding(.bottom, 40) // Space for console
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

// MARK: - Ready State (No book loaded)

struct PlayerReadyState: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 120))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("Ready to Play")
                .font(.title.bold())
                .foregroundStyle(.secondary)
            
            Text("Select a book from the sidebar to begin")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }
}
