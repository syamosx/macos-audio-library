//
//  PlayerMainView.swift
//  AudioLibrary
//
//  The persistent "Main Stage" player view
//

import SwiftUI

struct PlayerMainView: View {
    @Bindable var viewModel: LibraryViewModel
    @StateObject private var audioPlayer = AudioPlayer.shared
    
    var body: some View {
        VStack {
            // --- Top Bar (Traffic Light Spacer & Toggle) ---
            HStack {
                Spacer().frame(width: 60) // Traffic light spacer
                Spacer()
                Button(action: viewModel.toggleSidebar) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }
                .buttonStyle(.plain)
                .help("Toggle Sidebar")
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
            
            Spacer()
            
            // --- Artwork ---
            if let book = audioPlayer.currentBook {
                ArtworkView(artworkPath: book.artworkPath, size: 320)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 15)
            } else {
                // Placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.16))
                    .frame(width: 300, height: 300)
                    .overlay(Text("Select Book").font(.caption).foregroundColor(.gray.opacity(0.5)))
            }
            
            Spacer().frame(height: 30)
            
            // --- Track Info ---
            VStack(spacing: 6) {
                Text(audioPlayer.currentBook?.title ?? "No Book Selected")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .foregroundColor(Color(white: 0.95))
                    .lineLimit(1)
                
                Text(audioPlayer.currentBook?.author ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.6))
                    .lineLimit(1)
            }
            
            Spacer().frame(height: 30)
            
            // --- Scrubber ---
            HStack(spacing: 15) {
                Text(formatTime(audioPlayer.currentPosition)).styleMono()
                ProgressBar(progress: audioPlayer.duration > 0 ? audioPlayer.currentPosition / audioPlayer.duration : 0)
                    .frame(maxWidth: 350)
                Text(formatTime(audioPlayer.duration - audioPlayer.currentPosition)).styleMono()
            }
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 25)
            
            // --- Controls ---
            HStack(spacing: 40) {
                ControlButton(icon: "backward.fill", size: 20) {
                    audioPlayer.seek(by: -15)
                }
                ControlButton(icon: audioPlayer.isPlaying ? "pause.fill" : "play.fill", size: 38) {
                    audioPlayer.togglePlayPause()
                }
                ControlButton(icon: "forward.fill", size: 20) {
                    audioPlayer.seek(by: 15)
                }
            }
            .padding(.bottom, 20)
            
            // --- Console (Conditional) ---
            if viewModel.isSidebarVisible {
                Spacer().frame(height: 10)
                MiniConsoleView()
                    .frame(height: 100)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .transition(.opacity)
            } else {
                Spacer().frame(height: 20)
            }
        }
        .onChange(of: audioPlayer.currentBook) { _, newBook in
            updateBackgroundGlow(for: newBook)
        }
        .onAppear {
            updateBackgroundGlow(for: audioPlayer.currentBook)
        }
    }
    
    private func updateBackgroundGlow(for book: Book?) {
        guard let path = book?.artworkPath,
              let image = NSImage(contentsOfFile: path) else {
            withAnimation(.easeOut(duration: 1.0)) {
                viewModel.backgroundGlow = Color(red: 0.2, green: 0.2, blue: 0.22)
            }
            return
        }
        
        // Calculate average color in background to avoid UI stutter
        DispatchQueue.global(qos: .userInitiated).async {
            let color = image.averageColor
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 1.5)) {
                    viewModel.backgroundGlow = color
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                Capsule().fill(Color(white: 0.7)).frame(width: geo.size.width * CGFloat(progress), height: 4)
            }
        }
        .frame(height: 4)
    }
}

struct ControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
        }
        .buttonStyle(.plain)
        .foregroundColor(Color(white: 0.9))
    }
}

// MARK: - Utilities
extension Text {
    func styleMono() -> some View {
        self.font(.system(size: 11, design: .monospaced))
            .foregroundColor(Color(white: 0.4))
    }
}
