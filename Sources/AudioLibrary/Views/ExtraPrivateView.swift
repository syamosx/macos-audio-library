//
//  ExtraPrivateView.swift
//  AudioLibrary
//
//  Extra private section (placeholder for Phase 1)
//

import SwiftUI

struct ExtraPrivateView: View {
    var body: some View {
        ContentUnavailableView(
            "Extra Private",
            systemImage: "lock.fill",
            description: Text("Private audiobooks will appear here")
        )
        .navigationTitle("Extra Private")
    }
}

