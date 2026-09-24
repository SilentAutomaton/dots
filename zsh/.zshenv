# Non-interactive zsh reads only this file, not .zshrc.
# Scripts and `zsh -c` need the XDG variables, otherwise tools fall back
# to ~/.<tool> and clutter $HOME again.
set -a; . "$HOME/.config/environment.d/10-xdg.conf"; set +a

export HERMES_HOME="$HOME/.config/hermes"
