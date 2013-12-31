# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
export SVN_EDITOR='vim'
export EDITOR='vim'
export VISUAL='vim'

# List of suffixes to ignore when performing filename completion
export FIGNORE=".svn:.o:~"

# Use less as our pager
export PAGER=/usr/bin/less
export LESS=-R

# Do not create ._ metadata files on Mac OSX
export COPYFILE_DISABLE=true

#-----------------------------------------------------------------------------
# Aliases
#-----------------------------------------------------------------------------
alias diff="colordiff -Naur"
alias less="less -R -i -E -M -X $@"
alias vi="vim"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls -G' # colorized output
alias l='ls' # colorized output
alias top='top -o cpu' # OSX's crazy top
alias rspec='rspec -c' # colorized rspec output

#-----------------------------------------------------------------------------
# Global Settings
#-----------------------------------------------------------------------------

# Save all lines of a multiple-line command in the same history entry
shopt -s cmdhist

#-----------------------------------------------------------------------------
# Initialization
#-----------------------------------------------------------------------------

# Source some subversion specific functions
#source $HOME/.svn_bash_completion

# Import our custom file/directory colors
# eval `dircolors -b $HOME/.dir_colors`

#-----------------------------------------------------------------------------
# Misc. Custom Functions
#-----------------------------------------------------------------------------

# change prompt when using git
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
if [ $EUID == '0' ]; then
  PS1="\[\e[32m\]\$(parse_git_branch)\[\e[m\]\h:\W # "
else
  PS1="\[\e[32m\]\$(parse_git_branch)\[\e[m\]\h:\W\$ "
fi
export PS1


# Nice ls output
function ll(){ ls -l "$@"| egrep "^d" ; ls -lXB "$@" 2>&-| egrep -v "^d|total "; }
