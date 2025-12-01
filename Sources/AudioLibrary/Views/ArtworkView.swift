//
//  ArtworkView.swift
//  AudioLibrary
//
//  Displays book cover artwork
//

import SwiftUI
import AppKit

struct ArtworkView: View {
    let artworkPath: String?
    let size: CGFloat
    
    @State private var image: NSImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: size, maxHeight: size)
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 15)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.16))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: size * 0.3))
                            .foregroundStyle(.white.opacity(0.3))
                    )
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: artworkPath) {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let artworkPath = artworkPath else {
            image = nil
            return
        }
        
        if let loadedImage = NSImage(contentsOfFile: artworkPath) {
            image = loadedImage
        } else {
            image = nil
        }
    }
}
