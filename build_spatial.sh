#!/bin/bash
# BUILD SPATIAL TUI
cd /Users/jack/chonker5/chonker5-tui
echo "🔨 BUILDING SPATIAL TUI..."
cargo build --release 2>&1
echo "✅ DONE"
echo "🚀 RUN: ./target/release/chonker5-tui test.pdf"
echo "🎮 Press Ctrl+M to extract with SPATIAL LAYOUT"