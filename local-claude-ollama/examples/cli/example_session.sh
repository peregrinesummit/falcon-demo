#!/bin/bash
# example_session.sh - Demonstrates Claude Code CLI usage with Ollama
# This script shows various CLI patterns (not meant to be run directly)

# ============================================
# Setup
# ============================================

# Source the local config
source ~/.claude-local-config

# Or set environment variables directly
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama

# ============================================
# One-shot Queries
# ============================================

# Simple code generation
claude --model qwen3-coder --print "Write a Python function to calculate fibonacci numbers"

# Code explanation
claude --model qwen3-coder --print "What does this regex do: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

# Complex reasoning with GLM
claude --model glm-4.7-flash --print "Design the database schema for a social media app"

# ============================================
# Working with Files
# ============================================

# Review a single file
claude --model qwen3-coder --print "Review this code for bugs:" < myapp.py

# Generate tests
claude --model qwen3-coder --print "Write pytest tests for:" < utils.py

# Explain code
claude --model qwen3-coder --print "Explain this code in detail:" < complex_algorithm.py

# ============================================
# Git Integration
# ============================================

# Review staged changes
git diff --staged | claude --model qwen3-coder --print "Review these changes for issues"

# Generate commit message
git diff --staged | claude --model qwen3-coder --print "Generate a concise commit message for these changes"

# Explain recent commits
git log -5 --oneline | claude --model qwen3-coder --print "Summarize what these commits do"

# ============================================
# Project Analysis
# ============================================

# Analyze project structure
find . -name "*.py" -type f | head -20 | claude --model qwen3-coder --print "What kind of project is this based on these files?"

# Understand dependencies
cat package.json | claude --model qwen3-coder --print "Explain what this project does based on its dependencies"

# ============================================
# Interactive Session Examples
# ============================================

# Start interactive mode (run manually, not in script)
# claude --model qwen3-coder
#
# Then use these commands:
# > /help
# > /model glm-4.7-flash
# > Read the main.py file and explain its purpose
# > Add error handling to the fetch_data function
# > /clear

echo "This script demonstrates CLI patterns - run commands individually"
