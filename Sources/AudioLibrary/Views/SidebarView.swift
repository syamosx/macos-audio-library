//
//  SidebarView.swift
//  AudioLibrary
//
//  The "Command Center" sidebar
//

import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: LibraryViewModel
    @State private var selectedTab: SidebarTab = .library
    
    enum SidebarTab: String, CaseIterable {
        case library = "Library"
        case recent = "Recent"
        case private_ = "Private"
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.16).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20) // Standard padding
                
                // Segmented Control
                HStack(spacing: 2) {
                    SegmentButton(title: "Library", isActive: selectedTab == .library) { selectedTab = .library }
                    SegmentButton(title: "Recent", isActive: selectedTab == .recent) { selectedTab = .recent }
                    SegmentButton(title: "Private", isActive: selectedTab == .private_) { selectedTab = .private_ }
                }
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 25)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        if selectedTab == .library {
                            // Recent Section
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "RECENTLY PLAYED")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.recentBooks.prefix(4)) { book in
                                            ArtworkView(artworkPath: book.artworkPath, size: 55)
                                                .frame(width: 55, height: 55)
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                            }.padding(.horizontal, 16)
                            
                            // Books Section
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "MY BOOKS")
                                ForEach(viewModel.books) { book in
                                    SidebarBookRow(book: book, viewModel: viewModel)
                                        .onTapGesture {
                                            // Load book logic
                                            Task {
                                                AudioPlayer.shared.load(book: book)
                                            }
                                        }
                                }
                            }.padding(.horizontal, 16)
                        } else if selectedTab == .private_ {
                             VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(text: "PRIVATE BOOKS")
                                if viewModel.privateBooks.isEmpty {
                                    Text("No private books")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.gray)
                                } else {
                                    ForEach(viewModel.privateBooks) { book in
                                        SidebarBookRow(book: book, viewModel: viewModel)
                                            .onTapGesture {
                                                Task {
                                                    AudioPlayer.shared.load(book: book)
                                                }
                                            }
                                    }
                                }
                            }.padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }
}

struct SidebarBookRow: View {
    let book: Book
    var viewModel: LibraryViewModel? // Optional to allow preview or simple usage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ArtworkView(artworkPath: book.artworkPath, size: 32)
                .frame(width: 32, height: 32)
                .cornerRadius(3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                Text(book.author)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                // Progress bar
                GeometryReader { geometry in
                    let accentColor = book.dominantColor.map { Color(hex: $0) } ?? Color.gray
                    
                    ZStack(alignment: .leading) {
                        // Background (lower opacity)
                        Capsule()
                            .fill(accentColor.opacity(0.3))
                            .frame(height: 3)
                        
                        // Foreground (normal opacity)
                        Capsule()
                            .fill(accentColor)
                            .frame(width: geometry.size.width * CGFloat(book.progress), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Options Button (Menu)
            if let vm = viewModel {
                Menu {
                    Button {
                        vm.togglePrivate(for: book)
                    } label: {
                        Label(book.status == .private_ ? "Move to Library" : "Move to Private", systemImage: book.status == .private_ ? "lock.open" : "lock")
                    }
                    
                    Button {
                        vm.recalculateColor(for: book)
                    } label: {
                        Label("Recalculate Color", systemImage: "paintpalette")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        vm.deleteBook(book)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden) // Hide the chevron
                .fixedSize()
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
        .contextMenu { // Also add context menu for convenience
            if let vm = viewModel {
                Button {
                    vm.togglePrivate(for: book)
                } label: {
                    Label(book.status == .private_ ? "Move to Library" : "Move to Private", systemImage: book.status == .private_ ? "lock.open" : "lock")
                }
                
                Button {
                    vm.recalculateColor(for: book)
                } label: {
                    Label("Recalculate Color", systemImage: "paintpalette")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    vm.deleteBook(book)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct SegmentButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? .white.opacity(0.9) : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isActive ? RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.1)) : nil)
                .padding(2)
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeader: View {
    let text: String
    var body: some View {
        HStack {
            Text(text).font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.3)).tracking(0.5)
            Spacer()
        }
    }
}
