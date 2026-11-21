# iOS Clipboard Keyboard

Extensión de teclado personalizada para iOS con:
- 📋 **Historial del portapapeles** (hasta 20 entradas)
- ⌨️ **Teclado QWERTY en español** con acentos y ñ
- 😀 **Emojis** organizados por categorías
- 🔢 **Números y símbolos**

## Requisitos

- macOS con Xcode 15+
- iPhone con iOS 16.0+
- Swift 5.9+
- Apple ID (gratuito para sideload con Xcode o AltStore)

## Estructura del proyecto

```
ios-clipboard-keyboard/
├── ClipboardKeyboard.xcodeproj/       # Proyecto listo para abrir en Xcode
│   ├── project.pbxproj
│   └── xcshareddata/xcschemes/ClipboardKeyboard.xcscheme
├── ClipboardKeyboardApp/              # App contenedora (obligatoria en iOS)
│   ├── AppDelegate.swift
│   ├── ViewController.swift           # Pantalla de instrucciones
│   ├── Assets.xcassets/               # AppIcon + AccentColor
│   ├── ClipboardKeyboard.entitlements # App Group opcional
│   └── Info.plist
├── KeyboardExtension/                 # La extensión de teclado
│   ├── KeyboardViewController.swift   # Controlador principal
│   ├── ClipboardManager.swift         # Gestión del historial
│   ├── KeyboardView.swift             # Vista del teclado QWERTY
│   ├── EmojiView.swift                # Vista de emojis
│   ├── NumbersView.swift              # Vista de números/símbolos
│   ├── ClipboardHistoryView.swift     # Vista del historial
│   ├── KeyboardExtension.entitlements # App Group opcional
│   └── Info.plist
├── scripts
│   ├── install.sh                     # Compila e instala en el iPhone conectado
│   └── make_ipa.sh                    # Genera un .ipa para AltStore/Sideloadly
├── .github/workflows/build-ipa.yml    # Botón "Run workflow" que compila el .ipa
└── SETUP.md                           # Instalación paso a paso
```

## Instalación en un click

### Opción 1 — GitHub Actions (sin Mac, sin Xcode)

1. Pestaña **Actions** del repo → **Build IPA** → **Run workflow**.
2. Cuando acabe, descarga el artefacto **ClipboardKeyboard-ipa**.
3. Arrastra el `.ipa` a [Sideloadly](https://sideloadly.io) o [AltStore](https://altstore.io)
   con tu Apple ID y se instala en el iPhone.

### Opción 2 — un comando en el Mac (iPhone conectado por cable)

```bash
DEVELOPMENT_TEAM=ABCDE12345 BUNDLE_ID_PREFIX=com.tunombre ./scripts/install.sh
```

Compila, firma con tu Team, instala en el iPhone y te recuerda los 3 pasos finales.
El Team ID sale de Xcode → **Settings → Accounts**.

### Opción 3 — Xcode

Abre `ClipboardKeyboard.xcodeproj`, pon tu `BUNDLE_ID_PREFIX`, elige tu Team en los dos
targets y pulsa ▶️.

### Solo el .ipa (para firmar a mano)

```bash
./scripts/make_ipa.sh          # genera build/ClipboardKeyboard.ipa sin firmar
```

### Después de instalar (una sola vez)

1. **Ajustes → General → VPN y gestión de dispositivos** → confía en tu Apple ID.
2. **Ajustes → General → Teclado → Teclados → Añadir teclado → Clipboard Keyboard**.
3. Activa **Permitir acceso completo**.

Instrucciones detalladas y resolución de problemas en **[SETUP.md](SETUP.md)**.

## Permisos

### Acceso completo (Full Access)
Necesario para leer el portapapeles automáticamente desde otras apps.
iOS 16+ muestra una notificación cuando se lee el clipboard.

Sin acceso completo el teclado escribe con normalidad, pero el historial queda vacío
porque iOS no permite leer `UIPasteboard` a una extensión sin acceso completo.

## Uso

| Botón | Acción |
|-------|--------|
| 📋 | Abre el historial del portapapeles |
| 😀 | Cambia a vista de emojis |
| 123 | Cambia a números y símbolos |
| ABC | Vuelve al teclado QWERTY |
| ⇧ | Mayúsculas |
| ⌫ | Borrar |
| Espacio | Insertar espacio |
| ↩ | Retorno |
| 🌐 | Siguiente teclado |

## Personalización

En `KeyboardExtension/ClipboardManager.swift`:
- `maxHistoryItems`: número máximo de entradas en el historial (por defecto 20)
- `clipboardHistoryKey`: clave de `UserDefaults` donde se guarda el historial

En Xcode (Build Settings):
- `BUNDLE_ID_PREFIX`: prefijo común de los Bundle IDs de app y extensión
- `CLIPBOARD_APP_GROUP`: App Group para compartir el historial con la app contenedora
  (opcional, requiere cuenta de pago; ver SETUP.md)
