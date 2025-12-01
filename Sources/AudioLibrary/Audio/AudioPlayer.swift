//
//  AudioPlayer.swift
//  AudioLibrary
//
//  Audio playback manager using AVFoundation
//

import Foundation
import AVFoundation
import Combine
import GRDB

class AudioPlayer: NSObject, ObservableObject {
    static let shared = AudioPlayer()
    
    // MARK: - Published State
    
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0
    @Published var duration: Double = 0
    @Published var playbackSpeed: Double = 1.0 {
        didSet {
            player?.rate = Float(playbackSpeed)
        }
    }
    
    var currentBook: Book?
    
    // MARK: - Private Properties
    
    private var player: AVAudioPlayer?
    private var updateTimer: Timer?
    
    // Callbacks
    var onPositionUpdate: ((Double) -> Void)?
    var onPlaybackFinished: (() -> Void)?
    var onPositionSave: ((Double) -> Void)?  // Callback to save position to DB
    
    // MARK: - Init/Deinit
    
    override init() {
        super.init()
    }
    
    deinit {
        stopUpdates()
        player?.stop()
    }
    
    // MARK: - Playback Control
    
    func load(book: Book) {
        Task {
            do {
                // Fetch device state to find file path
                let db = DatabaseManager.shared.database
                let deviceState = try await db.read { db in
                    try DeviceState
                        .filter(DeviceState.Columns.bookContentHash == book.contentHash)
                        .filter(DeviceState.Columns.deviceID == "mac")
                        .fetchOne(db)
                }
                
                if let path = deviceState?.path {
                    let url = URL(fileURLWithPath: path)
                    if FileManager.default.fileExists(atPath: url.path) {
                        try load(book: book, fileURL: url)
                        play()
                    } else {
                        ConsoleManager.shared.log("❌ File not found at \(path)")
                    }
                } else {
                    ConsoleManager.shared.log("❌ No file path found for book: \(book.title)")
                }
            } catch {
                ConsoleManager.shared.log("❌ Failed to load book: \(error.localizedDescription)")
            }
        }
    }
    
    func load(book: Book, fileURL: URL) throws {
        // Stop current playback
        stop()
        
        // Create player
        player = try AVAudioPlayer(contentsOf: fileURL)
        player?.delegate = self
        player?.prepareToPlay()
        player?.enableRate = true
        
        // Set properties
        currentBook = book
        duration = player?.duration ?? 0
        currentPosition = book.lastPositionSeconds
        
        // Seek to last position
        if currentPosition > 0 {
            player?.currentTime = currentPosition
        }
        
        ConsoleManager.shared.log("✅ Loaded audio: \(book.title) (\(formatTime(duration)))")
    }
    
    func play() {
        guard let player = player else { return }
        
        player.rate = Float(playbackSpeed)
        player.play()
        isPlaying = true
        startUpdates()
        
        ConsoleManager.shared.log("▶️ Playing at \(playbackSpeed)×")
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopUpdates()
        savePosition()
        
        ConsoleManager.shared.log("⏸ Paused at \(formatTime(currentPosition))")
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        stopUpdates()
        savePosition()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to position: Double) {
        guard let player = player else { return }
        
        let clampedPosition = min(max(0, position), duration)
        player.currentTime = clampedPosition
        currentPosition = clampedPosition
        
        // Save position after seeking
        savePosition()
        
        ConsoleManager.shared.log("⏩ Seeked to \(formatTime(clampedPosition))")
    }
    
    func seek(by seconds: Double) {
        seek(to: currentPosition + seconds)
    }
    
    func skipForward(_ seconds: Double = 15) {
        seek(to: currentPosition + seconds)
    }
    
    func skipBackward(_ seconds: Double = 15) {
        seek(to: currentPosition - seconds)
    }
    
    // MARK: - Position Updates
    
    private func startUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePosition()
        }
    }
    
    private func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updatePosition() {
        guard let player = player else { return }
        
        currentPosition = player.currentTime
        onPositionUpdate?(currentPosition)
    }
    
    private func savePosition() {
        // Trigger callback to save position immediately
        onPositionSave?(currentPosition)
        ConsoleManager.shared.log("💾 Saving position: \(formatTime(currentPosition))")
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

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopUpdates()
        
        if flag {
            // Reset to beginning
            currentPosition = 0
            player.currentTime = 0
            savePosition()
            
            ConsoleManager.shared.log("✅ Playback finished")
            onPlaybackFinished?()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        ConsoleManager.shared.log("❌ Audio decode error: \(error?.localizedDescription ?? "unknown")")
        isPlaying = false
        stopUpdates()
    }
}
