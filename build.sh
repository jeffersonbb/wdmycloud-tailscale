#!/bin/sh
# Gera o pacote .bin para o My Cloud EX2 Ultra (rodar em Linux x86_64, requer libxml2)
set -e
cd "$(dirname "$0")/package"
# O mksapkg assina com BF-CBC; no OpenSSL 3 isso exige o provider legacy
export OPENSSL_CONF="$(pwd)/../tools/openssl-legacy.cnf"
VERSION=$(awk '/^Version/{print $NF}' apkg.rc)
rm -f apkg.sign apkg.xml
../tools/mksapkg-OS5 -E -s -m MyCloudEX2Ultra > /tmp/mksapkg.log 2>&1
if grep -qi "error" /tmp/mksapkg.log; then cat /tmp/mksapkg.log; echo "ERRO ao gerar o pacote"; exit 1; fi
[ -s apkg.sign ] || { echo "ERRO: assinatura vazia"; exit 1; }
mkdir -p ../dist
for f in ../MyCloudEX2Ultra_tailscale_*.bin*; do mv "$f" "../dist/MyCloudEX2Ultra_tailscale_${VERSION}.bin"; done
echo "Pacote gerado em dist/MyCloudEX2Ultra_tailscale_${VERSION}.bin"
