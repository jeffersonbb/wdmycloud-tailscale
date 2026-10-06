#!/bin/sh
# Chamado pelo instalador: $1 = pasta temporaria do pacote, $2 = Nas_Prog
SRC=$(readlink -f "$1")
NAS_PROG=$(readlink -f "$2")
APKG_PATH="$NAS_PROG/tailscale"
. "$SRC/common.sh"

log "install: $SRC -> $APKG_PATH"
cp -rf "$SRC" "$NAS_PROG"
mkdir -p "$STATE_DIR" "$APKG_PATH/bin"
sh "$APKG_PATH/update.sh" >> "$LOG" 2>&1 || log "install: download falhou (veja acima)"
log "install: concluido"
