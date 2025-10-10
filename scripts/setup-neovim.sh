#!/bin/bash

set -e

echo "======================================"
echo "  Neovim IDE Setup Script"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
  echo "⚠️  Please don't run as root/sudo"
  exit 1
fi

# Install Neovim if not present
if ! command -v nvim &> /dev/null; then
  echo "📦 Installing Neovim..."
  sudo apt update
  sudo apt install -y neovim
else
  echo "✓ Neovim already installed"
fi

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt install -y git curl build-essential ripgrep fd-find nodejs npm python3-pip

# Install formatters and linters
echo "📦 Installing formatters and linters..."
sudo npm install -g prettier
pip3 install --user black flake8

# Create nvim config directory
echo "📁 Creating Neovim config directory..."
mkdir -p ~/.config/nvim/lua

# Create init.lua
echo "📝 Creating init.lua..."
cat > ~/.config/nvim/init.lua << 'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

require("plugins")
EOF

# Create plugins.lua
echo "📝 Creating plugins.lua..."
cat > ~/.config/nvim/lua/plugins.lua << 'EOF'
return require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        view = {
          width = 30,
        },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "pyright",
          "html",
          "cssls",
          "jsonls",
          "eslint",
          "lua_ls",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = { "ts_ls", "pyright", "html", "cssls", "jsonls", "eslint", "lua_ls" }
      
      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>fm", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          markdown = { "prettier" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "flake8" },
        javascript = { "eslint" },
        typescript = { "eslint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "javascript", "typescript", "python", "html", "css", "json", "lua", "vim", "sql"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
    },
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          globalstatus = true,
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
        },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = "cd app && npm install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown preview" },
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
})
EOF

# Create keymaps guide
echo "📝 Creating KEYMAPS.md..."
cat > ~/.config/nvim/KEYMAPS.md << 'EOF'
# Neovim IDE Quick Reference

Leader key: `<Space>`

## Essential Commands

### File Tree (NvimTree)
- `Ctrl-n` - Toggle file tree
- In NvimTree:
  - `Ctrl-v` - Open in vertical split
  - `Ctrl-x` - Open in horizontal split
  - `Ctrl-t` - Open in new tab
  - `Enter` or `o` - Open file
  - `a` - Create file/folder
  - `d` - Delete
  - `r` - Rename
  - `g?` - Show all keybindings

### Fuzzy Finder (Telescope)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>fb` - Browse buffers
- `<Space>fh` - Help tags
- `<Space>fo` - Recent files

### Window Splits
- `Ctrl-w v` - Vertical split
- `Ctrl-w s` - Horizontal split
- `Ctrl-w h/j/k/l` - Navigate splits
- `Ctrl-w q` - Close split

### LSP (Code Intelligence)
- `gd` - Go to definition
- `K` - Hover documentation
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions
- `<Space>fm` - Format file

### Buffers
- `Tab` - Next buffer
- `Shift-Tab` - Previous buffer

### Comments
- `gcc` - Toggle line comment
- `gc` (visual mode) - Comment selection

### Basic Vim
- `i` - Insert mode
- `Esc` - Normal mode
- `:w` - Save
- `:q` - Quit
- `:wq` - Save and quit
EOF

echo ""
echo "🚀 Installing Neovim plugins..."
echo "   (This may take a few minutes on first run)"
nvim --headless "+Lazy! sync" +qa

echo ""
echo "✅ Setup complete!"
echo ""
echo "======================================"
echo "  Quick Start Guide"
echo "======================================"
echo ""
echo "Launch Neovim:     nvim"
echo "Open file tree:    Ctrl-n"
echo "Find files:        Space + ff"
echo "View all keys:     nvim ~/.config/nvim/KEYMAPS.md"
echo ""
echo "Your config is at: ~/.config/nvim/"
echo ""
echo "Enjoy your new Neovim IDE! 🎉"
echo ""
