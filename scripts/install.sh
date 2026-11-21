#!/usr/bin/env bash
#
# Compila y instala el teclado en el iPhone conectado por cable, en un solo paso.
#
# Uso:
#   DEVELOPMENT_TEAM=ABCDE12345 BUNDLE_ID_PREFIX=com.tunombre ./scripts/install.sh
#
# Variables:
#   DEVELOPMENT_TEAM  Team ID de tu cuenta de Apple (Xcode → Settings → Accounts)
#   BUNDLE_ID_PREFIX  prefijo único de los Bundle IDs (por defecto com.example)
#   DEVICE            UDID del iPhone (opcional; si no, usa el único conectado)
#   CONFIGURATION     Debug (por defecto) o Release
#
# Requiere macOS con Xcode 15+ y el iPhone conectado y desbloqueado.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEAM="${DEVELOPMENT_TEAM:-}"
PREFIX="${BUNDLE_ID_PREFIX:-com.example}"
DEVICE="${DEVICE:-}"
CONFIG="${CONFIGURATION:-Debug}"

die() { echo "error: $*" >&2; exit 1; }

command -v xcodebuild >/dev/null 2>&1 || die "xcodebuild no está disponible. Necesitas macOS con Xcode 15+."
[[ -n "$TEAM" ]] || die "define DEVELOPMENT_TEAM. Xcode → Settings → Accounts muestra el Team ID (10 caracteres)."
[[ "$PREFIX" != "com.example" ]] || die "define BUNDLE_ID_PREFIX con un prefijo único, por ejemplo com.tunombre."

if [[ -z "$DEVICE" ]]; then
    echo "==> Buscando iPhone conectado"
    TMP_JSON="$(mktemp -t devicectl).json"
    xcrun devicectl list devices --json-output "$TMP_JSON" >/dev/null
    DEVICE="$(python3 - "$TMP_JSON" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
devices = data.get("result", {}).get("devices", [])
users = []
for d in devices:
    conn = d.get("connectionProperties", {})
    state = (conn.get("tunnelState") or "").lower()
    hw = d.get("hardwareProperties", {})
    if hw.get("platform", "iOS") not in ("iOS", "iOS "):
        continue
    if state == "connected":
        users.append(d.get("identifier", ""))
if len(users) == 1:
    print(users[0])
elif len(users) > 1:
    names = []
    for d in devices:
        if d.get("identifier") in users:
            names.append(f"  DEVICE={d['identifier']}  ({d.get('deviceProperties', {}).get('name', '?')})")
    sys.stderr.write("Hay varios iPhone conectados, elige uno:\n" + "\n".join(names) + "\n")
PY
)" || true
    rm -f "$TMP_JSON"
    [[ -n "$DEVICE" ]] || die "no hay un iPhone conectado. Conéctalo por cable, desbloquéalo y confía en este Mac (o pasa DEVICE=<udid>)."
fi

echo "==> Compilando para el dispositivo $DEVICE"
xcodebuild \
    -project "$ROOT/ClipboardKeyboard.xcodeproj" \
    -scheme ClipboardKeyboard \
    -configuration "$CONFIG" \
    -destination "id=$DEVICE" \
    -derivedDataPath "$ROOT/build/DerivedData" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="$TEAM" \
    BUNDLE_ID_PREFIX="$PREFIX" \
    build

APP="$ROOT/build/DerivedData/Build/Products/$CONFIG-iphoneos/ClipboardKeyboard.app"
[[ -d "$APP" ]] || die "no se generó $APP"

echo "==> Instalando en el iPhone"
xcrun devicectl device install app --device "$DEVICE" "$APP"

cat <<'MSG'

✅ Instalado. Últimos pasos en el iPhone (una sola vez):
   1. Ajustes → General → VPN y gestión de dispositivos → confía en tu Apple ID.
   2. Ajustes → General → Teclado → Teclados → Añadir nuevo teclado → Clipboard Keyboard.
   3. Toca Clipboard Keyboard en la lista y activa "Permitir acceso completo".

En cualquier app, toca 🌐 hasta el teclado y pulsa 📋 para el historial.
MSG
