#!/bin/bash
# Launcher script for Chonker5 TUI - supports WezTerm and Kitty

cd /Users/jack/chonker5

# Check what terminal we're in
if [[ "$TERM_PROGRAM" == "WezTerm" ]] || [[ "$TERM" == *"wezterm"* ]]; then
    echo "Running Chonker5 TUI in WezTerm..."
    # Already in WezTerm, just run the app
    DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui "$@"
elif [[ "$TERM" == *"kitty"* ]] || [[ "$TERM_PROGRAM" == "kitty" ]]; then
    echo "Running Chonker5 TUI in Kitty..."
    # Already in Kitty, just run the app
    DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui "$@"
else
    # Try WezTerm first (potentially more stable for images)
    if command -v wezterm &> /dev/null; then
        echo "Launching Chonker5 TUI in WezTerm..."
        wezterm start --cwd /Users/jack/chonker5 -- bash -c "DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui $*"
    # Fall back to Kitty
    elif command -v kitty &> /dev/null; then
        echo "Launching Chonker5 TUI in Kitty terminal..."
        kitty --single-instance \
              --title "Chonker5 TUI" \
              --override font_size=12 \
              --override cursor_shape=block \
              --override cursor_blink_interval=0.5 \
              --override remember_window_size=yes \
              --override window_padding_width=2 \
              bash -c "cd /Users/jack/chonker5 && DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui $*"
    else
        echo "Warning: Neither WezTerm nor Kitty found. PDF image display may not work."
        echo ""
        echo "Install WezTerm (recommended): brew install --cask wezterm"
        echo "Or install Kitty: brew install kitty"
        echo ""
        echo "Attempting to run in current terminal anyway..."
        DYLD_LIBRARY_PATH=/Users/jack/chonker5/lib ./target/release/chonker5-tui "$@"
    fi
fi