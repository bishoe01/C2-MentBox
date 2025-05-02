import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MentBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authNavigationManager = AuthNavigationManager()


    init() {
        // 다크 모드 강제 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SignInView()
                .ignoresSafeArea(.all)
                .environmentObject(authNavigationManager)
        }
    }
}
