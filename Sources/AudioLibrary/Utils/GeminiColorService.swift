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
    
    private let apiKey = "AIzaSyAGk2XxZXNwUgCdYQHmtLBi00vfcZeVUkI"
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
        Analyze this image and return the single most dominant, vibrant accent color in HEX format (e.g. #FF0000). 
        Return ONLY the hex code in a JSON object like {"color": "#HEXCODE"}.
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
                "responseMimeType": "application/json"
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
