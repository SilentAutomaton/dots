#!/usr/bin/env bash
# Drives kill-if-idle.sh on a throwaway socket. Covers the two timings that are
# not reproducible by hand: a busy session must survive a detach, and a session
# a client is attaching to must never be killed. A shim on PATH points every
# tmux call, including the ones inside the script, at the test socket.
set -u
S=kiitest
T=$(cd "$(dirname "$0")" && pwd)/kill-if-idle.sh
shimdir=$(mktemp -d)
printf '#!/bin/sh\nexec /usr/bin/tmux -L %s "$@"\n' "$S" > "$shimdir/tmux"
chmod +x "$shimdir/tmux"
export PATH="$shimdir:$PATH"
tmux kill-server 2>/dev/null
trap 'tmux kill-server 2>/dev/null; rm -rf "$shimdir"' EXIT

fail() { echo "FAIL: $1"; exit 1; }
alive() { tmux has-session -t "$1" 2>/dev/null; }
sid() { tmux list-sessions -F '#{session_id}' -f "#{==:#{session_name},$1}"; }

tmux -f /dev/null new-session -d -s a || fail "setup a"

# 1. Detached and busy: the session survives. The pane goes idle: it dies.
tmux send-keys -t a 'sleep 12' Enter
sleep 1
"$T" "$(sid a)" &
sleep 8
alive a || fail "busy session was killed"
sleep 16
alive a && fail "idle session was not killed"
wait

# 2. Detached and idle, but a client is attaching: the session survives.
# The pty client needs stdin held open, or its hangup destroys the session
# and the test measures the harness instead of the script.
tmux -f /dev/null new-session -d -s b || fail "setup b"
"$T" "$(sid b)" & watcher=$!
sleep 1
sleep 30 | script -qc "tmux attach -t b" /dev/null >/dev/null 2>&1 & client=$!
sleep 10
alive b || fail "session killed under an attaching client"
kill $watcher $client 2>/dev/null
wait 2>/dev/null

echo PASS
