import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        // 데이터 초기화 실행
        Task {
            do {
                print("🔥 Firebase 데이터 초기화 확인 중...")
                try await FirebaseService.shared.resetAndUploadData()
            } catch {
                print("❌ Firebase 데이터 초기화 실패: \(error)")
            }
        }
        
        return true
    }
}

@main
struct MentBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SignInView()
            }
        }
    }
}
