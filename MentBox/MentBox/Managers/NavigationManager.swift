import SwiftUI

enum AppRootView: Equatable {
    case auth(AuthView)
    case mentor(MentorView)
    case learner(LearnerView)
}

// Auth뷰
enum AuthView: Hashable {
    case login
    case userTypeSelection
    case userInfoInput(UserType)
}

// Mentor뷰
enum MentorView: Hashable {
    case home
    case myPage
}

// Learner뷰
enum LearnerView: Hashable {
    case home
    case chatRoom(mentorId: String)
    case myPage
    case myLetter
}

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var rootView: AppRootView = .auth(.login)

    // 같은이름 navigate는 추후 수정이 필요할 듯 책임 명확히
    func navigate(to destination: MentorView) {
        path.append(destination)
    }

    func navigate(to destination: LearnerView) {
        path.append(destination)
    }

    func navigate(to destination: AuthView) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        path.removeLast()
    }

    func setMainRoot(userType: UserType) {
        path = NavigationPath()
        switch userType {
        case .mentor:
            rootView = .mentor(.home)
        case .learner:
            rootView = .learner(.home)
        }
    }

    func setAuthRoot() {
        path = NavigationPath()
        rootView = .auth(.login)
    }
}
