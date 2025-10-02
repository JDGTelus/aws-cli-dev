# Neovim Navigation & IDE Features Manual

## Getting Started

Launch Neovim with: `nvim`

First time setup: Open Neovim and let lazy.nvim install all plugins automatically.

## Basic Navigation

### Moving Around
- **h, j, k, l** - Left, Down, Up, Right
- **w** - Jump to next word
- **b** - Jump to previous word  
- **0** - Go to beginning of line
- **$** - Go to end of line
- **gg** - Go to top of file
- **G** - Go to bottom of file
- **Ctrl+u** - Scroll up half page
- **Ctrl+d** - Scroll down half page

### Search & Jump
- **/pattern** - Search forward
- **?pattern** - Search backward  
- **n** - Next search result
- **N** - Previous search result
- **\*** - Search for word under cursor
- **%** - Jump to matching bracket/parenthesis

## File Operations

### File Explorer (nvim-tree)
- **F2** - Toggle file tree
- **Enter** - Open file/folder
- **o** - Open file in split
- **v** - Open file in vertical split  
- **t** - Open file in new tab
- **R** - Refresh tree
- **a** - Create new file/folder
- **d** - Delete file/folder
- **r** - Rename file/folder
- **x** - Cut file/folder
- **c** - Copy file/folder
- **p** - Paste file/folder

### Fuzzy Finding (Telescope)
- **Space + ff** - Find files
- **Space + fg** - Live grep (search in files)
- **Space + fb** - Show open buffers
- **Space + fh** - Show recent files
- **Ctrl+n/p** - Navigate results up/down
- **Enter** - Open file
- **Ctrl+x** - Open in horizontal split
- **Ctrl+v** - Open in vertical split
- **Ctrl+t** - Open in new tab

## Code Navigation & LSP Features

### Go to Definition/References
- **gd** - Go to definition
- **gD** - Go to declaration
- **gi** - Go to implementation
- **gr** - Show references
- **gy** - Go to type definition
- **K** - Show hover documentation

### Code Actions
- **Space + ca** - Show code actions
- **Space + rn** - Rename symbol
- **Space + f** - Format current file

### Diagnostics
- **]d** - Next diagnostic
- **[d** - Previous diagnostic
- **Space + e** - Show line diagnostics

## Window & Pane Management

### Splitting Windows
- **:sp** or **:split** - Horizontal split
- **:vs** or **:vsplit** - Vertical split
- **Ctrl+w + s** - Horizontal split
- **Ctrl+w + v** - Vertical split

### Moving Between Windows
- **Ctrl+w + h/j/k/l** - Move left/down/up/right
- **Ctrl+w + w** - Cycle through windows
- **Ctrl+m + h/j/k/l** - Move left/down/up/right (custom mapping)

### Resizing Windows
- **Ctrl+w + =** - Equal window sizes
- **Ctrl+w + +** - Increase height
- **Ctrl+w + -** - Decrease height
- **Ctrl+w + >** - Increase width
- **Ctrl+w + <** - Decrease width

### Closing Windows
- **Ctrl+w + c** - Close current window
- **Ctrl+w + o** - Close all other windows

## Buffer Management

### Buffer Navigation
- **F3** - Next buffer
- **Shift+F3** - Previous buffer
- **:b [name]** - Switch to buffer by name
- **:bd** - Delete current buffer
- **:bn** - Next buffer
- **:bp** - Previous buffer

### Buffer Actions
- **:ls** - List all buffers
- **:b#** - Switch to last buffer
- **:bw** - Wipe buffer (delete completely)

## Code Completion & Snippets

### Autocompletion
- **Ctrl+Space** - Trigger completion
- **Tab** - Select next item / expand snippet
- **Shift+Tab** - Select previous item / jump back in snippet
- **Enter** - Confirm selection
- **Ctrl+e** - Close completion menu

### Snippet Navigation
- **Tab** - Jump to next snippet placeholder
- **Shift+Tab** - Jump to previous snippet placeholder

## Editing Features

### Comments
- **gcc** - Toggle line comment
- **gc** (in visual mode) - Toggle block comment
- **gbc** - Toggle block comment on current line

### Auto-pairs
- Automatically closes brackets, quotes, etc.
- **Ctrl+h** - Delete pair
- **Alt+p** - Toggle auto-pairs

### Text Objects
- **ciw** - Change inner word
- **ci"** - Change inside quotes
- **ci(** - Change inside parentheses
- **ca"** - Change around quotes (includes quotes)
- **di{** - Delete inside braces
- **ya}** - Yank around braces

## Database Operations (vim-dadbod)

### Database UI
- **Space + db** - Open database UI
- **Enter** - Execute query
- **S** - Save query
- **R** - Refresh connection

### Connecting to SQLite
1. Open database UI with **Space + db**
2. Press **A** to add connection
3. Enter: `sqlite:///path/to/your/database.db`
4. Name your connection

## Git Integration (gitsigns)

### Git Hunks
- **]c** - Next git change
- **[c** - Previous git change
- **Space + hs** - Stage hunk
- **Space + hr** - Reset hunk
- **Space + hp** - Preview hunk

## Search & Replace

### Basic Search/Replace
- **:%s/old/new/g** - Replace all occurrences
- **:%s/old/new/gc** - Replace with confirmation
- **:s/old/new** - Replace in current line
- **:'<,'>s/old/new/g** - Replace in visual selection

### Advanced Search
- **Space + fg** - Live grep across project
- **/\\<word\\>** - Search for exact word
- **/\\v(pattern)** - Very magic mode (easier regex)

## Modes & Editing

### Mode Switching
- **Esc** or **Ctrl+[** - Exit to normal mode
- **i** - Insert before cursor
- **a** - Insert after cursor
- **I** - Insert at beginning of line
- **A** - Insert at end of line
- **o** - New line below and insert
- **O** - New line above and insert
- **v** - Visual mode
- **V** - Visual line mode
- **Ctrl+v** - Visual block mode

### Copying & Pasting
- **yy** - Yank (copy) current line
- **y** (in visual mode) - Yank selection
- **p** - Paste after cursor
- **P** - Paste before cursor
- **dd** - Delete (cut) current line
- **d** (in visual mode) - Delete selection

## Tabs

### Tab Operations
- **:tabnew** - New tab
- **:tabn** or **gt** - Next tab
- **:tabp** or **gT** - Previous tab
- **:tabc** - Close current tab
- **:tabo** - Close all other tabs

## Sessions & Workspaces

### Session Management
- **:mksession [name]** - Save session
- **:source [session_file]** - Load session
- **nvim -S [session_file]** - Start with session

## Markdown Preview

### Markdown Preview Features
- **Space + mp** - Start markdown preview in default browser
- **Space + mw** - Start markdown preview in w3m (terminal split)
- **Space + ms** - Stop markdown preview
- **Space + mt** - Toggle markdown preview
- **:MarkdownPreview** - Start preview in browser (manual command)
- **:MarkdownPreviewW3m** - Start preview in w3m (manual command)
- **:MarkdownPreviewStop** - Stop preview (manual command)

### Preview Options
- **Browser preview**: Live updates, full feature support
- **w3m preview**: Static snapshot in terminal split, no external dependencies
- Support for tables, code blocks, and basic formatting
- Works with any markdown file

### Usage Tips
- **For live preview**: Use **Space + mp** (opens in browser)
- **For terminal preview**: Use **Space + mw** (opens w3m in split)
- w3m preview opens in a horizontal split below current window
- Press **q** in w3m to quit, then **:q** to close the split
- Browser preview updates automatically on file save

## Using OpenCode from Neovim

### Terminal Integration
- **:terminal** - Open terminal in Neovim
- **:term opencode** - Launch opencode in terminal
- **Ctrl+\\** **Ctrl+n** - Exit terminal insert mode

### External Commands
- **:!opencode %** - Open current file in opencode
- **:!opencode .** - Open current directory in opencode

### Background Execution
- **:!opencode % &** - Open current file in background
- **:!opencode . &** - Open current directory in background

## Configuration & Customization

### Key Configuration Files
- **~/.config/nvim/init.lua** - Main config
- **~/.config/nvim/lua/plugins.lua** - Plugin configuration

### Useful Commands
- **:checkhealth** - Check Neovim health
- **:Lazy** - Manage plugins
- **:Mason** - Manage LSP servers
- **:LspInfo** - Show LSP status
- **:TSUpdate** - Update Treesitter parsers

### Settings Toggle
- **F4** - Toggle line numbers
- **:set wrap!** - Toggle line wrapping
- **:set hlsearch!** - Toggle search highlighting

## Troubleshooting

### Plugin Issues
- **:Lazy sync** - Update all plugins
- **:Lazy clean** - Remove unused plugins
- **:Lazy restore** - Restore plugins to lockfile state

### LSP Issues
- **:LspRestart** - Restart LSP server
- **:Mason** - Install/manage LSP servers (use this to install servers like ts_ls, pyright, etc.)
- **:checkhealth lsp** - Check LSP health
- **:LspInfo** - Show attached LSP servers

### Installing LSP Servers
1. Open Neovim and run **:Mason**
2. Navigate with **j/k** and press **i** to install servers:
   - **ts_ls** - TypeScript/JavaScript
   - **pyright** - Python  
   - **html** - HTML
   - **cssls** - CSS
   - **jsonls** - JSON
   - **eslint** - ESLint
   - **lua_ls** - Lua

### Performance
- **:profile start [file]** - Start profiling
- **:profile stop** - Stop profiling
- **:checkhealth** - Check overall health

## Advanced Tips

### Multiple Cursors (Visual Block)
1. **Ctrl+v** - Enter visual block mode
2. Select multiple lines
3. **I** - Insert at beginning of all lines
4. **A** - Insert at end of all lines

### Macros
- **q[letter]** - Start recording macro
- **q** - Stop recording
- **@[letter]** - Execute macro
- **@@** - Repeat last macro

### Marks
- **m[letter]** - Set mark
- **'[letter]** - Jump to mark
- **''** - Jump to previous position

---

## Quick Reference Card

| Action | Keymap |
|--------|--------|
| File tree toggle | F2 |
| Find files | Space + ff |
| Live grep | Space + fg |
| Go to definition | gd |
| Show references | gr |
| Rename symbol | Space + rn |
| Code actions | Space + ca |
| Format file | Space + f |
| Next buffer | F3 |
| Database UI | Space + db |
| Split horizontal | Ctrl+w + s |
| Split vertical | Ctrl+w + v |
| Toggle comment | gcc |
| Markdown preview (browser) | Space + mp |
| Markdown preview (w3m) | Space + mw |
| Stop MD preview | Space + ms |
| Toggle MD preview | Space + mt |

This manual covers the essential navigation and IDE features of your new Neovim setup. Practice these commands regularly to build muscle memory and boost your productivity!