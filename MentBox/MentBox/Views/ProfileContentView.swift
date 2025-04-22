import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ProfileContentView: View {
    @State private var showSignInView = false
    @State private var learner: Learner?
    @State private var mentor: Mentor?
    @State private var pendingQuestions: [(question: ChatBox, mentor: Mentor)] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteAlert = false
    @State private var selectedQuestionId = ""
    @State private var savedQuestions: [ChatBox] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 프로필 섹션
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Image(learner?.profileImage ?? mentor?.profileImage ?? "default_profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(learner?.name ?? mentor?.name ?? "사용자")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let learner = learner {
                            Text(learner.category)
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        } else if let mentor = mentor {
                            Text(mentor.expertise)
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if let mentor = mentor {
                    Text(mentor.bio)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("btn_dark").opacity(0.3),
                                Color("btn_light").opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("lightGray"), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            // 답변 대기 중인 질문 섹션 (학습자일 때만 표시)
            if learner != nil && !pendingQuestions.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("답변 대기 중인 질문")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        ForEach(pendingQuestions.indices, id: \.self) { index in
                            let pair = pendingQuestions[index]
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(pair.mentor.profileImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(pair.mentor.name)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text(pair.mentor.expertise)
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedQuestionId = pair.question.id
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                    }
                                }
                                
                                ChatCardView(question: pair.question, answer: nil)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // 로그아웃 버튼
            Button(action: {
                SignInView.signOut()
                showSignInView = true
            }) {
                Text("로그아웃")
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            Button(action: {
                SignInView.signOut()
                showSignInView = true
            }) {
                Text("로그아웃")
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 100)
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .alert("질문 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteQuestion()
            }
        } message: {
            Text("이 질문을 삭제하시겠습니까?")
        }
        .onAppear {
            print("ProfileContentView onAppear")
            loadUserData()
            loadSavedQuestions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarkChanged"))) { _ in
            print("BookmarkChanged notification received")
            loadSavedQuestions()
        }
    }
    
    private func loadUserData() {
        print("loadUserData called")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        Task {
            do {
                print("Fetching user data for ID: \(userId)")
                // 먼저 Learner로 시도
                if let user = try await FirebaseService.shared.fetchLearner(userId: userId) {
                    print("Found learner: \(user.name)")
                    await MainActor.run {
                        self.learner = user
                    }
                    // 학습자인 경우에만 답변 대기 중인 질문을 가져옴
                    FirebaseService.shared.fetchPendingQuestions(userId: userId) { pendingPairs in
                        print("Fetched \(pendingPairs.count) pending questions")
                        self.pendingQuestions = pendingPairs
                    }
                } else {
                    print("No learner found, trying mentor")
                    // Learner가 아니면 Mentor로 시도
                    let mentorDoc = try await Firestore.firestore().collection("mentors").document(userId).getDocument()
                    if let mentorData = mentorDoc.data() {
                        let mentor = Mentor(
                            id: mentorDoc.documentID,
                            name: mentorData["name"] as? String ?? "",
                            bio: mentorData["bio"] as? String ?? "",
                            profileImage: mentorData["profileImage"] as? String ?? "",
                            expertise: mentorData["expertise"] as? String ?? ""
                        )
                        print("Found mentor: \(mentor.name)")
                        await MainActor.run {
                            self.mentor = mentor
                        }
                    }
                }
            } catch {
                print("Error loading user data: \(error.localizedDescription)")
                alertMessage = "사용자 정보를 불러오는데 실패했습니다."
                showAlert = true
            }
        }
    }
    
    private func loadSavedQuestions() {
        print("loadSavedQuestions called")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found for saved questions")
            return
        }
        
        isLoading = true
        print("Fetching saved questions for user: \(userId)")
        FirebaseService.shared.fetchBookmarkedQuestionAnswerPairs(userId: userId) { pairs in
            print("Fetched \(pairs.count) saved questions")
            Task { @MainActor in
                self.savedQuestions = pairs.map { $0.question }
                self.isLoading = false
            }
        }
    }
    
    private func deleteQuestion() {
        print("deleteQuestion called for ID: \(selectedQuestionId)")
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        Task {
            do {
                try await FirebaseService.shared.deletePendingQuestion(questionId: selectedQuestionId, userId: userId)
                await MainActor.run {
                    loadUserData()
                    alertMessage = "질문이 삭제되었습니다."
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "질문 삭제에 실패했습니다."
                    showAlert = true
                }
            }
        }
    }
}
