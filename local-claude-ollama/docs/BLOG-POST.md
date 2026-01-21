# Running Claude Code Locally with Ollama: A Complete Guide

**TL;DR:** You can now run Claude Code (Anthropic's official AI coding assistant) completely locally using Ollama and open-source models like GLM-4.7-Flash. No API keys, no cloud services, no usage limits - just your local machine.

---

## Introduction

Claude Code is Anthropic's powerful CLI tool for AI-assisted software development. It can read your codebase, make edits, run commands, and help you build software faster. But traditionally, it required an Anthropic API subscription.

Starting with **Ollama 0.14.0**, that changed. Ollama now provides native compatibility with the Anthropic Messages API, which means you can point Claude Code at your local Ollama server and use any open-source model you want.

In this guide, I'll walk you through setting everything up from scratch, including the impressive **GLM-4.7-Flash** model that rivals commercial offerings.

## What You'll Get

After following this guide:

- **Claude Code** running on your local machine
- **Ollama** serving models via Anthropic-compatible API
- **GLM-4.7-Flash** or **Qwen3-Coder** as your AI backend
- Complete privacy - no data leaves your machine
- No usage limits or API costs

## Prerequisites

Before we start, ensure you have:

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 16GB | 32GB+ |
| Storage | 30GB free | 100GB+ |
| Node.js | v18+ | v20+ |
| OS | macOS 12+, Ubuntu 20.04+, Windows 11 (WSL2) | Apple Silicon Mac |

Check your system:

```bash
# Check Node.js
node --version

# Check available RAM (macOS)
sysctl -n hw.memsize | awk '{printf "%.0f GB\n", $0/1024/1024/1024}'

# Check disk space
df -h .
```

## Step 1: Install Ollama

Ollama is a fantastic tool for running LLMs locally. Installation is straightforward:

### macOS

```bash
# Option A: Download from ollama.com (recommended)
# Visit https://ollama.com/download

# Option B: Using Homebrew
brew install ollama
```

### Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Verify Installation

```bash
ollama --version
```

## Step 2: Pull a Model

Let's start with **Qwen3-Coder**, a fast model optimized for coding tasks:

```bash
ollama pull qwen3-coder
```

This downloads roughly 4-8GB depending on quantization.

### Want GLM-4.7-Flash?

GLM-4.7-Flash is a powerful 30B-A3B Mixture of Experts model that excels at reasoning and tool calling. However, it requires **Ollama 0.14.3+** (currently pre-release).

```bash
# Check your version first
ollama --version

# If below 0.14.3, upgrade (see Troubleshooting section)

# Pull the model (~19GB download)
ollama pull glm-4.7-flash
```

### Quick Test

```bash
ollama run qwen3-coder "Write a hello world in Python"
```

You should see a streaming response with Python code.

## Step 3: Install Claude Code

Claude Code is Anthropic's official CLI. Install it with:

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash
```

After installation, you may need to restart your terminal or source your profile:

```bash
source ~/.bashrc  # or ~/.zshrc
```

Verify:

```bash
claude --version
```

## Step 4: Configure the Connection

Here's where the magic happens. We need to tell Claude Code to use Ollama instead of Anthropic's servers.

### Set Environment Variables

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
```

The `api_key` can be any value - Ollama accepts but doesn't validate authentication.

### Make it Permanent

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
# Claude Code local configuration
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
```

Then reload:

```bash
source ~/.zshrc  # or ~/.bashrc
```

## Step 5: Test the Setup

Ensure Ollama is running (it usually auto-starts on macOS):

```bash
# Check if running
curl http://localhost:11434/api/tags

# If not running, start it
ollama serve &
```

Now test Claude Code with a local model:

```bash
claude --model qwen3-coder --print "Write a Python function to check if a number is prime"
```

If you see generated code, congratulations! You're running Claude Code locally.

## Using Claude Code

### Interactive Mode

```bash
# Start an interactive session
cd /path/to/your/project
claude --model qwen3-coder
```

In interactive mode, Claude Code can:
- Read and understand your codebase
- Make file edits
- Run shell commands
- Help debug issues

### One-Shot Queries

```bash
# Quick code generation
claude --model qwen3-coder --print "Write a REST API endpoint for user authentication"

# Review code
cat myfile.py | claude --model qwen3-coder --print "Review this code for bugs"

# Generate tests
cat utils.ts | claude --model qwen3-coder --print "Write unit tests for this"
```

### Switch Models On-the-Fly

In interactive mode, use slash commands:

```
/model glm-4.7-flash
```

## Model Comparison

Here's how the recommended models compare:

| Model | Size | Best For | Speed |
|-------|------|----------|-------|
| **qwen3-coder** | ~8GB | Quick code tasks, simple edits | Fast |
| **glm-4.7-flash** | ~19GB | Complex reasoning, tool calling, thorough reviews | Medium |
| **deepseek-r1:8b** | ~5GB | Lightweight reasoning | Very Fast |

### When to Use Each

**Qwen3-Coder:**
- Writing boilerplate code
- Simple bug fixes
- Quick explanations
- When you want fast responses

**GLM-4.7-Flash:**
- Architecture decisions
- Complex code reviews
- Multi-step reasoning
- Tool calling / function use
- When accuracy matters more than speed

## Advanced: Tool Calling

One of the most powerful features is tool calling (function calling). This lets the model use external functions you define.

Here's a Python example:

```python
import anthropic

client = anthropic.Anthropic(
    base_url="http://localhost:11434",
    api_key="ollama",
)

tools = [
    {
        "name": "get_weather",
        "description": "Get weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {"type": "string", "description": "City name"}
            },
            "required": ["location"]
        }
    }
]

response = client.messages.create(
    model="glm-4.7-flash",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in Tokyo?"}]
)
```

GLM-4.7-Flash handles tool calling particularly well.

## What's Supported (and What's Not)

### Supported Features

- Multi-turn conversations
- Streaming responses
- System prompts
- Tool calling / function calling
- Extended thinking
- Vision (base64 images)

### Not Supported

- Token counting endpoint
- Prompt caching
- URL-based images (use base64 instead)
- Batch processing
- PDF documents

## Troubleshooting

### "Connection refused"

Ollama isn't running. Start it:

```bash
ollama serve &
```

### "Model not found"

Pull the model first:

```bash
ollama list  # See what you have
ollama pull qwen3-coder  # Pull what you need
```

### GLM-4.7-Flash Not Working

You need Ollama 0.14.3+. Check version and upgrade if needed:

```bash
ollama --version
curl -fsSL https://ollama.com/install.sh | sh
```

### Out of Memory

Use a smaller quantization:

```bash
# Instead of full precision
ollama pull glm-4.7-flash:q4_K_M  # Smaller, 19GB
```

Or use a smaller model like `qwen3-coder` or `deepseek-r1:8b`.

## Performance Tips

1. **Keep Ollama running** - First request loads the model, which takes time. Keep it running to avoid reload delays.

2. **Pre-warm the model** - Send a simple request before your actual work:
   ```bash
   claude --model qwen3-coder --print "hi"
   ```

3. **Use appropriate model sizes** - Don't use GLM for simple tasks; Qwen is faster.

4. **Monitor memory** - Watch Activity Monitor or `htop` to ensure you're not swapping.

5. **Close other apps** - Large models benefit from available RAM.

## Conclusion

Running Claude Code locally with Ollama is now practical and powerful. You get:

- **Privacy**: Your code never leaves your machine
- **No limits**: No API quotas or rate limits
- **No costs**: Just your electricity bill
- **Model choice**: Use any Ollama-compatible model
- **Offline capable**: Work without internet (after setup)

The combination of Claude Code's excellent UX with open-source models like GLM-4.7-Flash brings enterprise-grade AI coding assistance to anyone with a decent laptop.

Give it a try, and happy coding!

---

## Resources

- [Ollama](https://ollama.com/) - Local LLM runtime
- [Ollama Anthropic API Docs](https://docs.ollama.com/api/anthropic-compatibility)
- [GLM-4.7-Flash on HuggingFace](https://huggingface.co/zai-org/GLM-4.7-Flash)
- [Qwen3-Coder on Ollama](https://ollama.com/library/qwen3-coder)
- [Claude Code](https://claude.ai/code) - Anthropic's CLI

---

*Have questions or issues? Check the [troubleshooting guide](TROUBLESHOOTING.md) or open an issue in the repository.*
