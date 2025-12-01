#!/bin/bash

# Audio Library - Run Script (No Xcode Required!)
# This runs the app using Swift Package Manager

cd "$(dirname "$0")"

echo "🎵 Audio Library"
echo "================"
echo ""
echo "Building and launching..."
echo ""

swift build
afplay /System/Library/Sounds/Glass.aiff
swift run AudioLibrary
