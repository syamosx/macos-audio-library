//
//  GeminiColorService.swift
//  AudioLibrary
//
//  Service to extract dominant color from artwork using Gemini API
//

import Foundation
import AppKit

struct GeminiColorService {
    static let shared = GeminiColorService()
    
    // API Key should be loaded from a secure source
    private var apiKey: String {
        let fileManager = FileManager.default
        guard let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return "" }
        
        let dbFolder = appSupport.appendingPathComponent("AudioLibrary", isDirectory: true)
        // Ensure folder exists
        try? fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
        
        let secretPath = dbFolder.appendingPathComponent("api_key")
        
        do {
            let key = try String(contentsOf: secretPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            return key
        } catch {
            return ""
        }
    }
    
    func setApiKey(_ key: String) {
        let fileManager = FileManager.default
        guard let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }
        
        let dbFolder = appSupport.appendingPathComponent("AudioLibrary", isDirectory: true)
        try? fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
        
        let secretPath = dbFolder.appendingPathComponent("api_key")
        try? key.write(to: secretPath, atomically: true, encoding: .utf8)
    }
    
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent"
    
    func analyze(artworkData: Data) async -> String? {
        ConsoleManager.shared.log("🎨 Starting AI color analysis...")
        
        // Retry logic: 3 attempts
        for attempt in 1...3 {
            do {
                if attempt > 1 {
                    ConsoleManager.shared.log("🔄 Retry attempt \(attempt)/3...")
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1s delay
                }
                
                let color = try await performRequest(artworkData: artworkData)
                ConsoleManager.shared.log("✅ AI Color Selected: \(color)")
                return color
            } catch {
                ConsoleManager.shared.log("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
            }
        }
        
        ConsoleManager.shared.log("❌ AI Analysis Failed after 3 attempts.")
        return nil
    }
    
    private func performRequest(artworkData: Data) async throws -> String {
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let base64Image = artworkData.base64EncodedString()
        
        let prompt = """
        You will receive a book cover. Your job will be to look at the book and then decide on a good accent color for the cover. Focus on the actual book, the visual features, not the content of the book. The accent color should preferably be vibrant. Your response should be a single simple hex code for the color. 
        don't choose the actual color, but the more vibrant accent color that would be inspired by the book cover. lean more toward extreme vibrant colors.
        Return ONLY the hex code in a JSON object like {"color": "#HEXCODE"}.
        if there's an issue, like you didn't recieve the image, then respond with {"color" : "ERROR: (reason for the issue)"} or something similar. don't halucinate a color.
        """
        
        let jsonBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "thinkingConfig": [
                    "thinkingLevel": "LOW",
                ],
                "responseMimeType": "application/json",
                "mediaResolution": "MEDIA_RESOLUTION_HIGH"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorBody)"])
        }
        
        // Parse Response
        // Structure: candidates[0].content.parts[0].text -> JSON String -> {"color": "#..."}
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String,
              let data = text.data(using: .utf8),
              let resultJson = try JSONSerialization.jsonObject(with: data) as? [String: String],
              let colorHex = resultJson["color"] else {
            throw NSError(domain: "GeminiAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return colorHex
    }
}
