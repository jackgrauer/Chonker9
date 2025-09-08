#!/bin/bash
# Build script for Chonker5-TUI

echo "🐹 Building Chonker5-TUI..."

# Check if PDFium library exists
if [[ "$OSTYPE" == "darwin"* ]]; then
    LIB_EXT="dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIB_EXT="so"
else
    LIB_EXT="dll"
fi

if [ ! -f "./lib/libpdfium.$LIB_EXT" ]; then
    echo "⚠️  Warning: PDFium library not found at ./lib/libpdfium.$LIB_EXT"
    echo "   PDF functionality may be limited."
fi

# Build the TUI version
echo "📦 Building release binary..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "To run Chonker5-TUI:"
    echo "  ./target/release/chonker5-tui"
    echo ""
    echo "Or run directly with:"
    echo "  cargo run --release"
else
    echo "❌ Build failed!"
    exit 1
fi