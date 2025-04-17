import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MentorsSection()

                VStack {
                    HStack {
                        Text("공감 받은 사연")
                            .menterFont(.header)
                        Spacer()
                    }

                    VStack(spacing: 20) {
                        ForEach(MockChatBoxData.chatPairs.indices, id: \.self) { index in
                            let pair = MockChatBoxData.chatPairs[index]
                            ChatCardView(question: pair.question, answer: pair.answer)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding(.horizontal, 16)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                MentBoxHeader(title: "MENTBOX")
                HomeView()
            }
        }
    }
}
