import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MentorStoriesView: View {
    @State private var pendingQuestions: [(question: ChatBox, learner: Learner)] = []
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedQuestion: ChatBox?
    @State private var answerText = ""
    @State private var isSubmitting = false
    @State private var showTestAlert = false
    @State private var showCreateLearnerAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    MentBoxHeader(title: "MENTBOX", isPadding: false)
                    
                    HStack {
                        Text("답변 대기 중인 사연")
                            .menterFont(.header)
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                } else if pendingQuestions.isEmpty {
                    Text("답변 대기 중인 사연이 없습니다.")
                        .foregroundColor(.white)
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        ForEach(pendingQuestions.indices, id: \.self) { index in
                            let pair = pendingQuestions[index]
                            VStack(alignment: .leading, spacing: 12) {
                                // 학습자 정보
                                HStack(spacing: 12) {
                                    Image(pair.learner.profileImage ?? "default_profile")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(pair.learner.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(pair.learner.category)
                                            .font(.subheadline)
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(pair.question.sentDate.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                // 질문 내용
                                Text(pair.question.content)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("btn_dark").opacity(0.3))
                                    )
                                
                                // 답변 입력 필드
                                TextField("답변을 입력하세요...", text: $answerText, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                
                                // 답변 제출 버튼
                                Button(action: {
                                    selectedQuestion = pair.question
                                    submitAnswer()
                                }) {
                                    Text("답변 제출")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.yellow)
                                        .cornerRadius(12)
                                }
                                .disabled(answerText.isEmpty || isSubmitting)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
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
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .alert("테스트 사연 보내기", isPresented: $showTestAlert) {
            Button("취소", role: .cancel) {}
            Button("보내기") {
                sendTestQuestion()
            }
        } message: {
            Text("테스트 사연을 보내시겠습니까?")
        }
        .alert("테스트 Learner 생성", isPresented: $showCreateLearnerAlert) {
            Button("취소", role: .cancel) {}
            Button("생성") {
                createTestLearner()
            }
        } message: {
            Text("테스트 Learner를 생성하시겠습니까?")
        }
        .onAppear {
            loadPendingQuestions()
        }
    }
    
    private func loadPendingQuestions() {
        guard let mentorId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            isLoading = false
            return
        }
        
        print("🔍 멘토 ID: \(mentorId)에게 온 사연을 불러옵니다...")
        
        FirebaseService.shared.fetchPendingQuestionsForMentor(mentorId: mentorId) { pairs in
            Task { @MainActor in
                print("📝 받은 사연 개수: \(pairs.count)")
                for (index, pair) in pairs.enumerated() {
                    print("""
                    📌 사연 #\(index + 1)
                    - 질문자: \(pair.learner.name)
                    - 카테고리: \(pair.learner.category)
                    - 내용: \(pair.question.content)
                    - 날짜: \(pair.question.sentDate)
                    """)
                }
                self.pendingQuestions = pairs
                self.isLoading = false
            }
        }
    }
    
    private func submitAnswer() {
        guard let question = selectedQuestion,
              let mentorId = Auth.auth().currentUser?.uid
        else {
            alertMessage = "답변을 제출할 수 없습니다."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        Task {
            do {
                try await FirebaseService.shared.submitAnswer(
                    questionId: question.id,
                    mentorId: mentorId,
                    content: answerText
                )
                
                await MainActor.run {
                    alertMessage = "답변이 성공적으로 제출되었습니다."
                    showAlert = true
                    answerText = ""
                    loadPendingQuestions()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "답변 제출에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            
            await MainActor.run {
                isSubmitting = false
            }
        }
    }
    
    private func sendTestQuestion() {
        guard let mentorId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        Task {
            do {
                try await FirebaseService.shared.sendQuestionToMentor(
                    mentorId: mentorId,
                    content: "안녕하세요! iOS 개발에 대해 궁금한 점이 있어서 질문드립니다. SwiftUI에서 상태 관리는 어떻게 하는 것이 좋을까요?"
                )
                
                await MainActor.run {
                    alertMessage = "테스트 사연이 성공적으로 전송되었습니다."
                    showAlert = true
                    loadPendingQuestions()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "테스트 사연 전송에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func createTestLearner() {
        let testLearner = Learner(
            id: "4gGsjHzRmXa51VGNaaKt35eeYmY2",
            name: "테스트 러너",
            email: "test@example.com",
            profileImage: "default_profile",
            category: "Tech",
            letterCount: 0,
            bookmarkedCount: 0,
            createdAt: Date(),
            lastLoginAt: Date(),
            bookmarkedQuestions: [],
            sentQuestions: []
        )
        
        Task {
            do {
                try await FirebaseService.shared.createLearner(learner: testLearner)
                await MainActor.run {
                    alertMessage = "테스트 Learner가 생성되었습니다."
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Learner 생성에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct MentorStoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MentorStoriesView()
    }
}
