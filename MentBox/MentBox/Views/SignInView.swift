import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI
import UserNotifications

enum UserType {
    case learner
    case mentor
}

struct SignInView: View {
    @State private var isSignedIn = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showMainView = false
    @State private var showUserTypeSelection = false
    @State private var selectedUserType: UserType?
    
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
        .sheet(isPresented: $showUserTypeSelection) {
            UserTypeSelectionView(selectedUserType: $selectedUserType) { userType in
                handleUserTypeSelection(userType: userType)
            }
        }
        .onAppear {
            checkSignInStatus()
        }
        .fullScreenCover(isPresented: $showMainView) {
            ContentView()
        }
    }
    
    private func handleUserTypeSelection(userType: UserType) {
        // 신규 사용자 정보 입력이 끝났으므로 메인 화면으로 이동
        UserDefaults.standard.set(false, forKey: "isLoggedOut")
        withAnimation {
            showUserTypeSelection = false // 회원‑유형 선택 시트 닫기
            showMainView = true // ContentView로 전환
        }
    }
    
    private func checkSignInStatus() {
        if isLoggedOut {
            print("로그아웃 상태")
            showMainView = false
            return
        }
        
        if let user = Auth.auth().currentUser {
            print("이미 로그인된 사용자: \(user.uid)")
            showMainView = true
        } else {
            print(" 로그인된 사용자 없음")
            showMainView = false
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
                    // 기존 사용자인지 볼거야  -> 아니면 이제 실패
                    Task {
                        do {
                            let isExistingUser = try await FirebaseService.shared.checkExistingUser(userId: user.uid)
                            if isExistingUser {
                                // 기존 사용자인 경우 바로 메인 화면으로
                                UserDefaults.standard.set(false, forKey: "isLoggedOut")
                                withAnimation {
                                    showMainView = true
                                }
                            } else {
                                // 신규 사용자인 경우 사용자 유형 선택 화면 표시
                                showUserTypeSelection = true
                            }
                        } catch {
                            errorMessage = "사용자 로그인 / 확인 실패했습니다."
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

struct UserInfoInputView: View {
    let userType: UserType
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: String = ""
    @State private var expertise: String = ""
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let categories = ["Tech", "Design", "Business"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("이름", text: $name)
                }
                
                if userType == .learner {
                    Section(header: Text("관심 분야")) {
                        Picker("관심 분야", selection: $category) {
                            ForEach(categories, id: \.self) { category in
                                Text(category.capitalized).tag(category)
                            }
                        }
                    }
                } else {
                    Section(header: Text("전문 분야")) {
                        Picker("전문 분야", selection: $expertise) {
                            ForEach(categories, id: \.self) { category in
                                Text(category.capitalized).tag(category)
                            }
                        }
                    }
                    
                    Section(header: Text("자기 소개")) {
                        TextEditor(text: $bio)
                            .frame(height: 100)
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("추가 정보 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        saveUserInfo()
                    }
                    .disabled(isLoading || !isValidInput)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        if userType == .learner {
            return !name.isEmpty && !category.isEmpty
        } else {
            return !name.isEmpty && !expertise.isEmpty && !bio.isEmpty
        }
    }
    
    private func saveUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        Task {
            do {
                switch userType {
                case .learner:
                    let learner = Learner(
                        id: user.uid,
                        name: name,
                        email: user.email ?? "",
                        profileImage: nil,
                        category: category,
                        letterCount: 0,
                        bookmarkedCount: 0,
                        createdAt: Date(),
                        lastLoginAt: Date(),
                        bookmarkedQuestions: [],
                        sentQuestions: []
                    )
                    try await FirebaseService.shared.createLearner(learner: learner)
                    print(" 학습자 정보 저장 완료: \(name), \(category)")
                    
                case .mentor:
                    let mentor = Mentor(
                        id: user.uid,
                        name: name,
                        bio: bio,
                        profileImage: "",
                        expertise: expertise
                    )
                    try await FirebaseService.shared.createMentor(mentor: mentor)
                    print(" 멘토 정보 저장 완료: \(name), \(expertise), \(bio)")
                }
                
                UserDefaults.standard.set(false, forKey: "isLoggedOut")
                onComplete()
            } catch {
                print(" 사용자 정보 저장 실패: \(error.localizedDescription)")
                errorMessage = "사용자 정보 저장에 실패했습니다."
            }
            isLoading = false
        }
    }
}

struct UserTypeSelectionView: View {
    @Binding var selectedUserType: UserType?
    let onSelection: (UserType) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showUserInfoInput = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("회원 유형을 선택해주세요")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 20) {
                    Button {
                        selectedUserType = .learner
                        showUserInfoInput = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                            Text("학습자")
                                .font(.title3)
                            Text("멘토에게 질문하고 답변을 받아보세요")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary").opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button {
                        selectedUserType = .mentor
                        showUserInfoInput = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.system(size: 40))
                            Text("멘토")
                                .font(.title3)
                            Text("학습자들의 질문에 답변해주세요")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary").opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showUserInfoInput) {
                if let userType = selectedUserType {
                    UserInfoInputView(userType: userType) {
                        dismiss()
                        onSelection(userType)
                    }
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
