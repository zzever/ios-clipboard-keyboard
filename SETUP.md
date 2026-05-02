# Configuración del proyecto en Xcode

## 1. Crea el proyecto en Xcode

1. Abre Xcode → **File → New → Project**
2. Elige **iOS → App**
3. Nombre del producto: `ClipboardKeyboard`
4. Bundle ID: `com.tuempresa.clipboardkeyboard`
5. Interface: **UIKit**, Language: **Swift**

## 2. Añade la extensión de teclado

1. **File → New → Target**
2. Elige **Custom Keyboard Extension**
3. Nombre: `KeyboardExtension`
4. Xcode crea automáticamente la clase `KeyboardViewController`

## 3. Configura el App Group (para compartir datos)

El App Group permite que la extensión y la app contenedora compartan `UserDefaults`.

1. Selecciona el **target de la app** → **Signing & Capabilities**
2. Pulsa **+** → **App Groups**
3. Añade: `group.com.tuempresa.clipboardkeyboard`
4. Repite exactamente igual para el **target de la extensión**
5. Actualiza `appGroupIdentifier` en `ClipboardManager.swift` si usas otro identificador

## 4. Configura los Bundle IDs

| Target | Bundle ID sugerido |
|--------|-------------------|
| App contenedora | `com.tuempresa.clipboardkeyboard` |
| Extensión | `com.tuempresa.clipboardkeyboard.keyboard` |

## 5. Añade los archivos Swift

Copia los archivos de `KeyboardExtension/` al target de la extensión en Xcode.
Copia los de `ClipboardKeyboardApp/` al target principal.

## 6. Compila y prueba

1. Selecciona el esquema de la **app contenedora**
2. Conecta tu iPhone o usa el simulador
3. Ejecuta con ▶️
4. En el iPhone: **Ajustes → General → Teclado → Teclados → Añadir teclado**
5. Selecciona **Clipboard Keyboard**
6. Activa **Permitir acceso completo**

## 7. Instalación con AltStore (sin cuenta de pago)

1. Instala [AltStore](https://altstore.io) en tu Mac y tu iPhone
2. En Xcode: **Product → Archive**
3. Exporta como **Ad Hoc** o **Development**
4. Abre el `.ipa` con AltStore en el iPhone
5. AltStore renueva la firma automáticamente cada 7 días (cuenta gratuita)

## Notas importantes

- Con cuenta de desarrollador **gratuita**: la app expira cada 7 días, AltStore la renueva
- Con cuenta de **pago ($99/año)**: distribución por App Store o sin limitaciones
- El teclado funciona **sin acceso completo** pero el historial automático requiere activarlo
- Xcode 15+ y iOS 16+ recomendados
