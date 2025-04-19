import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor
    
    var mentorChatPairs: [(question: ChatBox, answer: ChatBox)] {
        MockChatBoxData.chatPairs.filter { pair in
            // 멘토랑 이름 일치하면 가능
            pair.answer.recipient.name == mentor.name
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 멘토 프로필 섹션
                    VStack(spacing: 16) {
                        Image(mentor.profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                        
                        Text(mentor.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(mentor.expertise)
                            .font(.headline)
                            .foregroundColor(.yellow)
                        
                        Text(mentor.bio)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    // 멘토가 답변한 사연들
                    VStack(alignment: .leading, spacing: 20) {
                        Text("답변한 사연")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            ForEach(mentorChatPairs.indices, id: \.self) { index in
                                let pair = mentorChatPairs[index]
                                ChatCardView(question: pair.question, answer: pair.answer)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(mentor.name)
    }
}

struct MentorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MentorDetailView(mentor: Mentor(
                name: "김멘토",
                bio: "10년차 iOS 개발자",
                profileImage: "profile_image",
                expertise: "테크"
            ))
        }
    }
}
