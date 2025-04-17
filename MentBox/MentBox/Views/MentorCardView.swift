import SwiftUI

struct MentorCardView: View {
    let mentor: Mentor
    @State private var isPressed = false
    
    var profileImageName: String {
        "\(mentor.name)"
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
            // 채팅 시작 액션
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // 프로필 이미지와 이모지
                HStack(alignment: .top) {
                    Image(profileImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                    
                    Spacer()
                    
                    // 분야별 이모지
                    Text(mentor.expertise == "Tech" ? "👨‍💻" :
                         mentor.expertise == "Design" ? "🎨" : "💼")
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(mentor.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(mentor.expertise)
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                    
                    Text(mentor.bio)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 180, height: 220)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("btn_dark").opacity(0.95),
                                Color("btn_light").opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("lightGray").opacity(0.6),
                                Color("lightGray").opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: isPressed ? 0.5 : 0)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MentorCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MentorCardView(mentor: Mentor(
                name: "김멘토",
                bio: "10년차 iOS 개발자",
                profileImage: "profile_image",
                expertise: "테크"
            ))
        }
    }
} 
