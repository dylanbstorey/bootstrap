# bootstrap

Personal dev environment setup: Oh My Zsh + Powerlevel10k + CRT terminal + dev tools.

## Quick Install

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/dylanbstorey/bootstrap/main/tools/install.sh)"
```

## What's Included

**Shell**
- [Oh My Zsh](https://ohmyz.sh/) with curated plugins
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- Custom plugins: `uv` (Python shims), `claude-code` (CLI aliases)

**Terminal**
- [CRT](https://github.com/colliery-io/crt) terminal config (synthwave theme)

**Dev Tools** (`tools/install_packages.sh`)
- CLI utilities via MacPorts/apt (ripgrep, fd, bat, delta, jq, gh, etc.)
- Rust toolchain + cargo tools (cargo-watch, tauri-cli, typst-cli, etc.)
- Python via [uv](https://github.com/astral-sh/uv) + CLI tools (ruff, pytest, pre-commit, etc.)
- Node.js (LTS) + Claude Code CLI

## Usage

```bash
# Fresh install (zsh + all packages)
sh tools/install_packages.sh -y --fresh

# Just packages on existing setup
sh tools/install_packages.sh

# Specific components
sh tools/install_packages.sh --rust --python --cli
```

## Platforms

- macOS (MacPorts preferred, Homebrew fallback)
- Linux (apt, dnf, pacman)
