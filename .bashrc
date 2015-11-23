q# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# common .bashrc to share among all machines
# Last update AH 1/28/2015


# --- Source global definitions --- #
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


# --- Environmental variables --- #
export HISTSIZE=1000  # Changing history size
export HISTFILESIZE=1000  # Changing history size
export HISTCONTROL='ignoredups'  # Eliminate duplicates in history
export EDITOR='emacs -nw'  # Set default edit to emacs
export PATH="/app/fastqc/FastQC:$PATH"
export PATH="$PATH:$HOME/scripts:$HOME/scripts/linuxTools:$HOME/scripts/copy_JDBtools:/app/homer/v4.6/bin:$HOME/scripts/atac_tools_SKD/scripts:$HOME/scripts/atac_tools_SKD/libs:/app/preseq/preseq-1.0.2.Linux_x86_64"
export PYTHONPATH="$PYTHONPATH:$HOME/scripts/atac_tools_SKD/libs:$HOME/scripts/SKD_plotting/plotting_tools:$HOME/scripts/atac_tools_SKD:$HOME/scripts/atac_tools_SKD/scripts"
#export PYTHONPATH="$PYTHONPATH:$HOME/scripts/AHH_arrayTools/pythonLib"
export PYTHONSTARTUP="$HOME/scripts/dotfiles/python_init.py"
if [ "$(uname)" == "Darwin" ]; then  # Mac
    export LSCOLORS=GxFxCxDxBxegedabagaced  # Specify ls colors for Mac
fi


# --- Define aliases --- #

# - safety first - #
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias killall='killall -i'

# - emacs - #
alias e='emacs -nw'  # emacs no windows 
er() {
    emacs -nw "$1" --eval '(setq buffer-read-only t)'  # emacs read only shortcut
}

# - options for common Linux commands - #
if [ "$(uname)" == "Darwin" ]; then  # Mac
    alias l='ls -G'
    alias ls='ls -G'
    alias lst='ls -trhlG'
    alias ll='ls -hlG'
    alias la='ls -AtrhlG'
elif [ "$(uname)" == "Linux" ]; then  # Linux
    alias l='ls --color=auto'
    alias ls='ls --color=auto'
    alias lst='ls -trhl --color=auto'
    alias ll='ls -hl --color=auto'
    alias la='ls -Atrhl --color=auto'
fi
alias grep='grep -i --color=auto'  # Ignore case and turn color on
alias fgrep='fgrep --color=auto'  # Turn color on
alias egrep='egrep --color=auto'  # Turn color on
alias jobs='jobs -l'  # List process IDs in addition to the normal information
alias echo='echo -e' # Enable special characters
alias mkdir='mkdir -p'  # Create intermediate directories as required.
alias rsync='rsync -avz --progress'
alias rsyncd='rsync -avz --progress --delete'
alias rsynce='rsync -avz --progress --existing'
alias rsynci='rsync -avzi'

# - options for other apps - #
alias matlab="matlab -nodesktop"  # MATLAB no desktop

# - shortcuts - #
alias whereami='echo $HOSTNAME'
alias stfu='sudo shutdown -h now'
alias ctfo='sudo shutdown -r now'
if [ "$(uname)" == "Darwin" ]; then  # Mac
    alias preview='open -a Preview'
fi

# - git shortcuts - #
alias gs='git status'
alias gb='git branch'
alias gci='git commit -a'
alias gpm='git push -u origin master'
alias gcpm='git commit -a && git push -u origin master'


# --- Terminal display --- #

# - colors - #
BLACK='\[\e[0m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
VIOLET='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
GRAY='\[\e[0;37m\]'

# - bash prompt and title - #
PS1="$VIOLET[\j] $BLUE\w $BLACK"  # Set bash prompt style
if [ "$SSH_CONNECTION" ]; then
    PS1="\[\e]2;\u@\h\a\]$PS1"  # Set bash title if ssh'ed into remote machine
else
    PS1="\[\e]2;\w\007\]$PS1" # Set bash title to current directory if local
fi


# --- Remote access --- #

# - home - #
export lotus='anthony@lotus.stanford.edu'
export mesquite='anthony@mesquite.stanford.edu'
alias lotus='ssh -X $lotus'
alias mesquite='ssh -X $mesquite'

# - work - # 
export laurel='anthony@laurel.stanford.edu'
export greenseqwjg='wjg@greenseq.stanford.edu'
export greenseq='anthony@greenseq.stanford.edu'
export clusterlustre='anthony@clusterlustre.stanford.edu'
export greendragonwjg='wjg@greendragon.stanford.edu'
export greendragon='anthony@greendragon.stanford.edu'
export raid='wjg@gatorraid.stanford.edu'
export raidBackup='backupdaemon@gatorraid.stanford.edu'
alias laurel='ssh -X $laurel'
alias greenseqwjg='ssh -X $greenseqwjg'
alias greenseq='ssh -X $greenseq'
alias clusterlustre='ssh -X $clusterlustre'
alias greendragonwjg='ssh -X $greendragonwjg'
alias greendragon='ssh -X $greendragon'
alias raid='ssh -X $raid'
alias raidBackup='ssh -X $raidBackup'

# - other people's work machines - #
export clubmoss='wjg@clubmoss.stanford.edu'
export alfalfa='greenleaflab@alfalfa.stanford.edu'
export allspice='greenleaflab@allspice.stanford.edu'
export allspiceViviana='vrisca@allspice.stanford.edu'
export alicia='alicia@sr13-52e8946c88.stanford.edu'
alias clubmoss='ssh $clubmoss'
alias alfalfa='ssh $alfalfa'
alias allspice='ssh $allspice'
alias allspiceViviana='ssh $allspiceViviana'
alias alicia='ssh $alicia'
