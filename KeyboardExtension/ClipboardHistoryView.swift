import UIKit

protocol ClipboardHistoryViewDelegate: AnyObject {
    func clipboardHistoryView(_ view: ClipboardHistoryView, didSelectText text: String)
    func clipboardHistoryViewDidTapClose(_ view: ClipboardHistoryView)
}

/// Panel del historial del portapapeles con tabla scrollable
class ClipboardHistoryView: UIView {

    weak var delegate: ClipboardHistoryViewDelegate?
    private var tableView: UITableView!
    private var emptyLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        backgroundColor = .systemGroupedBackground

        // Header
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text = "📋 Historial del portapapeles"
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)

        let clearBtn = UIButton(type: .system)
        clearBtn.setTitle("Limpiar", for: .normal)
        clearBtn.tintColor = .systemRed
        clearBtn.titleLabel?.font = .systemFont(ofSize: 13)
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        header.addSubview(clearBtn)

        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        header.addSubview(closeBtn)

        // Tabla
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ClipboardCell.self, forCellReuseIdentifier: "ClipboardCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.rowHeight = 48
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        // Label vacío
        emptyLabel = UILabel()
        emptyLabel.text = "El historial está vacío.\nCopia texto en cualquier app."
        emptyLabel.numberOfLines = 2
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 13)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            clearBtn.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor, constant: -8),
            clearBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            closeBtn.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -8),
            closeBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20)
        ])
    }

    func reload() {
        tableView.reloadData()
        emptyLabel.isHidden = !ClipboardManager.shared.items.isEmpty
    }

    @objc private func clearAll() {
        ClipboardManager.shared.clearAll()
        reload()
    }

    @objc private func closeTapped() {
        delegate?.clipboardHistoryViewDidTapClose(self)
    }
}

extension ClipboardHistoryView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ClipboardManager.shared.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClipboardCell", for: indexPath) as! ClipboardCell
        let item = ClipboardManager.shared.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let text = ClipboardManager.shared.items[indexPath.row].text
        delegate?.clipboardHistoryView(self, didSelectText: text)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, completion in
            let id = ClipboardManager.shared.items[indexPath.row].id
            ClipboardManager.shared.remove(id: id)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

class ClipboardCell: UITableViewCell {
    private let previewLabel = UILabel()
    private let dateLabel = UILabel()
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(previewLabel)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            previewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            previewLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),

            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with item: ClipboardManager.ClipboardItem) {
        previewLabel.text = item.text.trimmingCharacters(in: .newlines)
        dateLabel.text = ClipboardCell.df.string(from: item.date)
    }
}
