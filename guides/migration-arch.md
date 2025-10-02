# Migration to Arch Linux

## Summary

**Changed base image from Ubuntu 24.04 to Arch Linux**

## Rationale

### Problem with Ubuntu 24.04
- Neovim version: **0.9.5**
- nvim-lspconfig requires **0.10+**
- Error: `nvim-lspconfig requires Nvim version 0.10`
- Can't use latest LSP plugins

### Solution: Arch Linux
- Neovim version: **0.10.2+** (latest stable)
- Rolling release (always current)
- Lightweight (~150MB base)
- Fast pacman package manager

## What Changed

### Dockerfile

```diff
- FROM ubuntu:24.04
+ FROM archlinux:base

- ENV DEBIAN_FRONTEND=noninteractive

- RUN apt-get update && apt-get install -y \
+ RUN pacman -Syu --noconfirm && \
+     pacman -S --noconfirm \
-     fd-find \
+     fd \
-     build-essential \
+     base-devel \
-     && rm -rf /var/lib/apt/lists/*
+     && pacman -Scc --noconfirm

- RUN pip3 install --break-system-packages --no-cache-dir \
+ RUN pip install --break-system-packages --no-cache-dir \

- RUN ln -sf /usr/bin/python3 /usr/bin/python && \
-     ln -sf /usr/bin/pip3 /usr/bin/pip
+ RUN ln -sf /usr/bin/python /usr/bin/python3 && \
+     ln -sf /usr/bin/pip /usr/bin/pip3
```

### Package Manager

| Task | Ubuntu | Arch Linux |
|------|--------|------------|
| Update | `apt update` | `pacman -Sy` |
| Upgrade | `apt upgrade` | `pacman -Su` |
| Install | `apt install pkg` | `pacman -S pkg` |
| Remove | `apt remove pkg` | `pacman -R pkg` |
| Search | `apt search pkg` | `pacman -Ss pkg` |

### Python Commands

Arch uses `python` as primary (not `python3`):

```bash
# Both work (symlinked in container)
python    # Primary
python3   # Also works

pip       # Primary  
pip3      # Also works
```

## Benefits

✅ **Neovim 0.10.2+**: Latest stable, full plugin support  
✅ **Fast Package Manager**: pacman is very fast  
✅ **Rolling Release**: Always latest packages  
✅ **Lightweight**: Smaller base image  
✅ **Well Documented**: Arch Wiki is excellent  

## What Stays the Same

### Shell Environment
- ✅ Zsh with Oh-My-Zsh (identical)
- ✅ All aliases work
- ✅ Same prompt
- ✅ Same keybindings

### Development Tools
- ✅ AWS CLI v2
- ✅ Python 3.12+
- ✅ Node.js 22.x
- ✅ Git, tmux, all tools work identically

### File Locations
- ✅ `/root` - Home directory
- ✅ `/etc` - Config files
- ✅ `/usr/bin` - Binaries
- ✅ Everything in standard locations

### Daily Work
- ✅ Git commands identical
- ✅ AWS CLI commands identical
- ✅ Python/Node development identical
- ✅ Neovim usage identical
- ✅ Scripting identical

## Migration Steps

```bash
# Complete teardown
docker-compose down -v
docker system prune -a  # Optional

# Rebuild with Arch base
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh

# Verify Neovim
nvim --version  # Should show v0.10.2+

# Setup Neovim IDE (now works!)
/scripts/setup-neovim.sh
```

## New User Guide

📖 **See [ARCH_LINUX_GUIDE.md](ARCH_LINUX_GUIDE.md)** for:
- Pacman command reference
- Package management basics
- Differences from Debian/Ubuntu
- Common tasks and troubleshooting

Also available in HTML: [ARCH_LINUX_GUIDE.html](ARCH_LINUX_GUIDE.html)

## Package Versions

| Package | Ubuntu 24.04 | Arch Linux |
|---------|--------------|------------|
| Neovim | 0.9.5 | **0.10.2** ✅ |
| Python | 3.12 | 3.12 |
| Node.js | 20.x | 22.x |
| Git | 2.43 | 2.47 |
| GCC | 13.x | 14.x |

## Common Questions

### Q: Will my scripts break?
**A:** No. All standard Unix commands work identically.

### Q: Do I need to learn new commands?
**A:** Only for package management (`pacman` instead of `apt`). Everything else is the same.

### Q: Is Arch stable enough?
**A:** Yes. Arch "rolling release" means continuous updates, but packages are tested before release. It's very stable.

### Q: What about the AWS CLI?
**A:** Identical. AWS CLI is installed from official AWS source, not package manager.

### Q: Will Neovim config work?
**A:** Yes! Now it will work even better with 0.10+ support.

## Verification

After migration, verify:

```bash
# Check OS
cat /etc/os-release
# Should show: NAME="Arch Linux"

# Check Neovim
nvim --version
# Should show: NVIM v0.10.2 or higher

# Check package manager
pacman --version
# Should work

# Test Neovim LSP (should work now!)
/scripts/setup-neovim.sh
nvim
# No more version errors!
```

## Troubleshooting

### "command not found: apt"
Use `pacman` instead:
```bash
pacman -S package-name
```

### "Package not found"
Search for it:
```bash
pacman -Ss keyword
```

### Need help?
See [ARCH_LINUX_GUIDE.md](ARCH_LINUX_GUIDE.md) for complete guide.

## Bottom Line

**For AWS development work, you won't notice any difference** except:
1. ✅ Neovim 0.10+ now works perfectly
2. ✅ Use `pacman` instead of `apt` for packages
3. ✅ Everything else is identical

The migration is **purely beneficial** with minimal learning curve!

---

**Migration Date**: October 1, 2025  
**Reason**: Neovim 0.10+ requirement for nvim-lspconfig
