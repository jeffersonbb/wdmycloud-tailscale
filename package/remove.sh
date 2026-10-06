#!/bin/sh
# Remove o app. O login fica guardado em .systemfile/tailscale
# (apague manualmente se quiser desvincular de vez).
APKG_PATH=$(readlink -f "$1")
sh "$APKG_PATH/stop.sh" "$APKG_PATH" 2>/dev/null
rm -rf "$APKG_PATH" /var/www/apps/tailscale
