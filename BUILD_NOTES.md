# Build Notes

## Base Image

**Base:** `archlinux:latest` (Rolling Release)

We use Arch Linux for the latest stable packages, including Neovim 0.10+.

**Why Arch Linux?**
- Rolling release (always latest stable packages)
- Neovim 0.10+ in official repositories
- Lightweight base image (~150MB)
- Fast package manager (pacman)
- Excellent documentation (Arch Wiki)
- Python 3.12, Node 22.x, latest everything

## Architecture Compatibility

This Docker image is built to support both **x86_64** and **ARM64** (Apple Silicon) architectures.

**Important:** The host chipset (x86_64 or ARM64) does NOT affect the container. Docker automatically handles cross-platform builds. All software is installed via pacman inside the container for the container's architecture.

### Neovim Installation

**Version:** Arch Linux (0.10.2+)

**Installation Method:** pacman (Arch package manager)

We use the Neovim package from Arch's official repositories for the latest stable version.

**Features:**
- ✅ Fast installation (no compilation required)
- ✅ Works on all architectures supported by Arch
- ✅ vim-plug pre-installed for `:PlugInstall` compatibility
- ✅ Latest stable version (0.10.2+) with all modern features
- ✅ Full compatibility with lazy.nvim, nvim-lspconfig, and all plugins

**Why 0.10+?**
- Required by modern nvim-lspconfig (v0.10+)
- Latest Lua API improvements
- Best LSP performance and features
- Latest Treesitter integration
- Full compatibility with entire plugin ecosystem

### Build Time Expectations

Total build time: **3-5 minutes** (first build)

Breakdown:
- System packages (including Neovim): ~1-2 minutes
- AWS CLI: ~30 seconds
- Python packages: ~1 minute
- Node.js packages: ~1-2 minutes
- Oh-My-Zsh: ~30 seconds

Subsequent builds with Docker layer caching will be much faster (~30 seconds) if only configuration files change.

## Troubleshooting

### qemu-x86_64 Error

If you see:
```
qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory
```

This means you had an old build using x86_64 binaries. Solution:
```bash
docker-compose down -v
docker system prune -a  # Optional: clean all Docker cache
./setup.sh
```

### Package Installation Fails

If package installation fails during container build:

1. Check internet connection
2. Try rebuilding without cache:
   ```bash
   docker-compose build --no-cache
   ```
3. Check Docker has enough disk space

## Platform-Specific Notes

### Apple Silicon (M1/M2/M3)
- Uses native ARM64 Debian base image
- Neovim compiled natively for ARM64
- Optimal performance, no emulation

### Intel x86_64
- Uses native x86_64 Debian base image
- Neovim compiled natively for x86_64
- Standard performance

### Verification

After build, verify Neovim is working:

```bash
docker-compose exec aws-cli-env nvim --version
```

Should show:
```
NVIM v0.10.2 (or higher)
Build type: Release
...
```

And vim-plug should be installed:
```bash
docker-compose exec aws-cli-env ls -la ~/.local/share/nvim/site/autoload/plug.vim
```
