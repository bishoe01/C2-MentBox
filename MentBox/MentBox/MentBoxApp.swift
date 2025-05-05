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
        switch navigationManager.rootView {
        case .auth(let authView):
            switch authView {
            case .login:
                SignInView()
            case .userTypeSelection:
                UserTypeSelectionView(selectedUserType: .constant(nil))
            case .userInfoInput(let userType):
                UserInfoInputView(userType: userType) {
                    navigationManager.setMainRoot(userType: userType)
                }
            }

        case .mentor(let mentorView):
            switch mentorView {
            case .home:
                MentorMainView()
            case .myPage:
                MentorProfileView()
            }

        case .learner(let learnerView):
            switch learnerView {
            case .home:
                LearnerMainView()
            case .chatRoom(let mentorId):
//                ChatRoomView(mentorId: mentorId)
                Text("Hi chatview")
            case .myLetter:
                MyLetterView()
            case .myPage:
                LearnerProfileView()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            rootContent // 조건 분기는 모두 여기서 해결
                .environmentObject(navigationManager)
                .ignoresSafeArea()
        }
    }
}
