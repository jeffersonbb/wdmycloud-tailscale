#!/bin/sh
# Baixa (ou atualiza) o Tailscale oficial para ARM. Pode ser rodado manualmente via SSH.
APKG_PATH=$(dirname "$(readlink -f "$0")")
. "$APKG_PATH/common.sh"
CA="$APKG_PATH/cacert.pem"
BASE=https://pkgs.tailscale.com/stable
TMP=/tmp/tailscale_dl
rm -rf "$TMP"; mkdir -p "$TMP" "$APKG_PATH/bin"

fetch() { curl -fsSL --cacert "$CA" "$1" -o "$2" || curl -fsSL "$1" -o "$2"; }

fetch "$BASE/?mode=json" "$TMP/idx.json" || { echo "ERRO: sem acesso a pkgs.tailscale.com"; exit 1; }
FILE=$(sed -n 's/.*"arm": *"\([^"]*\)".*/\1/p' "$TMP/idx.json" | head -1)
[ -n "$FILE" ] || { echo "ERRO: nao achei o pacote ARM no indice"; exit 1; }
echo "Baixando $FILE"
fetch "$BASE/$FILE" "$TMP/ts.tgz" || { echo "ERRO: download falhou"; exit 1; }

# Confere o SHA-256 publicado pela Tailscale
if fetch "$BASE/$FILE.sha256" "$TMP/ts.sha256"; then
  WANT=$(cut -c1-64 "$TMP/ts.sha256")
  GOT=$(sha256sum "$TMP/ts.tgz" | cut -c1-64)
  [ "$WANT" = "$GOT" ] || { echo "ERRO: SHA-256 nao confere, abortando"; exit 1; }
  echo "SHA-256 ok"
else
  echo "AVISO: nao foi possivel baixar o .sha256"
fi

tar -xzf "$TMP/ts.tgz" -C "$TMP" || exit 1
DIR=$(find "$TMP" -maxdepth 1 -type d -name 'tailscale_*' | head -1)
RUNNING=0; pidof tailscaled >/dev/null && RUNNING=1
[ $RUNNING = 1 ] && sh "$APKG_PATH/stop.sh"
cp -f "$DIR/tailscale" "$DIR/tailscaled" "$APKG_PATH/bin/"
chmod +x "$APKG_PATH/bin/"*
[ $RUNNING = 1 ] && sh "$APKG_PATH/start.sh" "$APKG_PATH"
rm -rf "$TMP"
echo "Tailscale instalado: $("$APKG_PATH/bin/tailscale" version | head -1)"
