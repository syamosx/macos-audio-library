//
//  KeyboardShortcuts.swift
//  AudioLibrary
//
//  Global keyboard shortcuts for playback control
//

import SwiftUI

extension View {
    /// Add keyboard shortcuts for playback control
    /// - Space: Play/Pause
    /// - Left Arrow: Skip backward 15s
    /// - Right Arrow: Skip forward 15s
    func playbackKeyboardShortcuts(
        onPlayPause: @escaping () -> Void,
        onSkipBackward: @escaping () -> Void,
        onSkipForward: @escaping () -> Void
    ) -> some View {
        self
            .onKeyPress(.space) {
                onPlayPause()
                return .handled
            }
            .onKeyPress(.leftArrow) {
                onSkipBackward()
                return .handled
            }
            .onKeyPress(.rightArrow) {
                onSkipForward()
                return .handled
            }
    }
}
