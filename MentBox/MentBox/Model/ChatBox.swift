import Foundation

enum MessageType {
    case question
    case answer
}

struct ChatBox: Identifiable {
    let id: UUID = .init()
    let messageType: MessageType
    let senderName: String // 보낸사람
    let content: String // 메세지
    let sentDate: Date
    let isFromMe: Bool // 내가 보낸건지
    let recipient: Mentor // 어떤 멘토한테 보낼것인지
    let isBookmarked: Bool // 내가 저장한 것인지
    let bookmarkCount: Int // 저장한 사람의 수
}

struct Mentor: Identifiable {
    let id: UUID = .init()
    let name: String // 이름
    let bio: String // 한줄소개
    let profileImage: String // 프로필이미지
    let expertise: String // 디자인 ,테크 , 도메인 같은 분야 ?
}

// 멘토 인스턴스 생성
let mentor = Mentor(
    name: "김멘토",
    bio: "10년차 iOS 개발자",
    profileImage: "profile_image",
    expertise: "테크"
)

// 질문 메시지
let question = ChatBox(
    messageType: .question,
    senderName: "사용자",
    content: "질문 내용",
    sentDate: Date(),
    isFromMe: true,
    recipient: mentor,
    isBookmarked: false,
    bookmarkCount: 0
)

// 답변 메시지
let answer = ChatBox(
    messageType: .answer,
    senderName: "멘토",
    content: "답변 내용",
    sentDate: Date(),
    isFromMe: false,
    recipient: mentor,
    isBookmarked: false,
    bookmarkCount: 0
)
