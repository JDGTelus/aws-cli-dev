# AWS CLI Development Environment

**Completely isolated containerized development environment** for AWS AI Practitioner certification preparation with modern terminal-based tooling.

**Base Image:** Ubuntu 24.04 LTS - Stable, well-supported, excellent compatibility

**Platform:** Native support for both x86_64 and ARM architectures

📖 **All tools included:** AWS CLI v2, Neovim 0.12-dev, OpenCode, tmux, zsh

## 🔒 Complete Isolation Model

This environment is designed for **maximum isolation** with no data leakage to the host system:

```
┌─────────────────────────────────────┐
│         HOST SYSTEM                 │
│                                     │
│  Shared with container:             │
│  • Port forwards (localhost only)   │
│  • ./workspace → /root/git          │
│  • ./scripts (read-only)            │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│      DOCKER CONTAINER               │
│                                     │
│  Working Directory: /root           │
│  Projects: /root/git (persistent)   │
│  AWS Credentials: Docker volume     │
│  Tools: OpenCode, Neovim, tmux      │
└─────────────────────────────────────┘
```

**Key Features:**
- ✅ AWS credentials stored ONLY in isolated Docker volume
- ✅ Your projects in `/root/git` persist on host (`./workspace`)
- ✅ Read-only scripts mount for setup automation
- ✅ Port forwarding for development (localhost only)
- ✅ OpenCode AI assistant pre-installed

## Quick Start

```bash
cd aws-cli-dev
chmod +x setup.sh
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh
```

You'll start in `/root` directory - your home directory. Your projects go in `/root/git`.

📖 **See [QUICKREF.md](QUICKREF.md) for essential commands and workflows**

## Features

- **AWS CLI v2** - Latest version
- **Python 3** with boto3 and development tools
- **Node.js 20 LTS** with TypeScript support
- **Neovim 0.12-dev** - Latest development version with full LSP support
- **OpenCode** - AI-powered coding assistant
- **Tmux** - 256-color and UTF-8 support, ready for plugins
- **Zsh + Oh-My-Zsh** - Enhanced shell with UTF-8 locale and AWS region in prompt
- **Independent AWS config** - Isolated in Docker volume (never touches host)
- **Port Mapping** - Common dev/prod ports exposed for web development
- **Persistent Workspace** - `/root/git` mounted to host `./workspace`

## Documentation

### Guides (in `/guides` directory)
- `usage_guide.md` - Complete usage instructions
- `neovim-lua-configuration-guide.md` - Comprehensive Neovim setup guide
- `neovim-navigation-manual.md` - Navigation and shortcuts reference

### Setup Guides
- `guides/aws-setup-guide.md` - AWS account and service configuration
- `guides/quick-start.md` - Fast reference guide
- `guides/port-mapping-guide.md` - Port configuration for web development

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
- **Dracula theme** - Beautiful dark theme with powerline
- **256-color support** - Full color range and true color
- **UTF-8 support** - Proper rendering of special characters
- **Mouse support** and vim-like navigation
- **Status bar** with RAM usage and git info

**Note:** The container is pre-configured with UTF-8 locale and tmux terminal settings for full character support.

**Dependencies:** Git is required (pre-installed in container).

### 3. Configure AWS Credentials

The container uses an isolated Docker volume for AWS credentials. Configure inside the container:

```bash
aws configure
```

Or set environment variables in `docker-compose.yml`.

**Important:** AWS credentials are stored ONLY in the Docker volume, never on the host system.

## Directory Structure

```
aws-cli-dev/                        # Host directory
├── Dockerfile                      # Container definition (Ubuntu 24.04)
├── docker-compose.yml              # Container orchestration
├── .zshrc                          # Zsh configuration
├── entrypoint.sh                   # Container startup script
├── setup.sh                        # Initial setup script
├── iam-policy-template.json        # IAM policy for AWS services
├── guides/                         # Documentation
│   ├── usage_guide.md
│   ├── neovim-lua-configuration-guide.md
│   └── neovim-navigation-manual.md
├── scripts/                        # Setup scripts (mounted read-only)
│   ├── setup-neovim.sh            # Neovim IDE setup
│   ├── setup-tmux-preview.sh      # Tmux configuration
│   └── configure-billing-alerts.sh # AWS billing alerts
└── workspace/                      # Your projects (mounted to /root/git)

Container filesystem:
/root/                              # Home directory (working directory)
├── .aws/                           # AWS credentials (Docker volume)
├── .config/                        # Configuration files
│   ├── nvim/                       # Neovim configuration
│   └── opencode/                   # OpenCode configuration
├── git/                            # Your projects (mounted from ./workspace)
└── .zshrc                          # Zsh configuration
/scripts/                           # Setup scripts (read-only mount)
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

**Note:** You'll start in `/root` directory. Your projects are in `/root/git/`.

### Stop the environment
```bash
docker-compose down
```

### Complete teardown (including AWS config volume)
```bash
docker-compose down -v
```

⚠️ **Warning:** This will permanently delete all AWS credentials and any data in the container!

### Rebuild after changes
```bash
docker-compose build --no-cache
docker-compose up -d
```

## Data Persistence & Backups

### What Persists
- **Docker Volume (`aws-config`)**: AWS credentials survive container restarts and removal
- **Host Mount (`./workspace`)**: Your projects in `/root/git` persist on your host machine

### What Gets Deleted
- Running `docker-compose down -v`: Deletes AWS credentials (but keeps `./workspace`)
- Your projects in `/root/git` are always safe (mounted from `./workspace`)

### How to Backup

#### Your Projects (Already Safe!)
Your projects in `/root/git` are automatically saved to `./workspace` on your host machine. No backup needed!

#### AWS Credentials
```bash
# Backup AWS credentials volume
docker run --rm -v aws-cli-dev_aws-config:/data -v $(pwd):/backup ubuntu tar czf /backup/aws-config-backup.tar.gz -C /data .

# Restore AWS credentials volume
docker run --rm -v aws-cli-dev_aws-config:/data -v $(pwd):/backup ubuntu tar xzf /backup/aws-config-backup.tar.gz -C /data
```

#### Using Git (Recommended)
```bash
# Inside container
cd /root/git
git init
git remote add origin <your-repo-url>
git add .
git commit -m "Initial commit"
git push
```

**Recommendation:** Use git for version control. Your files are already persistent in `./workspace`.

## Key Features

### Installed Tools
- **AWS CLI v2** (official binary installation)
- **Python 3.12** (aliased as `python`)
- pip (aliased from `pip3`)
- boto3, pylint, flake8, black, autopep8, pyright, ruff
- **Node.js 20 LTS** & npm
- TypeScript, ESLint, Prettier
- **Neovim 0.12-dev** (Latest from official PPA with vim-plug pre-installed)
- **OpenCode** - AI coding assistant
- **Tmux 3.4** with plugin support
- Git, jq, ripgrep, fd, groff, less
- Zsh with Oh-My-Zsh
- Ubuntu 24.04 LTS base (apt package manager)

### Zsh Features
- **Custom Prompt** - Shows current AWS region when configured
- **UTF-8 Locale** - Full character support (en_US.UTF-8)
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
- `LANG=en_US.UTF-8` - UTF-8 locale support
- `LC_ALL=en_US.UTF-8` - UTF-8 locale support
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
cd /root/git
npx create-react-app my-app
cd my-app
npm start
# Access from host: http://localhost:3000

# Inside container - start a Flask app
cd /root/git
mkdir my-api && cd my-api
# Create app.py with Flask app on port 5000
python app.py
# Access from host: http://localhost:5000

# Use OpenCode AI assistant
opencode
```

## Troubleshooting

### Container won't build
```bash
docker-compose down -v
docker system prune -a
./setup.sh
```

### AWS credentials not working
Ensure you've run `aws configure` inside the container. Credentials are stored in the Docker volume, not on the host.

### Scripts not executable
```bash
chmod +x /scripts/*.sh
```

### Want to start fresh
```bash
docker-compose down -v  # Remove AWS credentials volume
./setup.sh              # Rebuild
```

⚠️ **Warning:** This deletes AWS credentials. Your code in `./workspace` is safe!

## Support

See the comprehensive guides in the `/guides` directory for detailed configuration, troubleshooting, and usage instructions.

## Security Best Practices

1. **Never commit AWS credentials** to git repositories
2. **Use git** for version control of your projects in `./workspace`
3. **Use IAM roles** with minimal permissions for AWS access
4. **Monitor AWS costs** using the billing alerts script
5. **Keep the container updated** by rebuilding periodically
6. **Backup AWS credentials volume** if you need to preserve it
