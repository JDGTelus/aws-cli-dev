# AWS CLI Development Environment

Complete containerized development environment for AWS AI Practitioner certification preparation.

**Base Image:** Alpine Linux (Latest) - Tiny, secure, multi-platform with Neovim 0.10+

📖 **New to Alpine?** See [guides/alpine-linux-guide.md](guides/alpine-linux-guide.md)

## Quick Start

```bash
cd aws-cli-dev
chmod +x setup.sh
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh
```

## Features

- **AWS CLI v2** - Latest version
- **Python 3** with boto3 and development tools
- **Node.js** with TypeScript support
- **Neovim** - Ready for custom configuration
- **Tmux** - Terminal multiplexer ready for plugins
- **Zsh + Oh-My-Zsh** - Enhanced shell with AWS region in prompt
- **Independent AWS config** - Isolated from host credentials
- **Port Mapping** - Common dev/prod ports exposed for web development

## Documentation

### Guides (in `/guides` directory)
- `usage_guide.md` - Complete usage instructions
- `neovim-lua-configuration-guide.md` - Comprehensive Neovim setup guide
- `neovim-navigation-manual.md` - Navigation and shortcuts reference

### Setup Guides
- `guides/aws-setup-guide.md` - AWS account and service configuration
- `guides/alpine-linux-guide.md` - Alpine Linux basics (apk package manager)
- `guides/quick-start.md` - Fast reference guide
- `guides/port-mapping-guide.md` - Port configuration for web development
- `guides/migration-*.md` - Migration history (historical reference)

## Post-Build Setup

After building and entering the container, you can optionally configure:

### 1. Configure Neovim IDE (Lua-based)

Run the automated setup script to install a complete IDE configuration:

```bash
/scripts/setup-neovim.sh
```

This installs:
- **lazy.nvim** plugin manager
- **LSP servers** (Python, TypeScript, HTML, CSS, JSON, Lua)
- **Autocompletion** with nvim-cmp
- **File explorer** (nvim-tree)
- **Fuzzy finder** (Telescope)
- **Syntax highlighting** (Treesitter)
- **Git integration** (gitsigns)
- **Auto-formatting** on save (prettier, black, eslint)
- **Tokyo Night** dark theme
- **Status line** and buffer tabs

**Dependencies:** All required tools are pre-installed in the container.

### 2. Configure Tmux (Optional)

Run the automated setup script to configure tmux with plugins:

```bash
/scripts/setup-tmux-preview.sh
```

This installs:
- **TPM** (Tmux Plugin Manager)
- **tmux-sensible** - Sensible defaults
- **tmux-resurrect** - Session persistence
- **Dracula theme** - Beautiful dark theme
- **Mouse support** and vim-like navigation
- **Status bar** with RAM usage and git info

**Dependencies:** Git is required (pre-installed in container).

### 3. Configure AWS Credentials

The container uses an isolated Docker volume for AWS credentials. Configure inside the container:

```bash
aws configure
```

Or set environment variables in `docker-compose.yml`.

## Directory Structure

```
aws-cli-dev/
├── Dockerfile                      # Container definition
├── docker-compose.yml              # Container orchestration
├── .zshrc                          # Zsh configuration
├── entrypoint.sh                   # Container startup script
├── setup.sh                        # Initial setup script
├── iam-policy-template.json        # IAM policy for AWS services
├── guides/                         # Documentation
│   ├── usage_guide.md
│   ├── neovim-lua-configuration-guide.md
│   └── neovim-navigation-manual.md
├── scripts/                        # Setup scripts (created by setup.sh)
│   ├── setup-neovim.sh            # Neovim IDE setup
│   ├── setup-tmux-preview.sh      # Tmux configuration
│   └── configure-billing-alerts.sh # AWS billing alerts
└── workspace/                      # Your work files (created by setup.sh)
```

## Container Management

### Start the environment
```bash
docker-compose up -d
```

### Enter the container
```bash
docker-compose exec aws-cli-env zsh
```

**Note:** The service name is `aws-cli-env` (not `aws-dev-env`)

### Stop the environment
```bash
docker-compose down
```

### Complete teardown (including AWS config volume)
```bash
docker-compose down -v
```

### Rebuild after changes
```bash
docker-compose build --no-cache
docker-compose up -d
```

## Key Features

### Installed Tools
- AWS CLI v2
- Python 3 (aliased as `python`)
- pip (aliased from `pip3`)
- boto3, pylint, flake8, black, autopep8, pyright
- Node.js & npm
- TypeScript, ESLint, Prettier
- **Neovim 0.11+** (Latest from Alpine repos with vim-plug pre-installed)
- Tmux (bare installation)
- Git, jq, ripgrep, fd
- Zsh with Oh-My-Zsh

### Zsh Features
- **Custom Prompt** - Shows current AWS region when configured
- **Git Integration** - Branch and status in prompt
- **No Plugin Errors** - Clean startup, no missing dependencies

### Zsh Aliases (pre-configured)
- `awswho` - Check AWS identity
- `awsregion` - Show configured region
- `dc`, `dcu`, `dcd` - Docker compose shortcuts
- `gs`, `ga`, `gc`, `gp`, `gl` - Git shortcuts
- `t`, `ta`, `tn`, `tl` - Tmux shortcuts
- `ll`, `la`, `l` - Enhanced ls commands

### Environment Variables
- `EDITOR=nvim` - Default editor
- `SHELL=/bin/zsh` - Default shell
- `AWS_DEFAULT_REGION=us-east-1` - Default AWS region
- `AWS_DEFAULT_OUTPUT=json` - Default AWS output format

### Exposed Ports

The container exposes common development ports for web applications:

#### Frontend Development
- **3000** - React, Next.js, Vite (default)
- **3001** - Alternative frontend port
- **5173** - Vite development server
- **8080** - Vue.js, alternative dev server
- **4200** - Angular default

#### Backend Development
- **5000** - Flask (default)
- **8000** - Django, FastAPI (default)
- **8001** - Alternative backend port
- **9000** - Alternative backend port

#### Node.js Services
- **3030** - Express alternative
- **4000** - GraphQL/Apollo (default)
- **5001** - Alternative API port

#### Databases (optional)
- **5432** - PostgreSQL
- **3306** - MySQL
- **27017** - MongoDB
- **6379** - Redis

**Usage Example:**
```bash
# Inside container - start a React dev server
cd workspace/my-app
npm run dev
# Access from host: http://localhost:3000

# Inside container - start a Flask app
cd workspace/my-api
python app.py
# Access from host: http://localhost:5000
```

## Troubleshooting

### Container won't build
```bash
docker-compose down -v
docker system prune -a
./setup.sh
```

### AWS credentials not working
Ensure you've run `aws configure` inside the container, not on the host.

### Scripts not executable
```bash
chmod +x /scripts/*.sh
```

### Want to start fresh
```bash
docker-compose down -v  # Remove everything including volumes
rm -rf workspace/*       # Clear workspace
./setup.sh              # Rebuild
```

## Support

See the comprehensive guides in the `/guides` directory for detailed configuration, troubleshooting, and usage instructions.
