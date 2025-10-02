# Alpine Linux Container Guide

## What is Alpine Linux?

**Alpine Linux** is a security-oriented, lightweight Linux distribution. It's the most popular base image for Docker containers.

### Why Alpine?

- **Neovim 0.10+**: Latest in repositories
- **Tiny**: ~7MB base image
- **Fast**: APK package manager
- **Multi-platform**: ARM64 + x86_64 support

## Package Manager: `apk`

| Task | Debian/Ubuntu | Alpine |
|------|---------------|--------|
| Update | `apt update` | `apk update` |
| Install | `apt install pkg` | `apk add pkg` |
| Remove | `apt remove pkg` | `apk del pkg` |
| Search | `apt search pkg` | `apk search pkg` |

## Common Commands

```bash
# Update & upgrade
apk update && apk upgrade

# Install package
apk add package-name

# Remove package
apk del package-name

# Search
apk search keyword

# List installed
apk list --installed
```

## Everything Else is Identical

✅ Zsh with Oh-My-Zsh (same)  
✅ AWS CLI (same)  
✅ Git, Python, Node.js (same)  
✅ Neovim 0.10+ (works perfectly)  
✅ All your scripts (same)  

**Only difference:** Use `apk` instead of `apt`!
