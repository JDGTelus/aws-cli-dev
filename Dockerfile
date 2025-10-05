FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies and development tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    vim \
    build-essential \
    zsh \
    tmux \
    jq \
    ripgrep \
    fd-find \
    less \
    groff \
    locales \
    ca-certificates \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Setup locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install latest Neovim (from official PPA)
RUN add-apt-repository ppa:neovim-ppa/unstable -y && \
    apt-get update && \
    apt-get install -y neovim && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.12 and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install Python development tools
RUN pip3 install --no-cache-dir --break-system-packages \
    boto3 \
    awscli-plugin-endpoint \
    pynvim \
    pylint \
    flake8 \
    black \
    autopep8 \
    pyright \
    ruff

# Install Node.js development tools
RUN npm install -g \
    neovim \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    eslint \
    prettier \
    @fsouza/prettierd \
    eslint_d \
    stylelint

# Create symlinks for convenience
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    ln -sf /usr/bin/fdfind /usr/bin/fd

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install vim-plug for Neovim
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Change default shell to zsh
RUN chsh -s $(which zsh)

# Install opencode
RUN curl -fsSL https://opencode.ai/install | bash

WORKDIR /root

# Create necessary directories
RUN mkdir -p /root/.aws /root/.config/nvim /root/.config/opencode /root/git

# Copy configuration files
COPY .zshrc /root/.zshrc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment variables
ENV EDITOR=nvim
ENV VISUAL=nvim
ENV SHELL=/bin/zsh
ENV AWS_DEFAULT_REGION=us-east-1
ENV AWS_DEFAULT_OUTPUT=json
ENV PATH=/root/.opencode/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/zsh"]
