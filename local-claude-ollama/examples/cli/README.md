# CLI Examples for Claude Code + Ollama

These examples show how to use Claude Code CLI with local Ollama models.

## Setup

First, ensure environment variables are set:

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
```

Or source the config file:

```bash
source ~/.claude-local-config
```

## Basic Usage

### One-shot Queries

```bash
# Simple code generation
claude --model qwen3-coder --print "Write a Python function to sort a list"

# Code explanation
claude --model qwen3-coder --print "Explain this code: $(cat myfile.py)"

# With GLM-4.7-Flash for complex reasoning
claude --model glm-4.7-flash --print "Design a REST API for a todo app"
```

### Interactive Mode

```bash
# Start interactive session
claude --model qwen3-coder

# In a project directory
cd /path/to/project
claude --model glm-4.7-flash
```

### Piping Input

```bash
# Review a file
cat app.py | claude --model qwen3-coder --print "Review this code for bugs"

# Explain git diff
git diff | claude --model qwen3-coder --print "Explain these changes"

# Generate tests from implementation
cat src/utils.ts | claude --model qwen3-coder --print "Write unit tests for this"
```

## Slash Commands

Once in interactive mode, use slash commands:

```
/help                    # Show all commands
/model glm-4.7-flash     # Switch to different model
/clear                   # Clear conversation
/history                 # Show conversation history
```

## Common Workflows

### Code Review

```bash
# Review staged changes
git diff --staged | claude --model qwen3-coder --print "Review these changes"

# Review a PR
gh pr diff 123 | claude --model glm-4.7-flash --print "Review this PR"
```

### Documentation Generation

```bash
# Generate README
claude --model qwen3-coder --print "Generate a README.md for a Node.js project with: $(cat package.json)"

# Document a function
cat utils.py | claude --model qwen3-coder --print "Add docstrings to all functions"
```

### Debugging

```bash
# Explain an error
echo "TypeError: Cannot read property 'foo' of undefined" | \
  claude --model qwen3-coder --print "Explain this error and how to fix it"

# Analyze logs
tail -100 app.log | claude --model glm-4.7-flash --print "Analyze these logs for issues"
```

## Model Selection Guide

| Task | Recommended Model | Why |
|------|-------------------|-----|
| Quick code generation | `qwen3-coder` | Fast, optimized for code |
| Complex reasoning | `glm-4.7-flash` | Better at multi-step thinking |
| Code review | `glm-4.7-flash` | Thorough analysis |
| Simple explanations | `qwen3-coder` | Quick responses |
| Tool calling | `glm-4.7-flash` | Better tool use support |

## Environment Variables Reference

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_BASE_URL` | `http://localhost:11434` | Point to Ollama server |
| `ANTHROPIC_AUTH_TOKEN` | `ollama` | Auth token (any value works) |
| `ANTHROPIC_API_KEY` | `ollama` | API key (any value works) |

## Troubleshooting

### "Connection refused"
Ensure Ollama is running:
```bash
ollama serve
```

### "Model not found"
Pull the model first:
```bash
ollama pull qwen3-coder
```

### Slow responses
- Try a smaller model quantization
- Check available RAM with `top` or Activity Monitor
- Close other memory-intensive applications
