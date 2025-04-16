import Foundation

struct ChatBox: Identifiable {
    let id: UUID = .init()
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
