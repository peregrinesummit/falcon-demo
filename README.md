# Claude Code + Ollama Local

Run Claude Code with local LLMs via Ollama. No API keys required.

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

## Quick Start

```bash
./scripts/install.sh
source ~/.claude-local-config
claude --model glm-4.7-flash
```

That's it. The install script handles everything:
- Installs Ollama pre-release (required for GLM-4.7-Flash)
- Pulls the GLM-4.7-Flash model (~19GB)
- Creates the environment config file

## Requirements

- macOS (Apple Silicon) or Linux
- 24GB+ RAM for GLM-4.7-Flash
- Node.js 18+ (for Claude Code)

## How It Works

Ollama 0.14+ includes Anthropic API compatibility. Claude Code talks to Ollama as if it were the Anthropic API:

```
Claude Code  ──▶  http://localhost:11434/v1/messages  ──▶  Ollama  ──▶  Local Model
```

## Models

| Model | RAM | Notes |
|-------|-----|-------|
| `glm-4.7-flash` | 24GB+ | Best for reasoning and tool calling |
| `qwen3-coder` | 8GB+ | Fast, good for general coding |
| `deepseek-r1:8b` | 8GB+ | Lightweight reasoning |

Pull additional models with:
```bash
ollama pull qwen3-coder
```

## Examples

### Python SDK

```bash
pip install anthropic
python examples/python/basic_chat.py
```

### JavaScript SDK

```bash
cd examples/javascript
npm install
npm run basic
```

### CLI One-liners

```bash
# Code generation
claude --model glm-4.7-flash --print "Write a Python quicksort"

# Code review
git diff | claude --model glm-4.7-flash --print "Review these changes"
```

## Limitations

Ollama's Anthropic compatibility doesn't support:
- Token counting
- Prompt caching
- URL-based images (base64 only)
- PDF documents
- Batch API

## Troubleshooting

**"Connection refused"** - Start the server:
```bash
ollama serve
```

**"Model not found"** - Pull it:
```bash
ollama pull glm-4.7-flash
```

**412 error pulling GLM-4.7-Flash** - You need Ollama 0.14.3+:
```bash
./scripts/install.sh
```

## Links

- [Ollama Anthropic Compatibility](https://docs.ollama.com/api/anthropic-compatibility)
- [GLM-4.7-Flash on Ollama](https://ollama.com/library/glm-4.7-flash)
- [Claude Code](https://claude.ai/code)
