## VI MODE STUFF

#Load necessary stuff
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

#enable vi mode
bindkey -v

#Prompt colors based on vi mode
# urxvt (and family) accepts even #RRGGBB
INSERT_PROMPT="gray"
COMMAND_PROMPT="red"

# helper for setting color including all kinds of terminals
# \033 is \e is ESC
set_prompt_color() {
    if [[ $TERM = "linux" || $TERM = "fbterm" ]]; then
        #see tty_prompt_colors
        if [[ $1 = $INSERT_PROMPT ]]; then
            #Turn the cursor white
            echo -ne "\033[?16;0;127;c"
        else
            #Turn the cursor "red"
            echo -ne "\033[?16;0;64;c"
        fi
    elif [[ $TMUX != '' ]]; then
        printf '\033Ptmux;\033\033]12;%b\007\033\\' "$1"
    else
        echo -ne "\033]12;$1\007"
    fi
}

# change cursor color basing on vi mode
zle-keymap-select () {
    if [ $KEYMAP = vicmd ]; then
        set_prompt_color $COMMAND_PROMPT
    else
        set_prompt_color $INSERT_PROMPT
    fi
}

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    zle-line-finish() {
        echoti rmkx
        set_prompt_color $INSERT_PROMPT
    }

    zle-line-init () {
        echoti smkx
        zle -K viins
        set_prompt_color $INSERT_PROMPT
    }
else
    zle-line-finish() {
        set_prompt_color $INSERT_PROMPT
    }

    zle-line-init () {
        zle -K viins
        set_prompt_color $INSERT_PROMPT
    }
fi

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish


#Decrease timeout  to make vi mode usable
export KEYTIMEOUT=1


####Keybindings#####

#Arrows
#TODO: use shift/ctrl arrows
if [[ "${terminfo[kpp]}" != "" ]]; then
  bindkey "${terminfo[kpp]}" up-line-or-history       # [PageUp] - Up a line of history
fi
if [[ "${terminfo[knp]}" != "" ]]; then
  bindkey "${terminfo[knp]}" down-line-or-history     # [PageDown] - Down a line of history
fi

if [[ "${terminfo[kcuu1]}" != "" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search      # start typing + [Up-Arrow] - fuzzy find history forward
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search      # start typing + [Up-Arrow] - fuzzy find history forward
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search    # start typing + [Down-Arrow] - fuzzy find history backward
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search    # start typing + [Down-Arrow] - fuzzy find history backward
fi

#fix search
#in command mode
bindkey -M vicmd "/" history-incremental-search-backward
bindkey -M vicmd "?" history-incremental-search-forward
#in insert mode
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-backward

#fix backspace
bindkey "^W" backward-kill-word    # vi-backward-kill-word
bindkey "^H" backward-delete-char  # vi-backward-delete-char
bindkey "^U" kill-line             # vi-kill-line
bindkey "^?" backward-delete-char  # vi-backward-delete-char

#fix delete
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char            # [Delete] - delete forward
  bindkey -M vicmd "${terminfo[kdch1]}" vi-delete-char            # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
  bindkey -M vicmd "^[[3~" vi-delete-char
  bindkey -M vicmd "^[3;5~" vi-delete-char
  bindkey -M vicmd "\e[3~" vi-delete-char
fi

#needed?
bindkey ' ' magic-space                               # [Space] - do history expansion

#Command line in editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^f' edit-command-line
