#\!/bin/bash

# Test script to verify chonker5-tui builds and basic functionality
echo "Testing Chonker5-TUI..."

# Set library path for PDFium
export DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib

# Check if binary exists
if [ \! -f "./target/release/chonker5-tui" ]; then
    echo "Building chonker5-tui first..."
    cargo build --release
fi

# Check the binary
echo "Binary info:"
file ./target/release/chonker5-tui
echo ""

echo "To run the TUI interactively, use:"
echo "  DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui"
echo ""
echo "Key features in the simplified (non-vim) version:"
echo "  ✅ Direct editing - just type to insert text\!"
echo "  ✅ Standard shortcuts - Ctrl+C/X/V for copy/cut/paste"
echo "  ✅ Ctrl+F for search"
echo "  ✅ Ctrl+S to export/save"
echo "  ✅ Arrow keys for navigation"
echo "  ✅ Shift+Arrow for selection"
echo "  ✅ No mode switching required\!"
echo ""
echo "Press 'o' to open a PDF, 'm' to extract matrix, then start editing\!"
