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
                        // 첫 번째 ChatCardView
                        ChatCardView(
                            question: ChatBox(
                                messageType: .question,
                                senderName: "김서준",
                                content: "iOS 개발자로 전환하고 싶은데, 현재 안드로이드 개발자에서 전환하는 게 쉽지 않네요. Swift UI가 매력적으로 보이는데, 어떤 방식으로 접근하면 좋을까요?",
                                sentDate: Date(),
                                isFromMe: true,
                                recipient: Mentor(
                                    name: "Gommin",
                                    bio: "Senior iOS Developer",
                                    profileImage: "Gommin",
                                    expertise: "Tech"
                                ),
                                isBookmarked: false,
                                bookmarkCount: 42
                            ),
                            answer: ChatBox(
                                messageType: .answer,
                                senderName: "Gommin",
                                content: "안드로이드 개발자셨다니 좋은 기반이 있으시네요! SwiftUI는 선언적 UI로 Jetpack Compose와 비슷한 개념이에요. 저도 비슷한 경험이 있는데, MVVM 패턴을 아신다면 더 쉽게 적응하실 수 있을 거예요. Stanford CS193p 강의로 시작해보시는 걸 추천드립니다. 제가 전환 과정에서 작성했던 학습 로드맵도 공유해드릴 수 있어요 😊",
                                sentDate: Date(),
                                isFromMe: false,
                                recipient: Mentor(
                                    name: "Gommin",
                                    bio: "Senior iOS Developer",
                                    profileImage: "Gommin",
                                    expertise: "Tech"
                                ),
                                isBookmarked: true,
                                bookmarkCount: 42
                            )
                        )

                        // 두 번째 ChatCardView
                        ChatCardView(
                            question: ChatBox(
                                messageType: .question,
                                senderName: "이하늘",
                                content: "UX 디자인 포트폴리오를 준비중인데요, 실무에서는 어떤 부분을 중점적으로 보시나요? 프로젝트의 깊이와 다양성 중 어떤 것에 더 초점을 맞추는 게 좋을까요?",
                                sentDate: Date(),
                                isFromMe: true,
                                recipient: Mentor(
                                    name: "Daisy",
                                    bio: "UX/UI Designer",
                                    profileImage: "Daisy",
                                    expertise: "Design"
                                ),
                                isBookmarked: false,
                                bookmarkCount: 38
                            ),
                            answer: ChatBox(
                                messageType: .answer,
                                senderName: "Daisy",
                                content: "포트폴리오에서 가장 중요한 건 문제 해결 과정이에요. 다양한 프로젝트보다는 2-3개의 프로젝트를 깊이있게 보여주세요. 특히 사용자 리서치부터 최종 결과물까지의 의사결정 과정이 잘 드러나면 좋아요. 실패한 시도들과 그로부터 배운 점을 포함하면 더 진정성있게 느껴질 거예요. 제 경험상 회사들은 탄탄한 프로세스와 논리적인 사고를 중요하게 봅니다 ✨",
                                sentDate: Date(),
                                isFromMe: false,
                                recipient: Mentor(
                                    name: "Daisy",
                                    bio: "UX/UI Designer",
                                    profileImage: "Daisy",
                                    expertise: "Design"
                                ),
                                isBookmarked: true,
                                bookmarkCount: 38
                            )
                        )
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
