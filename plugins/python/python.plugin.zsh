# Python utilities
# Note: python/pip commands are shimmed by the uv plugin

# Find python files
alias pyfind='find . -name "*.py"'

# Grep among .py files
alias pygrep='grep -nr --include="*.py"'

# Share local directory as a HTTP server
alias pyserver='python -m http.server'

# Run IPython via uv
alias ipy='uvx ipython'

# Remove python compiled byte-code and cache directories
pyclean() {
  find "${@:-.}" -type f -name "*.py[co]" -delete
  find "${@:-.}" -type d -name "__pycache__" -delete
  find "${@:-.}" -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name ".ruff_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name "*.egg-info" -exec rm -r "{}" +
  find "${@:-.}" -type f -name "*.egg" -delete
}
