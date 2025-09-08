#!/bin/bash
# Benchmark script for Chonker5-TUI performance

echo "🚀 Chonker5-TUI Performance Benchmark"
echo "===================================="
echo ""

# Check if mutool is installed
if ! command -v mutool &> /dev/null; then
    echo "⚠️  mutool not found. Installing would greatly improve performance!"
    echo "   macOS: brew install mupdf-tools"
    echo "   Linux: apt-get install mupdf-tools"
    echo ""
fi

# Build both versions
echo "📦 Building standard version..."
cargo build --release --bin chonker5-tui 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Standard version built"
else
    echo "❌ Standard build failed"
    exit 1
fi

echo ""
echo "📦 Building enhanced version..."
cargo build --release --bin chonker5-tui-enhanced 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Enhanced version built"
else
    echo "❌ Enhanced build failed"
fi

echo ""
echo "Performance Features in Enhanced Version:"
echo "----------------------------------------"
echo "✅ Pre-render adjacent pages in background"
echo "✅ LRU cache for rendered pages (20 page limit)"
echo "✅ Terminal-aware DPI optimization"
echo "✅ Progressive loading (low-res → high-res)"
echo "✅ Cache hit rate tracking"
echo ""
echo "Keyboard Shortcuts:"
echo "------------------"
echo "Standard:"
echo "  ← → : Navigate pages"
echo "  Tab : Switch panes"
echo "  o   : Open PDF"
echo "  m   : Extract matrix"
echo ""
echo "Enhanced (additional):"
echo "  1   : Fast render mode (low quality)"
echo "  2   : Quality render mode (high quality)"
echo "  3   : Progressive mode (default)"
echo "  PageUp/PageDown : Jump 10 pages"
echo "  Ctrl+C : Clear cache"
echo ""
echo "To run standard version:"
echo "  ./target/release/chonker5-tui"
echo ""
echo "To run enhanced version:"
echo "  ./target/release/chonker5-tui-enhanced"
echo ""
echo "The enhanced version will show cache statistics in the UI!"