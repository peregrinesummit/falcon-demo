#!/bin/bash
# install.sh - Install Ollama pre-release + GLM-4.7-Flash for Claude Code
#
# Usage: ./install.sh [-i]
#   -i    Interactive mode (prompt for confirmation)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REQUIRED_VERSION="0.14.3"
INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive) INTERACTIVE=true; shift ;;
        *) shift ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ollama Pre-release Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS
case "$(uname -s)" in
    Darwin*) OS="macos" ;;
    Linux*) OS="linux" ;;
    *) echo -e "${RED}Unsupported OS${NC}"; exit 1 ;;
esac

# Detect architecture
case "$(uname -m)" in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo -e "${RED}Unsupported architecture: $(uname -m)${NC}"; exit 1 ;;
esac

echo -e "Detected: ${GREEN}$OS-$ARCH${NC}"

version_gte() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Check current version
SKIP_INSTALL=false
if command -v ollama >/dev/null 2>&1; then
    CURRENT_VERSION=$(ollama --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo -e "Current version: ${YELLOW}$CURRENT_VERSION${NC}"
    if version_gte "$CURRENT_VERSION" "$REQUIRED_VERSION"; then
        echo -e "${GREEN}✓${NC} Already at version $REQUIRED_VERSION or later."
        SKIP_INSTALL=true
    fi
fi

if [ "$SKIP_INSTALL" = false ]; then
    # Fetch latest pre-release
    echo -e "${YELLOW}Fetching latest pre-release...${NC}"
    PRERELEASE_TAG=$(curl -s https://api.github.com/repos/ollama/ollama/releases | \
        grep -E '"tag_name":|"prerelease":' | \
        paste - - | \
        grep 'true' | \
        head -1 | \
        grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+-rc[0-9]+' | \
        head -1)

    if [ -z "$PRERELEASE_TAG" ]; then
        echo -e "${RED}Could not find pre-release version${NC}"
        exit 1
    fi

    echo -e "Latest pre-release: ${GREEN}$PRERELEASE_TAG${NC}"

    # Confirm (only in interactive mode)
    if [ "$INTERACTIVE" = true ]; then
        echo ""
        read -p "Install Ollama $PRERELEASE_TAG? [Y/n] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && exit 0
    fi

    # Stop Ollama
    echo -e "${YELLOW}Stopping Ollama...${NC}"
    pkill -x ollama 2>/dev/null || true
    pkill -x Ollama 2>/dev/null || true
    osascript -e 'quit app "Ollama"' 2>/dev/null || true
    sleep 2

    # Download and extract
    if [ "$OS" = "macos" ]; then
        DOWNLOAD_FILE="ollama-darwin.tgz"
        DOWNLOAD_URL="https://github.com/ollama/ollama/releases/download/$PRERELEASE_TAG/$DOWNLOAD_FILE"

        echo -e "${YELLOW}Downloading $DOWNLOAD_FILE...${NC}"
        curl -fSL --progress-bar "$DOWNLOAD_URL" -o "/tmp/$DOWNLOAD_FILE"

        echo -e "${YELLOW}Extracting...${NC}"
        tar -xzf "/tmp/$DOWNLOAD_FILE" -C /tmp

        if [ ! -f /tmp/ollama ]; then
            echo -e "${RED}Extraction failed - ollama binary not found${NC}"
            exit 1
        fi

        chmod +x /tmp/ollama

        # On macOS, the Ollama.app creates a symlink at /usr/local/bin/ollama
        # We need to remove that symlink and install our binary instead
        OLLAMA_PATH="/usr/local/bin/ollama"

        if [ -L "$OLLAMA_PATH" ]; then
            echo -e "${YELLOW}Removing Ollama.app symlink...${NC}"
            sudo rm "$OLLAMA_PATH"
        elif [ -f "$OLLAMA_PATH" ]; then
            echo -e "${YELLOW}Backing up existing binary...${NC}"
            sudo mv "$OLLAMA_PATH" "${OLLAMA_PATH}.backup"
        fi

        echo -e "${YELLOW}Installing to $OLLAMA_PATH...${NC}"
        sudo mv /tmp/ollama "$OLLAMA_PATH"
        rm -f "/tmp/$DOWNLOAD_FILE"

    else
        # Linux
        DOWNLOAD_FILE="ollama-linux-$ARCH.tar.zst"
        DOWNLOAD_URL="https://github.com/ollama/ollama/releases/download/$PRERELEASE_TAG/$DOWNLOAD_FILE"

        echo -e "${YELLOW}Downloading $DOWNLOAD_FILE...${NC}"
        curl -fSL --progress-bar "$DOWNLOAD_URL" -o "/tmp/$DOWNLOAD_FILE"

        if ! command -v zstd >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing zstd...${NC}"
            sudo apt-get install -y zstd 2>/dev/null || sudo yum install -y zstd 2>/dev/null
        fi

        echo -e "${YELLOW}Extracting...${NC}"
        EXTRACT_DIR=$(mktemp -d)
        zstd -d "/tmp/$DOWNLOAD_FILE" -o "/tmp/ollama-linux.tar"
        tar -xf "/tmp/ollama-linux.tar" -C "$EXTRACT_DIR"

        OLLAMA_BIN=$(find "$EXTRACT_DIR" -name "ollama" -type f | head -1)
        chmod +x "$OLLAMA_BIN"

        OLLAMA_PATH="/usr/local/bin/ollama"
        [ -f "$OLLAMA_PATH" ] && sudo mv "$OLLAMA_PATH" "${OLLAMA_PATH}.backup"
        sudo mv "$OLLAMA_BIN" "$OLLAMA_PATH"

        rm -rf "$EXTRACT_DIR" "/tmp/$DOWNLOAD_FILE" "/tmp/ollama-linux.tar"
    fi

    # Verify
    INSTALLED_VERSION=$(ollama --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-rc[0-9]+)?' | head -1)
    echo -e "${GREEN}✓${NC} Installed: ${GREEN}$INSTALLED_VERSION${NC}"
fi

# Ensure server is running
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "${YELLOW}Starting Ollama server...${NC}"
    nohup ollama serve >/dev/null 2>&1 &
    for i in {1..10}; do
        if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Ollama server is running"
            break
        fi
        sleep 1
    done
else
    echo -e "${GREEN}✓${NC} Ollama server is running"
fi

# Pull GLM-4.7-Flash
echo ""
echo -e "${YELLOW}Pulling glm-4.7-flash (this may take a while)...${NC}"
ollama pull glm-4.7-flash

# Create config file
CONFIG_FILE="$HOME/.claude-local-config"
cat > "$CONFIG_FILE" << 'EOF'
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_API_KEY=ollama
EOF
echo -e "${GREEN}✓${NC} Created $CONFIG_FILE"

echo ""
echo -e "${GREEN}Done!${NC} GLM-4.7-Flash is ready to use."
echo ""
echo "Start Claude Code with:"
echo -e "  ${YELLOW}source ~/.claude-local-config && claude --model glm-4.7-flash${NC}"
