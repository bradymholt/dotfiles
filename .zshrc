# History
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY      # share history across sessions
setopt APPEND_HISTORY     # append to history file rather than replacing it
setopt INC_APPEND_HISTORY # add to history as immediately rather than waiting for session exit
setopt HIST_IGNORE_DUPS   # ignore duplicated commands history list
setopt HIST_FIND_NO_DUPS  # ignore dupes when searchng history
setopt HIST_REDUCE_BLANKS # prevents empty history entries
setopt HIST_VERIFY        # show command with history expansion to user before running it
setopt HIST_IGNORE_SPACE  # prepend sensitive commands with a space so they are not in history

# Misc settings
setopt CORRECT
bindkey -e          # Make zle use Emacs mode
bindkey "^[[A" history-beginning-search-backward # Bind Up arrow to a backward history search based on what has already been entered at the prompt
bindkey "^[[B" history-beginning-search-forward # Bind Up arrow to a forward history search based on what has already been entered at the prompt
export WORDCHARS='' # When jumping backward-word and forward-word stop at characters like '-' and '/' which is more like bash.

# Prompt (Pure - https://github.com/sindresorhus/pure)
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
zstyle :prompt:pure:path color '#41badf'
zstyle :prompt:pure:git:branch color '#eada4a'
zstyle ':prompt:pure:prompt:*' color '#e36743'
prompt pure

# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$(brew --prefix)/share/zsh-syntax-highlighting/highlighters"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Turn on completions
#fpath+="$(brew --prefix)/share/zsh/site-functions"
autoload -Uz compinit; compinit

# Source additional config
source ~/.zsh/aliases
source ~/.zsh/path
source ~/.zsh/var
source ~/.zsh/functions
source ~/.secrets/zsh
source ~/.secrets/ynab.zsh
source ~/.config/op/plugins.sh

# Setup LazyShell (shortcut: Option+G; docs: https://github.com/not-poma/lazyshell)
[ -f $HOME/.zsh/lazyshell ] && source $HOME/.zsh/lazyshell
