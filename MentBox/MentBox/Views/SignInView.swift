import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI
import UserNotifications

struct SignInView: View {
    @State private var isSignedIn = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showMainView = false
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
                        .padding()
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
                            print("❌ Apple 로그인 실패: \(error.localizedDescription)")
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
            checkSignInStatus()
        }
        .fullScreenCover(isPresented: $showMainView) {
            ContentView()
        }
    }
    
    private func checkSignInStatus() {
        if isLoggedOut {
            print("❌ 로그아웃 상태")
            showMainView = false
            return
        }
        
        if let user = Auth.auth().currentUser {
            print("✅ 이미 로그인된 사용자: \(user.uid)")
            showMainView = true
        } else {
            print("❌ 로그인된 사용자 없음")
            showMainView = false
        }
    }
    
    // 로그아웃 함수 수정
    static func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey: "isLoggedOut")
            print("✅ 로그아웃 성공")
        } catch {
            print("❌ 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    private func handleAppleSignIn(result: ASAuthorization) {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8)
        else {
            print("❗️토큰 가져오기 실패")
            errorMessage = "인증 정보를 가져오는데 실패했습니다."
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
                print("❌ Firebase 로그인 실패: \(error.localizedDescription)")
                errorMessage = "서버 연결에 실패했습니다. 다시 시도해주세요."
                isLoading = false
            } else {
                print("✅ Firebase 로그인 성공! 사용자: \(authResult?.user.uid ?? "없음")")
                
                if let user = authResult?.user {
                    saveUserInfo(user: user, appleIDCredential: appleIDCredential)
                }
                
                // 로그인 성공 시 로그아웃 상태 초기화
                UserDefaults.standard.set(false, forKey: "isLoggedOut")
                
                withAnimation {
                    showMainView = true
                }
            }
        }
    }
    
    private func saveUserInfo(user: User, appleIDCredential: ASAuthorizationAppleIDCredential) {
        let changeRequest = user.createProfileChangeRequest()
        
        if let fullName = appleIDCredential.fullName {
            let displayName = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            changeRequest.displayName = displayName
        }
        
        let learner = Learner(
            id: user.uid,
            name: changeRequest.displayName ?? "",
            email: appleIDCredential.email ?? "",
            profileImage: nil,
            category: "",
            letterCount: 0,
            bookmarkedCount: 0,
            createdAt: Date(),
            lastLoginAt: Date(),
            bookmarkedQuestions: [],
            sentQuestions: []
        )
    
        Task {
            do {
                try await FirebaseService.shared.createLearner(learner: learner)
                print("✅ 사용자 정보 저장 성공")
            } catch {
                print("❌ 사용자 정보 저장 실패: \(error.localizedDescription)")
                errorMessage = "사용자 정보 저장에 실패했습니다."
            }
            isLoading = false
        }
    }
}

#Preview {
    SignInView()
}
