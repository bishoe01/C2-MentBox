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
    @StateObject private var navigationManager = NavigationManager()

    // 다크모드 강제 (Scene이 여러 개일 때는 추가 처리 필요)
    init() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            window.overrideUserInterfaceStyle = .dark
        }
    }

    // Group 'v'에러 -> ViewBuilder로 조건부 뷰 보여주기
    @ViewBuilder
    private var rootContent: some View {
        if let mentorView = navigationManager.mentorView {
            MentorMainView()
        } else if let learnerView = navigationManager.learnerView {
            LearnerMainView()
        } else {
            switch navigationManager.rootView {
            case .login:
                SignInView()
            case .userTypeSelection:
                UserTypeSelectionView(
                    selectedUserType: .constant(nil)
                )
            case .userInfoInput(let userType):
                UserInfoInputView(userType: userType) {
                    navigationManager.setMainRoot(userType: userType)
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            rootContent // 조건 분기는 모두 여기서 해결
                .ignoresSafeArea()
                .environmentObject(navigationManager)
        }
    }
}
