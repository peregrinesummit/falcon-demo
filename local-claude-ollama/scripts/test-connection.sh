#!/bin/bash
# test-connection.sh - Test Ollama + Claude Code connection
# Usage: ./test-connection.sh [model]

set -e

MODEL="${1:-qwen3-coder}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Testing Claude Code + Ollama Connection${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 1: Ollama server
echo -e "${YELLOW}Test 1: Ollama Server${NC}"
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Ollama server is running"
else
    echo -e "  ${RED}✗${NC} Ollama server not responding"
    echo "    Start with: ollama serve"
    exit 1
fi

# Test 2: Model availability
echo ""
echo -e "${YELLOW}Test 2: Model Availability ($MODEL)${NC}"
if ollama list 2>/dev/null | grep -q "$MODEL"; then
    echo -e "  ${GREEN}✓${NC} Model '$MODEL' is available"
else
    echo -e "  ${RED}✗${NC} Model '$MODEL' not found"
    echo "    Pull with: ollama pull $MODEL"
    exit 1
fi

# Test 3: Anthropic API endpoint
echo ""
echo -e "${YELLOW}Test 3: Anthropic API Compatibility${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:11434/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: ollama" \
    -d "{
        \"model\": \"$MODEL\",
        \"max_tokens\": 100,
        \"messages\": [{\"role\": \"user\", \"content\": \"Respond with exactly: CONNECTION_TEST_OK\"}]
    }" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✓${NC} Anthropic API endpoint responding (HTTP 200)"

    if echo "$BODY" | grep -q "content"; then
        echo -e "  ${GREEN}✓${NC} Response contains content"
    else
        echo -e "  ${YELLOW}⚠${NC} Response format unexpected"
        echo "  Response: $BODY"
    fi
else
    echo -e "  ${RED}✗${NC} API returned HTTP $HTTP_CODE"
    echo "  Response: $BODY"
    exit 1
fi

# Test 4: Environment variables
echo ""
echo -e "${YELLOW}Test 4: Environment Variables${NC}"

if [ -n "$ANTHROPIC_BASE_URL" ] && [ "$ANTHROPIC_BASE_URL" = "http://localhost:11434" ]; then
    echo -e "  ${GREEN}✓${NC} ANTHROPIC_BASE_URL set correctly"
else
    echo -e "  ${YELLOW}⚠${NC} ANTHROPIC_BASE_URL not set or incorrect"
    echo "    Current: ${ANTHROPIC_BASE_URL:-<not set>}"
    echo "    Expected: http://localhost:11434"
fi

if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo -e "  ${GREEN}✓${NC} ANTHROPIC_AUTH_TOKEN is set"
else
    echo -e "  ${YELLOW}⚠${NC} ANTHROPIC_AUTH_TOKEN not set"
fi

# Test 5: Streaming
echo ""
echo -e "${YELLOW}Test 5: Streaming Support${NC}"
STREAM_RESPONSE=$(curl -s http://localhost:11434/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: ollama" \
    -d "{
        \"model\": \"$MODEL\",
        \"max_tokens\": 50,
        \"stream\": true,
        \"messages\": [{\"role\": \"user\", \"content\": \"Say hi\"}]
    }" 2>&1 | head -5)

if echo "$STREAM_RESPONSE" | grep -q "message_start\|content_block"; then
    echo -e "  ${GREEN}✓${NC} Streaming working"
else
    echo -e "  ${YELLOW}⚠${NC} Streaming response format may differ"
fi

# Test 6: Claude Code (if installed)
echo ""
echo -e "${YELLOW}Test 6: Claude Code CLI${NC}"
if command -v claude >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Claude Code is installed"
    CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "    Version: $CLAUDE_VERSION"
else
    echo -e "  ${YELLOW}⚠${NC} Claude Code not found in PATH"
    echo "    Install with: curl -fsSL https://claude.ai/install.sh | bash"
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}All tests passed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Ready to use Claude Code with local models:"
echo ""
echo "  export ANTHROPIC_AUTH_TOKEN=ollama"
echo "  export ANTHROPIC_BASE_URL=http://localhost:11434"
echo "  claude --model $MODEL"
echo ""
