#!/usr/bin/env bash
# Kill a tmux session once its last client is gone and every pane sits at an
# idle login shell. Wired to the client-detached hook in tmux.conf. A busy
# session is watched instead of killed, so it still goes away when the job
# finishes after the window was closed. Always exits 0: run-shell reports a
# non-zero status to the next client that attaches.
#
# Takes a session id ($3), never a name. .zshrc recycles the names 0, 1, 2 ...
# for new windows, so a name can point at a different session by the time this
# wakes up. Uses list-clients, not display-message: display-message answers an
# unknown target with an empty string and status 0, which reads as "nobody is
# attached" and kills live windows.
session=$1
shell=$(basename "$SHELL")

free() {
  local clients
  clients=$(tmux list-clients -t "$session" -F x 2>/dev/null) || return 1
  [[ -z $clients ]]
}

# A pane is idle only when it sits in the login shell and that shell has no
# children. pane_current_command alone misses a backgrounded or disowned job.
busy() {
  local pid cmd
  while read -r pid cmd; do
    [[ $cmd == "$shell" ]] || return 0
    [[ -z $(pgrep -P "$pid") ]] || return 0
  done < <(tmux list-panes -t "$session" -s -F '#{pane_pid} #{pane_current_command}' 2>/dev/null)
  return 1
}

while :; do
  free || exit 0
  if ! busy; then
    # .zshrc picks a free session, then execs tmux attach-session. The session
    # reads as unattached for as long as that handshake takes, so confirm it is
    # still free before the kill.
    sleep 3
    free || exit 0
    busy || { tmux kill-session -t "$session"; exit 0; }
  fi
  sleep 15
done
