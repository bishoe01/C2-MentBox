import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MentorDetailView: View {
    let mentor: Mentor
    @Environment(\.presentationMode) private var presentationMode
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var pendingQuestions: [(question: ChatBox, mentor: Mentor)] = []
    @State private var questionText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showDeleteAlert = false
    @State private var selectedQuestionId: String = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // 멘토 프로필 섹션
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Image(mentor.profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mentor.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(mentor.expertise)
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal)
                            
                            Text(mentor.bio)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
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
                        
                        // 답변 대기 중인 질문 섹션
                        if !pendingQuestions.isEmpty {
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
                        
                        // 멘토가 답변한 사연들
                        VStack(alignment: .leading, spacing: 20) {
                            Text("답변한 사연")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                ForEach(chatPairs.indices, id: \.self) { index in
                                    let pair = chatPairs[index]
                                    ChatCardView(question: pair.question, answer: pair.answer)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // 편지 작성 영역
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        ZStack(alignment: .center) {
                            if questionText.isEmpty {
                                Text("\(mentor.name) 멘토에게 편지를 작성해주세요")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $questionText)
                                .frame(height: 40)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Button(action: {
                            checkPendingQuestion()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("btn_dark"), Color("btn_light")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        .disabled(questionText.isEmpty || isSubmitting)
                        .opacity(questionText.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.black.opacity(0.5))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadChatPairs()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .alert("질문 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                deleteQuestion()
            }
        } message: {
            Text("이 질문을 삭제하시겠습니까?")
        }
    }
    
    private func checkPendingQuestion() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        FirebaseService.shared.canSendQuestion(userId: userId, mentorId: mentor.id) { canSend in
            isSubmitting = false
            
            if canSend {
                self.submitQuestion()
            } else {
                self.alertMessage = "이미 답변을 기다리고 있는 질문이 있습니다. 답변이 완료된 후에 새로운 질문을 보낼 수 있습니다."
                self.showAlert = true
            }
        }
    }
    
    private func submitQuestion() {
        guard !questionText.isEmpty else { return }
        
        isSubmitting = true
        
        // Firebase에 질문 저장
        let questionId = UUID().uuidString
        let question = ChatBox(
            id: questionId,
            messageType: .question,
            userId: Auth.auth().currentUser?.uid ?? "",
            senderName: Auth.auth().currentUser?.displayName ?? "익명",
            content: questionText,
            sentDate: Date(),
            isFromMe: true,
            mentorId: mentor.id,
            bookmarkCount: 0,
            questionId: nil,
            status: "pending"
        )
        
        // questions 컬렉션에 질문 저장
        let db = Firestore.firestore()
        let questionData: [String: Any] = [
            "id": question.id,
            "userId": question.userId,
            "senderName": question.senderName,
            "content": question.content,
            "sentDate": Timestamp(date: question.sentDate),
            "mentorId": question.mentorId,
            "status": question.status ?? "pending",
            "bookmarkCount": question.bookmarkCount
        ]
        
        // learner 컬렉션의 sentQuestions 필드 업데이트
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("learners").document(userId).getDocument { document, error in
                if let error = error {
                    print(" 사용자 데이터 가져오기 실패: \(error)")
                    return
                }
                
                var sentQuestions = document?.data()?["sentQuestions"] as? [String] ?? []
                sentQuestions.append(questionId)
                
                // 질문 저장과 sentQuestions 업데이트를 하나의 배치로 처리
                let batch = db.batch()
                
                let questionRef = db.collection("questions").document(questionId)
                batch.setData(questionData, forDocument: questionRef)
                
                let learnerRef = db.collection("learners").document(userId)
                batch.updateData(["sentQuestions": sentQuestions], forDocument: learnerRef)
                
                batch.commit { error in
                    if let error = error {
                        print(" 데이터 저장 실패: \(error)")
                        self.alertMessage = "편지 전송에 실패했습니다."
                        self.showAlert = true
                    } else {
                        print(" 데이터 저장 성공")
                        self.alertMessage = "편지가 성공적으로 전송되었습니다. 답변을 기다려주세요."
                        self.showAlert = true
                        self.questionText = ""
                        // 질문 전송 후 데이터 새로고침
                        self.loadChatPairs()
                    }
                    self.isSubmitting = false
                }
            }
        }
    }
    
    private func loadChatPairs() {
        print("🔍 MentorDetailView - loadChatPairs 시작 - mentorId: \(mentor.id)")
        FirebaseService.shared.fetchQuestionAnswerPairs(for: mentor.id) { pairs in
            print(" MentorDetailView - 데이터 로드 완료 - pairs 개수: \(pairs.count)")
            self.chatPairs = pairs
        }
        
        // 답변 대기 중인 질문 로드
        if let userId = Auth.auth().currentUser?.uid {
            FirebaseService.shared.fetchPendingQuestions(userId: userId) { pendingPairs in
                self.pendingQuestions = pendingPairs.filter { $0.question.mentorId == mentor.id }
            }
        }
    }
    
    private func deleteQuestion() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        Task {
            do {
                try await FirebaseService.shared.deletePendingQuestion(questionId: selectedQuestionId, userId: userId)
                // 삭제 후 데이터 다시 로드
                await MainActor.run {
                    loadChatPairs()
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

struct MentorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MentorDetailView(mentor: Mentor(
                id: "preview_mentor_id",
                name: "김멘토",
                bio: "10년차 iOS 개발자",
                profileImage: "profile_image",
                expertise: "테크"
            ))
        }
    }
}
