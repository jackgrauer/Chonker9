#!/bin/bash
# CHONKER9 - Galaxy Brain PDF Intelligence with Lance

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set library path for pdfium
export DYLD_LIBRARY_PATH="$SCRIPT_DIR/lib:$DYLD_LIBRARY_PATH"

# Run chonker9 with Lance enabled by default
exec "$SCRIPT_DIR/target/release/chonker9" --lance "$@"