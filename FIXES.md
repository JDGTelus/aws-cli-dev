# Recent Fixes

## Neovim LSP Server Installation

### Issue
The `setup-neovim.sh` script was using deprecated Mason package names that don't work with Neovim 0.11+:
```
"ts_ls" is not a valid package.
"html" is not a valid package.
"cssls" is not a valid package.
"jsonls" is not a valid package.
"eslint" is not a valid package.
"lua_ls" is not a valid package.
```

### Fix
Updated Mason package names to correct format:

**Old (deprecated):**
```bash
nvim --headless "+MasonInstall pyright ts_ls html cssls jsonls eslint lua_ls" +qa
```

**New (correct):**
```bash
nvim --headless "+MasonInstall pyright typescript-language-server html-lsp css-lsp json-lsp eslint-lsp lua-language-server" +qa
```

### Mason Package Names Reference

| Language/Tool | Correct Package Name |
|---------------|---------------------|
| TypeScript | `typescript-language-server` |
| Python | `pyright` |
| HTML | `html-lsp` |
| CSS | `css-lsp` |
| JSON | `json-lsp` |
| ESLint | `eslint-lsp` |
| Lua | `lua-language-server` |

## Zsh Prompt Container Name

### Issue
The custom prompt wasn't showing the container name "aws-cli-env" as expected, even after editing the theme file.

### Fix
Updated `.zshrc` to include container name in the custom PROMPT variable:

**Before:**
```bash
PROMPT='%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)$(aws_region_prompt) '
```

**After:**
```bash
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ ) %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)$(aws_region_prompt) '
```

### Why Theme Edits Don't Work

The `.zshrc` file sets a custom `PROMPT` variable **after** sourcing Oh-My-Zsh, which overrides any theme settings. To customize the prompt:

1. ✅ **Correct**: Edit the `PROMPT` variable in `.zshrc` (line 24)
2. ❌ **Won't work**: Edit theme files (they get overridden)

### Current Prompt Format

```
aws-cli-env ➜ git <us-east-1>
```

Components:
- `aws-cli-env` - Container name
- `➜` - Prompt character (green if last command succeeded, red if failed)
- `git` - Current directory name
- `<us-east-1>` - AWS region (only shows when configured)

When in a git repository:
```
aws-cli-env ➜ my-repo (main) <us-east-1>
```

## Files Updated

1. **scripts/setup-neovim.sh** - Fixed Mason package names
2. **.zshrc** - Added container name to PROMPT

## Verification

After rebuild:

```bash
# Check prompt shows container name
docker-compose exec aws-cli-env zsh
# Should show: aws-cli-env ➜ git

# Run Neovim setup (LSP servers should install without errors)
/scripts/setup-neovim.sh
```

## No Rebuild Needed For

If you only want to update the prompt in an existing container:

```bash
# Enter container
docker-compose exec aws-cli-env zsh

# Edit .zshrc directly
nvim ~/.zshrc
# Change line 24 PROMPT variable

# Reload
source ~/.zshrc
```

## Note on Deprecation Warnings

You may still see this warning:
```
The `require('lspconfig')` "framework" is deprecated, use vim.lsp.config
```

This is a warning from nvim-lspconfig itself and doesn't affect functionality. It will be resolved when nvim-lspconfig updates to v3.0.0.
