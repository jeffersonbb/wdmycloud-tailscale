#!/bin/sh
APKG_PATH=$(readlink -f "${1:-$(dirname "$0")}")
. "$APKG_PATH/common.sh"
BIN="$APKG_PATH/bin"
[ -x "$BIN/tailscaled" ] || { log "start: binario ausente, tentando baixar"; sh "$APKG_PATH/update.sh" >> "$LOG" 2>&1; }
[ -x "$BIN/tailscaled" ] || { log "start: sem binario, abortando"; exit 1; }
ts_running && { log "start: ja rodando"; exit 0; }

mkdir -p "$STATE_DIR" "$RUN_DIR"
log "start: iniciando tailscaled"
# userspace-networking: nao depende de modulo tun no kernel do NAS.
# Conexoes ao IP 100.x do NAS sao entregues aos servicos locais (SMB, painel).
"$BIN/tailscaled" --tun=userspace-networking \
  --statedir="$STATE_DIR" --socket="$SOCKET" --port=41641 \
  </dev/null >> /tmp/tailscaled.log 2>&1 &

# espera o socket
i=0; while [ ! -S "$SOCKET" ] && [ $i -lt 20 ]; do sleep 1; i=$((i+1)); done
[ -S "$SOCKET" ] || log "start: AVISO socket nao apareceu em 20 s (veja /tmp/tailscaled.log)"

# Painel web do Tailscale (login e status), apenas na rede local
LANIP=$(lan_ip)
"$BIN/tailscale" --socket="$SOCKET" web --listen "$LANIP:$WEB_PORT" \
  </dev/null >> /tmp/tailscale_web.log 2>&1 &
log "start: ok (painel em http://$LANIP:$WEB_PORT)"
