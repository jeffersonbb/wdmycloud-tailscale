#!/bin/sh
APKG_PATH=$(readlink -f "${1:-$(dirname "$0")}")
. "$APKG_PATH/common.sh"
BIN="$APKG_PATH/bin"
[ -x "$BIN/tailscaled" ] || { log "start: binario ausente, tentando baixar"; sh "$APKG_PATH/update.sh" >> "$LOG" 2>&1; }
[ -x "$BIN/tailscaled" ] || { log "start: sem binario, abortando"; exit 1; }
pidof tailscaled >/dev/null && { log "start: ja rodando"; exit 0; }

mkdir -p "$STATE_DIR" "$RUN_DIR"
log "start: iniciando tailscaled"
# userspace-networking: nao depende de modulo tun no kernel do NAS.
# Conexoes ao IP 100.x do NAS sao entregues aos servicos locais (SMB, painel).
nohup "$BIN/tailscaled" --tun=userspace-networking \
  --statedir="$STATE_DIR" --socket="$SOCKET" --port=41641 \
  >> /tmp/tailscaled.log 2>&1 &

# espera o socket
i=0; while [ ! -S "$SOCKET" ] && [ $i -lt 20 ]; do sleep 1; i=$((i+1)); done

# Painel web do Tailscale (login e status) so na rede local
LANIP=$(ip -4 addr show egiga0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
[ -n "$LANIP" ] || LANIP=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p')
[ -n "$LANIP" ] || LANIP=0.0.0.0
nohup "$BIN/tailscale" --socket="$SOCKET" web --listen "$LANIP:$WEB_PORT" >> /tmp/tailscale_web.log 2>&1 &
log "start: ok (painel em http://$LANIP:$WEB_PORT)"
