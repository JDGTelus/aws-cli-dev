# AI Practitioner AWS Environment - Usage Guide

## Overview

This containerized environment provides a complete development setup for AWS AI Practitioner certification preparation, featuring AWS CLI v2, Python, Node.js, and a fully configured Neovim IDE.

## Quick Start

### 1. Initial Setup

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Create necessary directories (`workspace/`, `scripts/`)
- Build the Docker container
- Generate billing alert configuration script

### 2. Start the Environment

```bash
docker-compose up -d
```

### 3. Access the Container

```bash
docker-compose exec aws-cli-env bash
```

### 4. Stop the Environment

```bash
docker-compose down
```

## Environment Features

### Installed Tools

- **AWS CLI v2**: Latest version with full AWS service support
- **Python 3**: Aliased to `python` (also includes `pip`)
- **Node.js & npm**: For JavaScript/TypeScript development
- **Neovim**: Configured as complete IDE with LSP support
- **Git**: Version control
- **jq**: JSON processor for AWS CLI output
- **Additional utilities**: curl, unzip, ripgrep, fd-find

### Development Tools

#### Python
- `boto3`: AWS SDK for Python
- `pylint`, `flake8`: Linters
- `black`, `autopep8`: Code formatters
- `pyright`: Language server for Python

#### JavaScript/TypeScript
- `typescript`: TypeScript compiler
- `typescript-language-server`: LSP for TypeScript
- `eslint`: JavaScript/TypeScript linter
- `prettier`: Code formatter
- `vscode-langservers-extracted`: HTML, CSS, JSON LSP

#### CSS
- `stylelint`: CSS linter

## Neovim IDE Configuration

### Plugin Manager

The environment uses `vim-plug` for plugin management. First time you enter Neovim, install plugins:

```vim
:PlugInstall
```

### Installed Plugins

- **LSP Support**: `nvim-lspconfig`, `nvim-cmp` (autocompletion)
- **Syntax Highlighting**: `nvim-treesitter`
- **Linting & Fixing**: `ALE` (Asynchronous Lint Engine)
- **File Navigation**: `telescope.nvim`
- **Git Integration**: `vim-fugitive`
- **Code Editing**: `vim-surround`, `vim-commentary`, `auto-pairs`
- **Theme**: Gruvbox

### Key Bindings

#### Leader Key
Leader key is set to `<Space>`

#### File Navigation (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Browse buffers
- `<leader>fh` - Help tags

#### File Operations
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>x` - Save and quit

#### Window Navigation
- `<C-h>` - Move to left window
- `<C-j>` - Move to bottom window
- `<C-k>` - Move to top window
- `<C-l>` - Move to right window

#### LSP Features
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `gr` - Go to references

#### Insert Mode
- `jk` - Exit insert mode (alternative to `<Esc>`)

### Auto-Formatting

Files are automatically formatted on save using:
- **Python**: black
- **JavaScript/TypeScript**: prettier + eslint
- **CSS**: prettier
- **HTML**: prettier
- **JSON**: prettier

### Linting

Automatic linting is configured for:
- **Python**: pylint, flake8
- **JavaScript**: eslint
- **TypeScript**: eslint, tsserver
- **CSS**: stylelint
- **HTML**: htmlhint

## AWS CLI Usage

### Verify AWS Configuration

```bash
aws sts get-caller-identity
```

### Test Bedrock Access

```bash
aws bedrock list-foundation-models --region us-east-1
```

### Common AWS Commands

#### List SageMaker Domains
```bash
aws sagemaker list-domains --region us-east-1
```

#### List Comprehend Jobs
```bash
aws comprehend list-entities-detection-jobs --region us-east-1
```

#### List Rekognition Collections
```bash
aws rekognition list-collections --region us-east-1
```

#### Check CloudWatch Alarms
```bash
aws cloudwatch describe-alarms --region us-east-1
```

## AWS Credentials Configuration

### Method 1: Mount Local AWS Credentials (Recommended)

The docker-compose.yml is configured to mount `~/.aws:/root/.aws:ro` by default.

### Method 2: Environment Variables

Edit `docker-compose.yml` and add:

```yaml
environment:
  - AWS_ACCESS_KEY_ID=your_access_key
  - AWS_SECRET_ACCESS_KEY=your_secret_key
  - AWS_DEFAULT_REGION=us-east-1
```

### Method 3: Configure Inside Container

```bash
docker-compose exec aws-cli-env bash
aws configure
```

## Working with Python

### Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate
```

### Install Python Packages

```bash
pip install package-name
```

### Run Python Scripts

```bash
python script.py
```

### Example: Using Boto3

```python
import boto3

bedrock = boto3.client('bedrock', region_name='us-east-1')
response = bedrock.list_foundation_models()
print(response)
```

## Working with Node.js

### Initialize Project

```bash
npm init -y
```

### Install Packages

```bash
npm install package-name
```

### Run Scripts

```bash
node script.js
```

## Billing Alerts

Configure billing alerts to avoid unexpected costs:

```bash
/scripts/configure-billing-alerts.sh
```

**Note**: Update `YOUR_ACCOUNT_ID` in the script with your actual AWS account ID.

## File Persistence

The following directories are mounted from your host:
- `./workspace` → `/workspace` (Read/Write)
- `./scripts` → `/scripts` (Read-only)
- `~/.aws` → `/root/.aws` (Read-only)

All work in `/workspace` will persist after container restarts.

## Troubleshooting

### AWS Credentials Not Found

Ensure your `~/.aws/credentials` file exists or environment variables are set.

### Neovim Plugins Not Working

Run `:PlugInstall` inside Neovim to install all plugins.

### LSP Not Working

Install language servers on first use:
```vim
:TSInstall python javascript typescript html css json
```

### Permission Issues

Ensure `setup.sh` and `entrypoint.sh` are executable:
```bash
chmod +x setup.sh entrypoint.sh
```

## Container Management

### Rebuild Container

```bash
docker-compose build --no-cache
docker-compose up -d
```

### View Logs

```bash
docker-compose logs -f
```

### Remove Everything

```bash
docker-compose down -v
docker rmi ai-practitioner-aws-env
```

## Tips and Best Practices

1. **Always use us-east-1 region** for maximum AI service availability
2. **Set up billing alerts** before starting practice
3. **Use workspaces** for organizing different practice areas
4. **Commit code to Git** for version control
5. **Test AWS connectivity** before starting work sessions
6. **Use jq** to parse AWS CLI JSON output: `aws ... | jq .`
7. **Leverage Neovim LSP** for intelligent code completion

## Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [Neovim Documentation](https://neovim.io/doc/)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)

## Support

For issues with the environment setup, check:
1. Docker/Rancher Desktop is running
2. AWS credentials are properly configured
3. Internet connectivity for AWS API calls
4. Sufficient disk space for Docker images

---

**Environment Version**: 1.0  
**Last Updated**: October 2025
