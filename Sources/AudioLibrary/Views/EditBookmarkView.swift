//
//  EditBookmarkView.swift
//  AudioLibrary
//
//  Sheet for editing an existing bookmark
//

import SwiftUI

struct EditBookmarkView: View {
    @Binding var isPresented: Bool
    let bookmark: Bookmark
    let onSave: (String, String?) -> Void
    let onDelete: () -> Void
    
    @State private var label: String
    @State private var note: String
    
    init(isPresented: Binding<Bool>, bookmark: Bookmark, onSave: @escaping (String, String?) -> Void, onDelete: @escaping () -> Void) {
        self._isPresented = isPresented
        self.bookmark = bookmark
        self.onSave = onSave
        self.onDelete = onDelete
        self._label = State(initialValue: bookmark.label)
        self._note = State(initialValue: bookmark.note ?? "")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Bookmark")
                .font(.title2.bold())
            
            Text("Position: \(bookmark.formattedPosition)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Label")
                    .font(.subheadline.bold())
                
                TextField("Bookmark label", text: $label)
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
                Button("Delete", role: .destructive) {
                    onDelete()
                    isPresented = false
                }
                
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    onSave(label, note.isEmpty ? nil : note)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(label.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
