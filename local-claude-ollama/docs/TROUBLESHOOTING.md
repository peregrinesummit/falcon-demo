# Troubleshooting Guide: Claude Code + Ollama

This guide covers common issues and their solutions when running Claude Code with Ollama locally.

## Table of Contents

1. [Connection Issues](#connection-issues)
2. [Model Issues](#model-issues)
3. [Memory Problems](#memory-problems)
4. [Performance Issues](#performance-issues)
5. [API Compatibility](#api-compatibility)
6. [Claude Code Specific](#claude-code-specific)
7. [Platform Specific](#platform-specific)

---

## Connection Issues

### "Connection refused" or "ECONNREFUSED"

**Symptom:** Claude Code can't connect to Ollama.

**Solution:**

1. Check if Ollama is running:
   ```bash
   curl http://localhost:11434/api/tags
   ```

2. Start Ollama if not running:
   ```bash
   # macOS - Open the app or:
   ollama serve

   # Linux
   ollama serve &
   ```

3. Verify the port:
   ```bash
   lsof -i :11434
   # Should show ollama process
   ```

### "Network is unreachable"

**Symptom:** Cannot reach localhost:11434.

**Solution:**

1. Check if localhost resolves correctly:
   ```bash
   ping localhost
   ```

2. Try using `127.0.0.1` instead:
   ```bash
   export ANTHROPIC_BASE_URL=http://127.0.0.1:11434
   ```

3. Check firewall settings (Linux):
   ```bash
   sudo ufw status
   sudo ufw allow 11434
   ```

### Connection Timeout

**Symptom:** Requests hang or timeout.

**Solution:**

1. Check Ollama logs:
   ```bash
   # macOS
   cat ~/Library/Logs/Ollama/server.log

   # Linux
   journalctl -u ollama
   ```

2. Restart Ollama:
   ```bash
   pkill ollama
   sleep 2
   ollama serve
   ```

---

## Model Issues

### "Model not found" or "model 'X' not found"

**Symptom:** Requested model doesn't exist.

**Solution:**

1. List available models:
   ```bash
   ollama list
   ```

2. Pull the missing model:
   ```bash
   ollama pull qwen3-coder
   # Or
   ollama pull glm-4.7-flash
   ```

3. Check model name spelling - common mistakes:
   - `glm-4.7-flash` not `glm4.7-flash`
   - `qwen3-coder` not `qwen-3-coder`

### "GLM-4.7-Flash not working"

**Symptom:** GLM-4.7-Flash model fails to load or respond.

**Solution:**

1. Check Ollama version (needs 0.14.3+):
   ```bash
   ollama --version
   ```

2. Upgrade Ollama:
   ```bash
   # See scripts/install-ollama-prerelease.sh
   curl -fsSL https://ollama.com/install.sh | sh
   ```

3. If still on older version, install pre-release:
   ```bash
   ./scripts/install-ollama-prerelease.sh
   ```

### "Model loading slow"

**Symptom:** First request takes very long.

**Solution:**

This is normal! Models need to load into memory on first use.

1. Keep Ollama running to avoid reload
2. Use `ollama run <model>` first to pre-load
3. Consider smaller quantizations for faster loading

---

## Memory Problems

### "Out of memory" or "OOM killed"

**Symptom:** Model crashes during loading or inference.

**Solution:**

1. Check current memory usage:
   ```bash
   # macOS
   top -l 1 | grep PhysMem

   # Linux
   free -h
   ```

2. Use a smaller quantization:
   ```bash
   # Instead of full precision
   ollama pull glm-4.7-flash:q4_K_M  # 19GB vs 60GB
   ```

3. Close other memory-intensive apps

4. Memory requirements by model:

   | Model | Min RAM | Recommended |
   |-------|---------|-------------|
   | qwen3-coder | 8GB | 12GB |
   | glm-4.7-flash | 24GB | 32GB |
   | glm-4.7-flash:q8_0 | 40GB | 48GB |

### "CUDA out of memory" (GPU)

**Symptom:** GPU memory exhausted.

**Solution:**

1. Check GPU memory:
   ```bash
   nvidia-smi
   ```

2. Use smaller quantization or CPU:
   ```bash
   # Force CPU mode
   CUDA_VISIBLE_DEVICES="" ollama serve
   ```

3. Reduce context window in requests:
   ```python
   # Limit max_tokens
   client.messages.create(
       model="qwen3-coder",
       max_tokens=512,  # Smaller value
       ...
   )
   ```

### "Swap usage high"

**Symptom:** System becomes slow, disk thrashing.

**Solution:**

1. Monitor swap:
   ```bash
   # macOS
   sysctl vm.swapusage

   # Linux
   free -h
   ```

2. Use smaller model:
   ```bash
   # Try deepseek-r1:8b (~5GB) instead
   ollama pull deepseek-r1:8b
   ```

---

## Performance Issues

### "Responses are very slow"

**Symptom:** Tokens generate slowly.

**Solution:**

1. Check if using GPU vs CPU:
   ```bash
   # During generation, check GPU usage
   # macOS M-series: Activity Monitor > GPU History
   # NVIDIA: nvidia-smi
   ```

2. Use smaller model:
   ```bash
   ollama run qwen3-coder  # Faster than GLM
   ```

3. Reduce context:
   - Shorter conversation history
   - Smaller system prompts

4. Close background applications

### "First response slow, subsequent fast"

**Symptom:** Initial request takes long, then normal.

This is **expected behavior** - models load into memory on first use.

**Optimization:**
- Keep Ollama running
- Pre-warm with a simple request:
  ```bash
  curl http://localhost:11434/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: ollama" \
    -d '{"model":"qwen3-coder","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}'
  ```

---

## API Compatibility

### "Unsupported feature: cache_control"

**Symptom:** Error about prompt caching.

**Solution:**

Ollama doesn't support prompt caching. Remove `cache_control` from requests.

```python
# Don't use:
# {"type": "text", "text": "...", "cache_control": {...}}

# Use instead:
{"role": "user", "content": "..."}
```

### "Token counting not supported"

**Symptom:** `/v1/messages/count_tokens` fails.

**Solution:**

This endpoint isn't implemented in Ollama. Estimate tokens manually:
- Rough estimate: 1 token ≈ 4 characters (English)
- Or use tiktoken library locally

### "PDF/Document upload failed"

**Symptom:** Document features don't work.

**Solution:**

Ollama's Anthropic API doesn't support PDF documents. Options:
1. Extract text from PDF first
2. Convert to base64 image (for vision models)
3. Use text content directly

### "Image URL not working"

**Symptom:** Images via URL fail.

**Solution:**

Ollama only supports base64 images:

```python
import base64

with open("image.png", "rb") as f:
    image_data = base64.standard_b64encode(f.read()).decode()

messages = [{
    "role": "user",
    "content": [
        {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": image_data}},
        {"type": "text", "text": "What's in this image?"}
    ]
}]
```

---

## Claude Code Specific

### "Environment variables not working"

**Symptom:** Claude Code ignores local config.

**Solution:**

1. Verify variables are set:
   ```bash
   echo $ANTHROPIC_BASE_URL
   # Should show: http://localhost:11434
   ```

2. Set in current shell:
   ```bash
   export ANTHROPIC_AUTH_TOKEN=ollama
   export ANTHROPIC_BASE_URL=http://localhost:11434
   export ANTHROPIC_API_KEY=ollama
   ```

3. Source config file:
   ```bash
   source ~/.claude-local-config
   ```

4. Check for conflicts:
   ```bash
   env | grep -i anthropic
   env | grep -i claude
   ```

### "Claude still using Anthropic API"

**Symptom:** Requests go to api.anthropic.com.

**Solution:**

1. Unset conflicting variables:
   ```bash
   unset ANTHROPIC_API_KEY
   ```

2. Set local config:
   ```bash
   export ANTHROPIC_BASE_URL=http://localhost:11434
   export ANTHROPIC_AUTH_TOKEN=ollama
   ```

3. Explicitly specify model:
   ```bash
   claude --model qwen3-coder
   ```

### "Model switching doesn't work"

**Symptom:** `/model` command fails.

**Solution:**

The model must be available in Ollama:

1. Check available:
   ```bash
   ollama list
   ```

2. Pull if needed:
   ```bash
   ollama pull glm-4.7-flash
   ```

---

## Platform Specific

### macOS Issues

**"Ollama app not responding"**

1. Quit and restart from Applications
2. Or use CLI:
   ```bash
   pkill Ollama
   open -a Ollama
   ```

**"Rosetta translation issues" (Intel Mac)**

Intel Macs should work natively. If issues:
```bash
# Force native binary
arch -x86_64 ollama serve
```

### Linux Issues

**"Permission denied starting ollama"**

```bash
# Add user to ollama group
sudo usermod -aG ollama $USER
# Log out and back in
```

**"Systemd service not starting"**

```bash
# Check status
systemctl status ollama

# View logs
journalctl -u ollama -f

# Restart service
sudo systemctl restart ollama
```

### Windows (WSL2) Issues

**"Cannot connect from Windows"**

Ollama in WSL2 isn't accessible from Windows by default:

```bash
# In WSL2, get IP
hostname -I

# Use that IP instead of localhost
export ANTHROPIC_BASE_URL=http://<WSL_IP>:11434
```

**"WSL2 memory limits"**

Create `.wslconfig` in Windows user folder:
```ini
[wsl2]
memory=16GB
```

Then restart WSL:
```powershell
wsl --shutdown
```

---

## Getting Help

If none of these solutions work:

1. **Check Ollama logs:**
   ```bash
   # macOS
   tail -100 ~/Library/Logs/Ollama/server.log

   # Linux
   journalctl -u ollama -n 100
   ```

2. **Ollama GitHub Issues:**
   https://github.com/ollama/ollama/issues

3. **Claude Code Discussions:**
   https://github.com/anthropics/claude-code/discussions

4. **Run diagnostics:**
   ```bash
   ./scripts/test-connection.sh
   ```
