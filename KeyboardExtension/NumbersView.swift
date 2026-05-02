import UIKit

protocol NumbersViewDelegate: AnyObject {
    func numbersView(_ view: NumbersView, didTapKey key: String)
    func numbersViewDidTapDelete(_ view: NumbersView)
    func numbersViewDidTapABC(_ view: NumbersView)
    func numbersViewDidTapClipboard(_ view: NumbersView)
}

/// Panel de números, símbolos y signos de puntuación
class NumbersView: UIView {

    weak var delegate: NumbersViewDelegate?

    private let rows: [[String]] = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","€","&","@","\""  ],
        [".",",","?","!","'","_","+","=","#","%"],
        ["[","]","{","}","<",">","|","~","^","*"]
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            rowStack.heightAnchor.constraint(equalToConstant: 42).isActive = true
            for key in row {
                let btn = makeKeyButton(title: key)
                btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
            }
            stack.addArrangedSubview(rowStack)
        }

        // Fila de control
        let control = UIStackView()
        control.axis = .horizontal
        control.spacing = 4
        control.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let abc = makeFuncButton(title: "ABC", color: .systemBlue)
        abc.addTarget(self, action: #selector(abcTapped), for: .touchUpInside)

        let space = makeKeyButton(title: "espacio")
        space.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)

        let clip = makeFuncButton(title: "📋", color: .systemOrange)
        clip.addTarget(self, action: #selector(clipboardTapped), for: .touchUpInside)

        let del = makeFuncButton(title: "⌫", color: .systemRed)
        del.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        [abc, space, clip, del].forEach { control.addArrangedSubview($0) }
        stack.addArrangedSubview(control)
    }

    private func makeKeyButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
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

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        delegate?.numbersView(self, didTapKey: key)
    }
    @objc private func spaceTapped() {
        delegate?.numbersView(self, didTapKey: " ")
    }
    @objc private func deleteTapped() {
        delegate?.numbersViewDidTapDelete(self)
    }
    @objc private func abcTapped() {
        delegate?.numbersViewDidTapABC(self)
    }
    @objc private func clipboardTapped() {
        delegate?.numbersViewDidTapClipboard(self)
    }
}
