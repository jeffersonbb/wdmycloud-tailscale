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

# --- Funcoes auxiliares (o BusyBox do My Cloud OS 5 nao tem todos os comandos) ---

# Imprime o SHA-256 de um arquivo usando o que estiver disponivel
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -c1-64
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$1" | sed 's/.*= *//' | cut -c1-64
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$1"
  else
    return 1
  fi
}

# PIDs de processos cuja linha de comando contenha o texto (sem depender de pidof/pgrep)
pids_of() {
  ps w 2>/dev/null | grep -F -e "$1" | grep -v -e grep -e 'stop.sh' -e 'start.sh' | awk -v me="$$" '$1 != me {print $1}'
}

ts_running() { [ -n "$(pids_of 'tailscaled --tun=userspace')" ]; }

# IP da rede local do NAS
lan_ip() {
  _ip=""
  if command -v ip >/dev/null 2>&1; then
    _ip=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p' | head -1)
  fi
  if [ -z "$_ip" ] && command -v ifconfig >/dev/null 2>&1; then
    for _if in egiga0 bond0 eth0; do
      _ip=$(ifconfig "$_if" 2>/dev/null | sed -n 's/.*inet addr:\([0-9.]*\).*/\1/p' | head -1)
      [ -n "$_ip" ] && break
    done
  fi
  echo "${_ip:-0.0.0.0}"
}
