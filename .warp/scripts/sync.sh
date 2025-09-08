#!/bin/bash

# Sync .warp directory contents to Warp Drive
# This script imports workflows, notebooks, and scripts into ~/warp-drive

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WARP_DIR="$(dirname "$SCRIPT_DIR")"
WARP_DRIVE_DIR="$HOME/warp-drive"
REPO_NAME="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")")"

echo "🔄 Syncing .warp directory to Warp Drive..."
echo "📂 Source: $WARP_DIR"
echo "📁 Target: $WARP_DRIVE_DIR"
echo "📋 Repository: $REPO_NAME"

# Ensure Warp Drive directories exist
mkdir -p "$WARP_DRIVE_DIR/workflows"
mkdir -p "$WARP_DRIVE_DIR/notebooks"  
mkdir -p "$WARP_DRIVE_DIR/scripts"
mkdir -p "$WARP_DRIVE_DIR/agent-knowledge"

# Sync workflows
if [ -d "$WARP_DIR/workflows" ]; then
    echo "📋 Syncing workflows..."
    for workflow in "$WARP_DIR/workflows"/*.yaml; do
        if [ -f "$workflow" ]; then
            filename=$(basename "$workflow")
            # Prefix with repo name to avoid conflicts
            target="$WARP_DRIVE_DIR/workflows/${REPO_NAME}_${filename}"
            cp "$workflow" "$target"
            echo "   ✅ $filename -> ${REPO_NAME}_${filename}"
        fi
    done
fi

# Sync notebooks
if [ -d "$WARP_DIR/notebooks" ]; then
    echo "📖 Syncing notebooks..."
    for notebook in "$WARP_DIR/notebooks"/*.md; do
        if [ -f "$notebook" ]; then
            filename=$(basename "$notebook")
            # Prefix with repo name to avoid conflicts
            target="$WARP_DRIVE_DIR/notebooks/${REPO_NAME}_${filename}"
            cp "$notebook" "$target"
            echo "   ✅ $filename -> ${REPO_NAME}_${filename}"
        fi
    done
fi

# Sync scripts
if [ -d "$WARP_DIR/scripts" ]; then
    echo "🔧 Syncing scripts..."
    for script in "$WARP_DIR/scripts"/*.sh; do
        if [ -f "$script" ] && [ "$(basename "$script")" != "sync.sh" ]; then
            filename=$(basename "$script")
            # Prefix with repo name to avoid conflicts
            target="$WARP_DRIVE_DIR/scripts/${REPO_NAME}_${filename}"
            cp "$script" "$target"
            chmod +x "$target"
            echo "   ✅ $filename -> ${REPO_NAME}_${filename}"
        fi
    done
fi

# Update agent knowledge with any new known issues
if [ -f "$WARP_DIR/notebooks/known-issues.md" ]; then
    echo "🧠 Updating AI agent knowledge..."
    # Append repo-specific issues to the main knowledge base
    echo "" >> "$WARP_DRIVE_DIR/agent-knowledge/known-issues.md"
    echo "## Issues from $REPO_NAME repository:" >> "$WARP_DRIVE_DIR/agent-knowledge/known-issues.md"
    echo "" >> "$WARP_DRIVE_DIR/agent-knowledge/known-issues.md"
    cat "$WARP_DIR/notebooks/known-issues.md" >> "$WARP_DRIVE_DIR/agent-knowledge/known-issues.md"
    echo "   ✅ Known issues updated"
fi

# Sync to Warp AI directory if it exists
if [ -d "$HOME/.warp/ai-knowledge" ]; then
    echo "🤖 Syncing to Warp AI..."
    cp "$WARP_DRIVE_DIR/agent-knowledge"/* "$HOME/.warp/ai-knowledge/"
    echo "   ✅ AI knowledge updated"
fi

echo ""
echo "✅ Sync completed successfully!"
echo "🔄 Run 'warp-reload' to refresh your Warp Drive functions"
echo "🤖 AI agent now has access to $REPO_NAME workflows and knowledge"

# Offer to commit changes if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo ""
    echo "💡 Tip: Consider committing these .warp changes:"
    echo "   git add .warp/"
    echo "   git commit -m \"Add Warp Drive configuration\""
fi
