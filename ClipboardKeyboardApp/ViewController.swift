import UIKit

/// App contenedora: muestra instrucciones de configuración
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Clipboard Keyboard"

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        let title = UILabel()
        title.text = "⌨️ Clipboard Keyboard"
        title.font = .boldSystemFont(ofSize: 24)
        title.textAlignment = .center
        stack.addArrangedSubview(title)

        let steps: [(String, String)] = [
            ("1", "Ve a Ajustes → General → Teclado → Teclados"),
            ("2", "Toca 'Añadir nuevo teclado'"),
            ("3", "Selecciona 'Clipboard Keyboard'"),
            ("4", "Activa 'Permitir acceso completo' para el historial automático"),
            ("5", "En cualquier app, toca el 🌐 para cambiar al teclado"),
            ("6", "Pulsa 📋 para ver el historial del portapapeles")
        ]

        for (num, text) in steps {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12

            let numLabel = UILabel()
            numLabel.text = num
            numLabel.font = .boldSystemFont(ofSize: 18)
            numLabel.backgroundColor = .systemBlue
            numLabel.textColor = .white
            numLabel.textAlignment = .center
            numLabel.layer.cornerRadius = 14
            numLabel.clipsToBounds = true
            numLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
            numLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true

            let textLabel = UILabel()
            textLabel.text = text
            textLabel.font = .systemFont(ofSize: 15)
            textLabel.numberOfLines = 0

            row.addArrangedSubview(numLabel)
            row.addArrangedSubview(textLabel)
            stack.addArrangedSubview(row)
        }

        // Botón a Ajustes
        let settingsBtn = UIButton(type: .system)
        settingsBtn.setTitle("Abrir Ajustes", for: .normal)
        settingsBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        settingsBtn.backgroundColor = .systemBlue
        settingsBtn.tintColor = .white
        settingsBtn.layer.cornerRadius = 12
        settingsBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settingsBtn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        stack.addArrangedSubview(settingsBtn)
    }

    @objc private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
