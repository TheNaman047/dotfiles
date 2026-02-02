# zmodload zsh/zprof  ## Uncomment this & the last line to enable zsh-profiling
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Source/Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load starship theme
# line 1: `starship` binary as command, from github release
# line 2: starship setup at clone(create init.zsh, completion)
# line 3: pull behavior same as clone, source init.zsh
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Add in zsh plugins
zinit wait lucid for \
  zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  Aloxaf/fzf-tab \
  dominik-schwabe/zsh-fnm

# zsh-completions needs special handling to update FPATH
zinit wait lucid atpull'zinit creinstall -q .' for \
  zsh-users/zsh-completions

# Check for macos for configuring brew
if type brew &>/dev/null
then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
# Load completions
# zinit cclear
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
zinit cdreplay -q

# Load bash completions for tools like terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# Key Bindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -r '^L'

# History Config
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias lg='lazygit'
alias oil='~/.local/bin/oil-ssh.sh'

# Key Maps
# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Lazy Load miniconda
# source $HOME/.config/miniconda/.zsh_lazyload_conda.sh

# fnm
FNM_PATH="/home/naman47/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/naman47/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

myip() {
    local ip=$(curl -s -4 ifconfig.me)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo -n "$ip" | pbcopy
        echo "Public IPv4 copied to clipboard: $ip"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - try different clipboard tools
        if command -v xclip &> /dev/null; then
            echo -n "$ip" | xclip -selection clipboard
            echo "Public IPv4 copied to clipboard: $ip"
        elif command -v xsel &> /dev/null; then
            echo -n "$ip" | xsel --clipboard --input
            echo "Public IPv4 copied to clipboard: $ip"
        elif command -v wl-copy &> /dev/null; then
            echo -n "$ip" | wl-copy
            echo "Public IPv4 copied to clipboard: $ip"
        else
            echo "Public IPv4: $ip"
            echo "No clipboard tool found. Install xclip, xsel, or wl-clipboard."
        fi
    else
        echo "Public IPv4: $ip"
        echo "Clipboard copy not supported on this platform."
    fi
}
# zprof
