#!/bin/sh
# Chamado no boot e apos a instalacao: liga a pagina do app no painel
APKG_PATH=$(readlink -f "$1")
WEBPATH=/var/www/apps/tailscale
mkdir -p "$WEBPATH"
ln -sf "$APKG_PATH"/web/* "$WEBPATH"/
