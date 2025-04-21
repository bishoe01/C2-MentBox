import SwiftUI
import FirebaseAuth

struct SavedView: View {
    @State private var selectedCategory: Category = .all
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true

    var filteredChatPairs: [(question: ChatBox, answer: ChatBox)] {
        if selectedCategory == .all {
            return chatPairs
        }
        return chatPairs.filter { pair in
            if let mentor = mentors.first(where: { $0.id == pair.answer.mentorId }) {
                return mentor.expertise.lowercased() == selectedCategory.rawValue.lowercased()
            }
            return false
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                CategoryToggleView(
                    selectedCategory: $selectedCategory,
                    title: "공감 받은 사연",
                    onSeeAll: {},
                    showSeeAll: false
                )

                if isLoading {
                    ProgressView()
                        .padding()
                } else if chatPairs.isEmpty {
                    Text("북마크한 질문이 없습니다.")
                        .foregroundColor(.white)
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        ForEach(filteredChatPairs.indices, id: \.self) { index in
                            let pair = filteredChatPairs[index]
                            ChatCardView(question: pair.question, answer: pair.answer)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding(.horizontal, 16)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookmarkChanged"))) { _ in
            loadData()
        }
    }

    private func loadData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 로그인된 사용자가 없습니다.")
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
}

// preview
struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                MentBoxHeader(title: "MENTBOX")
                SavedView()
            }
        }
    }
}
