import SwiftUI

// Auth뷰
enum AuthView: Hashable {
    case login
    case userTypeSelection
    case userInfoInput(UserType)
}

// Mentor뷰
enum MentorView: Hashable {
    case profile
    case home
    case myPage
}

// Learner뷰
enum LearnerView: Hashable {
    case home
    case chatRoom(mentorId: String)
    case profile
    case myPage
    case bookMark
}

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var rootView: AuthView = .login
    @Published var mentorView: MentorView?
    @Published var learnerView: LearnerView?
    
    func navigate(to destination: MentorView) {
        path.append(destination)
    }
    
    func navigate(to destination: LearnerView) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        path.removeLast()
    }
    
    func setMainRoot(userType: UserType) {  //로그인할 떄 넣어줘야하는 페이지 
        path = NavigationPath()
        rootView = .userTypeSelection
        if userType == .mentor { // 멘토뷰 
            mentorView = .profile
            learnerView = nil
        } else {  //러너 뷰 
            mentorView = nil
            learnerView = .profile
        }
    }
    
    func setAuthRoot() {  // 로그아웃 했을 때 씀 
        path = NavigationPath()
        rootView = .login
        mentorView = nil
        learnerView = nil
    }
}
