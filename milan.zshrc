##############################################################################
# mmehner's zshrc with a lot of stuff from grml
#############################################################################

################################################################################
#{{{ helper functions 
################################################################################

hascmd() {
    type &> /dev/null $1 && return 0 || return 1
}

################################################################################
#}}}
#{{{ environment for external tools
################################################################################

[ -r $HOME/bin ] && PATH="$HOME/bin:$PATH"

export PATH

hascmd dircolors && eval $(dircolors -b) # color setup for ls


if hascmd vim ; then
    export EDITOR=${EDITOR:-vim}
else
    export EDITOR=${EDITOR:-vi}
fi

export PAGER=${PAGER:-less}              # if not set, use less

export LESS="-iR"                        # search case insensitive, "raw" mode

# available on Ubuntu/Debian
# sets LESSOPEN and LESSCLOSE to make less open compressed files
# unfortunately every distro has its own solution
# if you know a portable way to do it, change it.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'



# disable mailchecks
export MAILCHECK=""

# make bc read standard config
# export BC_ENV_ARGS=~/.bcrc


################################################################################
#}}}
#{{{ zsh parameters & options
################################################################################

HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=$HOME/.zsh_history
ZSHDIR=${HOME}/.zsh

setopt nobeep            # don't beep

setopt nohup             # don't kill jobs on shell exit

setopt pushd_ignore_dups # don't push the same dir twice.

# the history entry is written out to the file after the command is finished,
# rather than waiting until the shell exits
# Tip: import new commands from $HISTFILE with: fc -R
setopt inc_append_history 

setopt extended_history  # save each command's beginning timestamp and 
                         # the duration to the history file
                            
setopt histignorealldups # when a new command is added to history, older
                         # duplicates are removed

setopt histignorespace   # don't save a command to history if first character
                         # on the line is space
                         
setopt hist_fcntl_lock   # use fcntl $HISTFILE locking where available


setopt extended_glob     # Treat the `#', `~' and `^' characters as part of 
                         # patterns for filename generation  
                         # *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word 
                         # not in compressed files 
                         
setopt completeinword    # <TAB> completes not just at the end of a word

setopt always_to_end     # When completing from the middle of a word, move the 
                         # cursor to the end of the word    

setopt norecexact        # show completion menu even if input matches one option
                         # completely. Without this ls<TAB> will just give ls. 
                         # With this, ls<TAB> will also list things like lspci

setopt hash_list_all     # whenever a command completion is attempted, make sure
                         # the entire command path is hashed first.
                         
setopt nocorrect         # can be confusing, turn off in shared config

setopt prompt_subst      # If set, parameter expansion, command substitution 
                         # and arithmetic expansion are performed in prompts.
                         # Substitutions within prompts do not affect the
                         # command status.
                         
setopt prompt_cr         # Print  a  carriage  return just before printing a 
                         # prompt in the line editor.  This is on by default as 
                         # multi-line editing is only possible if the editor 
                         # knows where the start of the line appears.
                         # Needs to be set, bc. idiots of OpenSuSE unset this 
                         # system-wide

# PLEASE DONT SET:
# sharedhistory - It's nice for single user, but confusing when multiple people
# run root shells at the same time

autoload zmv             # mv on steroids


################################################################################
#}}}
#{{{ prompt
#    see man 1 zshmisc for explanation of escape codes
################################################################################

# printed when waiting for more input
PS2="%F{green}%_%f> " 
# when debugging with set -x: file in blue, linenum in green
PS4="+%F{blue}%N%f:%F{green}%i%f> " 

# only show hostname when in ssh connection
if [[ -z "$SSH_CLIENT" ]]; then
    prompt_host=""
else
    prompt_host="@%F{220}%m%f"
fi

# disables prompt mangling in virtual_env/bin/activate because ...
export VIRTUAL_ENV_DISABLE_PROMPT=1
# ... we have our own venv prompt
function virtualenv_prompt_info(){
  if [[ -n $VIRTUAL_ENV ]]; then
    printf "%s[%s] " "%{${YELLOW}%}" ${${VIRTUAL_ENV}:t}
  fi
}

# exit code on the left if != 0, red username for root, blue otherwise; host only if ssh; vcs info
PS1="%(?..%B%F{red}%?%b )$(virtualenv_prompt_info)%(!.%B%F{red}.%F{075})%n%b%f${prompt_host}:%F{048}%~%f "'${vcs_info_msg_0_}'"
%# "
case $TERM in
  (*xterm* | rxvt*)

    # Write some info to terminal title.
    # This is seen when the shell prompts for input.
    function precmd {
      print -Pn "\e]0;zsh%L %(1j,%j job%(2j|s|); ,)%~\a"
    }
    # Write command and args to terminal title.
    # This is seen while the shell waits for a command to complete.
    function preexec {
      printf "\033]0;%s\a" "$1"
    }

  ;;
esac

################################################################################
#}}}
#{{{ green cursor
###############################################################################
#if [[ "${TERM}" == *rxvt* || "${TERM}" == *xterm* ]]; then
    #echo -ne "\033]12;green\007"
#fi


################################################################################
#}}}
#{{{ keybindings
#    we're using vi mode as default, but make life easy for emacs users
#    some stuff stolen from grml
################################################################################

H-keybindings() {
# this is included in H-zsh()
# PLEASE UPDATE WHEN YOU CHANGE SOMETHING
cat <<ENDHELP
Useful keybindings:
  Ctrl-Left/Right --  Jump words
  Alt-Left/Right  --  Jump words bash style (boundary on "/")
  Alt-.           --  insert last word of last command
  Ctrl-g          --  send-break (also aborts completion)
  Ctrl-o          --  in complete menu: accept choice and continue completion
  Ctrl-x u        --  undo (try in combination with Ctrl-o in completion menu)
  Ctrl-x Ctrl-x   --  complete word from history with menu

Extra special keybindings:
  Ctrl-x h        --  add a cmdline to history without executing it 
                      (you can also prefix the cmdline with space)
  Ctrl-x d        --  insert date YYYY-MM-DD
  Ctrl-x e        --  edit current commandline in $EDITOR
  Ctrl-x i        --  insert unicode char: Ctrl-x i 00A7 Ctrl-x i
  Ctrl-x 1        --  jump to after first word (for adding options)
ENDHELP
}
# use vi mode as default
bindkey -v

# bind to multiple maps 
function bind2maps () {
    local i sequence widget
    local -a maps

    while [[ "$1" != "--" ]]; do
        maps+=( "$1" )
        shift
    done
    shift

    if [[ "$1" == "-s" ]]; then
        shift
        sequence="$1"
    else
        sequence="${key[$1]}"
    fi
    widget="$2"

    [[ -z "$sequence" ]] && return 1

    for i in "${maps[@]}"; do
        bindkey -M "$i" "$sequence" "$widget"
    done
}

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

typeset -A key
key=(
    Home     "${terminfo[khome]}"
    End      "${terminfo[kend]}"
    Insert   "${terminfo[kich1]}"
    Delete   "${terminfo[kdch1]}"
    Up       "${terminfo[kcuu1]}"
    Down     "${terminfo[kcud1]}"
    Left     "${terminfo[kcub1]}"
    Right    "${terminfo[kcuf1]}"
    PageUp   "${terminfo[kpp]}"
    PageDown "${terminfo[knp]}"
    BackTab  "${terminfo[kcbt]}"
)

# bind those keys that noobs expect to work
bind2maps emacs             -- Home   beginning-of-line
bind2maps       viins vicmd -- Home   vi-beginning-of-line
bind2maps emacs             -- End    end-of-line
bind2maps       viins vicmd -- End    vi-end-of-line
bind2maps emacs viins       -- Insert overwrite-mode
bind2maps             vicmd -- Insert vi-insert
bind2maps emacs             -- Delete delete-char
bind2maps       viins vicmd -- Delete vi-delete-char
bind2maps emacs viins vicmd -- Up     up-line-or-search
bind2maps emacs viins vicmd -- Down   down-line-or-search
bind2maps emacs             -- Left   backward-char
bind2maps       viins vicmd -- Left   vi-backward-char
bind2maps emacs             -- Right  forward-char
bind2maps       viins vicmd -- Right  vi-forward-char
bind2maps       viins vicmd -- Right  vi-forward-char

if autoload history-search-end; then
    zle -N history-beginning-search-backward-end history-search-end
    zle -N history-beginning-search-forward-end  history-search-end
    # search history backward for entry beginning with typed text
    bind2maps emacs viins       -- PageUp history-beginning-search-backward-end
    # search history forward for entry beginning with typed text
    bind2maps emacs viins       -- PageDown history-beginning-search-forward-end
fi

# Ctrl-a: jump to beginning of line
bind2maps viins -- -s "^A" beginning-of-line

# Ctrl-e: jump to end of line
bind2maps viins -- -s "^E" end-of-line

# Ctrl-f: forward char
bind2maps viins -- -s "^F" forward-char

# Ctrl-b: backward char
bind2maps viins -- -s "^B" backward-char

# Ctrl-p: previous history
bind2maps viins -- -s "^P" vi-up-line-or-history

# Ctrl-n: next history
bind2maps viins -- -s "^N" vi-down-line-or-history

# Ctrl-r: use the new *-pattern-* widgets for incremental history search
bind2maps emacs viins vicmd -- -s '^R' history-incremental-pattern-search-backward 

# Alt-.: insert last word of last command like in emacs mode
bind2maps viins -- -s '\e.' insert-last-word

# Ctrl-x u: Undo last text modification (also while completing)
bind2maps viins -- -s '^Xu' undo

# Ctrl-x Ctrl-x: complete word from history with menu
bind2maps emacs viins       -- -s "^x^x" hist-complete

## Ctrl-Left and Ctrl-Right: jumping to word-beginnings on the command line.
# URxvt sequences:
bind2maps emacs viins vicmd -- -s '\eOc' forward-word
bind2maps emacs viins vicmd -- -s '\eOd' backward-word
# These are for xterm:
bind2maps emacs viins vicmd -- -s '\e[1;5C' forward-word
bind2maps emacs viins vicmd -- -s '\e[1;5D' backward-word
# Also try ESC Left/Right:
bind2maps emacs viins vicmd -- -s '\e'${key[Right]} forward-word
bind2maps emacs viins vicmd -- -s '\e'${key[Left]}  backward-word

## Alt-Left and Alt-Right: the same but bash style: "/" is a word a boundary
bash-forward-word() {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle forward-word
}
zle -N bash-forward-word
bash-backward-word() {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle backward-word
}
zle -N bash-backward-word
# URxvt again:
bind2maps emacs viins vicmd -- -s '\e\e[C' bash-forward-word
bind2maps emacs viins vicmd -- -s '\e\e[D' bash-backward-word
# Xterm again:
bind2maps emacs viins vicmd -- -s '^[[1;3C' bash-forward-word
bind2maps emacs viins vicmd -- -s '^[[1;3D' bash-backward-word

zmodload -i zsh/complist && {
    # Ctrl-o: while in completion menu accept a completion and try to complete
    # again by using menu completion; very useful with completing directories by
    # using 'undo' one's got a simple file browser
    bind2maps menuselect -- -s '^o' accept-and-infer-next-history    \

    # Shift-tab: Perform backwards menu completion                                    
    bind2maps menuselect -- BackTab reverse-menu-complete                              

    } || print "No complist module available"

# Ctrl-x i: insert unicode character
# usage example: 'ctrl-x i' 00A7 'ctrl-x i' will give you an §
# See for example http://unicode.org/charts/ for unicode characters code
#k# Insert Unicode character
autoload -U insert-unicode-char
zle -N insert-unicode-char
bind2maps emacs viins       -- -s '^xi' insert-unicode-char

# Ctrl-x h: add a command line to the shells history without executing it 
commit-to-history() {                                                            
    print -s ${(z)BUFFER}                                                        
    zle send-break                                                               
}                                                                                
zle -N commit-to-history                                                          
bind2maps emacs viins vicmd -- -s '^xh' commit-to-history     

# Ctrl-x d: insert date YYYY-MM-DD
insert-timestamp() { BUFFER="$BUFFER$(date '+%F')"; CURSOR=$#BUFFER; }
zle -N insert-timestamp  
bind2maps emacs viins -- -s '^xd' insert-timestamp

# Ctrl-x e: edit current commandline in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bind2maps emacs viins vicmd -- -s '^xe' edit-command-line

# Ctrl-x 1: jump to after first word (for adding options)
function jump_after_first_word() {
    local words
    words=(${(z)BUFFER})

    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}
zle -N jump_after_first_word
bind2maps emacs viins       -- -s '^x1' jump_after_first_word

# run command line as user root via sudo:
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
}
zle -N sudo-command-line

# Put the current command line into a \kbd{sudo} call
bindkey "^xs" sudo-command-line


################################################################################
#}}}
#{{{ Completion
################################################################################

# syntax: 
# zstyle :completion:<function>:<completer>:<command>:<arg>:<tag> style value

# colorize completion
zstyle ':completion:*'                list-colors ${(s.:.)LS_COLORS}
    
# separate matches into groups
zstyle ':completion:*'                group-name ''

# menu selection for all completions
zstyle ':completion:*' menu select=1

# formats
zstyle ':completion:*:warnings'       format $'%F{red}No matches for:%f %d'
zstyle ':completion:*:messages'       format '%d'
zstyle ':completion:*:descriptions'   format $'%F{red}completing %B%d%b%f'
zstyle ':completion:*:corrections'    format $'%F{red}completing %B%d%b%F{red} (%e errors)%f'
    
# verbose descriptions (include explanation of options)
zstyle ':completion:*'                 verbose yes

# prompt to show when scrolling in output longer than screen
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    
# complete manpages by section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

# history completion
zle -C hist-complete complete-word _generic
zstyle ':completion:hist-complete:*' completer _history

# ignore duplicate entries
zstyle ':completion:*:history-words'  remove-all-dups yes
zstyle ':completion:*:history-words'  stop yes

# match uppercase from lowercase
zstyle ':completion:*'                matcher-list 'm:{a-z}={A-Z}'

# provide .. as a completion
zstyle ':completion:*' special-dirs ..
    
# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# group original command first, so that it is not immediately replaced
# TODO: not sure if this is the right way to achieve this.
zstyle ':completion::*approximate*:*' group-order original corrections

# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# format for process list on kill completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,start_time,cmd -w -w"

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps -u ${USER} -o command | uniq'
    
# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                            /usr/local/bin  \
                                            /usr/sbin       \
                                            /usr/bin        \
                                            /sbin           \
                                            /bin            \
                                            /usr/X11R6/bin

# run rehash on completion so new installed program are found automatically:
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored _approximate

# caching
[[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
    zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

if autoload -Uz compinit; then
    compinit || print 'Notice: no compinit available'
fi

# use generic completion system for programs not yet defined; (_gnu_generic works
# with commands that provide a --help option with "standard" gnu-like output.)
for compcom in cp deborphan df feh fetchipac gpasswd head hnb ipacsum mv \
                pal stow tail uname ; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom

# show three dots while completing
expand-or-complete-with-dots() {
     echo -n "\e[32m...\e[0m"
     zle expand-or-complete
     zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

################################################################################
#}}}
#{{{ vcs_info
################################################################################

autoload -Uz vcs_info

precmd() {
    vcs_info
}

zstyle ':vcs_info:*' formats '%F{5}[%F{2}%r:%b%c%u%F{5}%m]%f '

zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '

zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' stagedstr '%F{010}■'
zstyle ':vcs_info:*' unstagedstr '%F{011}■'
zstyle ':vcs_info:*' check-for-changes true


################################################################################
#}}}
#{{{ common aliasas 
#    DO NOT define aliases that change existing commands (like rm="rm -f")
################################################################################

# Exception for ls: With --color=auto, ls emits color codes only when standard
# output is connected to a terminal -> does not break stuff, allowed
alias ls="ls --color=auto"

alias l="ls -F"
alias ll="ls -lF"
alias la="ls -aF"
alias lla="ls -laF"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# GREP_OPTIONS is deprecated
alias grep='grep --color=auto'

# Take a look at the syslog
alias llog="journalctl | $PAGER"     # take a look at the syslog
# Take a look at the syslog
alias tlog="journalctl -f"    # follow the syslog

alias s='sudo -s'
alias us='setxkbmap -layout us -variant altgr-intl; xmodmap ~/.xmodmap'
alias deutsch='setxkbmap -layout de; xmodmap ~/.xmodmap'

alias :q=exit
################################################################################
#}}}
#{{{ useful shell functions
#    taken from grml
################################################################################

dchange() {
    emulate -L zsh
    [[ -z "$1" ]] && printf 'Usage: %s <package_name(s)>\n' "$0" && return 1

    local package
    for package in "$@" ; do
        if [[ -r /usr/share/doc/${package}/changelog.Debian.gz ]] ; then
            $PAGER /usr/share/doc/${package}/changelog.Debian.gz
        elif [[ -r /usr/share/doc/${package}/changelog.gz ]] ; then
            $PAGER /usr/share/doc/${package}/changelog.gz
        elif [[ -r /usr/share/doc/${package}/changelog ]] ; then
            $PAGER /usr/share/doc/${package}/changelog
        else
            if hascmd aptitude ; then
                echo "No changelog for package $package found, using aptitude to retrieve it."
                aptitude changelog "$package"
            elif hascmd apt-get ; then
                echo "No changelog for package $package found, using apt-get to retrieve it."
                apt-get changelog "$package"
            else
                echo "No changelog for package $package found, sorry."
            fi
        fi
    done
}
_dchange() { _files -W /usr/share/doc -/ }
compdef _dchange dchange

# View Debian's NEWS of a given package
dnews() {
    emulate -L zsh
    if [[ -r /usr/share/doc/$1/NEWS.Debian.gz ]] ; then
        $PAGER /usr/share/doc/$1/NEWS.Debian.gz
    else
        if [[ -r /usr/share/doc/$1/NEWS.gz ]] ; then
            $PAGER /usr/share/doc/$1/NEWS.gz
        else
            echo "No NEWS file for package $1 found, sorry."
            return 1
        fi
    fi
}
_dnews() { _files -W /usr/share/doc -/ }
compdef _dnews dnews

# View Debian's copyright of a given package
dcopyright() {
    emulate -L zsh
    if [[ -r /usr/share/doc/$1/copyright ]] ; then
        $PAGER /usr/share/doc/$1/copyright
    else
        echo "No copyright file for package $1 found, sorry."
        return 1
    fi
}
_dcopyright() { _files -W /usr/share/doc -/ }
compdef _dcopyright dcopyright

# View upstream's changelog of a given package
uchange() {
    emulate -L zsh
    if [[ -r /usr/share/doc/$1/changelog.gz ]] ; then
        $PAGER /usr/share/doc/$1/changelog.gz
    else
        echo "No changelog for package $1 found, sorry."
        return 1
    fi
}
_uchange() { _files -W /usr/share/doc -/ }
compdef _uchange uchange

# install terminfo on some machine with ssh
terminfo_install() (
    # $1 = user@host
    # $2 = TERM name you want to install, defaults to $TERM

    if [ -n "$2" ]; then
        WHICHTERM="$2"
    else
        WHICHTERM="$TERM"
    fi

    set -e
    if [ -z "$1" ]; then
        echo "usage: terminfo_install user@host"
        return 1
    fi

    c="infocmp -L $WHICHTERM > /tmp/$WHICHTERM.terminfo"
    echo $c; eval $c

    c="scp /tmp/$WHICHTERM.terminfo $1:/tmp/$WHICHTERM.terminfo"
    echo $c; eval $c

    c="ssh $1 \"tic /tmp/$WHICHTERM.terminfo\""
    echo $c; eval $c
)
    
# display a nice view of all available colors in a 256 term
function 256colors {
    local -a COLORS

    local whitebg="[0;;47m"
    local blackbg="[0;;40m"
    local reset="[00m"
    local switch="[07m"
    

    COUNT=1
    for color in {000..256}; do
        local text="Lorem Ipsum"
        COLORS+="$color:[38;5;${color}m $text $switch $text $reset ${whitebg}[38;5;${color}m $text $switch $text $reset ${blackbg}[38;5;${color}m $text $switch $text [00m"
    done
    
    for i in $COLORS; do
        echo $i
    done
}


#################################################
#}}}
#{{{ optional Plugins
################################################
PLUGINS=(
    zsh-syntax-highlighting/zsh-syntax-highlighting.zsh)

for p in $PLUGINS; do 
    if [ -r ~/.zsh/plugins/$p ]; then
        source ~/.zsh/plugins/$p;
    fi
done

###############################################################################
#}}}
#{{{ finalizing
################################################################################

# remove functions that aren't needed anymore
unset -f bind2maps
unset -f hascmd

#}}}
# vim:filetype=zsh autoindent expandtab shiftwidth=4 foldmethod=marker foldlevel=0


