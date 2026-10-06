#!/bin/sh
# Variaveis comuns do pacote
APKG_NAME=tailscale
LOG=/tmp/tailscale_apkg.log
# Estado persistente no volume de dados (sobrevive a reboot e reinstalacao)
STATE_DIR=/mnt/HD/HD_a2/.systemfile/tailscale
RUN_DIR=/var/run/tailscale
SOCKET=$RUN_DIR/tailscaled.sock
WEB_PORT=5252
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }
