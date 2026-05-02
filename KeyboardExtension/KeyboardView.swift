import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func keyboardView(_ view: KeyboardView, didTapKey key: String)
    func keyboardViewDidTapDelete(_ view: KeyboardView)
    func keyboardViewDidTapReturn(_ view: KeyboardView)
    func keyboardViewDidTapNumbers(_ view: KeyboardView)
    func keyboardViewDidTapEmoji(_ view: KeyboardView)
    func keyboardViewDidTapClipboard(_ view: KeyboardView)
    func keyboardViewDidTapNextKeyboard(_ view: KeyboardView)
}

/// Teclado QWERTY en español con mayúsculas/minúsculas, acentos y ñ
class KeyboardView: UIView {

    weak var delegate: KeyboardViewDelegate?
    private var isShifted = false
    private var stackView: UIStackView!

    // Distribución QWERTY español
    private let rowsLower = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l","ñ"],
        ["z","x","c","v","b","n","m"]
    ]
    private let rowsUpper = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L","Ñ"],
        ["Z","X","C","V","B","N","M"]
    ]
    // Fila de acentos y caracteres especiales españoles
    private let accentRow = ["á","é","í","ó","ú","ü","¿","¡"]
    private let accentRowUpper = ["Á","É","Í","Ó","Ú","Ü","¿","¡"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build layout

    private func buildLayout() {
        subviews.forEach { $0.removeFromSuperview() }

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])

        let rows = isShifted ? rowsUpper : rowsLower
        let accents = isShifted ? accentRowUpper : accentRow

        // Fila de acentos
        stackView.addArrangedSubview(makeKeyRow(keys: accents, height: 36))

        // Filas QWERTY
        for row in rows {
            stackView.addArrangedSubview(makeKeyRow(keys: row, height: 42))
        }

        // Fila inferior: mayús, espacio, borrar
        stackView.addArrangedSubview(makeBottomRow())

        // Fila de funciones: 123, emoji, portapapeles, siguiente teclado, return
        stackView.addArrangedSubview(makeFunctionRow())
    }

    private func makeKeyRow(keys: [String], height: CGFloat) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fillEqually
        row.heightAnchor.constraint(equalToConstant: height).isActive = true
        for key in keys {
            let btn = makeKeyButton(title: key)
            btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
            row.addArrangedSubview(btn)
        }
        return row
    }

    private func makeBottomRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.heightAnchor.constraint(equalToConstant: 42).isActive = true

        let shift = makeFuncButton(title: isShifted ? "⇧" : "⇩", color: .systemBlue)
        shift.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)

        let space = makeKeyButton(title: "espacio")
        space.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)

        let delete = makeFuncButton(title: "⌫", color: .systemRed)
        delete.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        row.addArrangedSubview(shift)
        row.addArrangedSubview(space)
        row.addArrangedSubview(delete)
        return row
    }

    private func makeFunctionRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let nums = makeFuncButton(title: "123", color: .systemGray)
        nums.addTarget(self, action: #selector(numbersTapped), for: .touchUpInside)

        let emoji = makeFuncButton(title: "😀", color: .systemGray)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)

        let clip = makeFuncButton(title: "📋", color: .systemOrange)
        clip.addTarget(self, action: #selector(clipboardTapped), for: .touchUpInside)

        let next = makeFuncButton(title: "🌐", color: .systemGray)
        next.addTarget(self, action: #selector(nextKeyboardTapped), for: .touchUpInside)

        let ret = makeFuncButton(title: "↩", color: .systemGreen)
        ret.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        [nums, emoji, clip, next, ret].forEach { row.addArrangedSubview($0) }
        return row
    }

    // MARK: - Button factories

    private func makeKeyButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 8
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        return btn
    }

    private func makeFuncButton(title: String, color: UIColor) -> UIButton {
        let btn = makeKeyButton(title: title)
        btn.backgroundColor = color.withAlphaComponent(0.15)
        return btn
    }

    // MARK: - Actions

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        delegate?.keyboardView(self, didTapKey: key)
        if isShifted {
            isShifted = false
            buildLayout()
        }
    }

    @objc private func shiftTapped() {
        isShifted.toggle()
        buildLayout()
    }

    @objc private func spaceTapped() {
        delegate?.keyboardView(self, didTapKey: " ")
    }

    @objc private func deleteTapped() {
        delegate?.keyboardViewDidTapDelete(self)
    }

    @objc private func returnTapped() {
        delegate?.keyboardViewDidTapReturn(self)
    }

    @objc private func numbersTapped() {
        delegate?.keyboardViewDidTapNumbers(self)
    }

    @objc private func emojiTapped() {
        delegate?.keyboardViewDidTapEmoji(self)
    }

    @objc private func clipboardTapped() {
        delegate?.keyboardViewDidTapClipboard(self)
    }

    @objc private func nextKeyboardTapped() {
        delegate?.keyboardViewDidTapNextKeyboard(self)
    }
}
