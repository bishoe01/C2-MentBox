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
