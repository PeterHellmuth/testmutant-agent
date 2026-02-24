#!/bin/bash
set -e

REPO="peterhellmuth/TestMutant-agent"
INSTALL_DIR="$HOME/.testmutant"
mkdir -p "$INSTALL_DIR"

# 1. Detect OS
case "$(uname -s)" in
    Linux*)     
        OS_TYPE="linux"
        ASSET_SUFFIX="linux.zip"
        BINARY_NAME="TestMutant.Agent"
        ;;
    Darwin*)    
        OS_TYPE="osx"
        ASSET_SUFFIX="osx.zip"
        BINARY_NAME="TestMutant.Agent"
        ;;
    CYGWIN*|MINGW*|MSYS*) 
        OS_TYPE="windows"
        ASSET_SUFFIX="win.exe.zip"
        BINARY_NAME="TestMutant.Agent.exe"
        ;;
    *)          
        echo "❌ Error: Unsupported OS: $(uname -s)"
        exit 1
        ;;
esac

echo "🔍 Detected $OS_TYPE environment. Finding latest release..."

# 2. Get latest release download URL
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | \
    grep -o "https://.*$ASSET_SUFFIX" | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "❌ Error: Could not find a release asset ending in $ASSET_SUFFIX"
    exit 1
fi

# 3. Download & Extract to a temp location
TEMP_ZIP="$INSTALL_DIR/temp.zip"
TEMP_EXTRACT="$INSTALL_DIR/temp_extract"

echo "⬇️  Downloading TestMutant..."
curl -L "$DOWNLOAD_URL" -o "$TEMP_ZIP"

echo "📦 Extracting..."
rm -rf "$TEMP_EXTRACT"
unzip -q -o "$TEMP_ZIP" -d "$TEMP_EXTRACT"

# 4. Hunt down the exact file, completely ignoring the zip's internal folder structure
echo "🔍 Locating executable..."
FOUND_BINARY=$(find "$TEMP_EXTRACT" -name "$BINARY_NAME" -type f | head -n 1)

if [ -z "$FOUND_BINARY" ]; then
    echo "❌ Error: Could not find $BINARY_NAME in the downloaded zip."
    rm -f "$TEMP_ZIP"
    rm -rf "$TEMP_EXTRACT"
    exit 1
fi

# 5. Move it directly to the root installation directory
mv -f "$FOUND_BINARY" "$INSTALL_DIR/$BINARY_NAME"

# 6. Clean up the temp files
rm -f "$TEMP_ZIP"
rm -rf "$TEMP_EXTRACT"

# 7. Make executable (Linux/Mac only, Windows .exe doesn't need chmod)
if [ "$OS_TYPE" != "windows" ]; then
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
fi

echo "✅ TestMutant installed successfully to $INSTALL_DIR/$BINARY_NAME"