#!/usr/bin/env bash
#
# Genera un .ipa SIN firmar a partir del proyecto, listo para que AltStore,
# Sideloadly o Xcode lo firmen con tu Apple ID.
#
# Uso:   ./scripts/make_ipa.sh [directorio_de_salida]
# Salida: <salida>/ClipboardKeyboard.ipa
#
# Variables de entorno opcionales:
#   BUNDLE_ID_PREFIX     prefijo de los Bundle IDs (por defecto com.example)
#   CLIPBOARD_APP_GROUP  App Group, solo si ya activaste los .entitlements
#
# Requiere macOS con Xcode 15+ (xcodebuild).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/build}"
PREFIX="${BUNDLE_ID_PREFIX:-com.example}"
APP_GROUP="${CLIPBOARD_APP_GROUP:-}"

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "error: xcodebuild no está disponible. Ejecuta este script en macOS con Xcode instalado." >&2
    exit 1
fi

PROJECT="$ROOT/ClipboardKeyboard.xcodeproj"
SCHEME="ClipboardKeyboard"
ARCHIVE="$OUT/ClipboardKeyboard.xcarchive"

echo "==> Limpiando $OUT"
rm -rf "$OUT/Payload" "$OUT/ClipboardKeyboard.ipa"
mkdir -p "$OUT"

echo "==> Archivando (sin firma) con BUNDLE_ID_PREFIX=$PREFIX"
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE" \
    -derivedDataPath "$OUT/DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    BUNDLE_ID_PREFIX="$PREFIX" \
    CLIPBOARD_APP_GROUP="$APP_GROUP" \
    archive

APP="$ARCHIVE/Products/Applications/ClipboardKeyboard.app"
if [[ ! -d "$APP" ]]; then
    echo "error: no se encontró $APP. Revisa la salida de xcodebuild." >&2
    exit 1
fi

if [[ ! -d "$APP/PlugIns/KeyboardExtension.appex" ]]; then
    echo "error: la extensión de teclado no se empaquetó dentro de la app." >&2
    exit 1
fi

echo "==> Empaquetando Payload"
mkdir -p "$OUT/Payload"
cp -R "$APP" "$OUT/Payload/"

# La app sin firmar trae una firma vacía de la extensión que confunde a algunos
# instaladores; se elimina para que el firmado posterior sea limpio.
rm -rf "$OUT/Payload/ClipboardKeyboard.app/PlugIns/KeyboardExtension.appex/_CodeSignature"
rm -rf "$OUT/Payload/ClipboardKeyboard.app/_CodeSignature"

( cd "$OUT" && /usr/bin/zip -qry ClipboardKeyboard.ipa Payload )

echo
echo "Listo: $OUT/ClipboardKeyboard.ipa  (bundle ID: $PREFIX.ClipboardKeyboard)"
echo "Instálalo con AltStore (Sideloadly) usando tu Apple ID."
