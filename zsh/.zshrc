### Settings
# TERM is set by the terminal itself (kitty: xterm-kitty, tmux: tmux-256color).
# Only fall back when it is missing or useless.
[[ -z $TERM || $TERM == dumb || $TERM == unknown ]] && export TERM="xterm-256color"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/.histfile
setopt histignorealldups sharehistory

# Non-interactive shells (scripts, Claude Code subshells) need the env, nothing else.
[[ -o interactive ]] || { source "$HOME/.sh/env"; return }

### tmux: auto-attach in an interactive GUI terminal only.
### Runs before the includes: the outer shell execs away, so it must not pay
### for pyenv or the aliases, and $PATH must not be built twice.
### One session per terminal window: take the first session nobody is looking
### at, otherwise start a fresh one. Closing a window leaves its session alive
### for the next window to pick up.
if [[ -z $TMUX && -z $SSH_CONNECTION && -z $CLAUDECODE && -z $VSCODE_INJECTION \
      && -z $INSIDE_EMACS && -z $NO_TMUX && $(tty) != /dev/tty[0-9]* ]] \
   && command -v tmux >/dev/null; then
  _free=$(tmux list-sessions -F '#{session_attached} #{session_name}' 2>/dev/null \
          | awk '$1 == 0 { print substr($0, index($0, " ") + 1); exit }')
  if [[ -n $_free ]]; then
    exec tmux attach-session -t "$_free"
  else
    _sn=0
    while tmux has-session -t "=$_sn" 2>/dev/null; do
      _sn=$((_sn + 1))
    done
    exec tmux new-session -s "$_sn"
  fi
fi

### Includes
source "$HOME/.sh/env"
source "$HOME/.sh/aliases"

### ZSH plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


### Substring search bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

### SETTING THE STARSHIP PROMPT
eval "$(starship init zsh)"

### Zoxide
eval "$(zoxide init zsh)"
alias cd="z"

### Header
echo "#!/bin/zsh\n"
fortune
if [[ -s /var/mail/silent ]]; then
    _n=$(awk '/^From /{if(in_msg && !read) c++; in_msg=1; read=0} /^Status:/{if($2~/R/) read=1} END{if(in_msg && !read) c++; print c+0}' /var/mail/silent 2>/dev/null)
    [[ "${_n}" -gt 0 ]] && print "\n📬 ${_n}"
    unset _n
fi

#autoload bashcompinit
#bashcompinit
#source /usr/share/nvm/init-nvm.sh

### yazi wrapper: leave yazi in the directory it was closed in
y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
