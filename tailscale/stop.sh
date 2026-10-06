#!/bin/sh
APKG_PATH=$(readlink -f "${1:-$(dirname "$0")}")
. "$APKG_PATH/common.sh"
log "stop"
for p in $(pids_of ' web --listen '); do kill "$p" 2>/dev/null; done
for p in $(pids_of 'tailscaled --tun=userspace'); do kill "$p" 2>/dev/null; done
i=0; while ts_running && [ $i -lt 10 ]; do sleep 1; i=$((i+1)); done
for p in $(pids_of 'tailscaled --tun=userspace'); do kill -9 "$p" 2>/dev/null; done
exit 0
