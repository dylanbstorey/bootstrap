# uv - Fast Python package and project manager (https://github.com/astral-sh/uv)

if ! (( $+commands[uv] )); then
  return
fi

# Generate and cache completions
if [[ ! -f "$ZSH_CACHE_DIR/completions/_uv" ]] || \
   [[ $(command -v uv) -nt "$ZSH_CACHE_DIR/completions/_uv" ]]; then
  uv generate-shell-completion zsh >| "$ZSH_CACHE_DIR/completions/_uv" &|
fi

if [[ ! -f "$ZSH_CACHE_DIR/completions/_uvx" ]] || \
   [[ $(command -v uv) -nt "$ZSH_CACHE_DIR/completions/_uvx" ]]; then
  uvx --generate-shell-completion zsh >| "$ZSH_CACHE_DIR/completions/_uvx" &|
fi

# ============================================================================
# Python shims - escape system Python hell
# Uses uv-managed Python so you never touch the system Python
# ============================================================================

# Get the path to uv-managed Python (installs if needed)
_uv_python_path() {
  local py_path
  py_path=$(uv python find 2>/dev/null)
  if [[ -z "$py_path" ]]; then
    echo "Installing Python via uv..." >&2
    uv python install >&2
    py_path=$(uv python find 2>/dev/null)
  fi
  echo "$py_path"
}

# python -> uv-managed Python
python() {
  if [[ -f "pyproject.toml" ]] || [[ -f "uv.lock" ]]; then
    # In a uv project, use uv run for proper environment
    uv run python "$@"
  else
    # Outside a project, use uv's managed Python directly
    $(_uv_python_path) "$@"
  fi
}

# python3 -> same as python
python3() {
  python "$@"
}

# pip -> uv pip (always use uv for package management)
pip() {
  echo "Using 'uv pip' instead of pip..." >&2
  uv pip "$@"
}

pip3() {
  pip "$@"
}

# ============================================================================
# uv Aliases
# ============================================================================
alias uvi='uv init'
alias uva='uv add'
alias uvr='uv remove'
alias uvs='uv sync'
alias uvl='uv lock'
alias uvrun='uv run'
alias uvp='uv pip'
alias uvpi='uv pip install'
alias uvpu='uv pip uninstall'
alias uvpl='uv pip list'
alias uvv='uv venv'
alias uvpy='uv python'
alias uvpyi='uv python install'
alias uvpyl='uv python list'

# Upgrade uv itself
alias uvup='uv self update'

# Escape hatch: access the real system python if you really need it
alias syspython='/usr/bin/python3'
