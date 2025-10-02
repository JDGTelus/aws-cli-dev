# Recent Changes

## Removed VimScript/vim-plug Support

**Date:** October 1, 2025

### Changes Made

1. **Removed init.vim.example**
   - Deleted VimScript-based configuration file
   - No longer supporting vim-plug plugin manager

2. **Removed vim-plug Installation**
   - Removed vim-plug installation from Dockerfile
   - Container now ships with bare Neovim installation

3. **Updated Documentation**
   - Removed all references to `init.vim.example`
   - Removed vim-plug setup instructions
   - Updated to only reference Lua-based configuration via `/scripts/setup-neovim.sh`

4. **Updated Entrypoint**
   - Removed misleading tips about init.vim.example
   - Now only mentions Lua-based setup script

### Current Neovim Setup

**Only Lua-based configuration is supported:**

```bash
# Inside container
/scripts/setup-neovim.sh
```

This installs:
- **lazy.nvim** (modern Lua plugin manager)
- Full LSP setup
- Lua-based configuration files
- All plugins configured in Lua

### Base Image Change

**Changed from:** Debian Bookworm Slim → **Ubuntu 24.04 LTS**

**Reason:** Ubuntu 24.04 provides newer packages while maintaining Debian compatibility:
- Neovim 0.9.5+ (vs 0.7.2 in Debian Bookworm)
- Still uses APT package manager
- Debian-based and fully compatible
- LTS support until 2029

### Architecture Notes

- Neovim v0.9.5+ installed from Ubuntu APT repositories
- No compilation required - fast installation
- vim-plug pre-installed for `:PlugInstall` support
- Full support for modern Lua plugins (lazy.nvim compatible)
- Build time: ~3-5 minutes (first build only)

### Migration from Old Setup

If you have an old container with `init.vim.example`:

```bash
# Complete teardown
docker-compose down -v

# Rebuild
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh

# Setup Neovim (Lua-based)
/scripts/setup-neovim.sh
```

## Philosophy

- **Lua-first approach**: Modern Neovim configuration uses Lua
- **Container-based builds**: All compilation happens inside container
- **Architecture agnostic**: Works on any platform Docker supports
