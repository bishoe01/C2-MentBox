import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI

enum UserType {
    case learner
    case mentor
}

extension UserType: Identifiable {
    var id: Int { hashValue }
}

struct SignInView: View {
    @State private var isSignedIn = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showUserTypeSelection = false
    @State private var selectedUserType: UserType?
    @State private var currentUserType: UserType?
    @EnvironmentObject var navigationManager: NavigationManager
    
    @AppStorage("isLoggedOut") private var isLoggedOut = false
    
    var body: some View {
        ZStack {
            Color("SignBG")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    HStack(spacing: -20) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("Primary"))
                            .rotationEffect(.degrees(-5))
                        
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(5))
                    }
                    
                    Text("MentBox")
                        .menterFont(.logoHeader)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
//                        .padding()
                }
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        isLoading = true
                        switch result {
                        case .success(let authResults):
                            handleAppleSignIn(result: authResults)
                        case .failure(let error):
                            print(" Apple 로그인 실패: \(error.localizedDescription)")
                            errorMessage = "로그인에 실패했습니다. 다시 시도해주세요."
                            isLoading = false
                        }
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .padding(.horizontal, 40)
                .disabled(isLoading)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            if !isLoggedOut {
                checkUserType()
            }
        }
//        .fullScreenCover(item: $currentUserType) { userType in
//            switch userType {
//            case .learner:
//                LearnerMainView()
//            case .mentor:
//                MentorMainView()
//            }
//        }
    }
    
    private func handleUserTypeSelection(userType: UserType) {
        currentUserType = userType
        UserDefaults.standard.set(false, forKey: "isLoggedOut")
        withAnimation {
            showUserTypeSelection = false
        }
    }
    
    // 이미 가입이 되어 있을 때
    private func checkUserType() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        Task {
            do {
                // 먼저 Learner로 시도
                if let _ = try await FirebaseService.shared.fetchLearner(userId: userId) {
                    await MainActor.run {
                        currentUserType = .learner
                        navigationManager.setMainRoot(userType: .learner)
                        isLoading = false
                    }
                    return
                }
                
                // Learner가 아니면 Mentor로 시도
                let mentorDoc = try await Firestore.firestore().collection("mentors").document(userId).getDocument()
                if mentorDoc.exists {
                    await MainActor.run {
                        currentUserType = .mentor
                        print("멘토 로그인 성공 - 화면 전환 시도")
                        navigationManager.setMainRoot(userType: .mentor)
                        print("멘토 화면 전환 완료: \(navigationManager.rootView)")
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                        showUserTypeSelection = true
                    }
                }
            } catch {
                await MainActor.run {
                    print(" 사용자 타입 확인 실패: \(error)")
                    isLoading = false
                }
            }
        }
    }
    
    private func handleAppleSignIn(result: ASAuthorization) {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8)
        else {
            print("토큰 가져오기 실패")
            errorMessage = "토큰 가져오는데 실패"
            isLoading = false
            return
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: ""
        )

        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                errorMessage = "서버 연결 실패 / 다시 시도해주세요."
                isLoading = false
            } else {
                print("로그인 성공 -> 사용자 이름 :  \(authResult?.user.uid ?? "없음")")
                
                if let user = authResult?.user {
                    Task {
                        do {
                            let isExistingUser = try await FirebaseService.shared.checkExistingUser(userId: user.uid)
                            if isExistingUser {
                                await MainActor.run {
                                    isLoading = true
                                }
                                checkUserType()
                            } else {
                                await MainActor.run {
                                    isLoading = false
                                    navigationManager.rootView = .auth(.userTypeSelection)
                                    showUserTypeSelection = true
                                }
                            }
                        } catch {
                            await MainActor.run {
                                errorMessage = "사용자 로그인 / 확인 실패했습니다."
                                isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey: "isLoggedOut")
            print("로그아웃 성공")
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SignInView()
}
