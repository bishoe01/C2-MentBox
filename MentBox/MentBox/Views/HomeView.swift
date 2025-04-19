import SwiftUI

struct HomeView: View {
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var mentors: [Mentor] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("BG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 5) {
                            MentBoxHeader(title: "MENTBOX", isPadding: false)
                            MentorsSection(mentors: mentors)
                        }

                        VStack {
                            HStack {
                                Text("공감 받은 사연")
                                    .menterFont(.header)
                                Spacer()
                            }

                            VStack(spacing: 20) {
                                ForEach(chatPairs.indices, id: \.self) { index in
                                    let pair = chatPairs[index]
                                    ChatCardView(question: pair.question, answer: pair.answer)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
