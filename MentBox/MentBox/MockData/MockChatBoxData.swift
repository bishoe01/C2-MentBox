import Foundation

enum MockChatBoxData {
    static let mentors = [
        Mentor(name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
        Mentor(name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
        Mentor(name: "Lumi", bio: "Business Consultant", profileImage: "Lumi", expertise: "Business")
    ]
    
    static let chatPairs: [(question: ChatBox, answer: ChatBox)] = [
        (
            question: ChatBox(
                messageType: .question,
                senderName: "김서준",
                content: "iOS 개발자로 전환하고 싶은데...",
                sentDate: Date(),
                isFromMe: true,
                recipient: mentors[0],
                isBookmarked: false,
                bookmarkCount: 42,
                mentorId: mentors[0].id
            ),
            answer: ChatBox(
                messageType: .answer,
                senderName: "Gommin",
                content: "안드로이드 개발자셨다니 좋은 기반이...",
                sentDate: Date(),
                isFromMe: false,
                recipient: mentors[0],
                isBookmarked: true,
                bookmarkCount: 42,
                mentorId: mentors[0].id
            )
        ),
        (
            question: ChatBox(
                messageType: .question,
                senderName: "이하늘",
                content: "UX 디자인 포트폴리오를 준비중인데요...",
                sentDate: Date(),
                isFromMe: true,
                recipient: mentors[1],
                isBookmarked: false,
                bookmarkCount: 38,
                mentorId: mentors[1].id
            ),
            answer: ChatBox(
                messageType: .answer,
                senderName: "Daisy",
                content: "포트폴리오에서 가장 중요한 건 문제 해결 과정이에요...",
                sentDate: Date(),
                isFromMe: false,
                recipient: mentors[1],
                isBookmarked: true,
                bookmarkCount: 38,
                mentorId: mentors[1].id
            )
        ),
        (
            question: ChatBox(
                messageType: .question,
                senderName: "박지성",
                content: "스타트업 창업을 준비중인데...",
                sentDate: Date(),
                isFromMe: true,
                recipient: mentors[2],
                isBookmarked: false,
                bookmarkCount: 25,
                mentorId: mentors[2].id
            ),
            answer: ChatBox(
                messageType: .answer,
                senderName: "Lumi",
                content: "스타트업 창업에서 가장 중요한 것은...",
                sentDate: Date(),
                isFromMe: false,
                recipient: mentors[2],
                isBookmarked: true,
                bookmarkCount: 25,
                mentorId: mentors[2].id
            )
        )
    ]
}
