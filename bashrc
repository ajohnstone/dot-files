#!/bin/bash
#
# Andrew Johnstone's bash environment
# Much taken from Mitchell Hashimoto and Ryan Tomayko (thanks!)

# Basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# Complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

#-------------------------------------------------------------------------------
# Shell Options
#-------------------------------------------------------------------------------

# System bashrc
test -r /etc/bash.bashrc && . /etc/bash.bashrc
test -r /etc/bashrc && . /etc/bashrc

# Notify bg task completion immediately
set -o notify

# Fucking mail notifications
unset MAILCHECK

# default umask
umask 0022

# Terminal type
case $UNAME in
    CYGWIN* | MINGW32*)
        export TERM=cygwin
        ;;
    *)
        export TERM=xterm-256color
        ;;
esac

#-------------------------------------------------------------------------------
# Path
#-------------------------------------------------------------------------------

case $UNAME in
    MINGW32*)
        # Don't touch the default PATH, it inherits Windows.
        ;;
    *)
        # Various sbins
        PATH="/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin"
        PATH="/usr/local/bin:$PATH"
        ;;
esac

# OS-Specific path stuff
if [[ `uname` == "Darwin" ]]; then
    alias emacs="/usr/local/Cellar/emacs/23.3/Emacs.app/Contents/MacOS/Emacs -nw"
elif [[ `uname` == "Linux" ]]; then
    PATH="/usr/bin/perlbin/vendor:$PATH"
fi

# ~/bin if it exists
test -d "$HOME/bin" &&
PATH="$HOME/bin:$PATH"

# texbin if it exists for LaTeX stuff
test -d "/usr/texbin" &&
PATH="/usr/texbin:$PATH"

# Heroku toolbelt
test -d "/usr/local/heroku/bin" &&
PATH="/usr/local/heroku/bin:$PATH"

#-------------------------------------------------------------------------------
# Env. Configuration
#-------------------------------------------------------------------------------

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

# Proper locale
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# Always use passive mode FTP
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# Ignore backups, CVS directories
FIGNORE="~:CVS:#:.pyc:.o:.git"
HISTCONTROL=ignoreboth
export HISTSIZE=1000000000

#-------------------------------------------------------------------------------
# Editor and Pager
#-------------------------------------------------------------------------------
EDITOR="vim"
SVN_EDITOR="vim"
VISUAL="vim"
export EDITOR SVN_EDITOR VISUAL

PAGER="less -FirSwX"
MANPAGER="$PAGER"
export PAGER MANPAGER

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREY="\[\033[0;97m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

COLOR1="${BLUE}"
COLOR2="${BLUE}"
P="\$"

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="\W\$(parse_git_branch) → "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREEN}\W\$(parse_git_branch) → ${GREY}"
    PS2="\[[33;1m\]continue \[[0m[1m\]> "
}

parse_git_branch() {
    [ -d .git ] || return 1
    git symbolic-ref HEAD 2> /dev/null | sed 's#\(.*\)\/\([^\/]*\)$# \2#'
}

#-------------------------------------------------------------------------------
# Aliases / Functions
#-------------------------------------------------------------------------------
alias dul='du -h --max-depth=1'
alias hi='history | tail -20'

# Git aliases
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gdiff='git diff'
alias gl='git prettylog'
alias gp='git push'
alias gs='git status'
alias gt='git tag'

# Others
alias be='bundle exec'
alias v='vagrant'

# Usage: puniq [path]
# Remove duplicate entries from a PATH style value while
# retaining the original order.
puniq() {
    echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
    cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
SSH_ENV=$HOME/.ssh/environment

function start_ssh_agent {
     ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
     chmod 0600 ${SSH_ENV}
     . ${SSH_ENV} > /dev/null
     ssh-add
}

# Source SSH agent settings if it is already running, otherwise start
# up the agent proprely.
if [ -f "${SSH_ENV}" ]; then
     . ${SSH_ENV} > /dev/null
     # ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_ssh_agent
     }
else
     start_ssh_agent
fi

#-------------------------------------------------------------------------------
# Other
#-------------------------------------------------------------------------------
# Plugins

#find $HOME/.bash.d/ -type f | while read p; do source $p; done

PLUGINS=( "depot_tools" "git" "go" "java" "rbenv" "scala" "tmux" "windows" "bash/docker" "bash/docker-bash-completion" "bash/json_val" )

for plugin in "${PLUGINS[@]}"; do
  plugin_path="$HOME/.bash.d/${plugin}"
  test -f $plugin_path && source $plugin_path
done

#-------------------------------------------------------------------------------
# User Shell Environment
#-------------------------------------------------------------------------------
case $UNAME in
    MINGW32*)
        # Don't condense path, since function doesn't work here.
        ;;
    *)
        # Condense path variables
        PATH=$(puniq $PATH)
        MANPATH=$(puniq $MANPATH)
        ;;
esac

# Set default prompt if interactive
test -n "$PS1" &&
prompt_color

# Do not create ._ metadata files on Mac OSX
export COPYFILE_DISABLE=true

#-----------------------------------------------------------------------------
# Aliases
#-----------------------------------------------------------------------------

# OS-Specific path stuff
if [[ `uname` == "Darwin" ]]; then
    CLI_COLOR=' -G '
elif [[ `uname` == "Linux" ]]; then
    CLI_COLOR=' --color '
fi

alias diff="colordiff -Naur"
alias less="less -R -i -E -M -X $@"
alias vi="vim"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls="ls -G ${CLI_COLOR}" # colorized output
alias ll="ls -alG ${CLI_COLOR}" # colorized output
alias l="ls ${CLI_COLOR}" # colorized output
alias top='top' # OSX's crazy top
alias rspec='rspec -c' # colorized rspec output
#-----------------------------------------------------------------------------
# Global Settings
#-----------------------------------------------------------------------------

# Save all lines of a multiple-line command in the same history entry
shopt -s cmdhist

export HISTTIMEFORMAT="%d/%m/%y %T ";

# Nice ls output
function ll(){ ls -l "$@"| egrep "^d" ; ls -lXB "$@" 2>&-| egrep -v "^d|total "; }

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
