import SwiftUI

struct HomeView: View {
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true
    @State private var selectedMentor: Mentor? = nil
    
    var body: some View {
        NavigationView {
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
                        VStack(spacing: 30) {
                            VStack(spacing: 5) {
                                MentBoxHeader(title: "MENTBOX", isPadding: false)
                                MentorsSection(mentors: mentors, selectedMentor: $selectedMentor)
                            }

                            VStack {
                                HStack {
                                    Text("공감 받은 사연")
                                        .menterFont(.header)
                                    Spacer()
                                }

                                if chatPairs.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                        Text("아직 답변된 사연이 없습니다")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    VStack(spacing: 20) {
                                        ForEach(chatPairs.indices, id: \.self) { index in
                                            let pair = chatPairs[index]
                                            ChatCardView(question: pair.question, answer: pair.answer)
                                        }
                                    }
                                    .padding(.vertical)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationBarTitle("MENTBOX", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear {
                loadData()
            }
            .background(
                NavigationLink(
                    destination: MentorDetailView(mentor: selectedMentor ?? mentors[0])
                        .navigationBarHidden(true),
                    isActive: Binding(
                        get: { selectedMentor != nil },
                        set: { if !$0 { selectedMentor = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private func loadData() {
        isLoading = true
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
        
        group.notify(queue: .main) {
            isLoading = false
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
