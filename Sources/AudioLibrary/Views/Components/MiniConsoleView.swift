//
//  MiniConsoleView.swift
//  AudioLibrary
//
//  Retro-tech console UI
//

import SwiftUI

struct MiniConsoleView: View {
    @ObservedObject var console = ConsoleManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            if let message = console.lastMessage {
                Text(message.formatted)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.3)) // Neon green
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                Text("[System Ready]")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 1, blue: 0.3).opacity(0.5))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(height: 28)
        .background(Color.black)
        .cornerRadius(0)
    }
}
