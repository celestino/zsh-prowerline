#!/bin/zsh

# chars       

case $TERM in
  xterm) TERM=xterm-256color ;;
  screen) TERM=screen-256color ;;
esac

display_colors() {
    for i in {0..256}; do echo -n ${(%):-$(printf '%%F{%1$d}%1$3d%%f' $i) }; (( $i % 36 == 15 )) && echo; done
}

autoload -Uz vcs_info

local vcsformat=" %F{black}%K{black}%F{white} %s %F{blue}%F{white}%K{blue} %b %F{black}%K{black}%F{white}%m %c%u"
local vcsactionformat="$vcsformat%F{yellow}%K{yellow}%F{232} %a %K{yellow}"


zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' use-simple false
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 5
zstyle ':vcs_info:*' formats $vcsformat 
zstyle ':vcs_info:*' actionformats $vcsactionformat
zstyle ':vcs_info:*' branchformat "%b#%r"
zstyle ':vcs_info:*' hgrevformat "%r"
zstyle ':vcs_info:*' stagedstr "%F{green}%K{green}%B%F{232} S %b%K{green}"
zstyle ':vcs_info:*' unstagedstr "%F{red}%K{red}%B%F{232} U %b%K{red}"
zstyle ':vcs_info:git+set-message:*' hooks git-hook-message

+vi-git-hook-message() {
  # Are we NOT on a remote-tracking branch?
  if git rev-parse --verify @{u} &>/dev/null; then
    hook_com[branch]+=" %F{255}%f"
  fi

  # Show +N/-N when your local branch is ahead-of or behind remote HEAD
  local -a gitstatus diff
  diff=($(git rev-list --left-right --count HEAD...@{u} 2>/dev/null))
  (( ${diff[1]} )) && hook_com[branch]+=" %F{46}%B↑%F{white} ${diff[1]}%b%K{blue}"
  (( ${diff[2]} )) && hook_com[branch]+=" %F{white}%B↓ ${diff[2]}%b%K{blue}"

  hook_com[misc]+=" $(git rev-parse --short HEAD)"

  [[ -n $(git ls-files --others --exclude-standard) ]] && hook_com[staged]+=$'%F{yellow}\ue0b2%K{yellow}%B%F{232} N %b%K{yellow}'
}

prompt_precmd() {
  local vcs_info_msg_0_ pwd_msg
  local -a pwd

  if vcs_info; then
    RPROMPT="$vcs_info_msg_0_"
  fi
  
  pwd=("${(s:/:)${(%):-%~}}")

  case ${pwd[1]} in
    "") pwd[1]=/ ;;
    \~) pwd[1]=⌂ ;;
    \~?*) pwd[1]=${pwd[1]/\~/⌂ } ;;
  esac

  [[ -z ${pwd[2]} ]] && pwd[2]=()

  pwd_msg=${(j: %F{232}%F{white} :)pwd: -3}

  PROMPT="
%(0#.%K{red}.%K{black})%F{white} %n %(0#.%F{red}.%F{black})%K{blue}%F{white} $pwd_msg %F{blue}%k%f "
}


autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd

