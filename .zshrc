# History
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
setopt share_history # Share history across terminals
setopt HIST_IGNORE_SPACE # Prepend sensitive commands with a space so they are not in history

# This binds Up and Down to a history search (backwards and forwards) based upon what has already been entered at the prompt.
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Prompt (Pure - https://github.com/sindresorhus/pure)
autoload -U promptinit; promptinit
zstyle :prompt:pure:path color '#41badf'
zstyle :prompt:pure:git:branch color '#eada4a'
zstyle ':prompt:pure:prompt:*' color '#e36743'
prompt pure

# Source additional config
source ~/.zsh/aliases
source ~/.zsh/path
source ~/.zsh/var
source ~/secrets/zsh
source ~/secrets/ynab.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh