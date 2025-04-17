import Foundation

enum MockChatBoxData {
    static let chatPairs: [(question: ChatBox, answer: ChatBox)] = [
        (
            question: ChatBox(
                messageType: .question,
                senderName: "김서준",
                content: "iOS 개발자로 전환하고 싶은데...",
                sentDate: Date(),
                isFromMe: true,
                recipient: Mentor(name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
                isBookmarked: false,
                bookmarkCount: 42
            ),
            answer: ChatBox(
                messageType: .answer,
                senderName: "Gommin",
                content: "안드로이드 개발자셨다니 좋은 기반이...",
                sentDate: Date(),
                isFromMe: false,
                recipient: Mentor(name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
                isBookmarked: true,
                bookmarkCount: 42
            )
        ),
        (
            question: ChatBox(
                messageType: .question,
                senderName: "이하늘",
                content: "UX 디자인 포트폴리오를 준비중인데요...",
                sentDate: Date(),
                isFromMe: true,
                recipient: Mentor(name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
                isBookmarked: false,
                bookmarkCount: 38
            ),
            answer: ChatBox(
                messageType: .answer,
                senderName: "Daisy",
                content: "포트폴리오에서 가장 중요한 건 문제 해결 과정이에요...",
                sentDate: Date(),
                isFromMe: false,
                recipient: Mentor(name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
                isBookmarked: true,
                bookmarkCount: 38
            )
        )
    ]
}
