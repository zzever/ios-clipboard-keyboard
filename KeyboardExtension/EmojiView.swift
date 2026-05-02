import UIKit

protocol EmojiViewDelegate: AnyObject {
    func emojiView(_ view: EmojiView, didSelectEmoji emoji: String)
    func emojiViewDidTapABC(_ view: EmojiView)
}

/// Panel de emojis organizados por categorías
class EmojiView: UIView {

    weak var delegate: EmojiViewDelegate?

    // Categorías de emojis
    private let categories: [(name: String, emojis: [String])] = [
        ("😀 Caras",    ["😀","😂","🥹","😍","🥰","😎","🤔","😴","🥺","😭","😡","🤯","🤩","😏","😬","🙄","😤","🤗","😇","🥳"]),
        ("👍 Gestos",   ["👍","👎","👏","🙌","🤝","👋","✌️","🤞","💪","🫶","🤟","👌","🤌","🫵","🤙","☝️","✋","🖐","🖖","💅"]),
        ("❤️ Corazones",["❤️","🧡","💛","💚","💙","💜","🖤","🤍","💗","💓","💞","💕","💝","💘","❣️","💔","❤️‍🔥","💯","✨","🎉"]),
        ("🎵 Música",   ["🎵","🎶","🎤","🎧","🎸","🥁","🎹","🎺","🎻","🪗","🎷","🎼","🎙️","📻","🔊","🔉","🔇","🎚️","🎛️","🔔"]),
        ("💡 Objetos",  ["💡","🔦","🕯️","🔌","🔋","💻","📱","⌨️","🖥","🖨","📷","📸","📹","🎥","📡","🔭","🔬","🧲","🔧","🔩"]),
        ("🚀 Viaje",    ["🚀","✈️","🚗","🚕","🚌","🚎","🏎","🚓","🚑","🚒","🚐","🛻","🚚","🛸","🚁","⛵","🚢","🚂","🚃","🚄"]),
        ("🍕 Comida",   ["🍕","🍔","🌮","🌯","🍜","🍣","🍱","🥘","🍗","🥩","🍰","🎂","🍩","🍪","🍫","🍦","☕","🧃","🍺","🥂"]),
        ("⚡ Símbolos", ["⚡","🔥","💥","🌊","💫","⭐","🌟","✅","❌","⚠️","❓","❗","♻️","🏳️","🏴","🔴","🟠","🟡","🟢","🔵"])
    ]

    private var selectedCategory = 0
    private var categoryButtons: [UIButton] = []
    private var emojiCollectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        backgroundColor = .systemGroupedBackground

        // Selector de categorías (scroll horizontal)
        let catScroll = UIScrollView()
        catScroll.showsHorizontalScrollIndicator = false
        catScroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(catScroll)

        let catStack = UIStackView()
        catStack.axis = .horizontal
        catStack.spacing = 6
        catStack.translatesAutoresizingMaskIntoConstraints = false
        catScroll.addSubview(catStack)

        categoryButtons = []
        for (i, cat) in categories.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(cat.name, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13)
            btn.layer.cornerRadius = 12
            btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            btn.backgroundColor = i == 0 ? UIColor.systemBlue.withAlphaComponent(0.2) : .systemBackground
            btn.tag = i
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            catStack.addArrangedSubview(btn)
            categoryButtons.append(btn)
        }

        // Grid de emojis
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 42, height: 42)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiCollectionView)

        // Botón ABC
        let abcBtn = UIButton(type: .system)
        abcBtn.setTitle("ABC", for: .normal)
        abcBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        abcBtn.layer.cornerRadius = 8
        abcBtn.translatesAutoresizingMaskIntoConstraints = false
        abcBtn.addTarget(self, action: #selector(abcTapped), for: .touchUpInside)
        addSubview(abcBtn)

        NSLayoutConstraint.activate([
            catScroll.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            catScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            catScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            catScroll.heightAnchor.constraint(equalToConstant: 34),

            catStack.topAnchor.constraint(equalTo: catScroll.topAnchor),
            catStack.bottomAnchor.constraint(equalTo: catScroll.bottomAnchor),
            catStack.leadingAnchor.constraint(equalTo: catScroll.leadingAnchor),
            catStack.trailingAnchor.constraint(equalTo: catScroll.trailingAnchor),
            catStack.heightAnchor.constraint(equalTo: catScroll.heightAnchor),

            emojiCollectionView.topAnchor.constraint(equalTo: catScroll.bottomAnchor, constant: 4),
            emojiCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiCollectionView.bottomAnchor.constraint(equalTo: abcBtn.topAnchor, constant: -4),

            abcBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            abcBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            abcBtn.widthAnchor.constraint(equalToConstant: 60),
            abcBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        selectedCategory = sender.tag
        categoryButtons.enumerated().forEach { i, btn in
            btn.backgroundColor = i == selectedCategory
                ? UIColor.systemBlue.withAlphaComponent(0.2)
                : .systemBackground
        }
        emojiCollectionView.reloadData()
    }

    @objc private func abcTapped() {
        delegate?.emojiViewDidTapABC(self)
    }
}

extension EmojiView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[selectedCategory].emojis.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(emoji: categories[selectedCategory].emojis[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = categories[selectedCategory].emojis[indexPath.item]
        delegate?.emojiView(self, didSelectEmoji: emoji)
    }
}

class EmojiCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        layer.cornerRadius = 8
        backgroundColor = .systemBackground
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(emoji: String) { label.text = emoji }
}
