//
//  AddBookmarkView.swift
//  AudioLibrary
//
//  Sheet for adding a new bookmark
//

import SwiftUI

struct AddBookmarkView: View {
    @Binding var isPresented: Bool
    let position: Double
    let onAdd: (String, String?) -> Void
    
    @State private var label: String = ""
    @State private var note: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Bookmark")
                .font(.title2.bold())
            
            Text("Position: \(formatTime(position))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Label")
                    .font(.subheadline.bold())
                
                TextField("e.g., Important scene", text: $label)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Note (Optional)")
                    .font(.subheadline.bold())
                
                TextEditor(text: $note)
                    .frame(height: 80)
                    .border(Color.gray.opacity(0.3), width: 1)
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Bookmark") {
                    onAdd(label, note.isEmpty ? nil : note)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(label.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            // Generate default label from position
            label = "Bookmark at \(formatTime(position))"
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}
