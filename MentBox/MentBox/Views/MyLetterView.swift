import FirebaseAuth
import SwiftUI

struct MyLetterView: View {
    @State private var selectedCategory: Category = .all
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox?)] = []
    @State private var pendingQuestions: [(question: ChatBox, mentor: Mentor)] = []
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true
    @State private var showDeleteAlert = false
    @State private var selectedQuestionId: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var filteredChatPairs: [(question: ChatBox, answer: ChatBox?)] {
        if selectedCategory == .all {
            return chatPairs
        }
        return chatPairs.filter { pair in
            if let mentor = mentors.first(where: { $0.id == pair.question.mentorId }) {
                return mentor.expertise.lowercased() == selectedCategory.rawValue.lowercased()
            }
            return false
        }
    }
    
    var filteredPendingQuestions: [(question: ChatBox, mentor: Mentor)] {
        if selectedCategory == .all {
            return pendingQuestions
        }
        return pendingQuestions.filter { $0.mentor.expertise.lowercased() == selectedCategory.rawValue.lowercased() }
    }
    
    var answeredQuestions: [(question: ChatBox, answer: ChatBox?)] {
        filteredChatPairs.filter { $0.answer != nil }
    }
    
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 5) {
                        MentBoxHeader(title: "MENTBOX", isPadding: false)
                        
                        CategoryToggleView(
                            selectedCategory: $selectedCategory,
                            title: "내가 쓴 편지",
                            onSeeAll: {},
                            showSeeAll: false
                        )
                    }

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else if chatPairs.isEmpty && pendingQuestions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.5))
                            Text("보낸 질문이 없습니다.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 20) {
                            if !filteredPendingQuestions.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("답변 대기 중")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(filteredPendingQuestions.count)개")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(filteredPendingQuestions.indices, id: \.self) { index in
                                        let pair = filteredPendingQuestions[index]
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
                                .padding(.bottom)
                            }

                            // MARK: 답변 대기

                            if !answeredQuestions.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("답변 완료")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(answeredQuestions.indices, id: \.self) { index in
                                        let pair = answeredQuestions[index]
                                        ChatCardView(question: pair.question, answer: pair.answer!)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarTitle("MENTBOX", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarkChanged"))) { _ in
            loadData()
        }
        .alert("질문 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteQuestion()
            }
        } message: {
            Text("이 질문을 삭제하시겠습니까?")
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print(" 로그인된 사용자가 없습니다.")
            Task { @MainActor in
                isLoading = false
            }
            return
        }

        let group = DispatchGroup()
        
        group.enter()
        FirebaseService.shared.fetchMentors { fetchedMentors in
            Task { @MainActor in
                self.mentors = fetchedMentors
                group.leave()
            }
        }
        
        group.enter()
        FirebaseService.shared.fetchSentQuestionAnswerPairs(userId: userId) { pairs in
            Task { @MainActor in
                self.chatPairs = pairs
                group.leave()
            }
        }
        
        group.enter()
        FirebaseService.shared.fetchPendingQuestions(userId: userId) { pendingPairs in
            Task { @MainActor in
                self.pendingQuestions = pendingPairs
                group.leave()
            }
        }

        group.notify(queue: .main) {
            Task { @MainActor in
                isLoading = false
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
                    loadData()
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

struct MyLetterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                MentBoxHeader(title: "MENTBOX")
                MyLetterView()
            }
        }
    }
}
