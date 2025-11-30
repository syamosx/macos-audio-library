//
//  BookmarkRowView.swift
//  AudioLibrary
//
//  Individual bookmark row in the list
//

import SwiftUI

struct BookmarkRowView: View {
    let bookmark: Bookmark
    let onJump: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Position and label
            VStack(alignment: .leading, spacing: 4) {
                Text(bookmark.label)
                    .font(.subheadline.bold())
                
                HStack(spacing: 6) {
                    Text(bookmark.formattedPosition)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    
                    if let note = bookmark.note, !note.isEmpty {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button {
                    onJump()
                } label: {
                    Image(systemName: "play.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Jump to  this position")
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Edit bookmark")
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
