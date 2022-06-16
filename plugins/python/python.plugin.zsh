# python command
alias py='python3'
alias python='python3'

# Find python file
alias pyfind='find . -name "*.py"'

# Grep among .py files
alias pygrep='grep -nr --include="*.py"'

# Run proper IPython regarding current virtualenv (if any)
alias ipython="python3 -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"

# Share local directory as a HTTP server
alias pyserver="python3 -m http.server"


# Remove python compiled byte-code and mypy/pytest cache in either the current
# directory or in a list of specified directories (including sub directories).
function pyclean() {
  find "${@:-.}" -type f -name "*.py[co]" -delete
  find "${@:-.}" -type d -name "__pycache__" -delete
  find "${@:-.}" -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
}

# Add the user installed site-packages paths to PYTHONPATH, only if the
#   directory exists. Also preserve the current PYTHONPATH value.
# Feel free to autorun this when .zshrc loads.
function pyuserpaths() {
  setopt localoptions extendedglob

  # Check for a non-standard install directory.
  local user_base="${PYTHONUSERBASE:-"${HOME}/.local"}"

  local python version site_pkgs
  for python in python2 python3; do
    # Check if command exists
    (( ${+commands[$python]} )) || continue

    # Get minor release version.
    # The patch version is variable length, truncate it.
    version=${(M)${"$($python -V 2>&1)":7}#[^.]##.[^.]##}

    # Add version specific path, if:
    # - it exists in the filesystem
    # - it isn't in $PYTHONPATH already.
    site_pkgs="${user_base}/lib/python${version}/site-packages"
    [[ -d "$site_pkgs" && ! "$PYTHONPATH" =~ (^|:)"$site_pkgs"(:|$) ]] || continue
    export PYTHONPATH="${site_pkgs}${PYTHONPATH+":${PYTHONPATH}"}"
  done
}



## venv utilities

# Activate a the python virtual environment specified.
# If none specified, use 'venv'.
function acv() {
  mkdir -p ${HOME}/.venvs
  local name="${1:-venv}"
  local venvpath="${HOME}/.venvs/${name}"

  if [[ ! -d "$venvpath" ]]; then
    echo >&2 "Error: no such venv at: $venvpath"
    return 1
  fi

  if [[ ! -f "${venvpath}/bin/activate" ]]; then
    echo >&2 "Error: '${name}' (at: ${venvpath})is not a proper virtual environment"
    return 1
  fi

  . "${venvpath}/bin/activate" || return $?
  echo "Activated virtual environment ${name}"
}

# Create a new virtual environment, with default name 'venv'.
function mkv() {
  mkdir -p ${HOME}/.venvs 
  local r_str=$(echo $RANDOM | md5sum | head -c 10)
  local name="${1:-$r_str}"
  local venvpath="${HOME}/.venvs/${name}"

  python3 -m venv "${venvpath}" || return
  echo >&2 "Created venv at '${venvpath}'"
  acv "${name}"
}


# Remove a virtual environment 
function rmv(){
  mkdir -p ${HOME}/.venvs 
  local name="${1:-$r_str}"
  local venvpath="${HOME}/.venvs/${name}"
  rm -rf ${venvpath} || return
  echo >&2 "Destroyed venv at '${venvpath}'"
}

# Print a list of available environments to activate
function lsv(){
  mkdir -p ${HOME}/.venvs 
  echo "Available environments: "
  local venvpath="${HOME}/.venvs/"
  ls -l ${venvpath} | grep -v total | tr -s ' ' | cut -d ' ' -f 9 | sed -e 's/^/  /'
}

# Autocompletes actv and rmv to all venvs in the ~/.venvs location
_actv_autocomp(){
  local cur=${COMP_WORDS[COMP_CWORD]}
  local availabl_venvs=$(ls -l ${HOME}/.venvs| grep -v total | tr -s ' ' | cut -d ' ' -f 9 | tr '\n' ' ')
  COMPREPLY=( $(compgen -W "${availabl_venvs}" -- $cur) )
  }

complete -F _actv_autocomp acv
complete -F _actv_autocomp rmv
