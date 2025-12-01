#!/bin/bash

APP_NAME="AudioLibrary"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"

echo "🚀 Building $APP_NAME..."

# 1. Build release binary
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed."
    exit 1
fi

# 2. Create App Bundle Structure
echo "📦 Creating App Bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 3. Copy Executable
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 4. Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 5. Create PkgInfo
echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# 6. Create a simple icon (Optional - generates a generic icon)
# sips -s format icns "icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.icns" 2>/dev/null

# 7. Ad-hoc code signing (to avoid permission issues locally)
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ $APP_NAME.app created successfully!"
echo "📂 Location: $(pwd)/$APP_BUNDLE"
echo "👉 You can drag this to your Applications folder or run it with 'open $APP_BUNDLE'"

# Optional: Open the folder
open -R "$APP_BUNDLE"
