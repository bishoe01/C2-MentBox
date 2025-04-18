import SwiftUI

struct MyLetterView: View {
    @State private var selectedCategory: Category = .all

    var filteredChatPairs: [(question: ChatBox, answer: ChatBox)] {
        if selectedCategory == .all {
            return MockChatBoxData.chatPairs
        }
        return MockChatBoxData.chatPairs.filter { pair in
            pair.answer.recipient.expertise.lowercased() == selectedCategory.rawValue.lowercased()
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
