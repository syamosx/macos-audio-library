//
//  NSImage+AverageColor.swift
//  AudioLibrary
//
//  Extension to calculate average color of an image for background glow
//

import AppKit
import SwiftUI

extension NSImage {
    // Helper to calculate average color for the glow effect
    func resized(to newSize: NSSize) -> NSImage? {
        let img = NSImage(size: newSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size), operation: .copy, fraction: 1)
        img.unlockFocus()
        return img
    }

    var averageColor: Color {
        guard let resized = self.resized(to: NSSize(width: 1, height: 1)),
              let cgImage = resized.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return Color(red: 0.2, green: 0.2, blue: 0.22) }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = 4 * width
        var rawData = [UInt8](repeating: 0, count: bytesPerRow * height)
        
        guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return Color(red: 0.2, green: 0.2, blue: 0.22) }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let r = CGFloat(rawData[0]) / 255.0
        let g = CGFloat(rawData[1]) / 255.0
        let b = CGFloat(rawData[2]) / 255.0
        
        // Convert to NSColor to extract Hue
        let originalColor = NSColor(red: r, green: g, blue: b, alpha: 1.0)
        
        // User Request: Keep Hue, force specific Saturation and Brightness
        // This ensures the glow is always colorful and cinematic, never muddy or gray.
        // Saturation: 0.6 (Rich)
        // Brightness: 0.4 (Subtle dark glow)
        return Color(hue: originalColor.hueComponent, saturation: 0.6, brightness: 0.4)
    }
}
