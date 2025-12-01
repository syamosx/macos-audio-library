//
//  ConsoleManager.swift
//  AudioLibrary
//
//  Manages the "Tech Console" logs
//

import Foundation
import Combine

class ConsoleManager: ObservableObject {
    static let shared = ConsoleManager()
    
    @Published var logs: [ConsoleLog] = []
    
    private init() {}
    
    func log(_ message: String) {
        Task { @MainActor in
            let log = ConsoleLog(message: message, timestamp: Date())
            logs.append(log)
            
            // Keep last 50 logs
            if logs.count > 50 {
                logs.removeFirst()
            }
        }
    }
    
    func clear() {
        Task { @MainActor in
            logs.removeAll()
        }
    }
}

struct ConsoleLog: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let timestamp: Date
}
