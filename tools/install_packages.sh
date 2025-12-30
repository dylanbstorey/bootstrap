#!/bin/sh
#
# Install favorite tools across macOS and Linux
#
# Usage:
#   sh tools/install_packages.sh [--all]
#   sh tools/install_packages.sh --crt
#   sh tools/install_packages.sh --rust
#   sh tools/install_packages.sh --python
#   sh tools/install_packages.sh --cli
#
set -e

# Colors
if [ -t 1 ]; then
  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')
else
  FMT_RED="" FMT_GREEN="" FMT_YELLOW="" FMT_BLUE="" FMT_BOLD="" FMT_RESET=""
fi

info()  { printf '%s%s%s\n' "$FMT_BLUE" "$1" "$FMT_RESET"; }
success() { printf '%s%s%s\n' "$FMT_GREEN" "$1" "$FMT_RESET"; }
warn()  { printf '%s%s%s\n' "$FMT_YELLOW" "$1" "$FMT_RESET"; }
error() { printf '%s%sError: %s%s\n' "$FMT_BOLD" "$FMT_RED" "$1" "$FMT_RESET" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect OS and package manager
detect_os() {
  case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      OS="unknown" ;;
  esac

  if [ "$OS" = "macos" ]; then
    if [ -f /opt/local/bin/port ]; then
      PKG_MGR="macports"
    elif command_exists brew; then
      PKG_MGR="homebrew"
    else
      PKG_MGR="none"
    fi
  elif [ "$OS" = "linux" ]; then
    if command_exists apt-get; then
      PKG_MGR="apt"
    elif command_exists dnf; then
      PKG_MGR="dnf"
    elif command_exists pacman; then
      PKG_MGR="pacman"
    else
      PKG_MGR="none"
    fi
  fi
}

# Package manager wrappers
pkg_install() {
  case "$PKG_MGR" in
    macports) sudo port install "$@" ;;
    homebrew) brew install "$@" ;;
    apt)      sudo apt-get install -y "$@" ;;
    dnf)      sudo dnf install -y "$@" ;;
    pacman)   sudo pacman -S --noconfirm "$@" ;;
    *)        error "No supported package manager found"; return 1 ;;
  esac
}

# ============================================================================
# MacPorts
# ============================================================================
install_macports() {
  if [ "$OS" != "macos" ]; then
    warn "MacPorts is only for macOS, skipping."
    return 0
  fi

  if [ -f /opt/local/bin/port ]; then
    success "MacPorts already installed."
    return 0
  fi

  info "MacPorts not found."
  echo ""
  echo "Install MacPorts from: ${FMT_BOLD}https://www.macports.org/install.php${FMT_RESET}"
  echo ""
  echo "Quick install for macOS Sequoia (15.x):"
  echo "  1. Download the pkg from the website"
  echo "  2. Or use the command line installer:"
  echo ""
  echo "     ${FMT_YELLOW}# Install Xcode Command Line Tools first${FMT_RESET}"
  echo "     xcode-select --install"
  echo ""
  echo "     ${FMT_YELLOW}# Then download and run the MacPorts installer${FMT_RESET}"
  echo ""
  echo "After installing, run this script again."
  return 1
}

# ============================================================================
# CRT Terminal
# ============================================================================
install_crt() {
  if [ -d "$HOME/.config/crt" ] || [ -d "/Applications/crt.app" ]; then
    success "CRT terminal already installed."
    return 0
  fi

  info "Installing CRT terminal..."
  curl -sSL https://raw.githubusercontent.com/colliery-io/crt/main/scripts/install.sh | sh

  # Copy our config if CRT was installed
  if [ -d "$HOME/.config/crt" ]; then
    local script_dir="$(cd "$(dirname "$0")/.." && pwd)"
    if [ -f "$script_dir/dot_crt_config.toml" ] && [ ! -f "$HOME/.config/crt/config.toml" ]; then
      cp "$script_dir/dot_crt_config.toml" "$HOME/.config/crt/config.toml"
      success "CRT config installed with synthwave theme."
    fi
  fi
}

# ============================================================================
# Metis (Flight Levels work management)
# ============================================================================
install_metis() {
  if command_exists metis; then
    success "Metis already installed."
    return 0
  fi

  info "Installing Metis..."
  curl -sSL https://raw.githubusercontent.com/colliery-io/metis/main/scripts/install.sh | sh
  success "Metis installed."
}

# ============================================================================
# Rust Toolchain
# ============================================================================
install_rust() {
  if command_exists rustup; then
    success "Rust toolchain already installed."
    info "Updating rustup..."
    rustup update
    return 0
  fi

  info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # Source cargo env for this session
  if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi

  success "Rust installed. You may need to restart your shell."
}

# ============================================================================
# Cargo Tools (Rust CLI tools)
# ============================================================================
install_cargo_tools() {
  if ! command_exists cargo; then
    info "Installing Rust first..."
    install_rust
  fi

  info "Installing Cargo tools..."

  # Use cargo-binstall for faster binary installs if available
  if ! command_exists cargo-binstall; then
    info "Installing cargo-binstall..."
    cargo install cargo-binstall
  fi

  # Development workflow
  cargo binstall -y cargo-watch      # File watcher, auto-rebuild
  cargo binstall -y cargo-machete    # Find unused dependencies

  # Testing & Coverage
  cargo binstall -y cargo-llvm-cov   # LLVM-based coverage
  cargo binstall -y cargo-tarpaulin  # Code coverage

  # Database
  cargo binstall -y diesel_cli       # Diesel ORM CLI

  # Desktop apps
  cargo binstall -y tauri-cli        # Tauri desktop apps
  cargo binstall -y trunk            # WASM web apps

  # Documentation & Publishing
  cargo binstall -y typst-cli        # Modern typesetting

  success "Cargo tools installed."
}

# ============================================================================
# Python Tools (uv)
# ============================================================================
install_python() {
  # Install uv (fast Python package manager)
  if command_exists uv; then
    success "uv already installed."
    info "Updating uv..."
    uv self update || true
  else
    info "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Source the env for this session
    if [ -f "$HOME/.local/bin/env" ]; then
      . "$HOME/.local/bin/env"
    fi
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Ensure Python is available via uv
  if command_exists uv; then
    info "Installing latest Python via uv..."
    uv python install 3.12 || uv python install
  fi

  success "Python tooling ready."
}

# ============================================================================
# Python CLI Tools (installed via uv tool)
# ============================================================================
install_python_tools() {
  if ! command_exists uv; then
    info "Installing uv first..."
    install_python
  fi

  info "Installing Python CLI tools via uv..."

  # Linting, Formatting & Type Checking
  uv tool install ruff           # Fast linter/formatter (replaces black, isort, flake8)
  uv tool install ty             # Astral's type checker (replaces mypy)

  # Project & Dev Tools
  uv tool install pre-commit     # Git hooks framework
  uv tool install angreal        # Project templating/tasks

  # Testing & Debugging
  uv tool install pytest         # Testing framework
  uv tool install ipython        # Better Python REPL

  # Packaging & Publishing
  uv tool install build          # Python package builder
  uv tool install twine          # PyPI publishing

  success "Python CLI tools installed."
  echo ""
  info "Installed tools:"
  uv tool list
}

# ============================================================================
# CLI Tools
# ============================================================================
install_cli_tools() {
  info "Installing CLI tools via $PKG_MGR..."

  case "$PKG_MGR" in
    macports)
      # GNU coreutils for ls colors, etc.
      pkg_install coreutils

      # Modern CLI replacements
      pkg_install ripgrep      # rg - fast grep
      pkg_install fd           # fd - fast find
      pkg_install bat          # bat - cat with syntax highlighting
      pkg_install git-delta    # delta - better git diffs
      pkg_install jq           # jq - JSON processor
      pkg_install yq           # yq - YAML processor
      pkg_install htop         # htop - better top
      pkg_install tree         # tree - directory listing
      pkg_install wget         # wget - HTTP client
      pkg_install curl         # curl - HTTP client

      # Git & GitHub
      pkg_install git
      pkg_install git-lfs
      pkg_install gh           # GitHub CLI

      # CI/CD & Dev
      pkg_install act          # Run GitHub Actions locally
      pkg_install hugo         # Static site generator

      # GPG
      pkg_install gnupg2
      ;;

    apt)
      pkg_install coreutils ripgrep fd-find bat git-delta jq \
                  htop tree wget curl git git-lfs gnupg2 gh
      # Note: fd is 'fdfind' on Debian/Ubuntu, bat may be 'batcat'
      # act and hugo may need separate repos on Debian
      ;;

    dnf)
      pkg_install coreutils ripgrep fd-find bat git-delta jq \
                  htop tree wget curl git git-lfs gnupg2 gh
      ;;

    pacman)
      pkg_install coreutils ripgrep fd bat git-delta jq yq \
                  htop tree wget curl git git-lfs gnupg gh act hugo
      ;;

    homebrew)
      pkg_install coreutils ripgrep fd bat git-delta jq yq \
                  htop tree wget curl git git-lfs gnupg gh act hugo
      ;;

    *)
      error "No supported package manager found"
      return 1
      ;;
  esac

  success "CLI tools installed."
}

# ============================================================================
# Node.js (minimal, for tooling like Claude Code)
# ============================================================================
install_node() {
  if command_exists node && command_exists npm; then
    success "Node.js already installed: $(node --version)"
    return 0
  fi

  info "Installing Node.js (LTS)..."

  case "$PKG_MGR" in
    macports)
      pkg_install nodejs22 npm10
      ;;
    apt)
      # Use NodeSource for recent LTS
      if ! command_exists node; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
      fi
      ;;
    dnf)
      pkg_install nodejs npm
      ;;
    pacman)
      pkg_install nodejs npm
      ;;
    homebrew)
      pkg_install node
      ;;
    *)
      warn "Installing Node.js via fnm..."
      curl -fsSL https://fnm.vercel.app/install | bash
      eval "$(fnm env)"
      fnm install --lts
      ;;
  esac

  success "Node.js installed."
}

# ============================================================================
# Claude Code CLI
# ============================================================================
install_claude() {
  if command_exists claude; then
    success "Claude Code already installed."
    info "Checking for updates..."
    claude update || true
    return 0
  fi

  # Ensure npm is available
  if ! command_exists npm; then
    install_node
  fi

  info "Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code
  success "Claude Code installed."
}

# ============================================================================
# Main
# ============================================================================
print_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --all       Install everything"
  echo "  --port      Install/check MacPorts (macOS only)"
  echo "  --crt       Install CRT terminal"
  echo "  --metis     Install Metis (work management)"
  echo "  --rust      Install Rust toolchain"
  echo "  --cargotools Install Cargo CLI tools (cargo-watch, tauri, etc.)"
  echo "  --python    Install uv + Python"
  echo "  --pytools   Install Python CLI tools (ruff, pre-commit, etc.)"
  echo "  --node      Install Node.js (LTS)"
  echo "  --cli       Install CLI utilities"
  echo "  --claude    Install Claude Code CLI (installs Node if needed)"
  echo "  --help      Show this help"
  echo ""
  echo "With no options, installs: cli, rust, cargotools, python, pytools, crt, metis"
}

main() {
  detect_os
  info "Detected: $OS with $PKG_MGR"
  echo ""

  # Default: install core stuff
  if [ $# -eq 0 ]; then
    set -- --cli --rust --cargotools --python --pytools --crt --metis
  fi

  for arg in "$@"; do
    case "$arg" in
      --all)
        install_macports || true
        install_cli_tools
        install_rust
        install_cargo_tools
        install_python
        install_python_tools
        install_node
        install_crt
        install_metis
        install_claude || true
        ;;
      --port|--macports)
        install_macports
        ;;
      --crt)
        install_crt
        ;;
      --metis)
        install_metis
        ;;
      --rust)
        install_rust
        ;;
      --cargotools)
        install_cargo_tools
        ;;
      --python)
        install_python
        ;;
      --pytools)
        install_python_tools
        ;;
      --cli)
        install_cli_tools
        ;;
      --node)
        install_node
        ;;
      --claude)
        install_claude
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      *)
        error "Unknown option: $arg"
        print_usage
        exit 1
        ;;
    esac
  done

  echo ""
  success "Done! You may need to restart your shell."
}

main "$@"
