# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Documentation and scripts for running Claude Code with local LLMs via Ollama's Anthropic API compatibility (v0.14.0+). This repo must work out of the box for anyone who clones it.

## Critical Implementation Details

### macOS Ollama.app Symlink Issue

The Ollama desktop app on macOS creates a **symlink** at `/usr/local/bin/ollama` pointing to `/Applications/Ollama.app/Contents/Resources/ollama`. This means:

- You cannot simply replace `/usr/local/bin/ollama` with a new binary - it will just overwrite the symlink
- The script must detect symlinks with `-L` and remove them before installing
- After removing the symlink, install the standalone binary directly to `/usr/local/bin/ollama`
- Do NOT start the Ollama.app after install - use `ollama serve` directly

### GLM-4.7-Flash Requires Pre-release Ollama

GLM-4.7-Flash model requires Ollama 0.14.3+, which may only be available as a GitHub pre-release (not via `ollama.com/install.sh`). The `install.sh` script:

1. Fetches the latest pre-release tag from GitHub API
2. Downloads the correct archive (`ollama-darwin.tgz` for macOS, `ollama-linux-{arch}.tar.zst` for Linux)
3. Extracts the binary (macOS tgz extracts to `/tmp/ollama`, Linux needs zstd)
4. Handles the symlink issue on macOS
5. Starts `ollama serve` directly (not the app)

### GitHub Release Asset Names

Ollama release assets follow this naming:
- macOS: `ollama-darwin.tgz` (universal binary, extracts to `ollama`)
- Linux: `ollama-linux-amd64.tar.zst` or `ollama-linux-arm64.tar.zst`
- NOT raw binaries like `ollama-darwin` - those don't exist

## Repository Structure

```
local-claude-ollama/
├── scripts/
│   ├── install.sh          # Install pre-release Ollama + GLM-4.7-Flash (just run it)
│   ├── setup.sh            # Full setup (Ollama + Claude Code + models)
│   └── test-connection.sh  # Verify setup works
├── examples/
│   ├── python/             # Anthropic SDK examples
│   └── javascript/         # Node.js SDK examples
└── docs/                   # Detailed guides
```

## Key Commands

```bash
# Install pre-release Ollama + pull GLM-4.7-Flash (runs non-interactively)
./scripts/install.sh

# Full setup (includes Claude Code install)
./scripts/setup.sh

# Test the connection
./scripts/test-connection.sh [model]

# Run Python examples
pip install anthropic
python examples/python/basic_chat.py
```

## Required Environment Variables

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
```

## Supported Models

| Model | RAM Needed | Notes |
|-------|------------|-------|
| `qwen3-coder` | ~8GB | Works with stable Ollama |
| `glm-4.7-flash` | ~24GB | Requires Ollama 0.14.3+ (pre-release) |
| `deepseek-r1:8b` | ~8GB | Works with stable Ollama |

## Limitations vs Cloud API

- No token counting endpoint
- No prompt caching
- Images must be base64 (no URLs)
- No PDF/document support
- No batch processing API
