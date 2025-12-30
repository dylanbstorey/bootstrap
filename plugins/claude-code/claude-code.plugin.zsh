# Claude Code CLI - Anthropic's official CLI for Claude
# https://github.com/anthropics/claude-code

if ! (( $+commands[claude] )); then
  return
fi

# Aliases
alias cc='claude'
alias ccc='claude -p'                    # Quick print mode (non-interactive)
alias ccr='claude -c'                    # Resume/continue last conversation
alias ccu='claude update'                # Update Claude Code

# MCP (Model Context Protocol) management
alias ccmcp='claude mcp'
alias ccmcpl='claude mcp list'           # List configured MCP servers
alias ccmcpa='claude mcp add'            # Add MCP server
alias ccmcpr='claude mcp remove'         # Remove MCP server
alias ccmcpg='claude mcp get'            # Get MCP server details

# Model shortcuts
alias ccsonnet='claude --model claude-sonnet-4-20250514'
alias ccopus='claude --model claude-opus-4-20250514'
alias cchaiku='claude --model claude-haiku-4-20250514'

# Git workflow helpers
alias cccommit='claude -p "Generate a commit message for these changes"'
alias ccreview='claude -p "Review this code for issues and improvements"'

# Function to start claude with a specific directory added
ccd() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccd <directory> [prompt]"
    return 1
  fi
  local dir="$1"
  shift
  claude --add-dir "$dir" "$@"
}

# Function to pipe file to claude
ccf() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccf <file> <prompt>"
    return 1
  fi
  local file="$1"
  shift
  cat "$file" | claude -p "$@"
}
