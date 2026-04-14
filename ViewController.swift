import UIKit
import ActivityKit
import FirebaseAuth

class ViewController: UIViewController, UITextViewDelegate {
    
    private let glassCard: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    private let promptTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 16
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "What should Eli build for you?"
        tv.textColor = .lightGray
        return tv
    }()
    
    private let modelPicker: UISegmentedControl = {
        let items = ["MiniMax", "Kimi", "Qwen", "DeepSeek"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        sc.selectedSegmentTintColor = UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1.0)
        return sc
    }()
    
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✨ Generate Code", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let responseTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let modelMap = [
        "MiniMax": "MiniMaxAI/MiniMax-M2.7",
        "Kimi": "moonshotai/Kimi-Dev-72B",
        "Qwen": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "DeepSeek": "deepseek-ai/DeepSeek-V2-236B"
    ]
    
    // Token injected via GitHub Actions
    private var hfToken = "YOUR_HF_TOKEN_HERE"
    
    private var currentActivity: Activity<EliAttributes>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupTextView()
        setupLogoutButton()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(glassCard)
        glassCard.contentView.addSubview(promptTextView)
        glassCard.contentView.addSubview(modelPicker)
        glassCard.contentView.addSubview(generateButton)
        glassCard.contentView.addSubview(responseTextView)
        glassCard.contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            glassCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            glassCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            glassCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            glassCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            promptTextView.topAnchor.constraint(equalTo: glassCard.contentView.topAnchor, constant: 20),
            promptTextView.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 16),
            promptTextView.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -16),
            promptTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            modelPicker.topAnchor.constraint(equalTo: promptTextView.bottomAnchor, constant: 16),
            modelPicker.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 16),
            modelPicker.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -16),
            generateButton.topAnchor.constraint(equalTo: modelPicker.bottomAnchor, constant: 20),
            generateButton.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 16),
            generateButton.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -16),
            generateButton.heightAnchor.constraint(equalToConstant: 56),
            responseTextView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 20),
            responseTextView.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 16),
            responseTextView.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -16),
            responseTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            responseTextView.bottomAnchor.constraint(equalTo: glassCard.contentView.bottomAnchor, constant: -20),
            loadingIndicator.centerXAnchor.constraint(equalTo: glassCard.contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: glassCard.contentView.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
    }
    
    private func setupTextView() {
        promptTextView.delegate = self
    }
    
    private func setupLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItem = logoutButton
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc private func logoutTapped() {
        try? Auth.auth().signOut()
        let authVC = AuthViewController()
        view.window?.rootViewController = authVC
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What should Eli build for you?" && textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What should Eli build for you?"
            textView.textColor = .lightGray
        }
    }
    
    @objc private func generateTapped() {
        guard let prompt = promptTextView.text, !prompt.isEmpty, promptTextView.textColor != .lightGray else {
            showAlert("Type a prompt first 😊")
            return
        }
        
        let selectedModel = modelMap[modelPicker.titleForSegment(at: modelPicker.selectedSegmentIndex) ?? "MiniMax"] ?? "MiniMaxAI/MiniMax-M2.7"
        
        loadingIndicator.startAnimating()
        generateButton.isEnabled = false
        responseTextView.text = ""
        
        sendLocalNotification(title: "Eli is thinking...", body: "Generating code for: \(prompt.prefix(50))")
        startLiveActivity(prompt: String(prompt.prefix(60)))
        
        callHuggingFace(model: selectedModel, prompt: prompt)
    }
    
    private func callHuggingFace(model: String, prompt: String) {
        guard let url = URL(string: "https://api-inference.huggingface.co/models/\(model)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(hfToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "inputs": "You are Eli. Write code for: \(prompt)",
            "parameters": ["max_new_tokens": 2048]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.generateButton.isEnabled = true
                
                if let error = error {
                    self?.responseTextView.text = "Error: \(error.localizedDescription)"
                    self?.sendLocalNotification(title: "⚠️ Eli hit a snag", body: "Check your connection")
                    self?.updateLiveActivity(status: "Failed", progress: 0)
                    return
                }
                
                guard let data = data else { return }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let generated = json.first?["generated_text"] as? String {
                        self?.responseTextView.text = generated
                        self?.sendLocalNotification(title: "✅ Eli finished!", body: "Your code is ready")
                        self?.updateLiveActivity(status: "Complete", progress: 1.0)
                        self?.endLiveActivity()
                    } else {
                        self?.responseTextView.text = String(data: data, encoding: .utf8) ?? "Unknown response"
                    }
                } catch {
                    self?.responseTextView.text = "Parse error: \(error)"
                }
            }
        }.resume()
    }
    
    // MARK: - Live Activity
    private func startLiveActivity(prompt: String) {
        if #available(iOS 16.1, *) {
            let attributes = EliAttributes(sessionId: UUID().uuidString)
            let state = EliAttributes.ContentState(status: "Starting...", progress: 0.0, promptPreview: prompt)
            do {
                currentActivity = try Activity<EliAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
            } catch {
                print("Live Activity error: \(error)")
            }
        }
    }
    
    private func updateLiveActivity(status: String, progress: Double) {
        if #available(iOS 16.1, *) {
            Task {
                let updatedState = EliAttributes.ContentState(status: status, progress: progress, promptPreview: currentActivity?.contentState.promptPreview ?? "")
                await currentActivity?.update(using: updatedState)
            }
        }
    }
    
    private func endLiveActivity() {
        if #available(iOS 16.1, *) {
            Task {
                await currentActivity?.end(dismissalPolicy: .immediate)
                currentActivity = nil
            }
        }
    }
    
    // MARK: - Local Notifications
    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
