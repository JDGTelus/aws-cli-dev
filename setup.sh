#!/bin/bash

echo "🚀 Setting up AI Practitioner AWS CLI Environment..."
echo ""
echo "Base Image: Alpine Linux (lightweight, multi-platform)"
echo "Neovim: 0.11+ with full LSP support"
echo "Shell: Zsh with UTF-8 locale and AWS region in prompt"
echo "Tmux: Configured with 256-color and UTF-8 support"
echo "Ports: Frontend (3000-8080) & Backend (5000-9000) exposed"
echo ""

mkdir -p scripts

echo "📦 Building Docker container (Alpine Linux)..."
docker-compose build

cat > scripts/configure-billing-alerts.sh << 'EOF'
#!/bin/bash

echo "Setting up billing alerts for AI Practitioner practice..."

aws cloudwatch put-metric-alarm \
    --alarm-name "AI-Practice-Billing-Alert" \
    --alarm-description "Alert when estimated charges exceed $10" \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 86400 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=Currency,Value=USD \
    --evaluation-periods 1 \
    --alarm-actions arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:billing-alerts

echo "✅ Billing alert configured"
EOF

chmod +x scripts/configure-billing-alerts.sh

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Start container: docker-compose up -d"
echo "2. Enter container: docker-compose exec aws-cli-env zsh"
echo "3. Configure AWS: aws configure"
echo "4. Setup Neovim: /scripts/setup-neovim.sh"
echo "5. Setup Tmux (optional): /scripts/setup-tmux-preview.sh"
echo ""
echo "📚 Documentation:"
echo "- Alpine Guide: guides/alpine-linux-guide.md"
echo "- Quick Start: guides/quick-start.md"
echo "- AWS Setup: guides/aws-setup-guide.md"
echo "- All guides available in guides/ directory"
echo ""
echo "💡 Features:"
echo "- AWS region shown in prompt (after 'aws configure')"
echo "- UTF-8 locale support for full character range"
echo "- Tmux with 256-color and true color support"
echo "- Package manager: apk add/del (instead of apt)"
echo "- Neovim 0.11+ with vim-plug for :PlugInstall"
echo "- Common dev ports exposed (React:3000, Flask:5000, etc.)"
echo "- Clean zsh startup (no plugin errors)"
