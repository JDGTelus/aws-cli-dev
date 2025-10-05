# Quick Reference

## Container Access

```bash
# Start container
docker-compose up -d

# Enter container
docker-compose exec aws-cli-env zsh

# Stop container
docker-compose down

# Rebuild
docker-compose build --no-cache && docker-compose up -d
```

## Inside Container

**Working Directory:** `/root` (home directory)  
**Your Projects:** `/root/git` (mounted to `./workspace` on host)  
**Scripts:** `/scripts` (setup automation)

## Directory Structure

```
/root/                  # You start here
├── git/                # Your projects (persists to host)
├── .aws/               # AWS credentials (Docker volume)
├── .config/            # Tool configurations
│   ├── nvim/
│   └── opencode/
└── .zshrc              # Shell configuration
```

## Essential Commands

```bash
# AWS Setup
aws configure                    # Configure AWS credentials
aws sts get-caller-identity      # Test AWS connection
awswho                          # Alias for above
awsregion                       # Show current AWS region

# Development
cd /root/git                    # Go to your projects
opencode                        # Launch AI coding assistant
nvim                            # Launch Neovim

# Setup Scripts
/scripts/setup-neovim.sh        # Install Neovim IDE config
/scripts/setup-tmux-preview.sh  # Install tmux config

# Git shortcuts
gs      # git status
ga      # git add
gc      # git commit
gp      # git push
gl      # git log --oneline --graph --decorate
```

## File Persistence

- **`/root/git`** → Mounted to `./workspace` on host (always persists)
- **`/root/.aws`** → Docker volume (persists across restarts)
- **All other files** → Lost when container is removed

## Tools Installed

- AWS CLI v2
- Python 3.12 (boto3, pylint, black, ruff)
- Node.js 20 LTS (TypeScript, ESLint, Prettier)
- Neovim 0.12-dev
- OpenCode 0.14.3
- Tmux 3.4
- Git 2.43
- Zsh + Oh-My-Zsh

## Prompt Features

Your prompt shows:
- Container name: `aws-cli-env`
- Current directory
- Git branch (if in git repo)
- AWS region (if configured)

Example: `aws-cli-env ➜ ~/git/myproject <us-east-1>`

## Port Mappings

Already exposed to localhost:
- 3000, 3001 - React/Next.js
- 5173 - Vite
- 8080 - Vue.js
- 5000 - Flask
- 8000 - Django/FastAPI
- 4000 - GraphQL
- 5432 - PostgreSQL
- 3306 - MySQL

## Backup

Your projects in `/root/git` are automatically saved to `./workspace`.

To backup AWS credentials:
```bash
docker run --rm -v aws-cli-dev_aws-config:/data -v $(pwd):/backup ubuntu tar czf /backup/aws-config-backup.tar.gz -C /data .
```

## Common Workflows

### Start a new project
```bash
cd /root/git
mkdir myproject && cd myproject
git init
# Your work auto-saves to ./workspace on host
```

### Test AWS services
```bash
# List Bedrock models
aws bedrock list-foundation-models --region us-east-1

# Test Comprehend
aws comprehend detect-sentiment --text "I love this!" --language-code en
```

### Use OpenCode
```bash
opencode
# AI coding assistant in your terminal
```
