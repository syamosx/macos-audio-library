//
//  ImportProgressView.swift
//  AudioLibrary
//
//  Progress sheet for import operations
//

import SwiftUI

struct ImportProgressView: View {
    @Bindable var importManager: ImportManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Importing Audio Files")
                .font(.title2.bold())
            
            if importManager.isImporting {
                ProgressView(value: importManager.importProgress) {
                    Text(importManager.importStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .progressViewStyle(.linear)
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    
                    Text(importManager.importStatus)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Button("Done") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 200)
        .padding()
    }
}
