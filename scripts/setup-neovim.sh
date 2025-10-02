#!/usr/bin/env bash

set -e

echo "=================================================="
echo "Neovim Development Environment Setup Script"
echo "=================================================="
echo ""

NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"
SCRIPTS_DIR="$HOME/.scripts"

echo "[1/8] Creating directory structure..."
mkdir -p "$NVIM_CONFIG_DIR/lua"
mkdir -p "$NVIM_DATA_DIR"
mkdir -p "$SCRIPTS_DIR"

echo "[2/8] Installing Python dependencies..."
pip3 install --break-system-packages --user black flake8 pylint autopep8 2>/dev/null || pip install --break-system-packages --user black flake8 pylint autopep8

echo "[3/8] Checking Node.js dependencies..."
echo "Note: Node.js packages are already installed globally in the container"

echo "[4/8] Checking system build dependencies..."
echo "✓ Build tools already installed in container"

echo "[5/8] Writing Neovim configuration files..."

cat > "$NVIM_CONFIG_DIR/init.lua" << 'INITLUA'
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

vim.opt.compatible = false
vim.opt.laststatus = 2
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.ruler = true
vim.opt.number = true
vim.opt.modeline = true
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.wrap = true
vim.opt.hidden = true
vim.opt.encoding = "UTF-8"
vim.opt.background = "dark"
vim.opt.visualbell = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.g.mapleader = " "
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<F4>", ":set number!<CR>", { silent = true })
vim.keymap.set("n", "<C-m>", "<C-w>", { silent = true })

require("plugins")
INITLUA

cat > "$NVIM_CONFIG_DIR/lua/plugins.lua" << 'PLUGINSLUA'
return require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = false,
        update_cwd = false,
        view = {
          adaptive_size = false,
          centralize_selection = false,
          width = 30,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          add_trailing = false,
          group_empty = false,
          highlight_git = false,
          full_name = false,
          highlight_opened_files = "none",
          root_folder_modifier = ":~",
          indent_markers = {
            enable = false,
            icons = {
              corner = "└ ",
              edge = "│ ",
              item = "│ ",
              none = "  ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = {},
          exclude = {},
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 400,
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
        },
        trash = {
          cmd = "trash",
          require_confirm = true,
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
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          layout_config = {
            horizontal = {
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules", ".git", "dist", "build" },
        },
      })
      telescope.load_extension("fzf")
      
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fh", ":Telescope oldfiles<CR>", { silent = true })
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        ["ts_ls"] = {},
        ["pyright"] = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              }
            }
          }
        },
        ["html"] = {},
        ["cssls"] = {},
        ["jsonls"] = {},
        ["eslint"] = {},
        ["lua_ls"] = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { 
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
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
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
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
    config = function()
      vim.g.db_ui_save_location = "~/.config/nvim/db_ui"
      vim.keymap.set("n", "<leader>db", ":DBUI<CR>", { silent = true })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      })
      vim.keymap.set("n", "<F3>", ":BufferLineCycleNext<CR>", { silent = true })
      vim.keymap.set("n", "<S-F3>", ":BufferLineCyclePrev<CR>", { silent = true })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "typescript", "css", "html", "json", "markdown" },
          }),
          null_ls.builtins.formatting.black.with({
            filetypes = { "python" },
          }),
          null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.diagnostics.flake8,
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.py", "*.json", "*.css", "*.html", "*.md" },
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_browserfunc = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
      }
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_combine_preview = 0
      vim.g.mkdp_combine_preview_auto_refresh = 1
      
      vim.api.nvim_create_user_command("MarkdownPreviewW3m", function()
        local file = vim.fn.expand("%:p")
        if vim.fn.fnamemodify(file, ":e") == "md" then
          local temp_html = vim.fn.tempname() .. ".html"
          vim.fn.system(string.format("python3 /home/jd/md_to_html.py '%s' '%s' 'Markdown Preview'", file, temp_html))
          vim.cmd("split")
          vim.cmd("terminal w3m " .. temp_html)
        else
          print("Not a markdown file")
        end
      end, {})

      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { silent = true, desc = "Markdown Preview (Browser)" })
      vim.keymap.set("n", "<leader>mw", ":MarkdownPreviewW3m<CR>", { silent = true, desc = "Markdown Preview (w3m)" })
      vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { silent = true })
      vim.keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", { silent = true })
    end,
    ft = { "markdown" },
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
PLUGINSLUA

echo "[6/8] Writing markdown to HTML converter script..."
cat > "$HOME/md_to_html.py" << 'MDTOHTML'
#!/usr/bin/env python3
import re
import html
import sys

def md_to_html(md_content):
    lines = md_content.split('\n')
    html_lines = []
    in_code_block = False
    
    for line in lines:
        if line.strip().startswith('```'):
            if not in_code_block:
                html_lines.append('<pre><code>')
                in_code_block = True
            else:
                html_lines.append('</code></pre>')
                in_code_block = False
            continue
        
        if in_code_block:
            html_lines.append(html.escape(line))
            continue
        
        if line.startswith('### '):
            html_lines.append(f'<h3>{html.escape(line[4:])}</h3>')
        elif line.startswith('## '):
            html_lines.append(f'<h2>{html.escape(line[3:])}</h2>')
        elif line.startswith('# '):
            html_lines.append(f'<h1>{html.escape(line[2:])}</h1>')
        elif line.startswith('- '):
            html_lines.append(f'<li>{process_inline_formatting(html.escape(line[2:]))}</li>')
        elif '|' in line and line.strip().startswith('|'):
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            if all(cell.strip() in ['', '-', '---', '----', '-----', '------', '-------', '--------'] or cell.strip().startswith('-') for cell in cells):
                continue
            cell_html = ''.join(f'<td>{process_inline_formatting(html.escape(cell))}</td>' for cell in cells)
            html_lines.append(f'<tr>{cell_html}</tr>')
        elif line.strip() == '':
            html_lines.append('<br>')
        else:
            if line.strip():
                html_lines.append(f'<p>{process_inline_formatting(html.escape(line))}</p>')
    
    return '\n'.join(html_lines)

def process_inline_formatting(text):
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    return text

def main():
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else "Document"
    
    with open(input_file, 'r') as f:
        md_content = f.read()
    
    html_content = md_to_html(md_content)
    
    html_content = re.sub(r'(<li>.*?</li>\s*)+', lambda m: f'<ul>{m.group(0)}</ul>', html_content, flags=re.DOTALL)
    
    html_content = re.sub(r'(<tr>.*?</tr>\s*)+', lambda m: f'<table>{m.group(0)}</table>', html_content, flags=re.DOTALL)
    
    full_html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{title}</title>
    <style>
        body {{ font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; line-height: 1.6; }}
        h1, h2, h3 {{ color: #333; margin-top: 30px; }}
        h1 {{ border-bottom: 2px solid #333; padding-bottom: 10px; }}
        code {{ background-color: #f4f4f4; padding: 2px 4px; border-radius: 3px; font-family: monospace; }}
        pre {{ background-color: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }}
        pre code {{ background: none; padding: 0; }}
        table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; font-weight: bold; }}
        ul {{ margin: 10px 0; padding-left: 20px; }}
        li {{ margin: 5px 0; }}
        strong {{ color: #d73027; }}
        p {{ margin: 10px 0; }}
    </style>
</head>
<body>
{html_content}
</body>
</html>'''
    
    with open(output_file, 'w') as f:
        f.write(full_html)
    
    print(f'Successfully converted {input_file} to {output_file}')

if __name__ == '__main__':
    main()
MDTOHTML

chmod +x "$HOME/md_to_html.py"

echo "[7/8] Starting Neovim to install and verify plugins..."
echo "This will bootstrap lazy.nvim and install all plugins..."
echo ""

nvim --headless "+Lazy! sync" +qa 2>&1 | tee /tmp/nvim-setup.log

sleep 2

echo ""
echo "[8/8] Installing LSP servers via Mason..."
nvim --headless "+MasonInstall pyright typescript-language-server html-lsp css-lsp json-lsp eslint-lsp lua-language-server" +qa 2>&1 | tee -a /tmp/nvim-setup.log

sleep 3

echo ""
echo "=================================================="
echo "✓ Setup Complete!"
echo "=================================================="
echo ""
echo "Installed components:"
echo "  • Neovim configuration: $NVIM_CONFIG_DIR"
echo "  • Plugin manager: lazy.nvim"
echo "  • LSP servers via Mason"
echo "  • Python formatters: black, flake8"
echo "  • Node.js formatters: prettier, eslint"
echo "  • Markdown converter: ~/md_to_html.py"
echo ""
echo "Key mappings:"
echo "  <Space> - Leader key"
echo "  <F2>    - Toggle file explorer"
echo "  <F3>    - Next buffer"
echo "  <F4>    - Toggle line numbers"
echo "  <Space>ff - Find files"
echo "  <Space>fg - Live grep"
echo "  <Space>fb - Browse buffers"
echo ""
echo "To complete setup:"
echo "  1. Open Neovim: nvim"
echo "  2. Wait for plugins to finish installing"
echo "  3. Run :checkhealth to verify installation"
echo "  4. Run :Mason to check LSP server status"
echo ""
echo "Setup log saved to: /tmp/nvim-setup.log"
echo "=================================================="
