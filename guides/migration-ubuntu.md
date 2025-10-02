# Migration to Ubuntu 24.04 LTS

## Summary

**Changed base image from Debian Bookworm to Ubuntu 24.04 LTS**

## Rationale

### Problem with Debian Bookworm
- Neovim version: **0.7.2** (released 2022)
- Too old for modern Lua plugins
- Missing features from Neovim 0.8+
- Limited lazy.nvim compatibility

### Solution: Ubuntu 24.04 LTS
- Neovim version: **0.9.5+** (released 2024)
- Debian-based (100% compatible)
- Uses APT package manager
- LTS support until April 2029
- Modern packages, stable foundation

## What Changed

### Dockerfile
```diff
- FROM debian:bookworm-slim
+ FROM ubuntu:24.04

+ ENV DEBIAN_FRONTEND=noninteractive

  RUN apt-get update && apt-get install -y \
+     software-properties-common \
      neovim \
      ...
```

### Package Versions

| Package | Debian Bookworm | Ubuntu 24.04 |
|---------|----------------|--------------|
| Neovim | 0.7.2 | 0.9.5+ |
| Python | 3.11 | 3.12 |
| Node.js | 18.x | 20.x |
| Git | 2.39 | 2.43 |

### Compatibility

✅ **Still Debian-based**
- Same APT commands
- Same package naming
- Same directory structure
- Same systemd integration

✅ **Better Neovim support**
- Full lazy.nvim compatibility
- Modern Lua API (vim.loop, vim.diagnostic, etc.)
- Better LSP performance
- Latest Treesitter features
- Up-to-date plugin ecosystem

## Migration Steps

If you have an existing container:

```bash
# Complete teardown
docker-compose down -v
docker system prune -a  # Optional: clean cache

# Rebuild with Ubuntu base
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh

# Verify
nvim --version  # Should show v0.9.5 or higher
```

## Benefits

1. **Modern Neovim**: Access to latest features and plugins
2. **Fast Installation**: Still using APT (no compilation)
3. **Stable Base**: Ubuntu LTS with 5 years support
4. **Debian Compatible**: All Debian commands work
5. **Better Ecosystem**: Newer package versions across the board

## Alternatives Considered

### Option 1: Debian Unstable (Sid)
- ❌ Not stable enough for production use
- ❌ Breaking changes between updates
- ✅ Has Neovim 0.9.x

### Option 2: Debian Backports
- ❌ Neovim not available in bookworm-backports
- ❌ Would need manual repository configuration
- ❌ Not officially supported

### Option 3: Build from Source
- ❌ 10-15 minute build time
- ❌ Requires build dependencies
- ❌ More complex maintenance
- ✅ Latest version (0.10.x)

### **✅ Option 4: Ubuntu 24.04 LTS** (Chosen)
- ✅ Fast APT installation
- ✅ Stable LTS release
- ✅ Modern Neovim (0.9.5+)
- ✅ Debian-based and compatible
- ✅ Well-maintained and supported

## Technical Details

### Ubuntu 24.04 LTS (Noble Numbat)
- **Release Date**: April 2024
- **Support Until**: April 2029
- **Kernel**: 6.8+
- **Base**: Debian Sid (with Ubuntu patches)
- **Philosophy**: Newer packages with stability

### Neovim 0.9.5
- **Release Date**: January 2024
- **Highlights**:
  - Improved LSP performance
  - Better Lua API consistency
  - Enhanced Treesitter support
  - Vim 9.0 patches backported
  - Better plugin compatibility

## Verification

After building, verify the setup:

```bash
# Check base OS
cat /etc/os-release

# Should show:
# NAME="Ubuntu"
# VERSION="24.04 LTS (Noble Numbat)"

# Check Neovim version
nvim --version

# Should show:
# NVIM v0.9.5 or higher

# Check vim-plug
ls ~/.local/share/nvim/site/autoload/plug.vim

# Should exist
```

## No Breaking Changes

All existing functionality remains:
- ✅ All scripts work unchanged
- ✅ `/scripts/setup-neovim.sh` works better
- ✅ AWS CLI configuration unchanged
- ✅ Python/Node.js tools work the same
- ✅ Zsh and tmux configs identical

The change is **purely beneficial** with no downsides.

---

**Migration Date**: October 1, 2025  
**Reason**: Modern Neovim support via APT
