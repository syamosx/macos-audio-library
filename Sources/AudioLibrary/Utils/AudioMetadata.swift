//
//  AudioMetadata.swift
//  AudioLibrary
//
//  Extract metadata from audio files using AVFoundation
//

import Foundation
import AVFoundation

struct AudioMetadata {
    let duration: Double
    let fileSize: Int64
    let title: String?
    let artist: String?
    let album: String?
    let artworkData: Data?
    
    /// Extract metadata from an audio file
    static func extract(from fileURL: URL) async throws -> AudioMetadata {
        let asset = AVURLAsset(url: fileURL)
        
        // Get duration
        let duration = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(duration)
        
        // Get file size
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        // Get metadata
        // Load all available metadata formats
        let metadata = try await asset.load(.metadata)
        let commonMetadata = try await asset.load(.commonMetadata)
        
        var title: String?
        var artist: String?
        var album: String?
        var artworkData: Data?
        
        // 1. Check Common Metadata (Best for most formats)
        for item in commonMetadata {
            guard let key = item.commonKey else { continue }
            
            switch key {
            case .commonKeyTitle:
                title = try? await item.load(.stringValue)
            case .commonKeyArtist:
                artist = try? await item.load(.stringValue)
            case .commonKeyAlbumName:
                album = try? await item.load(.stringValue)
            case .commonKeyArtwork:
                if let data = try? await item.load(.dataValue) {
                    artworkData = data
                }
            default:
                break
            }
        }
        
        // 2. Fallback: Check all metadata (e.g. ID3 tags specifically) if common failed
        if artworkData == nil {
            for item in metadata {
                if let key = item.key as? String {
                    // ID3 Attached Picture
                    if key == "APIC" || key == "PIC" {
                        if let data = try? await item.load(.dataValue) {
                            artworkData = data
                            break
                        }
                    }
                }
            }
        }
        
        return AudioMetadata(
            duration: durationSeconds,
            fileSize: fileSize,
            title: title,
            artist: artist,
            album: album,
            artworkData: artworkData
        )
    }
}
