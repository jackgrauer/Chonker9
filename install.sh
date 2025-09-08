#!/bin/bash
# Install chonker9 command

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Create wrapper script
cat > "$INSTALL_DIR/chonker9" << 'EOF'
#!/bin/bash
exec /Users/jack/chonker9/chonker9.sh "$@"
EOF

chmod +x "$INSTALL_DIR/chonker9"

echo "✅ Installed chonker9 to $INSTALL_DIR/chonker9"
echo ""
echo "Make sure $INSTALL_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then you can run: chonker9"