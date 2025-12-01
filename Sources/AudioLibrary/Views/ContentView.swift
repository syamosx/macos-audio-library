//
//  ContentView.swift
//  AudioLibrary
//
//  Main application window view
//

import SwiftUI

struct ContentView: View {
    @Environment(LibraryViewModel.self) private var viewModel
    let baseColor = Color(red: 0.12, green: 0.12, blue: 0.13)
    
    var body: some View {
        HStack(spacing: 0) {
            
            // 1. LEFT: Main Player
            PlayerMainView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        baseColor.ignoresSafeArea()
                        // Dynamic Ambient Background
                        RadialGradient(
                            gradient: Gradient(colors: [
                                viewModel.backgroundGlow.opacity(0.25),
                                baseColor
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 700
                        )
                    }
                )
                .clipped()
                .zIndex(1) // Keep Player above Sidebar during transition

            // 2. MIDDLE: Divider (Visible only when sidebar is open)
            if viewModel.isSidebarVisible {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 1)
                    .edgesIgnoringSafeArea(.vertical)
            }
            
            // 3. RIGHT: Sidebar
            if viewModel.isSidebarVisible {
                SidebarView(viewModel: viewModel)
                    .frame(width: 250)
                    .transition(.move(edge: .trailing))
                    .zIndex(0)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Connect AudioPlayer callbacks to ViewModel
            AudioPlayer.shared.onPositionSave = { [weak viewModel] position in
                if let book = AudioPlayer.shared.currentBook {
                    viewModel?.updatePosition(for: book, position: position)
                }
            }
            
            AudioPlayer.shared.onPlaybackFinished = { [weak viewModel] in
                if let book = AudioPlayer.shared.currentBook {
                    viewModel?.updatePosition(for: book, position: 0)
                }
            }
        }
    }
}
