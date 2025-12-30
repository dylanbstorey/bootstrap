# *_prompt_info functions for usage in your prompt
#
# Plugin creators, please add your *_prompt_info function to the list
# of dummy implementations to help theme creators not receiving errors
# without the need of implementing conditional clauses.
#
# See also lib/git.zsh for git_prompt_info

# Dummy implementations that return false to prevent command_not_found
# errors with themes, that implement these functions
# Real implementations will be used when the respective plugins are loaded
function pyenv_prompt_info \
  vi_mode_prompt_info \
  virtualenv_prompt_info \
  tf_prompt_info \
{
  return 1
}
