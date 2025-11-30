//
//  ContentView.swift
//  AudioLibrary
//
//  Main view with NavigationSplitView for sidebar navigation
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var selectedSection: SidebarSection? = .books
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            SidebarView(selectedSection: $selectedSection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 300)
        } detail: {
            // Detail view based on selected section
            DetailContentView(
                selectedSection: selectedSection,
                viewModel: viewModel
            )
        }
        .navigationTitle("Audio Library")
    }
}

// MARK: - Sidebar Section Enum

enum SidebarSection: String, Identifiable, CaseIterable {
    case books = "Books"
    case extraPrivate = "Extra Private"
    case recentlyPlayed = "Recently Played"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .books:
            return "books.vertical.fill"
        case .extraPrivate:
            return "lock.fill"
        case .recentlyPlayed:
            return "clock.fill"
        }
    }
}

// MARK: - Detail Content Router

struct DetailContentView: View {
    let selectedSection: SidebarSection?
    let viewModel: LibraryViewModel
    
    var body: some View {
        Group {
            switch selectedSection {
            case .books:
                BooksListView(viewModel: viewModel)
            case .extraPrivate:
                ExtraPrivateView()
            case .recentlyPlayed:
                RecentlyPlayedView(viewModel: viewModel)
            case .none:
                ContentUnavailableView(
                    "Select a Section",
                    systemImage: "sidebar.left",
                    description: Text("Choose a section from the sidebar to begin")
                )
            }
        }
    }
}

