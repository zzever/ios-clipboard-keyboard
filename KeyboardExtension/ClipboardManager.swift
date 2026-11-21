import Foundation
import UIKit

// Almacenamiento del historial.
//
// Por defecto se usa el UserDefaults de la propia extensión: no requiere cuenta
// de desarrollador de pago y el teclado (que es quien captura y muestra el
// historial) funciona igual.
//
// Para compartir el historial con la app contenedora, define el build setting
// CLIPBOARD_APP_GROUP (por ejemplo group.com.tuempresa.clipboardkeyboard),
// activa los .entitlements de ambos targets y registra el App Group en tu
// cuenta de desarrollador. Ver SETUP.md.
let clipboardHistoryKey = "clipboard_history"
let maxHistoryItems = 20

enum ClipboardStorage {
    private static let appGroupInfoKey = "ClipboardAppGroup"

    /// App Group realmente disponible en runtime (nil si no hay o no está firmado).
    /// `containerURL(forSecurityApplicationGroupIdentifier:)` devuelve nil cuando el
    /// perfil de firma no incluye el grupo, así que sirve como comprobación real.
    static var appGroupIdentifier: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: appGroupInfoKey) as? String else {
            return nil
        }
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !name.contains("$"),
              FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: name) != nil
        else { return nil }
        return name
    }

    static var defaults: UserDefaults {
        if let name = appGroupIdentifier, let shared = UserDefaults(suiteName: name) {
            return shared
        }
        return .standard
    }
}

class ClipboardManager {
    static let shared = ClipboardManager()

    private var history: [ClipboardItem] = []

    private init() {
        loadHistory()
    }

    // MARK: - Modelo

    struct ClipboardItem: Codable, Identifiable {
        let id: UUID
        let text: String
        let date: Date

        init(text: String) {
            self.id = UUID()
            self.text = text
            self.date = Date()
        }
    }

    // MARK: - Acceso al historial

    var items: [ClipboardItem] { history }

    /// Añade un item al historial (evita duplicados consecutivos)
    func add(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        // Evitar duplicado al inicio
        if history.first?.text == text { return }
        let item = ClipboardItem(text: text)
        history.insert(item, at: 0)
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        saveHistory()
    }

    /// Elimina un item por id
    func remove(id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }

    /// Limpia todo el historial
    func clearAll() {
        history.removeAll()
        saveHistory()
    }

    // MARK: - Persistencia via App Groups (UserDefaults compartido)

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            ClipboardStorage.defaults.set(data, forKey: clipboardHistoryKey)
        }
    }

    private func loadHistory() {
        guard let data = ClipboardStorage.defaults.data(forKey: clipboardHistoryKey),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data)
        else { return }
        history = decoded
    }

    // MARK: - Captura automática del portapapeles del sistema
    // Requiere "Acceso Completo" activado en Ajustes

    func captureSystemClipboard() {
        if let text = UIPasteboard.general.string, !text.isEmpty {
            add(text: text)
        }
    }

    /// Vuelve a leer el historial guardado (por si otra instancia lo modificó)
    func reloadFromStorage() {
        loadHistory()
    }
}
