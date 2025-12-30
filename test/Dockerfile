# Test container for zsh_setup (local files)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy local zsh_setup directly to .oh-my-zsh (skip git clone)
COPY --chown=testuser:testuser . /home/testuser/.oh-my-zsh

USER testuser
WORKDIR /home/testuser

# Create required directories
RUN mkdir -p ~/.ssh ~/.cache ~/.config/crt

# Copy config files directly (mimicking what install.sh does)
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    cp ~/.oh-my-zsh/p10k.zsh ~/.p10k.zsh && \
    cp ~/.oh-my-zsh/dircolors ~/.dircolors && \
    cp ~/.oh-my-zsh/dot_crt_config.toml ~/.config/crt/config.toml

# Clone powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel10k 2>/dev/null || true

CMD ["zsh", "-l"]
