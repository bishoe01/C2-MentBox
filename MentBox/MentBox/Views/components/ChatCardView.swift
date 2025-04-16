import SwiftUI

struct ChatCardView: View {
    let question: ChatBox
    let answer: ChatBox
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 질문 부분
            VStack(alignment: .leading, spacing: 8) {
                Text(question.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)))
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // 답변 부분
            VStack(alignment: .leading, spacing: 16) {
                // 멘토 프로필 영역
                HStack(spacing: 12) {
                    // 프로필 이미지
                    AsyncImage(url: URL(string: answer.recipient.profileImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    // 멘토 이름
                    Text(answer.recipient.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // 답변 내용
                Text(answer.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .background(Color(uiColor: UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    let previewMentor = Mentor(
        name: "데이지",
        bio: "UX 디자이너",
        profileImage: "https://example.com/profile.jpg",
        expertise: "디자인"
    )
    
    let previewQuestion = ChatBox(
        messageType: .question,
        senderName: "사용자",
        content: "다시는 잃을은 때 쓸빛이네 푸른 아무것도 회한도 푸른 파란 시간에 잊지 때 생각이다.",
        sentDate: Date(),
        isFromMe: true,
        recipient: previewMentor,
        isBookmarked: false,
        bookmarkCount: 0
    )
    
    let previewAnswer = ChatBox(
        messageType: .answer,
        senderName: "데이지",
        content: "답변 내용입니다.",
        sentDate: Date(),
        isFromMe: false,
        recipient: previewMentor,
        isBookmarked: false,
        bookmarkCount: 0
    )
    
    return ChatCardView(question: previewQuestion, answer: previewAnswer)
        .padding()
        .background(Color.black)
} 
