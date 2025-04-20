import SwiftUI

struct SavedView: View {
    @State private var selectedCategory: Category = .all
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var mentors: [Mentor] = []

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

                VStack(spacing: 20) {
                    ForEach(filteredChatPairs.indices, id: \.self) { index in
                        let pair = filteredChatPairs[index]
                        ChatCardView(question: pair.question, answer: pair.answer)
                    }
                }
                .padding(.vertical)
            }
        }
        .padding(.horizontal, 16)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        let group = DispatchGroup()

        group.enter()
        FirebaseService.shared.fetchMentors { fetchedMentors in
            self.mentors = fetchedMentors
            group.leave()
        }

        group.enter()
        FirebaseService.shared.fetchAllQuestionAnswerPairs { pairs in
            self.chatPairs = pairs
            group.leave()
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
