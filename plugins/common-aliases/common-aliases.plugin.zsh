# Common Aliases

# ls shortcuts
alias l='ls -lFh'     # size, show type, human readable
alias la='ls -lAFh'   # long list, show almost all, show type, human readable
alias lr='ls -tRFh'   # sorted by date, recursive, show type, human readable
alias lt='ls -ltFh'   # long list, sorted by date, show type, human readable
alias ll='ls -l'      # long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias lsr='ls -lARFh' # recursive list of files and directories
alias lsn='ls -1'     # single column

alias zshrc='${=EDITOR} ${ZDOTDIR:-$HOME}/.zshrc'

# grep
alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

# tail
alias t='tail -f'

# Global aliases (pipe shortcuts)
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"

# disk usage
alias dud='du -d 1 -h'
alias duf='du -sh *'

# find shortcuts (only define fd if the fd tool isn't installed)
(( $+commands[fd] )) || alias fd='find . -type d -name'
alias ff='find . -type f -name'

# misc
alias h='history'
alias hgrep="fc -El 0 | grep"
alias help='man'
alias p='ps -f'
alias sortnr='sort -n -r'
alias unexport='unset'

# safe file operations (with -f override support)
alias rm='rm -i'

# cp wrapper: use -i by default, but -f bypasses it
unalias cp 2>/dev/null || true
cp() {
  if [[ " $* " == *" -f "* ]] || [[ "$1" == "-f"* ]]; then
    command cp "$@"
  else
    command cp -i "$@"
  fi
}

# mv wrapper: use -i by default, but -f bypasses it
unalias mv 2>/dev/null || true
mv() {
  if [[ " $* " == *" -f "* ]] || [[ "$1" == "-f"* ]]; then
    command mv "$@"
  else
    command mv -i "$@"
  fi
}

# Suffix aliases for opening files by extension
autoload -Uz is-at-least
if is-at-least 4.2.0; then
  # Open URLs in browser
  if [[ -n "$BROWSER" ]]; then
    _browser_fts=(htm html)
    for ft in $_browser_fts; do alias -s $ft='$BROWSER'; done
  fi

  # Open source files in editor
  _editor_fts=(cpp cxx cc c hh h inl txt md json yaml yml toml)
  for ft in $_editor_fts; do alias -s $ft='$EDITOR'; done

  # Archives - list contents
  alias -s zip="unzip -l"
  alias -s rar="unrar l"
  alias -s tar="tar tf"
  alias -s gz="gunzip -l"
  alias -s tgz="tar tzf"
fi

# SSH known hosts completion
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
