# Scripts

## install.sh

Installs Ollama pre-release and pulls GLM-4.7-Flash model. Runs non-interactively by default.

```bash
./install.sh        # Just run it
./install.sh -i     # Interactive mode (prompts for confirmation)
```

### What it does

1. Detects OS (macOS/Linux) and architecture (amd64/arm64)
2. Checks current Ollama version - exits if already at 0.14.3+
3. Fetches latest pre-release tag from GitHub API
4. Downloads the correct archive from GitHub releases
5. Extracts and installs the binary
6. Starts `ollama serve`
7. Pulls `glm-4.7-flash` model (~19GB)

### macOS Symlink Issue

The Ollama desktop app creates a symlink at `/usr/local/bin/ollama` → `/Applications/Ollama.app/Contents/Resources/ollama`.

**Problem**: If you just copy a new binary to `/usr/local/bin/ollama`, it overwrites the symlink target detection, but the symlink still points to the app's old binary.

**Solution**: The script detects symlinks with `[ -L "$path" ]` and removes them with `sudo rm` before installing the standalone binary.

**Important**: After running this script, do NOT open the Ollama.app - it will recreate the symlink. Use `ollama serve` directly.

### GitHub Release Asset Names

Ollama packages releases as archives, not raw binaries:

| OS | Asset Name | Extraction |
|----|------------|------------|
| macOS | `ollama-darwin.tgz` | `tar -xzf` → `ollama` |
| Linux amd64 | `ollama-linux-amd64.tar.zst` | `zstd -d` then `tar -xf` |
| Linux arm64 | `ollama-linux-arm64.tar.zst` | `zstd -d` then `tar -xf` |

There are NO raw binaries like `ollama-darwin` or `ollama-linux-amd64` - those URLs will 404.

### GLM-4.7-Flash Requirements

- **Ollama version**: 0.14.3+ (currently pre-release only)
- **RAM**: 24GB+ recommended
- **Disk**: ~19GB for the model

The model will fail to pull with a 412 error if Ollama version is too old.

### Restoring Previous Version

If you need to restore the Ollama.app version:

```bash
# Remove standalone binary
sudo rm /usr/local/bin/ollama

# Reinstall Ollama.app (it will recreate the symlink)
# Or manually recreate:
sudo ln -s /Applications/Ollama.app/Contents/Resources/ollama /usr/local/bin/ollama
```

---

## setup.sh

Full setup script that installs:
- Ollama (stable release)
- Claude Code CLI
- Default model (qwen3-coder)

Use `install.sh` instead if you specifically need GLM-4.7-Flash.

---

## test-connection.sh

Verifies the Ollama + Claude Code setup is working.

```bash
./test-connection.sh              # Test with default model
./test-connection.sh glm-4.7-flash  # Test with specific model
```

Tests:
1. Ollama server is running
2. Model is available
3. Anthropic API compatibility endpoint works
4. Environment variables are set
5. Streaming works
6. Claude Code CLI is installed
