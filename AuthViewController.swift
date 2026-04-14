import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    private let glassCard: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 48
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🤖 Eli"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.textColor = .white
        field.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        field.layer.cornerRadius = 14
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.textColor = .white
        field.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        field.layer.cornerRadius = 14
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1.0).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(glassCard)
        glassCard.contentView.addSubview(titleLabel)
        glassCard.contentView.addSubview(emailField)
        glassCard.contentView.addSubview(passwordField)
        glassCard.contentView.addSubview(loginButton)
        glassCard.contentView.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            glassCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            glassCard.widthAnchor.constraint(equalToConstant: 340),
            glassCard.heightAnchor.constraint(equalToConstant: 460),
            
            titleLabel.topAnchor.constraint(equalTo: glassCard.contentView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: glassCard.contentView.centerXAnchor),
            
            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            signUpButton.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 24),
            signUpButton.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -24),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loginTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert("Please fill all fields")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(error.localizedDescription)
                return
            }
            self?.navigateToMainApp()
        }
    }
    
    @objc private func signUpTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert("Please fill all fields")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(error.localizedDescription)
                return
            }
            self?.navigateToMainApp()
        }
    }
    
    private func navigateToMainApp() {
        DispatchQueue.main.async {
            let mainVC = ViewController()
            self.view.window?.rootViewController = mainVC
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
