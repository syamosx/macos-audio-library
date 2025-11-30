#!/bin/bash

# Audio Library - Setup Script (No Xcode Required!)
# Updated for Swift Package Manager

echo "🎵 Audio Library - Phase 1 Setup"
echo "================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Project directory: $PROJECT_DIR"
echo ""

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed"
    echo "   Install Command Line Tools: xcode-select --install"
    exit 1
fi

SWIFT_VERSION=$(swift --version | head -n 1)
echo "✅ Swift found: $SWIFT_VERSION"
echo ""

# Check for Command Line Tools
if xcode-select -p &> /dev/null; then
    echo "✅ Command Line Tools: $(xcode-select -p)"
else
    echo "❌ Command Line Tools not found"
    echo "   Install: xcode-select --install"
    exit 1
fi
echo ""

echo "📦 Swift Package Structure"
echo "   • Package.swift configured"
echo "   • Sources/AudioLibrary/ contains all code"
echo "   • Ready to build with SPM"
echo ""

echo "🚀 Phase 1 Features:"
echo "   • Modern NavigationSplitView UI"
echo "   • Sidebar navigation"
echo "   • Books list with search & sort"
echo "   • Detailed book view with playback controls"
echo "   • Recently played view"
echo "   • Mock data for testing"
echo ""

echo "📚 How to Run:"
echo "   1. ./run.sh                    (quick start)"
echo "   2. swift run                   (build and run)"
echo "   3. swift build && swift run    (manual)"
echo ""

echo "🔧 Development Commands:"
echo "   • swift build                  (build only)"
echo "   • swift build -c release       (optimized build)"
echo "   • swift package clean          (clean build artifacts)"
echo ""

echo "✨ Ready to launch!"
echo ""
echo "Run: ./run.sh"
