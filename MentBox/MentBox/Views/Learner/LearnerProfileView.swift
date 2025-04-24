import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct LearnerProfileView: View {
    @State private var learner: Learner?
    @State private var pendingQuestions: [(question: ChatBox, mentor: Mentor)] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignInView = false
    @State private var showDeleteAlert = false
    @State private var selectedQuestionId = ""
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 5) {
                            MentBoxHeader(title: "MENTBOX", isPadding: false)

                            HStack {
                                Text("러너 프로필").menterFont(.header)
                                Spacer()
                            }.padding(.top, 16)
                        }.padding(.horizontal, 16)
                        VStack(spacing: 5) {
                            // 프로필 카드
                            HStack(spacing: 16) {
                                Image(learner?.profileImage ?? "default_profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 3)
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(learner?.name ?? "학습자")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)

                                    Text(learner?.category ?? "카테고리 미설정")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow.opacity(0.9))
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                            // 답변 대기 중인 질문
                            if !pendingQuestions.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("답변 대기 중")
                                            .menterFont(.header)
                                        Spacer()
                                        Text("\(pendingQuestions.count)개")
                                            .foregroundColor(.gray)
                                    }

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

                                            ChatCard(question: pair.question, answer: nil)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            // 북마크한 글
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("북마크한 글")
                                        .menterFont(.header)
                                    Spacer()
                                }

                                if chatPairs.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "bookmark")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                        Text("북마크한 질문이 없습니다")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    VStack(spacing: 20) {
                                        ForEach(chatPairs.indices, id: \.self) { index in
                                            let pair = chatPairs[index]
                                            ChatCard(question: pair.question, answer: pair.answer)
                                        }
                                    }
                                    .padding(.vertical)
                                }
                            }
                            .padding(.horizontal, 16)

                            // 로그아웃
                            Button(action: {
                                do {
                                    try Auth.auth().signOut()
                                    showSignInView = true
                                } catch {
                                    alertMessage = "로그아웃에 실패했습니다."
                                    showAlert = true
                                }
                            }) {
                                Text("로그아웃")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.gray.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationBarTitle("MENTBOX", displayMode: .inline)
        .navigationBarHidden(true)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("질문 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteQuestion()
            }
        } message: {
            Text("이 질문을 삭제하시겠습니까?")
        }
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
        }
        .onAppear {
            loadUserData()
            loadBookmarkedData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarkChanged"))) { _ in
            loadBookmarkedData()
        }
    }

    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }

        Task {
            do {
                if let user = try await FirebaseService.shared.fetchLearner(userId: userId) {
                    await MainActor.run {
                        self.learner = user
                    }
                    // 답변 대기 중인 질문을 가져옴
                    FirebaseService.shared.fetchPendingQuestions(userId: userId) { pendingPairs in
                        self.pendingQuestions = pendingPairs
                    }
                }
            } catch {
                alertMessage = "사용자 정보를 불러오는데 실패했습니다."
                showAlert = true
            }
        }
    }

    private func loadBookmarkedData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("로그인된 정보가 없습니다")
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
        FirebaseService.shared.fetchBookmarkedQuestionAnswerPairs(userId: userId) { pairs in
            Task { @MainActor in
                self.chatPairs = pairs
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

struct LearnerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LearnerProfileView()
    }
}
