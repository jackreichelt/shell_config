#!/bin/zsh

source "${HOME}/.shared_functions"

IS_MAC=""
if [[ $(uname) == "Darwin" ]]; then
  IS_MAC="yes"
fi

# SSH add via keychain.
if [[ $IS_MAC ]]; then
  eval `ssh-agent` >/dev/null
  ssh-add -l >/dev/null
  if [[ "$?" != "0" ]]; then
    ssh-add -q --apple-use-keychain
  fi
fi

# Bash-related friendly shell config.
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}'
zstyle ':vcs_info:*' stagedstr '%F{yellow}'
zstyle ':vcs_info:git:*' formats '%F{green}%c%u[%b]'
# only enable git
zstyle ':vcs_info:*' enable git
setopt PROMPT_SUBST
PREV_WORKINGDIR=""

precmd() {
  _DATA=$(dirs -p | head -1)
  echo -ne "$_DATA"

  vcs_info

  PREPROMPT_SOURCE="%B%F{blue} ${vcs_info_msg_0_}%F{default}%b"
  PREPROMPT=$(print -P $PREPROMPT_SOURCE)
  WORKINGDIR=$(print -P "%F{blue}%~")
  if [[ $PREV_WORKINGDIR != $WORKINGDIR ]]; then
      echo -e $PREPROMPT
      PREV_WORKINGDIR=$WORKINGDIR
  fi
  PROMPT="%F{blue}%1~ ${vcs_info_msg_0_} %F{magenta}→%F{default} "
  VENV=$VIRTUAL_ENV:t
  if [[ $VENV ]] then
    PROMPT="%B%F{cyan}${VENV}%b %F{blue}%1~ ${vcs_info_msg_0_} %F{magenta}→%F{default} "
  fi
}

# Exec/library paths
pathprepend "${HOME}/.local/bin"
pathprepend "${HOME}/.local/opt"
pathprepend "${HOME}/.local/opt/bin"
pathprepend "${HOME}/.local/lib/npm/bin"
pathprepend "${HOME}/.yarn/bin"

# pip user
PIP_USER=y
pathprepend "${HOME}/Library/Python/2.7/bin"
pathprepend "${HOME}/Library/Python/3.8/bin"
pathprepend "${HOME}/Library/Python/3.9/bin"

pathprepend "/usr/local/opt/python@3.8/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# NPM bin
pathprepend "./node_modules/.bin"

# Aliases
if [ $IS_MAC ]; then
  alias ls='ls -pG'
else
  alias ls='ls -lh --color=auto'
fi
alias ll='ls -lahF'
alias less="less -R"
alias top='top -ocpu -Otime'
alias df="df -h"
alias du="du -h"
alias grep='grep --color=auto'
alias egrep='egrep --color'
alias hg='history | grep'
alias ghome='git checkout master && git pull'

# flash and unmount a kookaberry
alias flashscav='setopt rmstarsilent && diskutil quiet rename "NO NAME" KOOKABERRY || rm -rf /Volumes/KOOKABERRY/* && mkdir /Volumes/KOOKABERRY/lib && mkdir /Volumes/KOOKABERRY/app && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && cp ~/src/scavenger-hunt-games/chalk_code.py /Volumes/KOOKABERRY/app && cp ~/src/scavenger-hunt-games/find_symbols.py /Volumes/KOOKABERRY/app && cp ~/src/scavenger-hunt-games/follow_the_path.py /Volumes/KOOKABERRY/app && cp ~/src/scavenger-hunt-games/simon_says.py /Volumes/KOOKABERRY/app && cp ~/src/scavenger-hunt-games/check_progress.py /Volumes/KOOKABERRY/app && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a"'

alias flashscavtutor='setopt rmstarsilent && rm -rf /Volumes/KOOKABERRY/* && mkdir /Volumes/KOOKABERRY/lib && mkdir /Volumes/KOOKABERRY/app && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && cp ~/src/scavenger-hunt-games/waypoint.py /Volumes/KOOKABERRY/app && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a"'

alias flashtutor='setopt rmstarsilent && rm -rf /Volumes/KOOKABERRY/* && mkdir /Volumes/KOOKABERRY/lib && mkdir /Volumes/KOOKABERRY/app && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && cp ~/src/murder-mystery-projects/* /Volumes/KOOKABERRY/app && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a"'

alias flash='setopt rmstarsilent && touch /Volumes/KOOKABERRY/tmp && rm -rf /Volumes/KOOKABERRY/* && mkdir /Volumes/KOOKABERRY/lib && mkdir /Volumes/KOOKABERRY/app && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && cp ~/src/murder-mystery-projects/* /Volumes/KOOKABERRY/app && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a"'

alias flashlib='setopt rmstarsilent && rm -rf /Volumes/KOOKABERRY/lib/ && mkdir /Volumes/KOOKABERRY/lib && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a" '

alias flashradio='setopt rmstarsilent && rm -rf /Volumes/KOOKABERRY/* && mkdir /Volumes/KOOKABERRY/lib && cp ~/src/kookaberry-libraries/* /Volumes/KOOKABERRY/lib && mkdir /Volumes/KOOKABERRY/app && cp ~/src/murder-mystery-projects/tutor_radio.py /Volumes/KOOKABERRY/app/tutor_radio.py && diskutil unmountDisk KOOKABERRY && unsetopt rmstarsilent && echo "\a" '

# enable programmable completion features
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# Homebrew
BREW_PREFIX=""
if [[ -d "/opt/homebrew" ]]; then
  # Brew has "brew --prefix", but only if _already_ in $PATH
  BREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  BREW_PREFIX="/usr/local"
fi
if [[ $BREW_PREFIX ]]; then
  eval "$($BREW_PREFIX/bin/brew shellenv)"
  pathprepend "$BREW_PREFIX/opt/python/libexec/bin"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && ssource "${HOME}/.sdkman/bin/sdkman-init.sh"
