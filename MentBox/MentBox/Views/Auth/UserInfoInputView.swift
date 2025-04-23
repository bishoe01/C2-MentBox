import SwiftUI
import FirebaseAuth


struct UserInfoInputView: View {
    let userType: UserType
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: UserCategory = .tech
    @State private var expertise: UserCategory = .tech
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedProfileImage: String = "Profile1"
    
    private let profileImages = ["Profile1", "Profile2", "Profile3", "Profile4"]
    
    init(userType: UserType, onComplete: @escaping () -> Void) {
        self.userType = userType
        self.onComplete = onComplete
        
        // 다크 모드 강제 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로필 이미지")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(profileImages, id: \.self) { imageName in
                                Button(action: {
                                    selectedProfileImage = imageName
                                }) {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedProfileImage == imageName ? Color("Primary") : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("기본 정보")) {
                    TextField("이름", text: $name)
                }
                
                if userType == .learner {
                    Section(header: Text("관심 분야")) {
                        Picker("관심 분야", selection: $category) {
                            ForEach(UserCategory.allCases) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                    }
                } else {
                    Section(header: Text("전문 분야")) {
                        Picker("전문 분야", selection: $expertise) {
                            ForEach(UserCategory.allCases) { category in
                                Text(category.displayName).tag(category)
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
            return !name.isEmpty
        } else {
            return !name.isEmpty && !bio.isEmpty
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
                        profileImage: selectedProfileImage,
                        category: category.rawValue,
                        letterCount: 0,
                        bookmarkedCount: 0,
                        createdAt: Date(),
                        lastLoginAt: Date(),
                        bookmarkedQuestions: [],
                        sentQuestions: []
                    )
                    try await FirebaseService.shared.createLearner(learner: learner)
                    print(" 학습자 정보 저장 완료: \(name), \(category.displayName)")
                    
                case .mentor:
                    let mentor = Mentor(
                        id: user.uid,
                        name: name,
                        bio: bio,
                        profileImage: selectedProfileImage,
                        expertise: expertise.rawValue
                    )
                    try await FirebaseService.shared.createMentor(mentor: mentor)
                    print(" 멘토 정보 저장 완료: \(name), \(expertise.displayName), \(bio)")
                }
                
                await MainActor.run {
                    UserDefaults.standard.set(false, forKey: "isLoggedOut")
                    isLoading = false
                    dismiss()
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    print(" 사용자 정보 저장 실패: \(error.localizedDescription)")
                    errorMessage = "사용자 정보 저장에 실패했습니다."
                    isLoading = false
                }
            }
        }
    }
} 
