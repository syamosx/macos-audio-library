# Audio Library - macOS

A modern macOS audio library app for managing and playing audiobooks, built with SwiftUI.

## Phase 1: UI & Scaffolding ✅

This is **Phase 1** of the implementation - a fully functional UI prototype with mock data.

### Current Features

- ✅ Modern SwiftUI NavigationSplitView architecture
- ✅ Sidebar navigation (Books, Extra Private, Recently Played)
- ✅ Books list with search and sort functionality
- ✅ Detailed book view with playback controls (UI only)
- ✅ Recently played view with progress tracking
- ✅ Mock data for 5 sample audiobooks
- ✅ Progress indicators and metadata display
- ✅ macOS Sequoia design guidelines

### Architecture

**Design Pattern**: MVVM with @Observable

- **Models**: `Book`, `Bookmark` (Phase 1)
- **ViewModels**: `LibraryViewModel` (using @Observable macro)
- **Views**: 
  - `ContentView` - Main NavigationSplitView container
  - `SidebarView` - Navigation sidebar
  - `BooksListView` - List of all books with search/sort
  - `BookDetailView` - Detailed book view with playback controls
  - `RecentlyPlayedView` - Recently played books
  - `ExtraPrivateView` - Placeholder for private section

### Project Structure

```
minimal mac player/
├── Package.swift                  # SPM configuration
├── run.sh                        # Quick run script
├── Sources/
│   └── AudioLibrary/
│       ├── AudioLibraryApp.swift          # App entry point
│       ├── Models/
│       │   ├── Book.swift                 # Book data model
│       │   └── Bookmark.swift             # Bookmark data model
│       ├── ViewModels/
│       │   └── LibraryViewModel.swift     # Main view model with mock data
│       └── Views/
│           ├── ContentView.swift          # Main container with NavigationSplitView
│           ├── SidebarView.swift          # Sidebar navigation
│           ├── BooksListView.swift        # Books list with search/sort
│           ├── BookDetailView.swift       # Book detail with playback UI
│           ├── RecentlyPlayedView.swift   # Recently played books
│           └── ExtraPrivateView.swift     # Private section placeholder
├── README.md
└── .gitignore
```

## How to Run (No Xcode Required!)

This project uses **Swift Package Manager** and runs directly from the command line.

### Requirements
- macOS 14.0+ (Sonoma or later)
- Swift 5.9+ (Command Line Tools)
  - Check: `swift --version`
  - Install: `xcode-select --install` (if needed)

### Quick Start

```bash
# Navigate to project directory
cd "/Volumes/Partation Two/cash/Practical Things/minimal mac player"

# Option 1: Use the run script
./run.sh

# Option 2: Build and run manually
swift build
swift run AudioLibrary

# Option 3: Run directly (builds automatically)
swift run
```

The app window will launch with the UI and mock data ready to explore!

### Development

```bash
# Clean build artifacts
swift package clean

# Build only (no run)
swift build

# Build for release (optimized)
swift build -c release

# Run release build
swift run -c release
```


## UI Features Demonstrated

### Books List
- Search by title or tags
- Sort by: Recently Played, Title, Date Added
- Progress bars for partially completed books
- Relative timestamps ("2 hours ago")
- Import and Refresh toolbar buttons (placeholders)

### Book Detail View
- Album artwork placeholder
- Metadata display (duration, file size, tags)
- Playback controls:
  - Play/Pause button
  - Skip backward/forward 15 seconds
  - Progress slider
  - Speed control (0.5× to 2.0×)
- Notes section
- Bookmarks section (placeholder for Phase 4)

### Recently Played
- Books sorted by last played time
- Progress indicators
- Position display (e.g., "2h 15m of 5h 30m")

## Next Phases

### Phase 2: Local DB & Models (Coming Next)
- Add GRDB.swift dependency
- Create SQLite database schema
- Implement migrations
- Replace mock data with real database queries
- Implement CRUD operations

### Phase 3: Playback & Import
- Implement AudioPlayer with AVFoundation
- File import with NSOpenPanel
- SHA-256 hashing with CryptoKit
- Metadata extraction from audio files
- Device state and path management

### Phase 4: Bookmarks, Logs & Conflict Hooks
- Full bookmark CRUD functionality
- Event logging system
- Local conflict resolution

### Phase 5: Polish & Packaging
- Keyboard shortcuts
- Accessibility improvements
- App packaging and code signing
- Database backup/export
- PowerSync migration preparation

## Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **@Observable** - Latest state management (macOS 14+)
- **NavigationSplitView** - Adaptive sidebar navigation
- **MVVM** - Clean architecture pattern
- **SF Symbols** - System icons

## Design Decisions

1. **NavigationSplitView**: Chosen over TabView for better macOS integration and adaptive layout
2. **@Observable macro**: Modern replacement for ObservableObject with better performance
3. **Mock data in ViewModel**: Allows UI testing without database dependency
4. **Modular view structure**: Each view is self-contained and reusable
5. **Type-safe navigation**: Using Swift's type system for navigation destinations

## Requirements

- macOS 14.0 (Sonoma) or later  
- Swift 5.9+ Command Line Tools
  - Check version: `swift --version`
  - Install if needed: `xcode-select --install`
- **No Xcode required!** Runs via Swift Package Manager

---

**Status**: Phase 1 Complete ✅  
**Next**: Phase 2 - Database Integration
