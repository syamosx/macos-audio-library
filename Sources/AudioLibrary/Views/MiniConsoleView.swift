//
//  MiniConsoleView.swift
//  AudioLibrary
//
//  Terminal-style status console
//

import SwiftUI

struct MiniConsoleView: View {
    @StateObject private var console = ConsoleManager.shared
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(console.logs) { log in
                        HStack(alignment: .top, spacing: 8) {
                            Text(formatTimestamp(log.timestamp))
                                .foregroundStyle(.gray)
                            Text(log.message)
                                .foregroundStyle(Color(red: 0.45, green: 0.75, blue: 0.45).opacity(0.9))
                        }
                    }
                }
                .font(.system(size: 10, design: .monospaced))
                .padding(12)
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "[HH:mm:ss]"
        return formatter.string(from: date)
    }
}
