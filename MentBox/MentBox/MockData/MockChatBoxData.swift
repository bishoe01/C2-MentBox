import Foundation

enum MockChatBoxData {
    
    static let tempUserIds = [
        UUID().uuidString,
        UUID().uuidString,
        UUID().uuidString,
        UUID().uuidString,
        UUID().uuidString  
    ]
    
    static let mentors = [
        Mentor(id: "mentor_1", name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
        Mentor(id: "mentor_2", name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
        Mentor(id: "mentor_3", name: "Lumi", bio: "Business Consultant", profileImage: "Lumi", expertise: "Business"),
        Mentor(id: "mentor_4", name: "Finn", bio: "Product Manager", profileImage: "Finn", expertise: "Business"),
        Mentor(id: "mentor_5", name: "Eve", bio: "Frontend Developer", profileImage: "Eve", expertise: "Tech"),
        Mentor(id: "mentor_6", name: "Max", bio: "Graphic Designer", profileImage: "Max", expertise: "Design")
    ]

    static let chatPairs: [(question: ChatBox, answer: ChatBox)] = [
        // Tech 관련 질문
        (
            question: ChatBox(
                id: "question_1",
                messageType: .question,
                userId: tempUserIds[0],
                senderName: "김서준",
                content: "iOS 개발자로 전환하고 싶은데, 어떤 것부터 시작하면 좋을까요?",
                sentDate: Date().addingTimeInterval(-86400 * 3),
                isFromMe: true,
                mentorId: mentors[0].id,
                bookmarkCount: 42,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: "answer_1",
                messageType: .answer,
                userId: mentors[0].id,
                senderName: "Gommin",
                content: "안드로이드 개발자셨다니 좋은 기반이 있으시네요! iOS 개발을 시작하시려면 Swift 언어부터 시작하시는 것을 추천드립니다. Xcode를 설치하시고, SwiftUI나 UIKit을 통해 UI를 만들어보시는 것도 좋은 시작이 될 것 같습니다.",
                sentDate: Date().addingTimeInterval(-86400 * 2),
                isFromMe: false,
                mentorId: mentors[0].id,
                bookmarkCount: 42,
                questionId: "question_1",
                status: nil
            )
        ),
        // Design 관련 질문
        (
            question: ChatBox(
                id: "question_2",
                messageType: .question,
                userId: tempUserIds[1],
                senderName: "이지은",
                content: "UX 디자인 포트폴리오를 준비하고 있는데, 어떤 프로젝트를 포함시키면 좋을까요?",
                sentDate: Date().addingTimeInterval(-86400 * 5),
                isFromMe: true,
                mentorId: mentors[1].id,
                bookmarkCount: 28,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: "answer_2",
                messageType: .answer,
                userId: mentors[1].id,
                senderName: "Daisy",
                content: "포트폴리오에는 사용자 리서치, 와이어프레임, 프로토타입 등 UX 디자인의 전체 과정을 보여주는 프로젝트를 포함시키는 것이 좋습니다. 특히 실제 사용자 피드백을 반영한 개선 사례가 있다면 더 좋겠죠.",
                sentDate: Date().addingTimeInterval(-86400 * 4),
                isFromMe: false,
                mentorId: mentors[1].id,
                bookmarkCount: 28,
                questionId: "question_2",
                status: nil
            )
        ),
        // Business 관련 질문
        (
            question: ChatBox(
                id: "question_3",
                messageType: .question,
                userId: tempUserIds[2],
                senderName: "박민수",
                content: "스타트업에서 PM으로 일하고 싶은데, 어떤 스킬을 키워야 할까요?",
                sentDate: Date().addingTimeInterval(-86400 * 7),
                isFromMe: true,
                mentorId: mentors[2].id,
                bookmarkCount: 35,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: "answer_3",
                messageType: .answer,
                userId: mentors[2].id,
                senderName: "Lumi",
                content: "스타트업 PM은 다양한 역할을 수행해야 합니다. 제품 기획, 데이터 분석, 커뮤니케이션 스킬이 중요합니다. 특히 사용자 중심의 사고방식과 빠른 의사결정 능력이 필요합니다.",
                sentDate: Date().addingTimeInterval(-86400 * 6),
                isFromMe: false,
                mentorId: mentors[2].id,
                bookmarkCount: 35,
                questionId: "question_3",
                status: nil
            )
        ),
        // 추가 Tech 질문
        (
            question: ChatBox(
                id: "question_4",
                messageType: .question,
                userId: tempUserIds[3],
                senderName: "최현우",
                content: "프론트엔드 개발자로 취업하려면 어떤 기술 스택을 준비해야 할까요?",
                sentDate: Date().addingTimeInterval(-86400 * 1),
                isFromMe: true,
                mentorId: mentors[4].id,
                bookmarkCount: 15,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: "answer_4",
                messageType: .answer,
                userId: mentors[4].id,
                senderName: "Eve",
                content: "기본적으로 HTML, CSS, JavaScript는 필수입니다. React나 Vue.js 같은 프레임워크도 중요하죠. 최근에는 TypeScript도 많이 사용되고 있어요. 실제 프로젝트 경험이 있다면 더 좋습니다.",
                sentDate: Date(),
                isFromMe: false,
                mentorId: mentors[4].id,
                bookmarkCount: 15,
                questionId: "question_4",
                status: nil
            )
        ),
        // 추가 Design 질문
        (
            question: ChatBox(
                id: "question_5",
                messageType: .question,
                userId: tempUserIds[4],
                senderName: "정수민",
                content: "그래픽 디자이너로 일하고 싶은데, 포트폴리오는 어떻게 준비하면 좋을까요?",
                sentDate: Date().addingTimeInterval(-86400 * 2),
                isFromMe: true,
                mentorId: mentors[5].id,
                bookmarkCount: 20,
                questionId: nil,
                status: "answered"
            ),
            answer: ChatBox(
                id: "answer_5",
                messageType: .answer,
                userId: mentors[5].id,
                senderName: "Max",
                content: "포트폴리오는 당신의 스타일과 역량을 보여주는 창구입니다. 다양한 프로젝트를 포함시키되, 특히 당신의 강점을 보여줄 수 있는 작품을 중심으로 구성하세요. 브랜딩, 포스터, UI/UX 등 다양한 분야의 작품을 보여주는 것도 좋습니다.",
                sentDate: Date().addingTimeInterval(-86400 * 1),
                isFromMe: false,
                mentorId: mentors[5].id,
                bookmarkCount: 20,
                questionId: "question_5",
                status: nil
            )
        )
    ]
}
