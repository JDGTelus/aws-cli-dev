#!/bin/sh

if [ ! -f /root/.aws/credentials ] && [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "⚠️  AWS credentials not found!"
    echo "Please configure AWS credentials using one of these methods:"
    echo "1. Set environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
    echo "2. Run 'aws configure' inside the container"
    echo ""
fi

echo "✅ AWS CLI Version:"
aws --version

echo ""
echo "🔧 Current AWS Configuration:"
echo "Region: $(aws configure get region 2>/dev/null || echo 'Not set')"
echo "Output: $(aws configure get output 2>/dev/null || echo 'Not set')"

if aws sts get-caller-identity &>/dev/null; then
    echo ""
    echo "✅ AWS Connection Test:"
    aws sts get-caller-identity
    
    echo ""
    echo "🌍 Available Bedrock Regions:"
    aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[0].modelId' --output text 2>/dev/null || echo "Bedrock access not configured"
else
    echo ""
    echo "❌ AWS credentials not configured or invalid"
fi

echo ""
echo "🏔️  OS: Alpine Linux (lightweight, secure)"
echo "📝 Editor: Neovim $(nvim --version 2>/dev/null | head -1 | awk '{print $2}' || echo 'installed')"
echo "🐍 Python: $(python --version 2>&1)"
echo "📦 Node: $(node --version 2>&1)"
echo "🐚 Shell: zsh with oh-my-zsh"
echo "🖥️  Tmux: Available"
echo ""
echo "💡 Tips:"
echo "  • Setup Neovim IDE: /scripts/setup-neovim.sh"
echo "  • Setup Tmux: /scripts/setup-tmux-preview.sh"
echo "  • Package manager: apk (e.g., apk add htop)"
echo "  • Alpine guide: /guides/alpine-linux-guide.md"
echo ""

exec "$@"
