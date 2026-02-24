#!/bin/bash
set -e

REPO="peterhellmuth/TestMutant-agent"
INSTALL_DIR="$HOME/.testmutant"

# 1. Detect Architecture
OS_TYPE="linux"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="osx"
fi

# 2. Get latest release download URL
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | \
    grep "browser_download_url.*$OS_TYPE.zip" | \
    cut -d : -f 2,3 | tr -d \" | xargs)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "❌ Error: Could not find a release for $OS_TYPE"
    exit 1
fi

# 3. Download & Install
mkdir -p "$INSTALL_DIR"
curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/testmutant.zip"
unzip -o "$INSTALL_DIR/testmutant.zip" -d "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/testmutant"

echo "✅ TestMutant installed to $INSTALL_DIR/testmutant"