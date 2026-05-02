import Foundation
import UIKit

// Compartir datos entre app contenedora y extensión via App Groups
// Configura tu propio App Group en Xcode: Signing & Capabilities → App Groups
let appGroupIdentifier = "group.com.tuempresa.clipboardkeyboard"
let clipboardHistoryKey = "clipboard_history"
let maxHistoryItems = 20

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
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: clipboardHistoryKey)
        }
    }

    private func loadHistory() {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: clipboardHistoryKey),
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
}
