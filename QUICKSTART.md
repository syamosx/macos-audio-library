# Quick Reference — Audio Library (No Xcode!)

## 🚀 Run the App

```bash
./run.sh
```

or

```bash
swift run
```

The app window launches automatically with mock audiobooks ready to explore!

---

## 📋 Common Commands

| Command | Description |
|---------|-------------|
| `./run.sh` | Quick start (build + run) |
| `swift run` | Build and run |
| `swift build` | Build only |
| `swift build -c release` | Build optimized version |
| `swift run -c release` | Run optimized build |
| `swift package clean` | Clean build artifacts |
| `./setup.sh` | Show setup info |

---

## 📂 Project Structure

```
Sources/AudioLibrary/
├── AudioLibraryApp.swift      # Main app (@main)
├── Models/                    # Data models
├── ViewModels/                # @Observable view models
└── Views/                     # SwiftUI views
```

---

## 🎯 What Works (Phase 1)

- ✅ Sidebar navigation (Books, Extra Private, Recently Played)
- ✅ Books list with search and sort
- ✅ Book detail view with playback UI
- ✅ Progress tracking
- ✅ Mock data (5 sample audiobooks)
- ✅ All UI interactions

---

## ❌ Not Yet Implemented

- Database (Phase 2)
- Real audio playback (Phase 3)
- File import (Phase 3)
- Bookmarks CRUD (Phase 4)

---

## 🛠️ Tech Stack

- **Swift 6.2.1** (no Xcode required)
- **SwiftUI** (macOS native UI)
- **SPM** (Swift Package Manager)
- **@Observable** (modern state management)
- **NavigationSplitView** (adaptive layout)

---

## 💡 Tips

1. **First time**: Run `./setup.sh` to verify Swift installation
2. **Clean build**: Use `swift package clean` if you encounter issues
3. **Fast iteration**: `swift run` rebuilds only changed files
4. **Performance**: Use `-c release` for optimized builds

---

## 📖 Full Docs

- [README.md](README.md) — Complete documentation
- [PHASE1_SUMMARY.md](PHASE1_SUMMARY.md) — Implementation details
- [walkthrough.md](../../../.gemini/antigravity/brain/adb84201-64a2-43fb-984a-df47fc7482e0/walkthrough.md) — Detailed walkthrough

---

**Ready to launch?** → `./run.sh`
