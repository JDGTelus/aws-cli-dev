#!/usr/bin/env bash

set -e

SCRIPT_VERSION="1.0.0"
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
NVIM_DATA_DIR="${HOME}/.local/share/nvim"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}  Neovim Development Environment Setup v${SCRIPT_VERSION}${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}==>${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} ${1}"
}

print_error() {
    echo -e "${RED}ERROR:${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
        DISTRO_VERSION=$DISTRIB_RELEASE
    else
        DISTRO="unknown"
        DISTRO_VERSION="unknown"
    fi
    
    DISTRO=$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]')
    print_step "Detected distribution: ${DISTRO} ${DISTRO_VERSION}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is installed ($(command -v $1))"
        return 0
    else
        print_warning "$1 is not installed"
        return 1
    fi
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_prereqs=()
    
    if ! check_command python3; then
        missing_prereqs+=("python3")
    fi
    
    if ! check_command node; then
        missing_prereqs+=("node")
    fi
    
    if ! check_command npm; then
        missing_prereqs+=("npm")
    fi
    
    if ! check_command pip3; then
        missing_prereqs+=("pip3")
    fi
    
    if [ ${#missing_prereqs[@]} -ne 0 ]; then
        print_error "Missing prerequisites: ${missing_prereqs[*]}"
        print_error "Please install Python 3 and Node.js first"
        exit 1
    fi
    
    print_success "All prerequisites met"
    python3 --version
    node --version
    npm --version
}

install_system_dependencies() {
    print_step "Installing system dependencies..."
    
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop|elementary)
            sudo apt-get update
            sudo apt-get install -y \
                git \
                curl \
                wget \
                build-essential \
                unzip \
                gettext \
                cmake \
                ripgrep \
                fd-find \
                xclip \
                python3-venv \
                python3-dev
            ;;
        
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                PKG_MGR="dnf"
            else
                PKG_MGR="yum"
            fi
            
            sudo $PKG_MGR install -y \
                git \
                curl \
                wget \
                gcc \
                gcc-c++ \
                make \
                unzip \
                gettext \
                cmake \
                ripgrep \
                fd-find \
                xclip \
                python3-devel
            ;;
        
        arch|manjaro|endeavouros)
            sudo pacman -Sy --noconfirm \
                git \
                curl \
                wget \
                base-devel \
                unzip \
                gettext \
                cmake \
                ripgrep \
                fd \
                xclip \
                python
            ;;
        
        opensuse*|sles)
            sudo zypper install -y \
                git \
                curl \
                wget \
                gcc \
                gcc-c++ \
                make \
                unzip \
                gettext-tools \
                cmake \
                ripgrep \
                fd \
                xclip \
                python3-devel
            ;;
        
        *)
            print_warning "Unknown distribution. Attempting to install basic dependencies..."
            print_warning "You may need to manually install: git, curl, wget, build-essential, cmake, ripgrep, fd"
            ;;
    esac
    
    print_success "System dependencies installed"
}

install_neovim() {
    print_step "Installing/Updating Neovim..."
    
    if check_command nvim; then
        CURRENT_NVIM_VERSION=$(nvim --version | head -n1)
        print_warning "Neovim already installed: $CURRENT_NVIM_VERSION"
        
        read -p "Do you want to update to the latest version? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_step "Skipping Neovim installation"
            return 0
        fi
    fi
    
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop|elementary)
            if [[ "$DISTRO_VERSION" =~ ^(22|23|24) ]] || [[ "$DISTRO" == "debian" && "$DISTRO_VERSION" -ge 12 ]]; then
                sudo apt-get install -y neovim
            else
                print_step "Installing Neovim from AppImage for older distribution..."
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                sudo mv nvim.appimage /usr/local/bin/nvim
            fi
            ;;
        
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y neovim
            else
                print_step "Installing Neovim from AppImage..."
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                sudo mv nvim.appimage /usr/local/bin/nvim
            fi
            ;;
        
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm neovim
            ;;
        
        opensuse*|sles)
            sudo zypper install -y neovim
            ;;
        
        *)
            print_step "Installing Neovim from AppImage..."
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
            ;;
    esac
    
    if check_command nvim; then
        nvim --version | head -n1
        print_success "Neovim installed successfully"
    else
        print_error "Neovim installation failed"
        exit 1
    fi
}

install_python_tools() {
    print_step "Installing Python tools for Neovim..."
    
    pip3 install --user --upgrade pip
    
    pip3 install --user \
        pynvim \
        black \
        flake8 \
        autopep8 \
        pylint \
        mypy
    
    print_success "Python tools installed"
    
    print_step "Installed Python tools:"
    pip3 list --user | grep -E "pynvim|black|flake8|autopep8|pylint|mypy" || true
}

install_node_tools() {
    print_step "Installing Node.js tools for Neovim..."
    
    npm install -g \
        neovim \
        prettier \
        eslint \
        @fsouza/prettierd \
        eslint_d \
        typescript \
        typescript-language-server \
        vscode-langservers-extracted \
        yaml-language-server \
        bash-language-server
    
    print_success "Node.js tools installed"
    
    print_step "Installed Node.js tools:"
    npm list -g --depth=0 | grep -E "neovim|prettier|eslint|typescript|language-server" || true
}

backup_existing_config() {
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        BACKUP_DIR="${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Existing Neovim config found. Creating backup at: $BACKUP_DIR"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        print_success "Backup created"
    fi
    
    if [ -d "$NVIM_DATA_DIR" ]; then
        BACKUP_DATA_DIR="${NVIM_DATA_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Existing Neovim data found. Creating backup at: $BACKUP_DATA_DIR"
        mv "$NVIM_DATA_DIR" "$BACKUP_DATA_DIR"
        print_success "Data backup created"
    fi
}

create_nvim_config() {
    print_step "Creating Neovim configuration..."
    
    mkdir -p "$NVIM_CONFIG_DIR/lua"
    
    cat > "$NVIM_CONFIG_DIR/init.lua" << 'INIT_LUA'
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
INIT_LUA

    cat > "$NVIM_CONFIG_DIR/lua/plugins.lua" << 'PLUGINS_LUA'
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

      local servers = {
        ["ts_ls"] = {},
        ["pyright"] = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
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
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
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
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "Format file or range (in visual mode)" })
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
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>l", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
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
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { silent = true })
      vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { silent = true })
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
PLUGINS_LUA

    print_success "Neovim configuration files created"
}

install_plugins() {
    print_step "Installing Neovim plugins..."
    
    print_step "This will open Neovim and automatically install plugins."
    print_step "The window will close automatically when done (may take 1-2 minutes)."
    
    sleep 2
    
    nvim --headless "+Lazy! sync" +qa
    
    print_success "Plugins installed"
}

verify_installation() {
    print_step "Verifying installation..."
    
    echo ""
    echo "=== Verification Report ==="
    echo ""
    
    if command -v nvim &> /dev/null; then
        echo "✓ Neovim: $(nvim --version | head -n1)"
    else
        echo "✗ Neovim: NOT FOUND"
    fi
    
    if command -v python3 &> /dev/null; then
        echo "✓ Python: $(python3 --version)"
    else
        echo "✗ Python: NOT FOUND"
    fi
    
    if command -v node &> /dev/null; then
        echo "✓ Node.js: $(node --version)"
    else
        echo "✗ Node.js: NOT FOUND"
    fi
    
    echo ""
    echo "=== Python Tools ==="
    pip3 list --user 2>/dev/null | grep -E "pynvim|black|flake8" || echo "Warning: Some Python tools may be missing"
    
    echo ""
    echo "=== Node.js Tools ==="
    npm list -g --depth=0 2>/dev/null | grep -E "neovim|prettier|eslint" || echo "Warning: Some Node.js tools may be missing"
    
    echo ""
    echo "=== Neovim Configuration ==="
    if [ -f "$NVIM_CONFIG_DIR/init.lua" ]; then
        echo "✓ init.lua: EXISTS"
    else
        echo "✗ init.lua: NOT FOUND"
    fi
    
    if [ -f "$NVIM_CONFIG_DIR/lua/plugins.lua" ]; then
        echo "✓ plugins.lua: EXISTS"
    else
        echo "✗ plugins.lua: NOT FOUND"
    fi
    
    if [ -d "$NVIM_DATA_DIR/lazy" ]; then
        echo "✓ Lazy.nvim: INSTALLED"
        PLUGIN_COUNT=$(find "$NVIM_DATA_DIR/lazy" -mindepth 1 -maxdepth 1 -type d | wc -l)
        echo "  Plugins installed: $PLUGIN_COUNT"
    else
        echo "✗ Lazy.nvim: NOT FOUND"
    fi
}

print_completion_message() {
    echo ""
    echo -e "${GREEN}================================================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}================================================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Start Neovim:"
    echo "   $ nvim"
    echo ""
    echo "2. Check plugin status:"
    echo "   :Lazy"
    echo ""
    echo "3. Check LSP servers:"
    echo "   :Mason"
    echo ""
    echo "4. Useful keybindings:"
    echo "   Leader key: SPACE"
    echo "   F2          - Toggle file tree"
    echo "   F3          - Next buffer"
    echo "   F4          - Toggle line numbers"
    echo "   <leader>ff  - Find files"
    echo "   <leader>fg  - Live grep"
    echo "   <leader>f   - Format code"
    echo "   <leader>l   - Lint code"
    echo "   gd          - Go to definition"
    echo "   K           - Show hover documentation"
    echo ""
    echo "For more information, see ~/.config/nvim/"
    echo ""
}

main() {
    print_header
    
    detect_distro
    check_prerequisites
    install_system_dependencies
    install_neovim
    install_python_tools
    install_node_tools
    backup_existing_config
    create_nvim_config
    install_plugins
    verify_installation
    print_completion_message
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
