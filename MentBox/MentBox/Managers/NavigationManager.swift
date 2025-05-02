import SwiftUI

enum AuthViewType: Hashable {
    case userTypeSelection
    case userInfoInput(UserType)
}

enum MainViewType: Hashable {
    case mentor
    case learner
}

class NavigationManager<T: Hashable>: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to destination: T) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        path.removeLast()
    }
}

// MARK: 네비게이션 매니저 분리

// 인증 관련 네비게이션  -> 회원가입 까지만
// 메인 네비게이션 -> 로그인 이후

let authNavigationManager = NavigationManager<AuthViewType>()

let mainNavigationManager = NavigationManager<MainViewType>()
