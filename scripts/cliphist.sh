#!/usr/bin/env bash
set -euo pipefail

# Launch wl-paste watchers once per session. Existing instances are left intact.
require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'cliphist.sh: missing dependency: %s\n' "$1" >&2
        return 1
    fi
}

if ! require_cmd wl-paste || ! require_cmd cliphist; then
    exit 0
fi

ensure_watcher() {
    local type="$1"
    local pattern="wl-paste --type ${type} --watch cliphist store"

    if pgrep -f "$pattern" >/dev/null 2>&1; then
        return
    fi

    nohup wl-paste --type "$type" --watch cliphist store >/dev/null 2>&1 &
}

ensure_watcher text
ensure_watcher image

exit 0
