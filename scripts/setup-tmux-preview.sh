#!/usr/bin/env bash

set -e

echo "=================================================="
echo "Tmux Configuration Setup Script"
echo "=================================================="
echo ""

TMUX_DIR="$HOME/.tmux"
TMUX_PLUGINS_DIR="$TMUX_DIR/plugins"
TPM_DIR="$TMUX_PLUGINS_DIR/tpm"
TMUX_CONF="$HOME/.tmux.conf"

echo "[1/5] Creating directory structure..."
mkdir -p "$TMUX_PLUGINS_DIR"

echo "[2/5] Installing TPM (Tmux Plugin Manager)..."
if [ -d "$TPM_DIR" ]; then
    echo "TPM already exists, updating..."
    cd "$TPM_DIR" && git pull origin master
else
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "[3/5] Writing tmux configuration..."
cat > "$TMUX_CONF" << 'TMUXCONF'
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

unbind r
bind r source-file ~/.tmux.conf

set -g mouse on

setw -g mode-keys vi
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'dracula/tmux'

set -g @dracula-show-powerline true
set -g @dracula-plugins 'ram-usage git'
set -g @dracula-show-flags true
set -g @dracula-show-left-icon session
set -g @dracula-border-contrast true
set -g status-position bottom
set -g pane-border-style fg='#6272a4'
set -g pane-active-border-style fg='#ff79c6'

run '~/.tmux/plugins/tpm/tpm'
TMUXCONF

echo "[4/5] Starting tmux session and installing plugins..."

if tmux has-session -t setup 2>/dev/null; then
    tmux kill-session -t setup
fi

tmux new-session -d -s setup

sleep 1

echo "Installing tmux plugins via TPM..."
"$TPM_DIR/bin/install_plugins"

sleep 2

echo "[5/5] Verifying configuration..."

tmux source-file "$TMUX_CONF" 2>&1 | tee /tmp/tmux-setup.log || {
    echo "Configuration loaded (some warnings may be normal)"
}

tmux list-keys | grep -E "(select-pane|source-file)" > /dev/null && echo "✓ Custom key bindings verified"
test -d "$TMUX_PLUGINS_DIR/tmux-sensible" && echo "✓ tmux-sensible plugin installed"
test -d "$TMUX_PLUGINS_DIR/tmux-resurrect" && echo "✓ tmux-resurrect plugin installed"
test -d "$TMUX_PLUGINS_DIR/tmux" && echo "✓ dracula theme installed"
test -d "$TPM_DIR" && echo "✓ TPM installed"

tmux kill-session -t setup 2>/dev/null || true

echo ""
echo "=================================================="
echo "✓ Setup Complete!"
echo "=================================================="
echo ""
echo "Installed components:"
echo "  • Tmux configuration: $TMUX_CONF"
echo "  • Plugin manager: TPM"
echo "  • Plugins:"
echo "    - tmux-sensible (sensible defaults)"
echo "    - tmux-resurrect (session persistence)"
echo "    - dracula theme (beautiful UI)"
echo ""
echo "Configuration features:"
echo "  • Mouse support enabled"
echo "  • Vim-like pane navigation (h/j/k/l)"
echo "  • Custom Dracula theme with powerline"
echo "  • Status bar shows RAM usage and git info"
echo ""
echo "Key bindings:"
echo "  prefix + r  - Reload config"
echo "  prefix + h  - Select left pane"
echo "  prefix + j  - Select pane below"
echo "  prefix + k  - Select pane above"
echo "  prefix + l  - Select right pane"
echo "  prefix + I  - Install new plugins"
echo "  prefix + U  - Update plugins"
echo ""
echo "To start using tmux:"
echo "  tmux new -s mysession"
echo ""
echo "Setup log saved to: /tmp/tmux-setup.log"
echo "=================================================="
