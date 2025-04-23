import SwiftUI

struct MentorCardView: View {
    let mentor: Mentor
    @State private var isPressed = false
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // 프로필이랑 카테고리 이모지 넣는 VSTACK
                HStack(alignment: .top) {
                    Image(mentor.profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                    
                    Spacer()
                    
                    // 카테고리별 이모지 -> 아마 라벨같은거로 바뀌어도 괜찮을수도 ?
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
                                Color("btn_dark"),
                                Color("btn_light")
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
        .sheet(isPresented: $showDetail) {
            MentorDetailView(mentor: mentor)
        }
    }
}

struct MentorCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MentorCardView(mentor: Mentor(
                id: "preview_mentor_id",
                name: "김멘토",
                bio: "10년차 iOS 개발자",
                profileImage: "profile_image",
                expertise: "테크"
            ))
        }
    }
}
