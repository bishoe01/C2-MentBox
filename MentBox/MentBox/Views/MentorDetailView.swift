import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor
    @Environment(\.dismiss) private var dismiss
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var isShowingNewQuestionSheet = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
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
                                dismiss()
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
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(mentor.name)
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            loadChatPairs()
        }
    }
    
    private func loadChatPairs() {
        print("🔍 MentorDetailView - loadChatPairs 시작 - mentorId: \(mentor.id)")
        FirebaseService.shared.fetchQuestionAnswerPairs(for: mentor.id) { pairs in
            print("✅ MentorDetailView - 데이터 로드 완료 - pairs 개수: \(pairs.count)")
            self.chatPairs = pairs
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
