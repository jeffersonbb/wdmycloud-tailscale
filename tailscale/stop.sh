#!/bin/sh
APKG_PATH=$(readlink -f "${1:-$(dirname "$0")}")
. "$APKG_PATH/common.sh"
log "stop"
pkill -f "tailscale.* web --listen" 2>/dev/null || true
killall tailscaled 2>/dev/null
sleep 2
killall -9 tailscaled 2>/dev/null || true
