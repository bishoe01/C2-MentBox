import SwiftUI
import FirebaseAuth

struct MyLetterView: View {
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
                    title: "내가 쓴 편지",
                    onSeeAll: {},
                    showSeeAll: false
                )

                if isLoading {
                    ProgressView()
                        .padding()
                } else if chatPairs.isEmpty {
                    Text("보낸 질문이 없습니다.")
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
    }
    
    private func loadData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 로그인된 사용자가 없습니다.")
            isLoading = false
            return
        }

        let group = DispatchGroup()
        
        group.enter()
        FirebaseService.shared.fetchMentors { fetchedMentors in
            self.mentors = fetchedMentors
            group.leave()
        }
        
        group.enter()
        FirebaseService.shared.fetchSentQuestionAnswerPairs(userId: userId) { pairs in
            self.chatPairs = pairs
            group.leave()
        }

        group.notify(queue: .main) {
            isLoading = false
        }
    }
}

// preview
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
