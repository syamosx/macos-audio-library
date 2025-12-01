import SwiftUI
import AppKit

// ============================================================================
// MARK: - 1. MODELS (DATA LAYER)
// ============================================================================
// Define your data structures here so they are ready for your backend/database.

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: String
    let message: String
}

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let coverColor: Color // In a real app, this might be a URL or data
}

struct RecentItem: Identifiable {
    let id = UUID()
    let color: Color
}

// ============================================================================
// MARK: - 2. VIEW MODEL (LOGIC LAYER)
// ============================================================================
// This is the "brain" of the view. Wire your Audio Engine and Database here.

class AppViewModel: ObservableObject {
    
    // MARK: - UI State
    @Published var isSidebarVisible: Bool = true
    @Published var coverImage: NSImage? = nil
    @Published var backgroundGlow: Color = Color(red: 0.2, green: 0.2, blue: 0.22)
    @Published var logs: [LogEntry] = []
    
    // MARK: - Player State (Wire these to your AudioEngine)
    @Published var isPlaying: Bool = false
    @Published var currentTrackTitle: String = "DUNE"
    @Published var currentTrackAuthor: String = "Frank Herbert"
    @Published var currentTime: String = "14:32"
    @Published var remainingTime: String = "-42:10"
    @Published var progress: CGFloat = 0.35 // 0.0 to 1.0
    
    // MARK: - Data Source (Populate these from your DB)
    @Published var recentItems: [RecentItem] = [
        RecentItem(color: Color(red: 0.2, green: 0.4, blue: 0.6)),
        RecentItem(color: Color(red: 0.8, green: 0.8, blue: 0.8)),
        RecentItem(color: Color(red: 0.7, green: 0.3, blue: 0.3))
    ]
    
    @Published var myBooks: [Book] = [
        Book(title: "Project Hail Mary", author: "Andy Weir", coverColor: Color(red: 0.2, green: 0.5, blue: 0.7)),
        Book(title: "Becoming", author: "Michelle Obama", coverColor: .gray),
        Book(title: "The Silent Patient", author: "Alex Michaelides", coverColor: Color(red: 0.8, green: 0.5, blue: 0.2))
    ]

    // MARK: - Configuration
    private let sidebarWidth: CGFloat = 250
    private let animDuration: Double = 0.35
    
    init() {
        // Simulate initial logs
        addLog("Audio engine initialized.")
        addLog("Loaded chapter 3.")
        addLog("Ready to play.")
    }
    
    // MARK: - Intents (Actions triggered by UI)
    
    func togglePlayPause() {
        isPlaying.toggle()
        addLog(isPlaying ? "Resumed playback." : "Paused playback.")
        // TODO: Call yourAudioEngine.play() or pause()
    }
    
    func skipForward() {
        addLog("Skipped forward 15s.")
        // TODO: Call yourAudioEngine.seek(by: 15)
    }
    
    func skipBackward() {
        addLog("Skipped backward 15s.")
        // TODO: Call yourAudioEngine.seek(by: -15)
    }
    
    func loadBook(_ book: Book) {
        addLog("Loading \(book.title)...")
        // TODO: Load book logic
    }
    
    func addLog(_ text: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let entry = LogEntry(timestamp: "[\(timestamp)]", message: text)
        withAnimation {
            if self.logs.count > 5 { self.logs.removeFirst() }
            self.logs.append(entry)
        }
    }
}

// MARK: - Window Management Extension
extension AppViewModel {
    
    /// Handles the complex window resizing logic
    func toggleSidebar() {
        guard let window = NSApp.keyWindow, let screen = window.screen else { return }
        
        let currentFrame = window.frame
        var newFrame = currentFrame
        
        if isSidebarVisible {
            // CLOSING: Shrink width
            newFrame.size.width -= sidebarWidth
            if newFrame.size.width < 350 { newFrame.size.width = 350 }
        } else {
            // OPENING: Expand width
            newFrame.size.width += sidebarWidth
            
            // Screen Bounds Check: If expanding pushes off-screen, shift left.
            let screenRightEdge = screen.visibleFrame.maxX
            let proposedRightEdge = newFrame.origin.x + newFrame.size.width
            
            if proposedRightEdge > screenRightEdge {
                newFrame.origin.x -= sidebarWidth
            }
        }
        
        // Synced Animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }
        
        withAnimation(.easeInOut(duration: animDuration)) {
            self.isSidebarVisible.toggle()
        }
    }
    
    /// Opens the native file picker
    func promptForCoverUpload() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Select Cover Art"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.coverImage = image
                        withAnimation(.easeOut(duration: 1.5)) {
                            self.backgroundGlow = image.averageColor
                        }
                        self.addLog("Cover art loaded. Theme updated.")
                    }
                }
            }
        }
    }
}

// ============================================================================
// MARK: - 3. APP ENTRY POINT
// ============================================================================

@main
struct AudioApp: App {
    @StateObject var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainLayoutView(viewModel: viewModel)
                // Dynamic Minimum Width: 600 when Open, 350 when Closed
                .frame(minWidth: viewModel.isSidebarVisible ? 600 : 350, minHeight: 450)
                .background(Color(red: 0.12, green: 0.12, blue: 0.13))
                .onAppear {
                    // Slight delay to allow window to settle before prompting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if viewModel.coverImage == nil {
                            viewModel.promptForCoverUpload()
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
    }
}

// ============================================================================
// MARK: - 4. MAIN LAYOUT (VIEW LAYER)
// ============================================================================

struct MainLayoutView: View {
    @ObservedObject var viewModel: AppViewModel
    let baseColor = Color(red: 0.12, green: 0.12, blue: 0.13)
    
    var body: some View {
        HStack(spacing: 0) {
            
            // 1. LEFT: Main Player
            PlayerView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        baseColor.ignoresSafeArea()
                        // Dynamic Ambient Background
                        RadialGradient(
                            gradient: Gradient(colors: [
                                viewModel.backgroundGlow.opacity(0.25),
                                baseColor
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 700
                        )
                    }
                )
                .clipped()
                .zIndex(1) // Keep Player above Sidebar during transition

            // 2. MIDDLE: Divider (Visible only when sidebar is open)
            if viewModel.isSidebarVisible {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 1)
                    .edgesIgnoringSafeArea(.vertical)
            }
            
            // 3. RIGHT: Sidebar
            if viewModel.isSidebarVisible {
                SidebarView(viewModel: viewModel)
                    .frame(width: 250)
                    .transition(.move(edge: .trailing))
                    .zIndex(0)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// ============================================================================
// MARK: - 5. SUB-VIEWS
// ============================================================================

struct PlayerView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            // --- Top Bar (Traffic Light Spacer & Toggle) ---
            HStack {
                Spacer().frame(width: 60) // Traffic light spacer
                Spacer()
                Button(action: viewModel.toggleSidebar) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }
                .buttonStyle(.plain)
                .help("Toggle Sidebar")
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
            
            Spacer()
            
            // --- Artwork ---
            ArtworkView(image: viewModel.coverImage)
            
            Spacer().frame(height: 30)
            
            // --- Track Info ---
            VStack(spacing: 6) {
                Text(viewModel.currentTrackTitle)
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .foregroundColor(Color(white: 0.95))
                
                Text(viewModel.currentTrackAuthor)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.6))
            }
            
            Spacer().frame(height: 30)
            
            // --- Scrubber ---
            HStack(spacing: 15) {
                Text(viewModel.currentTime).styleMono()
                ProgressBar(progress: viewModel.progress)
                Text(viewModel.remainingTime).styleMono()
            }
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 25)
            
            // --- Controls ---
            HStack(spacing: 40) {
                ControlButton(icon: "backward.fill", size: 20, action: viewModel.skipBackward)
                ControlButton(icon: viewModel.isPlaying ? "pause.fill" : "play.fill", size: 38, action: viewModel.togglePlayPause)
                ControlButton(icon: "forward.fill", size: 20, action: viewModel.skipForward)
            }
            .padding(.bottom, 20)
            
            // --- Console (Conditional) ---
            if viewModel.isSidebarVisible {
                Spacer().frame(height: 10)
                ConsoleView(logs: viewModel.logs)
                    .frame(height: 100)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .transition(.opacity)
            } else {
                Spacer().frame(height: 20)
            }
        }
    }
}

struct SidebarView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.16).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20) // Standard padding
                
                // Segmented Control (Visual Only for now)
                HStack(spacing: 2) {
                    SegmentButton(title: "Books", isActive: true)
                    SegmentButton(title: "Recent", isActive: false)
                    SegmentButton(title: "Private", isActive: false)
                }
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 25)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Recent Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(text: "RECENTLY PLAYED")
                            HStack(spacing: 12) {
                                ForEach(viewModel.recentItems) { item in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(item.color)
                                        .frame(width: 55, height: 80)
                                }
                            }
                        }.padding(.horizontal, 16)
                        
                        // Books Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(text: "MY BOOKS")
                            ForEach(viewModel.myBooks) { book in
                                BookRow(book: book)
                                    .onTapGesture { viewModel.loadBook(book) }
                            }
                        }.padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

// ============================================================================
// MARK: - 6. REUSABLE COMPONENTS
// ============================================================================

struct ArtworkView: View {
    let image: NSImage?
    
    var body: some View {
        ZStack {
            if let nsImage = image {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 15)
                    .padding(.horizontal, 20)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.16))
                    .frame(width: 300, height: 300)
                    .overlay(Text("Select Cover").font(.caption).foregroundColor(.gray.opacity(0.5)))
            }
        }
    }
}

struct ProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                Capsule().fill(Color(white: 0.7)).frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
        .frame(maxWidth: 350)
    }
}

struct ControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
        }
        .buttonStyle(.plain)
        .foregroundColor(Color(white: 0.9))
    }
}

struct ConsoleView: View {
    let logs: [LogEntry]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.2))
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(logs) { log in
                        HStack(alignment: .top, spacing: 8) {
                            Text(log.timestamp).foregroundColor(.gray)
                            Text(log.message).foregroundColor(Color(red: 0.45, green: 0.75, blue: 0.45).opacity(0.9))
                        }
                    }
                }
                .font(.system(size: 10, design: .monospaced))
                .padding(12)
            }
        }
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(book.coverColor.opacity(0.8))
                .frame(width: 32, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                Text(book.author)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                
                // Fake progress bar for the row
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 3)
                    Capsule().fill(Color.gray.opacity(0.5)).frame(width: 30, height: 3)
                }.padding(.top, 2)
            }
        }
        .contentShape(Rectangle()) // Makes the whole row tappable
    }
}

struct SegmentButton: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(isActive ? .white.opacity(0.9) : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isActive ? RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.1)) : nil)
            .padding(2)
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

// MARK: - Utilities
extension Text {
    func styleMono() -> some View {
        self.font(.system(size: 11, design: .monospaced))
            .foregroundColor(Color(white: 0.4))
    }
}

extension NSImage {
    // Helper to calculate average color for the glow effect
    func resized(to newSize: NSSize) -> NSImage? {
        let img = NSImage(size: newSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size), operation: .copy, fraction: 1)
        img.unlockFocus()
        return img
    }

    var averageColor: Color {
        guard let resized = self.resized(to: NSSize(width: 1, height: 1)),
              let cgImage = resized.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return Color(red: 0.2, green: 0.2, blue: 0.22) }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = 4 * width
        var rawData = [UInt8](repeating: 0, count: bytesPerRow * height)
        
        guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return Color(red: 0.2, green: 0.2, blue: 0.22) }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let r = CGFloat(rawData[0]) / 255.0; let g = CGFloat(rawData[1]) / 255.0; let b = CGFloat(rawData[2]) / 255.0
        return Color(red: Double(r) * 0.85, green: Double(g) * 0.85, blue: Double(b) * 0.85)
    }
}