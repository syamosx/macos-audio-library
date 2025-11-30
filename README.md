# macOS Audio Library

> Modern SwiftUI audio library for macOS — **no Xcode required!**

A beautiful, offline-first audiobook library built with the latest SwiftUI best practices for macOS Sequoia. Designed for personal use with local files.

[![Swift](https://img.shields.io/badge/Swift-6.2.1-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## ✨ Features (Phase 1)

- 🎨 **Modern UI** — NavigationSplitView with adaptive 3-column layout
- 📚 **Books Library** — Search and sort your audiobook collection
- 🎵 **Playback Controls** — UI for play/pause, skip, and speed control
- 📊 **Progress Tracking** — Visual progress bars and position saving
- 🕐 **Recently Played** — Track your listening history
- 🔒 **Extra Private** — Separate section for private content
- 🚀 **No Xcode** — Builds with Swift CLI (`swift build`)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/syamosx/macos-audio-library.git
cd macos-audio-library

# Run the app
./run.sh
```

That's it! The app window opens with your library ready to use.

## 📋 Requirements

- macOS 14.0+ (Sonoma or later)
- Swift 5.9+ Command Line Tools
  - Install: `xcode-select --install`
- **No Xcode required!**

## 🏗️ Architecture

**Design Pattern**: MVVM with @Observable

- **Modern SwiftUI** — NavigationSplitView, @Observable macro, type-safe navigation
- **No External Dependencies** (Phase 1) — Pure Swift + SwiftUI
- **SPM Structure** — Standard Swift Package Manager layout
- **CLI Builds** — Works with `swift build`, no Xcode needed

### Project Structure

```
Sources/AudioLibrary/
├── AudioLibraryApp.swift      # Main app entry point
├── Models/                    # Data models (Book, Bookmark)
├── ViewModels/                # @Observable view models
└── Views/                     # SwiftUI views (6 view components)
```

## 🎯 What Works

- ✅ **Sidebar Navigation** — Books, Extra Private, Recently Played
- ✅ **Books List** — Search by title/tags, sort by multiple criteria
- ✅ **Book Detail View** — Comprehensive playback UI
- ✅ **Progress Tracking** — Visual indicators and completion percentages
- ✅ **Mock Data** — 5 sample audiobooks for testing
- ✅ **Speed Control** — Dropdown menu (0.5× to 2.0×)
- ✅ **Skip Controls** — Forward/backward 15 seconds
- ✅ **Responsive Design** — Adapts to window size

## 🛠️ Development

```bash
# Build only
swift build

# Run the app
swift run

# Clean build artifacts
swift package clean

# Build for release (optimized)
swift build -c release
```

### IDE Options

Use any editor you prefer:
- VS Code with Swift extension
- CLion with Swift plugin
- Vim/Neovim with LSP
- Any text editor + terminal

## 🗺️ Roadmap

### Phase 1: UI & Scaffolding ✅ (Complete)
- Modern SwiftUI interface
- Navigation and layout
- Mock data for testing

### Phase 2: Database (Next)
- SQLite with GRDB.swift
- Persistent storage
- CRUD operations
- Migrations

### Phase 3: Playback & Import
- AVFoundation audio playback
- File import with NSOpenPanel
- SHA-256 hashing for content identification
- Metadata extraction
- File path management

### Phase 4: Advanced Features
- Bookmarks CRUD
- Event logging
- Conflict resolution
- Sync preparation

### Phase 5: Polish & Distribution
- Keyboard shortcuts
- Accessibility improvements
- App packaging & code signing
- Database backup/export

## 📖 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** — Common commands and quick reference
- **[START_HERE.md](START_HERE.md)** — New user guide
- **[PHASE1_SUMMARY.md](PHASE1_SUMMARY.md)** — Technical implementation details

## 🎨 Design Principles

Following macOS Sequoia best practices:

1. **NavigationSplitView** for native multi-column layout
2. **@Observable macro** for performant state management
3. **SF Symbols** for consistent iconography
4. **ContentUnavailableView** for empty states
5. **Native macOS styling** with proper colors and spacing
6. **Keyboard-friendly** navigation and controls

## 🤝 Contributing

This is currently a personal project, but feedback and suggestions are welcome! Feel free to:

- Open an issue for bugs or feature requests
- Share your ideas for improvements
- Fork and experiment with your own versions

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

Built with modern SwiftUI patterns based on:
- Apple's SwiftUI documentation
- macOS Human Interface Guidelines
- Swift Package Manager best practices

---

**Built with** ❤️ **and Swift 6.2.1**  
**Status**: Phase 1 Complete ✅  
**Next**: Phase 2 — Database Integration
