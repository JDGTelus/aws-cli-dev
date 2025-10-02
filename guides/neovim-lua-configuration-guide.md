# Neovim Lua Configuration Guide

## Overview

Your Neovim setup uses modern Lua configuration instead of the traditional Vimscript `.vimrc`. This provides better performance, type safety, and more powerful configuration options.

## Directory Structure

```
~/.config/nvim/
├── init.lua              # Main configuration entry point
├── lua/
│   └── plugins.lua       # Plugin configuration
└── lazy-lock.json        # Plugin version lock file (auto-generated)
```

## File Breakdown

### `~/.config/nvim/init.lua`

This is the main entry point for your Neovim configuration. It:

1. **Bootstraps lazy.nvim**: Downloads and sets up the plugin manager
2. **Sets basic Vim options**: Tab settings, line numbers, etc.
3. **Configures key mappings**: Leader key and function keys
4. **Loads plugins**: Requires the `plugins.lua` file

```lua
-- Key sections explained:

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Downloads lazy.nvim if not present

-- Basic settings (equivalent to your old .vimrc)
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.tabstop = 2         -- 2 spaces for tabs
vim.opt.number = true       -- Show line numbers

-- Key mappings
vim.g.mapleader = " "       -- Space as leader key
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { silent = true })

-- Load plugins
require("plugins")          -- Loads lua/plugins.lua
```

### `~/.config/nvim/lua/plugins.lua`

This file contains all plugin configurations using lazy.nvim. Each plugin is configured as a table:

```lua
return require("lazy").setup({
  -- Plugin structure:
  {
    "author/plugin-name",           -- GitHub repository
    dependencies = { "other/plugin" }, -- Required plugins
    config = function()             -- Setup function
      require("plugin-name").setup({
        -- Plugin configuration
      })
    end,
    cmd = { "PluginCommand" },      -- Lazy load on command
    ft = { "filetype" },           -- Lazy load on filetype
    keys = { "<leader>key" },      -- Lazy load on keypress
  },
})
```

## Plugin Categories

### Core Functionality
- **nvim-tree.lua**: File explorer (replaces NERDTree)
- **telescope.nvim**: Fuzzy finder (replaces FZF)
- **nvim-lspconfig**: Native LSP support (replaces coc.nvim)
- **mason.nvim**: LSP server management (manual installation)

### Code Intelligence
- **nvim-cmp**: Autocompletion engine
- **LuaSnip**: Snippet engine
- **nvim-treesitter**: Syntax highlighting and parsing

### UI Enhancements
- **lualine.nvim**: Status line
- **bufferline.nvim**: Buffer tabs
- **tokyonight.nvim**: Color scheme

### Development Tools
- **null-ls.nvim**: Formatting and linting
- **gitsigns.nvim**: Git integration
- **vim-dadbod**: Database tools
- **markdown-preview.nvim**: Markdown preview

## Configuration Patterns

### 1. Basic Plugin Setup
```lua
{
  "plugin/name",
  config = function()
    require("plugin").setup()
  end,
}
```

### 2. Plugin with Dependencies
```lua
{
  "main/plugin",
  dependencies = { "required/plugin" },
  config = function()
    require("main").setup({
      option = "value"
    })
  end,
}
```

### 3. Lazy Loading by Command
```lua
{
  "command/plugin",
  cmd = { "PluginCommand" },
  config = function()
    -- Configuration only runs when command is used
  end,
}
```

### 4. Lazy Loading by Filetype
```lua
{
  "filetype/plugin",
  ft = { "javascript", "typescript" },
  config = function()
    -- Only loads for JS/TS files
  end,
}
```

### 5. Key Mapping Setup
```lua
config = function()
  require("plugin").setup()
  
  -- Set key mappings
  vim.keymap.set("n", "<leader>key", ":Command<CR>", { silent = true })
end,
```

## LSP Configuration

The LSP setup uses three main components:

### 1. Mason (Server Management)
```lua
require("mason").setup()
-- Note: Install LSP servers manually using :Mason command
-- mason-lspconfig was removed due to compatibility issues
```

### 2. Server Configuration
```lua
local servers = {
  ts_ls = {},                      -- TypeScript/JavaScript (updated name)
  pyright = {                      -- Custom config
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic"
        }
      }
    }
  },
}
```

### 3. Key Mappings on Attach
```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- More mappings...
  end,
})
```

## Vim Options in Lua

Convert Vimscript options to Lua:

| Vimscript | Lua |
|-----------|-----|
| `set number` | `vim.opt.number = true` |
| `set tabstop=2` | `vim.opt.tabstop = 2` |
| `set expandtab` | `vim.opt.expandtab = true` |
| `set nobackup` | `vim.opt.backup = false` |
| `let g:variable = "value"` | `vim.g.variable = "value"` |

## Key Mapping Syntax

```lua
-- Basic syntax
vim.keymap.set(mode, key, command, options)

-- Examples
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("i", "<Tab>", function() ... end, { silent = true })
vim.keymap.set("v", "gc", ":Comment<CR>", { silent = true })

-- Modes:
-- "n" = normal mode
-- "i" = insert mode  
-- "v" = visual mode
-- "x" = visual block mode
-- "c" = command mode
```

## Autocommands in Lua

```lua
-- Create autocommand
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Create autocommand group
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
  end,
})
```

## Managing Plugins

### Adding New Plugins

1. Add to `~/.config/nvim/lua/plugins.lua`:
```lua
{
  "author/new-plugin",
  config = function()
    require("new-plugin").setup()
  end,
}
```

2. Restart Neovim or run `:Lazy sync`

### Plugin Commands

- `:Lazy` - Open plugin manager UI
- `:Lazy sync` - Update all plugins
- `:Lazy install` - Install missing plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy update` - Update plugins
- `:Lazy restore` - Restore to lockfile versions

### Plugin Loading States

- **Loaded**: Plugin is active and ready
- **Not Loaded**: Plugin is installed but not loaded (lazy loading)
- **Failed**: Plugin failed to load (check `:checkhealth`)

## Debugging Configuration

### Health Checks
```lua
-- Check overall health
:checkhealth

-- Check specific components
:checkhealth nvim-treesitter
:checkhealth mason
:checkhealth telescope
```

### Lua Errors
- Errors appear in `:messages`
- Use `print()` for debugging
- Check syntax with `:lua vim.cmd('syntax on')`

### LSP Debugging
- `:LspInfo` - Show attached LSP servers
- `:LspLog` - View LSP logs
- `:Mason` - Check server installations

## Best Practices

### 1. Modular Configuration
Split large configs into separate files:
```
lua/
├── plugins/
│   ├── lsp.lua
│   ├── completion.lua
│   └── ui.lua
└── config/
    ├── keymaps.lua
    └── options.lua
```

### 2. Lazy Loading
Use lazy loading to improve startup time:
```lua
{
  "heavy/plugin",
  cmd = { "HeavyCommand" },     -- Load on command
  ft = { "python" },            -- Load on filetype
  keys = { "<leader>h" },       -- Load on keypress
}
```

### 3. Error Handling
```lua
local ok, plugin = pcall(require, "plugin")
if not ok then
  vim.notify("Plugin not found: plugin", vim.log.levels.ERROR)
  return
end

plugin.setup()
```

### 4. Performance
- Use lazy loading for non-essential plugins
- Avoid heavy computations in config functions
- Profile startup time with `--startuptime`

## Migration Tips

### From .vimrc to init.lua

1. **Settings**: Convert `set` commands to `vim.opt`
2. **Variables**: Convert `let g:` to `vim.g`
3. **Key mappings**: Use `vim.keymap.set()`
4. **Autocommands**: Use `vim.api.nvim_create_autocmd()`
5. **Plugins**: Migrate to lazy.nvim syntax

### Common Conversions

```lua
-- Old .vimrc
set number
set tabstop=2
let g:variable = "value"
nnoremap <F2> :NERDTreeToggle<CR>

-- New init.lua
vim.opt.number = true
vim.opt.tabstop = 2
vim.g.variable = "value"
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { silent = true })
```

This Lua configuration provides better performance, easier debugging, and more powerful customization options than traditional Vimscript configurations.