# Running Claude Code Locally with Ollama

This guide provides complete instructions for running Claude Code with local LLMs via Ollama, including the GLM-4.7-Flash model.

## What This Does

Claude Code is Anthropic's official CLI for AI-assisted coding. By leveraging Ollama's new **Anthropic API compatibility** (v0.14.0+), you can run Claude Code with open-source models completely locally - no API keys or cloud services required.

## Prerequisites

- **macOS** (Apple Silicon recommended) or **Linux**
- **16GB+ RAM** (32GB+ recommended for larger models)
- **Ollama 0.14.3+** (pre-release required for GLM-4.7-Flash)
- **Node.js 18+** (for Claude Code)

## Quick Start

```bash
# 1. Run the setup script
./scripts/setup.sh

# 2. Start Claude Code with a local model
claude --model qwen3-coder

# Or with GLM-4.7-Flash (requires Ollama 0.14.3+)
claude --model glm-4.7-flash
```

## Directory Structure

```
local-claude-ollama/
├── README.md           # This file
├── scripts/
│   ├── setup.sh        # Complete setup script
│   ├── install-ollama-prerelease.sh  # Install Ollama pre-release
│   └── test-connection.sh            # Verify setup
├── examples/
│   ├── python/         # Python SDK examples
│   ├── javascript/     # JavaScript SDK examples
│   └── cli/            # CLI usage examples
└── docs/
    ├── SETUP.md        # Detailed setup guide
    ├── TROUBLESHOOTING.md  # Common issues and fixes
    └── BLOG-POST.md    # Full blog post writeup
```

## Supported Models

| Model | Size | Best For |
|-------|------|----------|
| `qwen3-coder` | ~8GB | General coding, fast responses |
| `glm-4.7-flash` | 19GB | Advanced reasoning, tool calling |
| `glm-4.7-flash:q8_0` | 32GB | Higher quality, more VRAM needed |
| `deepseek-r1:8b` | ~5GB | Lightweight reasoning |

## How It Works

1. **Ollama** runs locally and serves models via HTTP
2. **Anthropic API compatibility** translates Claude Code's API calls to Ollama format
3. **Environment variables** redirect Claude Code to use localhost instead of Anthropic's servers

```
┌─────────────────┐    Anthropic API     ┌─────────────────┐
│   Claude Code   │ ──────────────────── │     Ollama      │
│   (CLI Tool)    │    /v1/messages      │  (Local Server) │
└─────────────────┘                      └─────────────────┘
                                                 │
                                         ┌───────┴───────┐
                                         │  Local Model  │
                                         │ (GLM, Qwen)   │
                                         └───────────────┘
```

## Features Supported

- Multi-turn conversations
- Streaming responses
- System prompts
- Tool calling / function calling
- Extended thinking
- Vision (image input with base64)

## Limitations

- No token counting endpoint
- No prompt caching
- No URL-based images (base64 only)
- No batch processing API
- No PDF document support

## Next Steps

1. Read [SETUP.md](docs/SETUP.md) for detailed installation
2. Run the test scripts to verify your setup
3. Try the examples in `examples/`
4. Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) if you hit issues

## Resources

- [Ollama Anthropic Compatibility Docs](https://docs.ollama.com/api/anthropic-compatibility)
- [Ollama Blog: Claude Code Support](https://ollama.com/blog/claude)
- [GLM-4.7-Flash on Ollama](https://ollama.com/library/glm-4.7-flash)
- [GLM-4.7-Flash on HuggingFace](https://huggingface.co/zai-org/GLM-4.7-Flash)
