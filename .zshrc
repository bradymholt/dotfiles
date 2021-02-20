# History
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
setopt share_history # Share history across terminals
setopt HIST_IGNORE_SPACE # Prepend sensitive commands with a space so they are not in history

# Keybindings
# This binds Up and Down to a history search (backwards and forwards) based upon what has already been entered at the prompt and places cursor at EOL.
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# Prompt (Pure - https://github.com/sindresorhus/pure)
autoload -U promptinit; promptinit
zstyle :prompt:pure:path color '#41badf'
zstyle :prompt:pure:git:branch color '#eada4a'
zstyle ':prompt:pure:prompt:*' color '#e36743'
prompt pure

# Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Source additional config
source ~/.zsh/aliases
source ~/.zsh/path
source ~/.zsh/var
source ~/secrets/zsh
source ~/secrets/ynab.zsh