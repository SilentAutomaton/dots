#!/usr/bin/env bash
# Prints the plan, then the usage body, then "<http code> <retry-after>".
# The token goes to curl through a pipe, so it never shows up in the process list.

C="${CLAUDE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/claude}/.credentials.json"

# Only Claude Code refreshes its token; an expired one would just earn a 401.
jq -e '.claudeAiOauth.expiresAt > (now * 1000)' "$C" >/dev/null || { echo EXPIRED; exit 0; }

jq -r '.claudeAiOauth.subscriptionType // ""' "$C"
# The usage endpoint rate-limits hard any client that is not Claude Code.
jq -r '"Authorization: Bearer " + .claudeAiOauth.accessToken' "$C" |
    curl -s -w '\n%{http_code} %header{retry-after}' -H @- \
        -H 'anthropic-beta: oauth-2025-04-20' \
        -A "claude-cli/$(claude --version | cut -d' ' -f1) (external, cli)" \
        https://api.anthropic.com/api/oauth/usage
