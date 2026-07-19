# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

zle -N up-line-or-search
zle -N down-line-or-search
bindkey "^[[A" up-line-or-search
bindkey "^[[B" down-line-or-search

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---------------------------------------------------------------------------
# Prompt / wellcome
# ---------------------------------------------------------------------------
eval "$(starship init zsh)"
fastfetch
