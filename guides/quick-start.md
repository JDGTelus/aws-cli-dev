# Quick Start Guide

## Build and Run

```bash
cd aws-cli-dev
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh
```

## First Steps Inside Container

### 1. Configure AWS (Required for AWS work)

```bash
aws configure
```

### 2. Setup Neovim IDE (Lua-based)

```bash
/scripts/setup-neovim.sh
```

### 3. Setup Tmux (Optional)

```bash
/scripts/setup-tmux-preview.sh
```

## Quick Reference

### Neovim (after setup-neovim.sh)
- `<Space>` - Leader key
- `<F2>` - Toggle file explorer (nvim-tree)
- `<Leader>ff` - Find files (Telescope)
- `<Leader>fg` - Live grep (Telescope)
- `<Leader>fb` - Browse buffers (Telescope)
- `:Mason` - Manage LSP servers
- `:Lazy` - Manage plugins

### Tmux (after setup)
- `Ctrl+a` - Prefix key
- `Prefix + c` - New window
- `Prefix + "` - Split horizontal
- `Prefix + %` - Split vertical
- `Prefix + h/j/k/l` - Navigate panes
- `Prefix + I` - Install plugins

### Zsh Aliases
- `awswho` - Show AWS identity
- `awsregion` - Show AWS region
- `ll`, `la`, `l` - Better ls
- `gs`, `ga`, `gc` - Git shortcuts

## Useful Commands

```bash
# Check Neovim version (should be 0.10.2+)
nvim --version

# List available LSP servers
nvim --headless "+MasonInstallAll" +qa

# Test AWS connection
aws sts get-caller-identity

# List installed Python packages
pip list

# Check Node.js packages
npm list -g --depth=0
```

## Exposed Ports

Common development ports are mapped to your host:

- **Frontend**: 3000 (React/Next.js), 5173 (Vite), 8080 (Vue)
- **Backend**: 5000 (Flask), 8000 (Django/FastAPI)
- **Node.js**: 3030, 4000 (GraphQL)
- **Databases**: 5432 (PostgreSQL), 3306 (MySQL), 27017 (MongoDB)

**Example:**
```bash
# Start React app in container
cd workspace/my-app && npm run dev
# Access from host: http://localhost:3000
```

## Documentation

- Full docs: `/guides/usage_guide.md`
- Neovim guide: `/guides/neovim-lua-configuration-guide.md`
- AWS setup: `guides/aws-setup-guide.md`
