import Foundation

enum MockChatBoxData {
    // 현재 로그인된 사용자 ID
    static let currentUserId = "4gGsjHzRmXa51VGNaaKt35eeYmY2"
    
    // 고유 ID 생성
    static let mentorIds = [
        "mentor_1": UUID().uuidString,
        "mentor_2": UUID().uuidString,
        "mentor_3": UUID().uuidString,
        "mentor_4": UUID().uuidString,
        "mentor_5": UUID().uuidString,
        "mentor_6": UUID().uuidString
    ]
    
    static let questionIds = [
        "question_1": UUID().uuidString,
        "question_2": UUID().uuidString,
        "question_3": UUID().uuidString
    ]
    
    static let answerIds = [
        "answer_1": UUID().uuidString,
        "answer_2": UUID().uuidString,
        "answer_3": UUID().uuidString
    ]
    
    static let mentors = [
        Mentor(id: mentorIds["mentor_1"]!, name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
        Mentor(id: mentorIds["mentor_2"]!, name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
        Mentor(id: mentorIds["mentor_3"]!, name: "Lumi", bio: "Business Consultant", profileImage: "Lumi", expertise: "Business"),
        Mentor(id: mentorIds["mentor_4"]!, name: "Finn", bio: "Product Manager", profileImage: "Finn", expertise: "Business"),
        Mentor(id: mentorIds["mentor_5"]!, name: "Eve", bio: "Frontend Developer", profileImage: "Eve", expertise: "Tech"),
        Mentor(id: mentorIds["mentor_6"]!, name: "Max", bio: "Graphic Designer", profileImage: "Max", expertise: "Design")
    ]

    static let chatPairs: [(question: ChatBox, answer: ChatBox)] = [
        // Tech 관련 질문 (현재 사용자가 보낸 질문)
        (
            question: ChatBox(
                id: questionIds["question_1"]!,
                messageType: .question,
                userId: currentUserId,
                senderName: "김서준",
                content: "iOS 개발자로 전환하고 싶은데, 어떤 것부터 시작하면 좋을까요?",
                sentDate: Date().addingTimeInterval(-86400 * 3),
                isFromMe: true,
                mentorId: mentorIds["mentor_1"]!,
                bookmarkCount: 42,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: answerIds["answer_1"]!,
                messageType: .answer,
                userId: mentorIds["mentor_1"]!,
                senderName: "Gommin",
                content: "안드로이드 개발자셨다니 좋은 기반이 있으시네요! iOS 개발을 시작하시려면 Swift 언어부터 시작하시는 것을 추천드립니다. Xcode를 설치하시고, SwiftUI나 UIKit을 통해 UI를 만들어보시는 것도 좋은 시작이 될 것 같습니다.",
                sentDate: Date().addingTimeInterval(-86400 * 2),
                isFromMe: false,
                mentorId: mentorIds["mentor_1"]!,
                bookmarkCount: 42,
                questionId: questionIds["question_1"]!,
                status: nil
            )
        ),
        // Design 관련 질문 (현재 사용자가 북마크한 질문)
        (
            question: ChatBox(
                id: questionIds["question_2"]!,
                messageType: .question,
                userId: "temp_user_1",
                senderName: "이지은",
                content: "UX 디자인 포트폴리오를 준비하고 있는데, 어떤 프로젝트를 포함시키면 좋을까요?",
                sentDate: Date().addingTimeInterval(-86400 * 5),
                isFromMe: true,
                mentorId: mentorIds["mentor_2"]!,
                bookmarkCount: 28,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: answerIds["answer_2"]!,
                messageType: .answer,
                userId: mentorIds["mentor_2"]!,
                senderName: "Daisy",
                content: "포트폴리오에는 사용자 리서치, 와이어프레임, 프로토타입 등 UX 디자인의 전체 과정을 보여주는 프로젝트를 포함시키는 것이 좋습니다. 특히 실제 사용자 피드백을 반영한 개선 사례가 있다면 더 좋겠죠.",
                sentDate: Date().addingTimeInterval(-86400 * 4),
                isFromMe: false,
                mentorId: mentorIds["mentor_2"]!,
                bookmarkCount: 28,
                questionId: questionIds["question_2"]!,
                status: nil
            )
        ),
        // Business 관련 질문 (현재 사용자가 보낸 질문)
        (
            question: ChatBox(
                id: questionIds["question_3"]!,
                messageType: .question,
                userId: currentUserId,
                senderName: "박민수",
                content: "스타트업에서 PM으로 일하고 싶은데, 어떤 스킬을 키워야 할까요?",
                sentDate: Date().addingTimeInterval(-86400 * 7),
                isFromMe: true,
                mentorId: mentorIds["mentor_3"]!,
                bookmarkCount: 35,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: answerIds["answer_3"]!,
                messageType: .answer,
                userId: mentorIds["mentor_3"]!,
                senderName: "Lumi",
                content: "스타트업 PM은 다양한 역할을 수행해야 합니다. 제품 기획, 데이터 분석, 커뮤니케이션 스킬이 중요합니다. 특히 사용자 중심의 사고방식과 빠른 의사결정 능력이 필요합니다.",
                sentDate: Date().addingTimeInterval(-86400 * 6),
                isFromMe: false,
                mentorId: mentorIds["mentor_3"]!,
                bookmarkCount: 35,
                questionId: questionIds["question_3"]!,
                status: nil
            )
        )
    ]
    
    // 현재 사용자의 Learner 데이터
    static let currentLearner = Learner(
        id: currentUserId,
        name: "김서준",
        email: "example@example.com",
        profileImage: nil,
        category: "Tech",
        letterCount: 2,
        bookmarkedCount: 1,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        lastLoginAt: Date(),
        bookmarkedQuestions: [questionIds["question_2"]!], // 북마크한 질문 ID
        sentQuestions: [questionIds["question_1"]!, questionIds["question_3"]!] // 보낸 질문 ID
    )
}
