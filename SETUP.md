# Instalar en un iPhone

El proyecto ya está creado (`ClipboardKeyboard.xcodeproj`) con los dos targets:
la app contenedora `ClipboardKeyboard` y la extensión de teclado `KeyboardExtension`.
No hay que crear nada a mano: abre el proyecto y compila.

Requisitos: macOS con **Xcode 15 o superior**, un iPhone con **iOS 16+** y un Apple ID
(gratuito o de pago).

---

## 1. Pon un Bundle ID propio

Los Bundle IDs son de ejemplo (`com.example...`) y Apple no permite firmar con ellos.
Puedes cambiarlos de una sola vez:

1. Abre el proyecto en Xcode.
2. Selecciona el proyecto (arriba a la izquierda) → pestaña **Build Settings** → busca
   `BUNDLE_ID_PREFIX`.
3. Cámbialo por algo único, por ejemplo `com.tunombre`.

Con eso quedan:

| Target | Bundle ID |
|--------|-----------|
| App contenedora | `com.tunombre.ClipboardKeyboard` |
| Extensión | `com.tunombre.ClipboardKeyboard.Keyboard` |

## 2. Firma

1. Selecciona el target **ClipboardKeyboard** → **Signing & Capabilities**.
2. Marca **Automatically manage signing** y elige tu **Team** (tu Apple ID).
3. Repite lo mismo en el target **KeyboardExtension** con el **mismo Team**.
4. Comprueba que la extensión hereda el bundle ID de la app como prefijo
   (`...ClipboardKeyboard.Keyboard`).

## 3. Compilar e instalar

### Opción rápida — un comando o un botón

**Mac con el iPhone conectado por cable** (hace los pasos 1 y 2 por ti):

```bash
DEVELOPMENT_TEAM=ABCDE12345 BUNDLE_ID_PREFIX=com.tunombre ./scripts/install.sh
```

Compila, firma con `-allowProvisioningUpdates` e instala en el iPhone.

**Sin Mac ni Xcode instalados**: en GitHub → pestaña **Actions** → **Build IPA** →
**Run workflow** → descarga el artefacto `ClipboardKeyboard-ipa` y fírmalo con
Sideloadly o AltStore.

Las opciones A y B siguientes son el camino manual.

### Opción A — directo desde Xcode (cuenta de pago o gratuita)

1. Conecta el iPhone y confía en el ordenador.
2. Elige el esquema **ClipboardKeyboard** y tu iPhone como destino.
3. ▶️ Run.
4. En el iPhone, si aparece "Desarrollador no verificado":
   **Ajustes → General → VPN y gestión de dispositivos → Confiar en tu Apple ID**.
5. Con cuenta gratuita la app caduca a los 7 días; vuelve a ejecutar desde Xcode para renovarla.

### Opción B — AltStore / Sideloadly (cuenta gratuita)

```bash
./scripts/make_ipa.sh
```

Genera `build/ClipboardKeyboard.ipa` (sin firmar). Luego:

1. Instala [AltStore](https://altstore.io) o [Sideloadly](https://sideloadly.io) en el Mac.
2. Arrastra el `.ipa` y firma con tu Apple ID.
3. Instala en el iPhone y confía en el perfil de desarrollador.

AltStore renueva la firma automáticamente cada 7 días mientras el Mac esté en la misma red.

## 4. Activar el teclado

1. **Ajustes → General → Teclado → Teclados → Añadir nuevo teclado**.
2. Elige **Clipboard Keyboard**.
3. Toca **Clipboard Keyboard** en la lista y activa **Permitir acceso completo**.
   Sin acceso completo el teclado escribe, pero iOS no le deja leer el portapapeles,
   así que el historial se queda vacío.

En cualquier app, toca el 🌐 hasta llegar al teclado y pulsa **📋**.

---

## App Group (opcional, solo cuenta de pago)

Por defecto el historial se guarda en el contenedor de la propia extensión. Eso es lo
que permite instalarlo con un Apple ID gratuito, porque **una cuenta gratuita no puede
registrar App Groups**. El teclado captura y muestra el historial igual.

Si tienes cuenta de pago y quieres que la app contenedora lea el mismo historial:

1. Build Settings → añade `CLIPBOARD_APP_GROUP = group.com.tunombre.clipboardkeyboard`
   (sustituye `com.tunombre` por tu prefijo).
2. En cada target → **Build Settings → Code Signing Entitlements**, indica:
   - app: `ClipboardKeyboardApp/ClipboardKeyboard.entitlements`
   - extensión: `KeyboardExtension/KeyboardExtension.entitlements`
3. Registra el App Group `group.com.tunombre.clipboardkeyboard` en
   [developer.apple.com](https://developer.apple.com) → Identifiers y actívalo en los
   App IDs de la app y de la extensión.

Si activas los entitlements sin tener el App Group registrado, la instalación falla en
la firma. El código detecta en runtime si el grupo no está disponible y cae de vuelta
al almacenamiento local, así que quitarlos no rompe nada.

## Comprobaciones rápidas

```bash
# Compilar para el simulador sin firmar
xcodebuild -project ClipboardKeyboard.xcodeproj -scheme ClipboardKeyboard \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
```

El simulador sirve para ver la app contenedora, pero **no** para probar el teclado:
los teclados de terceros solo funcionan en dispositivo real.

## Problemas habituales

| Síntoma | Causa / solución |
|---------|------------------|
| "Failed to register bundle identifier" | El `BUNDLE_ID_PREFIX` no es único, o el Team no está seleccionado en los dos targets. |
| "Provisioning profile doesn't include the application-identifier" | La extensión tiene un bundle ID que no empieza por el de la app. |
| El teclado no aparece en Ajustes | La extensión no se copió dentro de la app (fase *Embed App Extensions*), o el iPhone no ha terminado de instalar. Reinicia el iPhone. |
| El teclado aparece pero el historial está vacío | Falta activar **Permitir acceso completo**. |
| Tras unos días deja de abrirse | Caducó la firma gratuita: vuelve a ejecutar desde Xcode o deja que AltStore la renueve. |
