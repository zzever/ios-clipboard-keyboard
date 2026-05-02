import UIKit

/// Controlador principal de la extensión de teclado.
/// Gestiona los paneles: QWERTY, Números, Emojis e Historial.
class KeyboardViewController: UIInputViewController {

    // Vistas de cada panel
    private var keyboardView: KeyboardView!
    private var numbersView: NumbersView!
    private var emojiView: EmojiView!
    private var clipboardHistoryView: ClipboardHistoryView!

    // Panel activo
    enum Panel { case qwerty, numbers, emoji, clipboard }
    private var currentPanel: Panel = .qwerty

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupPanels()
        showPanel(.qwerty)
        // Si tenemos acceso completo, capturamos el clipboard al aparecer
        if hasFullAccess {
            ClipboardManager.shared.captureSystemClipboard()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasFullAccess {
            ClipboardManager.shared.captureSystemClipboard()
        }
    }

    // MARK: - Setup

    private func setupPanels() {
        // QWERTY
        keyboardView = KeyboardView()
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)

        // Números
        numbersView = NumbersView()
        numbersView.delegate = self
        numbersView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numbersView)

        // Emojis
        emojiView = EmojiView()
        emojiView.delegate = self
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiView)

        // Historial portapapeles
        clipboardHistoryView = ClipboardHistoryView()
        clipboardHistoryView.delegate = self
        clipboardHistoryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipboardHistoryView)

        // Constraints para que todos ocupen toda la vista
        for panel in [keyboardView, numbersView, emojiView, clipboardHistoryView] as [UIView] {
            NSLayoutConstraint.activate([
                panel.topAnchor.constraint(equalTo: view.topAnchor),
                panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                panel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }

    // MARK: - Panel switching

    func showPanel(_ panel: Panel) {
        currentPanel = panel
        keyboardView.isHidden = panel != .qwerty
        numbersView.isHidden = panel != .numbers
        emojiView.isHidden = panel != .emoji
        clipboardHistoryView.isHidden = panel != .clipboard
        if panel == .clipboard {
            clipboardHistoryView.reload()
        }
    }

    // MARK: - Input helpers

    func insert(_ text: String) {
        textDocumentProxy.insertText(text)
    }

    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }

    func insertNewline() {
        textDocumentProxy.insertText("\n")
    }
}

// MARK: - KeyboardViewDelegate

extension KeyboardViewController: KeyboardViewDelegate {
    func keyboardView(_ view: KeyboardView, didTapKey key: String) {
        insert(key)
    }
    func keyboardViewDidTapDelete(_ view: KeyboardView) {
        deleteBackward()
    }
    func keyboardViewDidTapReturn(_ view: KeyboardView) {
        insertNewline()
    }
    func keyboardViewDidTapNumbers(_ view: KeyboardView) {
        showPanel(.numbers)
    }
    func keyboardViewDidTapEmoji(_ view: KeyboardView) {
        showPanel(.emoji)
    }
    func keyboardViewDidTapClipboard(_ view: KeyboardView) {
        showPanel(.clipboard)
    }
    func keyboardViewDidTapNextKeyboard(_ view: KeyboardView) {
        advanceToNextInputMode()
    }
}

// MARK: - NumbersViewDelegate

extension KeyboardViewController: NumbersViewDelegate {
    func numbersView(_ view: NumbersView, didTapKey key: String) {
        insert(key)
    }
    func numbersViewDidTapDelete(_ view: NumbersView) {
        deleteBackward()
    }
    func numbersViewDidTapABC(_ view: NumbersView) {
        showPanel(.qwerty)
    }
    func numbersViewDidTapClipboard(_ view: NumbersView) {
        showPanel(.clipboard)
    }
}

// MARK: - EmojiViewDelegate

extension KeyboardViewController: EmojiViewDelegate {
    func emojiView(_ view: EmojiView, didSelectEmoji emoji: String) {
        insert(emoji)
    }
    func emojiViewDidTapABC(_ view: EmojiView) {
        showPanel(.qwerty)
    }
}

// MARK: - ClipboardHistoryViewDelegate

extension KeyboardViewController: ClipboardHistoryViewDelegate {
    func clipboardHistoryView(_ view: ClipboardHistoryView, didSelectText text: String) {
        insert(text)
        showPanel(.qwerty)
    }
    func clipboardHistoryViewDidTapClose(_ view: ClipboardHistoryView) {
        showPanel(.qwerty)
    }
}
