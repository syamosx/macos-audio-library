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
        let metadata = try await asset.load(.metadata)
        
        var title: String?
        var artist: String?
        var album: String?
        
        for item in metadata {
            guard let key = item.commonKey?.rawValue,
                  let value = try? await item.load(.stringValue) else { continue }
            
            switch key {
            case AVMetadataKey.commonKeyTitle.rawValue:
                title = value
            case AVMetadataKey.commonKeyArtist.rawValue:
                artist = value
            case AVMetadataKey.commonKeyAlbumName.rawValue:
                album = value
            default:
                break
            }
        }
        
        return AudioMetadata(
            duration: durationSeconds,
            fileSize: fileSize,
            title: title,
            artist: artist,
            album: album
        )
    }
}
