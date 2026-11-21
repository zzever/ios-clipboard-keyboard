#!/bin/bash
#
# Doble click en el Finder para instalar el teclado en el iPhone conectado.
# Te pide el Team ID y el prefijo de Bundle ID, y hace el resto.

cd "$(dirname "$0")" || exit 1

titulo="Clipboard Keyboard"

pedir() {
    osascript -e "text returned of (display dialog \"$1\" default answer \"$2\" with title \"$titulo\" buttons {\"Instalar\", \"Cancelar\"} default button 1)"
}

TEAM="$(pedir "Team ID de tu Apple ID (Xcode → Settings → Accounts). Son 10 caracteres." "")" || exit 0
[[ -n "$TEAM" ]] || { echo "Necesitas el Team ID de tu Apple ID."; read -r -p "Enter para cerrar…"; exit 1; }

PREFIX="$(pedir "Prefijo único de Bundle ID (por ejemplo com.tunombre)." "com.")" || exit 0
[[ -n "$PREFIX" ]] || { echo "Necesitas un prefijo de Bundle ID."; read -r -p "Enter para cerrar…"; exit 1; }

echo "Instalando con Team $TEAM y Bundle ID $PREFIX.ClipboardKeyboard…"
echo

DEVELOPMENT_TEAM="$TEAM" BUNDLE_ID_PREFIX="$PREFIX" ./scripts/install.sh
estado=$?

echo
if [[ $estado -eq 0 ]]; then
    echo "🎉 Terminado."
else
    echo "❌ Algo falló (código $estado). Revisa el mensaje de arriba."
fi
read -r -p "Pulsa Enter para cerrar…"
exit $estado
