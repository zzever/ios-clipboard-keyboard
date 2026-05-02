# iOS Clipboard Keyboard

Extensión de teclado personalizada para iOS con:
- 📋 **Historial del portapapeles** (hasta 20 entradas)
- ⌨️ **Teclado QWERTY en español** con acentos y ñ
- 😀 **Emojis** organizados por categorías
- 🔢 **Números y símbolos**

## Requisitos

- Xcode 15+
- iOS 16.0+
- Swift 5.9+
- Cuenta de desarrollador Apple (gratuita para sideload con AltStore)

## Estructura del proyecto

```
ios-clipboard-keyboard/
├── ClipboardKeyboardApp/          # App contenedora (obligatoria en iOS)
│   ├── AppDelegate.swift
│   ├── ViewController.swift
│   ├── Info.plist
│   └── Assets.xcassets/
├── KeyboardExtension/             # La extensión de teclado
│   ├── KeyboardViewController.swift   # Controlador principal
│   ├── ClipboardManager.swift         # Gestión del historial
│   ├── KeyboardView.swift             # Vista del teclado QWERTY
│   ├── EmojiView.swift                # Vista de emojis
│   ├── NumbersView.swift              # Vista de números/símbolos
│   ├── ClipboardHistoryView.swift     # Vista del historial
│   └── Info.plist
└── ios-clipboard-keyboard.xcodeproj/
```

## Instalación

### Con AltStore (sin pagar)
1. Instala [AltStore](https://altstore.io) en tu iPhone
2. Compila el proyecto en Xcode con tu Apple ID gratuito
3. Instálalo con AltStore
4. Ve a **Ajustes → General → Teclado → Teclados → Añadir teclado**
5. Selecciona **Clipboard Keyboard**
6. Activa **Permitir acceso completo** para el historial automático

### Con cuenta de desarrollador de pago
1. Compila y ejecuta directamente desde Xcode en tu dispositivo

## Permisos

### Acceso completo (Full Access)
Necesario para leer el portapapeles automáticamente desde otras apps.
iOS 16+ muestra una notificación cuando se lee el clipboard.

Sin acceso completo, el teclado funciona pero el historial debe guardarse manualmente.

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

## Personalización

Edita `ClipboardManager.swift` para cambiar:
- `maxHistoryItems`: número máximo de entradas en el historial (por defecto 20)
- `appGroupIdentifier`: identificador del App Group para compartir datos
