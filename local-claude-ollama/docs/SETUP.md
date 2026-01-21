# Complete Setup Guide: Claude Code + Ollama + GLM-4.7-Flash

This guide walks through every step to get Claude Code running locally with Ollama and the GLM-4.7-Flash model.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Install Ollama](#step-1-install-ollama)
3. [Install Ollama Pre-release](#step-2-install-ollama-pre-release-for-glm-47-flash)
4. [Pull Models](#step-3-pull-models)
5. [Install Claude Code](#step-4-install-claude-code)
6. [Configure Environment](#step-5-configure-environment)
7. [Test the Setup](#step-6-test-the-setup)
8. [Usage Examples](#step-7-usage-examples)

---

## System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | macOS 12+, Ubuntu 20.04+, or Windows 11 (WSL2) |
| **RAM** | 16GB (for q4_K_M models) |
| **Storage** | 50GB free space |
| **Node.js** | v18.0.0 or later |

### Recommended for GLM-4.7-Flash

| Component | Recommendation |
|-----------|----------------|
| **RAM** | 32GB+ |
| **GPU** | Apple M1/M2/M3 with 16GB+ unified memory, or NVIDIA GPU with 12GB+ VRAM |
| **Storage** | 100GB+ SSD |

### Check Your System

```bash
# Check available RAM
# macOS
sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}'

# Linux
free -h | grep Mem

# Check Node.js version
node --version  # Should be v18+

# Check disk space
df -h .
```

---

## Step 1: Install Ollama

### macOS

```bash
# Option A: Download from website
# Visit https://ollama.com/download and download the macOS app

# Option B: Using Homebrew
brew install ollama
```

### Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Windows (WSL2)

```powershell
# In PowerShell, ensure WSL2 is installed
wsl --install

# Then in WSL2 Ubuntu
curl -fsSL https://ollama.com/install.sh | sh
```

### Verify Installation

```bash
ollama --version
# Should show: ollama version 0.x.x
```

---

## Step 2: Install Ollama Pre-release (for GLM-4.7-Flash)

GLM-4.7-Flash requires Ollama 0.14.3+, which is currently in pre-release.

### macOS (Download Pre-release)

```bash
# Download the latest pre-release
curl -fsSL https://github.com/ollama/ollama/releases/download/v0.14.3/ollama-darwin -o /tmp/ollama

# Make executable
chmod +x /tmp/ollama

# Replace existing binary (backup first)
sudo mv /usr/local/bin/ollama /usr/local/bin/ollama.backup 2>/dev/null || true
sudo mv /tmp/ollama /usr/local/bin/ollama

# Or for Homebrew installs
# brew install ollama --HEAD
```

### Linux (Download Pre-release)

```bash
# Get the pre-release binary
curl -fsSL https://github.com/ollama/ollama/releases/download/v0.14.3/ollama-linux-amd64 -o /tmp/ollama
chmod +x /tmp/ollama
sudo mv /tmp/ollama /usr/local/bin/ollama
```

### Build from Source (Alternative)

```bash
# Requires Go 1.22+
git clone https://github.com/ollama/ollama.git
cd ollama
git checkout v0.14.3
go generate ./...
go build .
sudo mv ollama /usr/local/bin/
```

### Verify Pre-release Version

```bash
ollama --version
# Should show: ollama version 0.14.3 or later
```

---

## Step 3: Pull Models

### Start Ollama Server

```bash
# Start in background (if not using the app)
ollama serve &

# Or on macOS, just open the Ollama app
```

### Pull Recommended Models

```bash
# Fast, general-purpose coding model (~8GB)
ollama pull qwen3-coder

# GLM-4.7-Flash - excellent for reasoning (~19GB)
ollama pull glm-4.7-flash

# Optional: Higher quality GLM (larger, ~32GB)
ollama pull glm-4.7-flash:q8_0

# Optional: Lightweight reasoning model (~5GB)
ollama pull deepseek-r1:8b
```

### Verify Models

```bash
ollama list
# Should show your pulled models
```

### Test a Model

```bash
# Quick test
ollama run qwen3-coder "Write a hello world in Python"
```

---

## Step 4: Install Claude Code

### macOS / Linux / WSL

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
```

### Verify Installation

```bash
claude --version
```

---

## Step 5: Configure Environment

### Option A: Export Variables (Session)

```bash
# Add to current session
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
```

### Option B: Add to Shell Profile (Permanent)

```bash
# For bash (~/.bashrc or ~/.bash_profile)
echo 'export ANTHROPIC_AUTH_TOKEN=ollama' >> ~/.bashrc
echo 'export ANTHROPIC_BASE_URL=http://localhost:11434' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY=ollama' >> ~/.bashrc
source ~/.bashrc

# For zsh (~/.zshrc)
echo 'export ANTHROPIC_AUTH_TOKEN=ollama' >> ~/.zshrc
echo 'export ANTHROPIC_BASE_URL=http://localhost:11434' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY=ollama' >> ~/.zshrc
source ~/.zshrc
```

### Option C: Create a Wrapper Script

```bash
# Create ~/bin/claude-local
mkdir -p ~/bin
cat > ~/bin/claude-local << 'EOF'
#!/bin/bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
claude "$@"
EOF
chmod +x ~/bin/claude-local

# Add ~/bin to PATH if not already
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## Step 6: Test the Setup

### Test Ollama API

```bash
# Test the Anthropic-compatible endpoint
curl http://localhost:11434/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: ollama" \
  -d '{
    "model": "qwen3-coder",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Say hello!"}]
  }'
```

### Test Claude Code

```bash
# With Qwen (fast)
claude --model qwen3-coder --print "Write a Python function to calculate factorial"

# With GLM-4.7-Flash (requires 0.14.3+)
claude --model glm-4.7-flash --print "Explain recursion with an example"
```

---

## Step 7: Usage Examples

### Basic CLI Usage

```bash
# Interactive mode with a local model
claude --model qwen3-coder

# One-shot query
claude --model glm-4.7-flash --print "What is the time complexity of quicksort?"

# With a specific file
claude --model qwen3-coder "Review this code" < myfile.py
```

### In a Project Directory

```bash
cd /path/to/your/project

# Start interactive session
claude --model glm-4.7-flash

# Then in Claude Code:
# > Read package.json and explain the project structure
# > Find all TODO comments in the codebase
# > Add error handling to the main function
```

### Using Claude Code Features

```bash
# Use slash commands
claude --model qwen3-coder
# > /help
# > /model glm-4.7-flash  (switch models)
# > /clear
```

---

## Memory Requirements by Model

| Model | Quantization | Download | RAM Needed |
|-------|--------------|----------|------------|
| qwen3-coder | Q4_K_M | ~4GB | ~8GB |
| glm-4.7-flash | Q4_K_M | ~19GB | ~24GB |
| glm-4.7-flash:q8_0 | Q8_0 | ~32GB | ~40GB |
| glm-4.7-flash:bf16 | BF16 | ~60GB | ~72GB |
| deepseek-r1:8b | Q4_K_M | ~5GB | ~8GB |

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| "Connection refused" | Ensure `ollama serve` is running |
| "Model not found" | Run `ollama pull <model>` first |
| "Out of memory" | Use smaller quantization or model |
| GLM-4.7 not working | Upgrade to Ollama 0.14.3+ |

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

---

## Next Steps

1. Try the [Python examples](../examples/python/)
2. Try the [JavaScript examples](../examples/javascript/)
3. Explore [CLI examples](../examples/cli/)
4. Read the [blog post](BLOG-POST.md) for more context
