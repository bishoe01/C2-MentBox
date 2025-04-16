import SwiftUI

struct HomeView: View {
    var body: some View {
        // 스크롤 뷰
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 첫 번째 ChatCardView
                    ChatCardView(
                        question: ChatBox(
                            messageType: .question,
                            senderName: "사용자1",
                            content: "첫 번째 질문입니다.",
                            sentDate: Date(),
                            isFromMe: true,
                            recipient: Mentor(
                                name: "김멘토",
                                bio: "10년차 iOS 개발자",
                                profileImage: "profile_image",
                                expertise: "테크"
                            ),
                            isBookmarked: false,
                            bookmarkCount: 0
                        ),
                        answer: ChatBox(
                            messageType: .answer,
                            senderName: "김멘토",
                            content: "첫 번째 답변입니다.",
                            sentDate: Date(),
                            isFromMe: false,
                            recipient: Mentor(
                                name: "김멘토",
                                bio: "10년차 iOS 개발자",
                                profileImage: "profile_image",
                                expertise: "테크"
                            ),
                            isBookmarked: false,
                            bookmarkCount: 0
                        )
                    )
                    .padding(.horizontal)

                    // 두 번째 ChatCardView
                    ChatCardView(
                        question: ChatBox(
                            messageType: .question,
                            senderName: "사용자2",
                            content: "두 번째 질문입니다.",
                            sentDate: Date(),
                            isFromMe: true,
                            recipient: Mentor(
                                name: "이멘토",
                                bio: "5년차 UX 디자이너",
                                profileImage: "profile_image",
                                expertise: "디자인"
                            ),
                            isBookmarked: false,
                            bookmarkCount: 0
                        ),
                        answer: ChatBox(
                            messageType: .answer,
                            senderName: "이멘토",
                            content: "두 번째 답변입니다.",
                            sentDate: Date(),
                            isFromMe: false,
                            recipient: Mentor(
                                name: "이멘토",
                                bio: "5년차 UX 디자이너",
                                profileImage: "profile_image",
                                expertise: "디자인"
                            ),
                            isBookmarked: false,
                            bookmarkCount: 0
                        )
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
