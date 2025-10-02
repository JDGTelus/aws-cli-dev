# Zsh Prompt Customization Guide

## Current Prompt Format

```
aws-cli-env ➜ ~ 
```

With git:
```
aws-cli-env ➜ ~ (main)
```

With AWS region:
```
aws-cli-env ➜ ~ <us-east-1>
```

With both:
```
aws-cli-env ➜ ~ (main) <us-east-1>
```

## How It Works

The prompt is defined in `~/.zshrc` (line 24):

```bash
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'
```

### Breakdown

1. **`%(?:...)`** - Conditional based on last command exit status
   - If successful (0): Shows green prompt
   - If failed (non-zero): Shows red prompt

2. **`%{$fg_bold[green]%}aws-cli-env ➜ `** - Green colored text
   - `%{...%}` = Color codes (don't count toward cursor position)
   - `$fg_bold[green]` = Bold green color
   - `aws-cli-env ➜ ` = The actual text with one space after ➜

3. **`%{$fg[cyan]%}~ `** - Cyan colored tilde
   - `~` = Always shows tilde (not directory name)
   - One space after `~`

4. **`$(git_prompt_info)`** - Git branch (from Oh-My-Zsh)
   - Shows like `(main)` when in a git repo
   - Empty when not in a git repo

5. **`$(aws_region_prompt)`** - AWS region
   - Custom function defined in `.zshrc`
   - Shows like `<us-east-1>` when region is configured
   - Empty when region is not set

## Customizing the Prompt

### Change Container Name

Edit line 24 in `~/.zshrc`:

```bash
# Change "aws-cli-env" to whatever you want
PROMPT='%(?:%{$fg_bold[green]%}my-name ➜ :%{$fg_bold[red]%}my-name ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'
```

### Show Current Directory Instead of Tilde

Replace `~` with `%c` (directory name) or `%~` (full path):

```bash
# Show just directory name (like "workspace")
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}%c %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'

# Show full path (like "~/git/project")
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}%~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'
```

### Remove Git Info

Remove `$(git_prompt_info)`:

```bash
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(aws_region_prompt)'
```

### Remove AWS Region

Remove `$(aws_region_prompt)`:

```bash
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(git_prompt_info)'
```

### Change Colors

Available colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`

```bash
# Change tilde to yellow
PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[yellow]%}~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'

# Change success color to blue
PROMPT='%(?:%{$fg_bold[blue]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'
```

## Zsh Prompt Codes

Useful codes for customization:

| Code | Meaning |
|------|---------|
| `%~` | Current directory (full path with ~ for home) |
| `%c` | Current directory name only |
| `%/` | Current directory (absolute path) |
| `%n` | Username |
| `%m` | Hostname (short) |
| `%M` | Hostname (full) |
| `%T` | Time (24-hour HH:MM) |
| `%*` | Time (24-hour HH:MM:SS) |
| `%D` | Date (YY-MM-DD) |
| `%?` | Exit code of last command |

## Applying Changes

After editing `~/.zshrc`:

```bash
source ~/.zshrc
```

Or restart your shell.

## Why Theme Files Don't Work

Oh-My-Zsh themes are loaded first, but then `.zshrc` sets a custom `PROMPT` variable which **overrides** the theme.

To use a theme instead:
1. Remove or comment out the `PROMPT=` line in `.zshrc`
2. Change `ZSH_THEME="robbyrussell"` to your desired theme
3. Run `source ~/.zshrc`

Available themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

## Current Setup Location

- **File**: `/root/.zshrc` (or `~/.zshrc`)
- **Line**: 24
- **Custom functions**: Lines 17-22 (`aws_region_prompt`)

## Example: Minimal Prompt

```bash
PROMPT='➜ '
```

Result: `➜ `

## Example: Detailed Prompt

```bash
PROMPT='[%n@%m] %~ $(git_prompt_info)$(aws_region_prompt)
%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$reset_color%}'
```

Result: `[root@container] ~/workspace (main) <us-east-1>
➜ `
