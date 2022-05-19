# Usage: pathremove /path/to/bin [PATH]
# e.g. to remove ~/bin from $PATH: pathremove ~/bin PATH
function pathremove {
  local IFS=':'
  local NEWPATH
  local DIR
  local PATHVARIABLE=${2:-PATH}
  for DIR in ${!PATHVARIABLE} ; do
    if [[ "${DIR}" != "${1}" ]] ; then
      NEWPATH="${NEWPATH:+${NEWPATH}:}${DIR}"
    fi
  done
  export ${PATHVARIABLE}="${NEWPATH}"
}


# Usage: pathprepend /path/to/bin [PATH]
# e.g. to prepend ~/bin to $PATH: pathprepend ~/bin PATH
function pathprepend {
  pathremove "${1}" "${2}"
  [ -d "${1}" ] || return
  local PATHVARIABLE="${2:-PATH}"
  export ${PATHVARIABLE}="${1}${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

# Usage: pathappend /path/to/bin [PATH]
# e.g. to append ~/bin to $PATH: pathappend ~/bin PATH
function pathappend {
  pathremove "${1}" "${2}"
  [ -d "${1}" ] || return
  local PATHVARIABLE=${2:-PATH}
  export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}${1}"
}


# =============================================================================
# =============================================================================

COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_OCHRE="\033[38;5;95m"
COLOR_BLUE="\033[0;34m"
COLOR_WHITE="\033[0;37m"
COLOR_RESET="\033[0m"

function git_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ ! $git_status =~ "working tree clean" ]]; then
    echo -e $COLOR_RED
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e $COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e $COLOR_GREEN
  else
    echo -e $COLOR_OCHRE
  fi
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "($branch)"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "($commit)"
  fi
}

PS1="\[$COLOR_BLUE\]\W"          # basename of pwd
PS1+="\[\$(git_color)\]"        # colors git status
PS1+=" \$(git_branch) "           # prints current branch
PS1+="\[$COLOR_BLUE\]\$\[$COLOR_RESET\] "   # '#' for root, else '$'
export PS1

# OS specific settings.
case "$(uname)" in
Darwin)
  alias ls='ls -pG'
  alias top='top -ocpu -Otime'
  export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
  pathprepend "${JAVA_HOME}/bin" PATH
  export LSCOLORS="exFxcxdxbxegedabagacad"
  export ARCHFLAGS="-arch x86_64"
  ;;
*)
  mkdir -p /tmp/tim
  ;;
esac

# Aliases.
alias egrep='egrep --color'
alias grep='grep --color'
alias l='ll'
alias less='less -R'
alias ll='ls -lahF'
alias ls='ls -pG'
alias ghome='git checkout master && git pull'

# Bash completion.
[ -r /etc/bash_completion ] && source /etc/bash_completion
$(which brew > /dev/null) && [ -r $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

# Load RVM bash functions.
# [ -s ${HOME}/.rvm/scripts/rvm ] && source ${HOME}/.rvm/scripts/rvm

export PATH=$PATH:/opt/apache-maven/bin
export JAVA_HOME=/Users/jreichelt/.sdkman/candidates/java/current

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# eval "$(pyenv init -)"
# export PATH="/usr/local/opt/terraform@0.13/bin:$PATH"
# export PATH="/usr/local/opt/terraform@0.12/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/jreichelt/.sdkman"
[[ -s "/Users/jreichelt/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/jreichelt/.sdkman/bin/sdkman-init.sh"
