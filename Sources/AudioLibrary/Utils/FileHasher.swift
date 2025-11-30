//
//  FileHasher.swift
//  AudioLibrary
//
//  SHA-256 hashing utility for content identification
//

import Foundation
import CryptoKit

struct FileHasher {
    /// Compute SHA-256 hash of a file using streaming to handle large files
    static func sha256(of fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }
        
        var hasher = SHA256()
        
        // Read in chunks to avoid loading entire file into memory
        let bufferSize = 32_768 // 32 KB chunks
        
        while autoreleasepool(invoking: {
            let data = handle.readData(ofLength: bufferSize)
            if data.count > 0 {
                hasher.update(data: data)
                return true
            } else {
                return false
            }
        }) { }
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Quick verification that a file exists at the expected hash
    static func verify(fileURL: URL, expectedHash: String) -> Bool {
        guard let computedHash = try? sha256(of: fileURL) else {
            return false
        }
        return computedHash == expectedHash
    }
}
