# Chonker5-TUI Design Document

## Overview

Chonker5-TUI is a terminal-based version of the Chonker5 PDF character matrix viewer and editor. It provides the same core functionality as the GUI version but optimized for terminal environments.

## Architecture

### Core Components

1. **PDF Rendering**
   - Uses PDFium for text extraction (same as GUI)
   - Optional mutool integration for better text layout
   - ASCII art fallback for basic terminals
   - Full image support via ratatui-image (optional)

2. **Character Matrix Engine**
   - Reuses core extraction logic from GUI version
   - Simplified coordinate mapping for terminal grid
   - Preserves spatial relationships of text

3. **TUI Framework**
   - Built on ratatui + crossterm
   - Split-pane interface with adjustable ratio
   - Virtual scrolling for large documents
   - Mouse and keyboard support

4. **Editor Modes**
   - **Normal**: Navigation and commands
   - **Insert**: Direct character editing
   - **Visual**: Block selection for copy/cut/paste

### Key Differences from GUI Version

| Feature | GUI (egui) | TUI (ratatui) |
|---------|-----------|---------------|
| PDF Display | Full raster | ASCII/Image |
| File Selection | Native dialog | Text input |
| Drag & Drop | Mouse drag | Cut/paste |
| Performance | GPU accelerated | Terminal limited |
| Remote Use | Limited | Full SSH support |

### Performance Characteristics

- **Startup**: <100ms (no GPU init)
- **Memory**: ~30MB base + PDF size
- **Rendering**: 60fps in most terminals
- **Network**: Optimized for SSH sessions

### Terminal Compatibility

1. **Full Support** (with images)
   - Kitty
   - WezTerm  
   - iTerm2
   - Alacritty + multiplexer

2. **Basic Support** (ASCII only)
   - Any ANSI terminal
   - Windows Terminal
   - PuTTY
   - tmux/screen

### Data Flow

```
PDF File -> PDFium/mutool -> Character Matrix -> TUI Renderer
                |                    |                |
                v                    v                v
          Text Objects         Editable Grid    Terminal Buffer
```

## Implementation Notes

### Coordinate Mapping

The TUI version uses a simplified coordinate system:
- 1 terminal cell = 1 character
- No sub-character positioning
- Automatic text reflow for narrow terminals

### Optimization Strategies

1. **Differential Rendering**: Only update changed cells
2. **Virtual Scrolling**: Render only visible viewport
3. **Lazy Loading**: Extract pages on demand
4. **Event Batching**: Combine rapid keystrokes

### Future Enhancements

1. **Ferrules Integration**: Add Smart Layout analysis
2. **Export Options**: Save to text/JSON/PDF
3. **Search & Replace**: Find text in matrix
4. **Multi-tab Support**: Multiple PDFs
5. **Syntax Highlighting**: Detect code/tables
6. **Network Mode**: Client/server architecture

## Usage Patterns

### Local Development
```bash
./chonker5-tui document.pdf
# Full local performance
```

### Remote SSH
```bash
ssh server
chonker5-tui document.pdf
# Optimized for latency
```

### Scripting
```bash
chonker5-tui --extract document.pdf | grep "pattern"
# Pipe-friendly output
```

## Build Options

### Minimal Build
```toml
[dependencies]
ratatui = "0.28"
crossterm = "0.28"
pdfium-render = "0.8"
```

### Full Featured
```toml
[features]
images = ["ratatui-image", "image"]
ferrules = ["ferrules-core"]
network = ["tokio", "tonic"]
```