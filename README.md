# AWS CLI Development Environment

**Completely isolated containerized development environment** for AWS AI Practitioner certification preparation with modern terminal-based tooling.

**Base Image:** Alpine Linux (Latest) - Tiny, secure, multi-platform with Neovim 0.11+

**Platform:** Configured for Apple Silicon (ARM) compatibility with platform: linux/amd64

📖 **New to Alpine?** See [guides/alpine-linux-guide.md](guides/alpine-linux-guide.md)

## 🔒 Complete Isolation Model

This environment is designed for **maximum isolation** with no data leakage to the host system:

```
┌─────────────────────────────────────┐
│         HOST SYSTEM                 │
│  (No AWS credentials, no code)      │
│                                     │
│  Only exposed:                      │
│  • Port forwards (localhost only)   │
│  • ./scripts (read-only configs)    │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│      DOCKER CONTAINER               │
│                                     │
│  Working Directory: /git            │
│  AWS Credentials: Docker volume     │
│  All work stays in container        │
│                                     │
│  ⚠️  User responsible for backups   │
└─────────────────────────────────────┘
```

**Key Security Features:**
- ✅ AWS credentials stored ONLY in isolated Docker volume
- ✅ All code and work files stay inside container (`/git` directory)
- ✅ No host directory mounts (except read-only scripts)
- ✅ Port forwarding for development (localhost only)
- ⚠️ **You must manually backup your work** (see Data Persistence section)

## Quick Start

```bash
cd aws-cli-dev
chmod +x setup.sh
./setup.sh
docker-compose up -d
docker-compose exec aws-cli-env zsh
```

You'll start in `/git` directory - your isolated workspace.

## Features

- **AWS CLI v2** - Latest version
- **Python 3** with boto3 and development tools
- **Node.js** with TypeScript support
- **Neovim** - Ready for custom configuration
- **Tmux** - 256-color and UTF-8 support, ready for plugins
- **Zsh + Oh-My-Zsh** - Enhanced shell with UTF-8 locale and AWS region in prompt
- **Independent AWS config** - Isolated in Docker volume (never touches host)
- **Port Mapping** - Common dev/prod ports exposed for web development
- **Complete Isolation** - All work stays in container

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
└── scripts/                        # Setup scripts (mounted read-only)
    ├── setup-neovim.sh            # Neovim IDE setup
    ├── setup-tmux-preview.sh      # Tmux configuration
    └── configure-billing-alerts.sh # AWS billing alerts

Container filesystem:
/git/                               # Your working directory (isolated)
├── (your projects and code here)
/root/.aws/                         # AWS credentials (Docker volume)
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

**Note:** You'll start in `/git` directory - your isolated workspace.

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
- **Docker Volume (`aws-config`)**: AWS credentials survive container restarts
- **Container Filesystem (`/git`)**: Your code survives container restarts BUT NOT container removal

### What Gets Deleted
- Running `docker-compose down -v`: Deletes EVERYTHING (credentials + code)
- Running `docker-compose down` then `docker-compose up`: Keeps credentials, DELETES code
- Removing the container: DELETES all code in `/git`

### How to Backup Your Work

#### Option 1: Copy files from container to host
```bash
# Copy entire /git directory
docker cp ai-practitioner-aws-env:/git ./backup-git

# Copy specific files
docker cp ai-practitioner-aws-env:/git/myproject ./myproject
```

#### Option 2: Commit container to image
```bash
# Save current state as new image
docker commit ai-practitioner-aws-env my-aws-backup:latest

# Later, run from backup
docker run -it my-aws-backup:latest zsh
```

#### Option 3: Backup Docker volume
```bash
# Backup AWS credentials volume
docker run --rm -v aws-cli-dev_aws-config:/data -v $(pwd):/backup alpine tar czf /backup/aws-config-backup.tar.gz -C /data .

# Restore AWS credentials volume
docker run --rm -v aws-cli-dev_aws-config:/data -v $(pwd):/backup alpine tar xzf /backup/aws-config-backup.tar.gz -C /data
```

#### Option 4: Use git inside container
```bash
# Inside container
cd /git/myproject
git init
git remote add origin <your-repo-url>
git add .
git commit -m "Backup"
git push
```

**Recommendation:** Use git repositories for your code and backup the AWS credentials volume periodically.

## Key Features

### Installed Tools
- **AWS CLI** (pip-based installation for ARM compatibility)
- Python 3.12+ (aliased as `python`)
- pip (aliased from `pip3`)
- boto3, pylint, flake8, black, autopep8, pyright
- Node.js 22+ & npm
- TypeScript, ESLint, Prettier
- **Neovim 0.11+** (Latest from Alpine repos with vim-plug pre-installed)
- Tmux (bare installation)
- Git, jq, ripgrep, fd, groff, less
- Zsh with Oh-My-Zsh

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
cd /git
npx create-react-app my-app
cd my-app
npm start
# Access from host: http://localhost:3000

# Inside container - start a Flask app
cd /git
mkdir my-api && cd my-api
# Create app.py with Flask app on port 5000
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
Ensure you've run `aws configure` inside the container. Credentials are stored in the Docker volume, not on the host.

### Scripts not executable
```bash
chmod +x /scripts/*.sh
```

### Want to start fresh
```bash
docker-compose down -v  # Remove everything including volumes
./setup.sh              # Rebuild
```

⚠️ **Warning:** This deletes ALL data including AWS credentials and code!

### Need to recover work after accidental deletion
If you didn't backup, your work is **permanently lost**. Always backup important work using git or `docker cp`.

## Support

See the comprehensive guides in the `/guides` directory for detailed configuration, troubleshooting, and usage instructions.

## Security Best Practices

1. **Never commit AWS credentials** to git repositories
2. **Regularly backup** your `/git` directory and AWS credentials volume
3. **Use IAM roles** with minimal permissions for AWS access
4. **Monitor AWS costs** using the billing alerts script
5. **Keep the container updated** by rebuilding periodically
6. **Use git** for version control of your code inside the container
