//
//  SidebarView.swift
//  AudioLibrary
//
//  Sidebar navigation using macOS design patterns
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedSection: SidebarSection?
    
    var body: some View {
        List(SidebarSection.allCases, selection: $selectedSection) { section in
            NavigationLink(value: section) {
                Label(section.rawValue, systemImage: section.icon)
            }
        }
        .navigationTitle("Library")
        .listStyle(.sidebar)
    }
}

