//
//  ConsoleManager.swift
//  AudioLibrary
//
//  Tech console for displaying system logs
//

import Foundation
import Combine

enum LogType {
    case info
    case success
    case warning
    case error
    
    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .success: return "✅"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

struct ConsoleMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: LogType
    let timestamp: Date
    
    var formatted: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return "[\(timeFormatter.string(from: timestamp))] \(type.emoji) \(text)"
    }
}

class ConsoleManager: ObservableObject {
    static let shared = ConsoleManager()
    
    @Published var lastMessage: ConsoleMessage?
    private var clearTimer: Timer?
    
    private init() {}
    
    func log(_ text: String, type: LogType = .info) {
        let message = ConsoleMessage(text: text, type: type, timestamp: Date())
        
        DispatchQueue.main.async {
            self.lastMessage = message
        }
        
        // Also print to actual console for debugging
        print(message.formatted)
    }
    
    func clear() {
        lastMessage = nil
    }
}
