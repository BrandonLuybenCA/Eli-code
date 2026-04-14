import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Check if user is already logged in
        if let _ = Auth.auth().currentUser {
            window?.rootViewController = ViewController()
        } else {
            window?.rootViewController = AuthViewController()
        }
        window?.makeKeyAndVisible()
    }
}
