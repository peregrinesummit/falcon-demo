#!/bin/bash
# setup.sh - Complete setup script for Claude Code + Ollama locally
# Usage: ./setup.sh [--skip-claude] [--skip-models] [--model MODEL]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
SKIP_CLAUDE=false
SKIP_MODELS=false
DEFAULT_MODEL="qwen3-coder"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-claude)
            SKIP_CLAUDE=true
            shift
            ;;
        --skip-models)
            SKIP_MODELS=true
            shift
            ;;
        --model)
            DEFAULT_MODEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code + Ollama Local Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get OS
get_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        MINGW*|CYGWIN*|MSYS*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

OS=$(get_os)
echo -e "${GREEN}Detected OS:${NC} $OS"

# Step 1: Check prerequisites
echo ""
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "  ${GREEN}✓${NC} Node.js installed: $NODE_VERSION"

    # Check version is 18+
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v\([0-9]*\).*/\1/')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "  ${RED}✗${NC} Node.js 18+ required, you have $NODE_VERSION"
        exit 1
    fi
else
    echo -e "  ${RED}✗${NC} Node.js not found. Please install Node.js 18+"
    echo "    Visit: https://nodejs.org/"
    exit 1
fi

# Check memory
echo ""
echo -e "${YELLOW}Checking system memory...${NC}"
if [ "$OS" = "macos" ]; then
    TOTAL_MEM_GB=$(sysctl -n hw.memsize | awk '{printf "%.0f", $0/1024/1024/1024}')
elif [ "$OS" = "linux" ]; then
    TOTAL_MEM_GB=$(free -g | awk '/^Mem:/{print $2}')
else
    TOTAL_MEM_GB=16  # Assume adequate for Windows
fi

echo -e "  Total RAM: ${TOTAL_MEM_GB}GB"
if [ "$TOTAL_MEM_GB" -lt 16 ]; then
    echo -e "  ${YELLOW}⚠${NC} 16GB+ RAM recommended. You may need smaller models."
fi

# Step 2: Install/Check Ollama
echo ""
echo -e "${YELLOW}Step 2: Setting up Ollama...${NC}"

if command_exists ollama; then
    OLLAMA_VERSION=$(ollama --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo -e "  ${GREEN}✓${NC} Ollama installed: v$OLLAMA_VERSION"
else
    echo -e "  ${YELLOW}Installing Ollama...${NC}"
    if [ "$OS" = "macos" ] || [ "$OS" = "linux" ]; then
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo -e "  ${RED}Please install Ollama manually from https://ollama.com/download${NC}"
        exit 1
    fi
fi

# Check if Ollama server is running
echo ""
echo -e "${YELLOW}Checking Ollama server...${NC}"
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Ollama server is running"
else
    echo -e "  ${YELLOW}Starting Ollama server...${NC}"
    if [ "$OS" = "macos" ]; then
        # On macOS, the Ollama app handles the server
        open -a Ollama 2>/dev/null || ollama serve &
    else
        ollama serve &
    fi
    sleep 3

    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Ollama server started"
    else
        echo -e "  ${RED}✗${NC} Could not start Ollama server"
        echo "    Try running 'ollama serve' manually"
        exit 1
    fi
fi

# Step 3: Pull models
if [ "$SKIP_MODELS" = false ]; then
    echo ""
    echo -e "${YELLOW}Step 3: Pulling models...${NC}"

    echo -e "  Pulling $DEFAULT_MODEL (this may take a while)..."
    ollama pull "$DEFAULT_MODEL"
    echo -e "  ${GREEN}✓${NC} $DEFAULT_MODEL ready"

    # Optionally pull GLM-4.7-Flash if user has enough memory
    if [ "$TOTAL_MEM_GB" -ge 24 ]; then
        echo ""
        read -p "  Pull glm-4.7-flash (19GB, requires 24GB+ RAM)? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  Pulling glm-4.7-flash..."
            ollama pull glm-4.7-flash
            echo -e "  ${GREEN}✓${NC} glm-4.7-flash ready"
        fi
    fi
else
    echo ""
    echo -e "${YELLOW}Step 3: Skipping model pull (--skip-models)${NC}"
fi

# Step 4: Install Claude Code
if [ "$SKIP_CLAUDE" = false ]; then
    echo ""
    echo -e "${YELLOW}Step 4: Installing Claude Code...${NC}"

    if command_exists claude; then
        echo -e "  ${GREEN}✓${NC} Claude Code already installed"
    else
        echo -e "  Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash

        # Reload shell to get claude in PATH
        export PATH="$HOME/.claude/bin:$PATH"

        if command_exists claude; then
            echo -e "  ${GREEN}✓${NC} Claude Code installed"
        else
            echo -e "  ${RED}✗${NC} Claude Code installation may have failed"
            echo "    Try running: curl -fsSL https://claude.ai/install.sh | bash"
        fi
    fi
else
    echo ""
    echo -e "${YELLOW}Step 4: Skipping Claude Code install (--skip-claude)${NC}"
fi

# Step 5: Configure environment
echo ""
echo -e "${YELLOW}Step 5: Configuring environment...${NC}"

# Create a local config file
CONFIG_FILE="$HOME/.claude-local-config"
cat > "$CONFIG_FILE" << 'EOF'
# Claude Code Local Configuration
# Source this file: source ~/.claude-local-config
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
EOF

echo -e "  ${GREEN}✓${NC} Created $CONFIG_FILE"

# Detect shell and offer to add to profile
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        PROFILE="$HOME/.bashrc"
        ;;
    zsh)
        PROFILE="$HOME/.zshrc"
        ;;
    *)
        PROFILE=""
        ;;
esac

if [ -n "$PROFILE" ] && [ -f "$PROFILE" ]; then
    if ! grep -q "claude-local-config" "$PROFILE" 2>/dev/null; then
        echo ""
        read -p "  Add to $PROFILE for permanent config? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo "" >> "$PROFILE"
            echo "# Claude Code local configuration" >> "$PROFILE"
            echo "source ~/.claude-local-config" >> "$PROFILE"
            echo -e "  ${GREEN}✓${NC} Added to $PROFILE"
        fi
    else
        echo -e "  ${GREEN}✓${NC} Already configured in $PROFILE"
    fi
fi

# Apply config for current session
source "$CONFIG_FILE"

# Step 6: Test the setup
echo ""
echo -e "${YELLOW}Step 6: Testing setup...${NC}"

# Test Ollama API
echo -e "  Testing Ollama Anthropic API..."
RESPONSE=$(curl -s http://localhost:11434/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: ollama" \
    -d "{
        \"model\": \"$DEFAULT_MODEL\",
        \"max_tokens\": 50,
        \"messages\": [{\"role\": \"user\", \"content\": \"Say 'Hello from Ollama!' and nothing else.\"}]
    }" 2>&1)

if echo "$RESPONSE" | grep -q "content"; then
    echo -e "  ${GREEN}✓${NC} Ollama Anthropic API working"
else
    echo -e "  ${RED}✗${NC} Ollama API test failed"
    echo "  Response: $RESPONSE"
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "To use Claude Code with local models:"
echo ""
echo -e "  ${YELLOW}source ~/.claude-local-config${NC}"
echo -e "  ${YELLOW}claude --model $DEFAULT_MODEL${NC}"
echo ""
echo -e "Or create an alias in your shell profile:"
echo ""
echo -e "  alias claude-local='source ~/.claude-local-config && claude'"
echo ""
echo -e "Available models:"
ollama list 2>/dev/null | head -10
echo ""
echo -e "For more help, see the docs/ directory."
