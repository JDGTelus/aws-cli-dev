FROM alpine:latest

RUN apk update && apk add --no-cache \
    curl \
    unzip \
    python3 \
    py3-pip \
    jq \
    git \
    vim \
    neovim \
    nodejs \
    npm \
    ripgrep \
    fd \
    build-base \
    zsh \
    tmux \
    wget \
    bash \
    shadow

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

RUN pip3 install --break-system-packages --no-cache-dir \
    boto3 \
    awscli-plugin-endpoint \
    aws-shell \
    pynvim \
    pylint \
    flake8 \
    black \
    autopep8 \
    pyright

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

RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN chsh -s $(which zsh)

WORKDIR /workspace

RUN mkdir -p /root/.aws /root/.config/nvim

COPY .zshrc /root/.zshrc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV EDITOR=nvim
ENV SHELL=/bin/zsh
ENV AWS_DEFAULT_REGION=us-east-1
ENV AWS_DEFAULT_OUTPUT=json

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/zsh"]
