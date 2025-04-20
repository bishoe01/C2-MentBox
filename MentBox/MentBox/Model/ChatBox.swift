import Foundation

enum MessageType {
    case question
    case answer
}

enum MentorCategory: String, CaseIterable {
    case all = "All"
    case tech = "Tech"
    case design = "Design"
    case business = "Business"
}

struct ChatBox: Identifiable {
    let id: String // Firebase 문서 ID
    let messageType: MessageType
    let userId: String // Firebase Auth UID 또는 임시 UUID
    let senderName: String // 보낸사람 이름 (닉네임)
    let content: String // 메세지
    let sentDate: Date
    let isFromMe: Bool // 내가 보낸건지
    let mentorId: String // 어떤 멘토한테 보낼것인지
    let bookmarkCount: Int // 저장한 사람의 수
    
    // 질문인 경우에만 사용되는 필드
    var questionId: String? // 답변인 경우, 어떤 질문에 대한 답변인지
    var status: String? // 질문의 상태 (answered, pending 등)
}

struct Mentor: Identifiable {
    let id: String // Firebase 문서 ID
    let name: String // 이름
    let bio: String // 한줄소개
    let profileImage: String // 프로필이미지
    let expertise: String // 디자인 ,테크 , 도메인 같은 분야 ?
}

struct Learner: Identifiable {
    let id: String // Firebase Auth UID
    let name: String // 사용자 이름
    let email: String // 이메일
    let profileImage: String? // 프로필 이미지 URL
    let category: String // 관심 분야
    let letterCount: Int // 보낸 편지 수
    let bookmarkedCount: Int // 북마크한 수
    let createdAt: Date // 가입일
    let lastLoginAt: Date // 마지막 로그인 시간
}

// 프리뷰용 샘플 데이터
let previewMentor = Mentor(
    id: "preview_mentor_id",
    name: "김멘토",
    bio: "10년차 iOS 개발자",
    profileImage: "profile_image",
    expertise: "테크"
)

// 프리뷰용 질문
let previewQuestion = ChatBox(
    id: "preview_question_id",
    messageType: .question,
    userId: "preview_user_id",
    senderName: "사용자",
    content: "질문 내용",
    sentDate: Date(),
    isFromMe: true,
    mentorId: previewMentor.id,
    bookmarkCount: 0,
    questionId: nil,
    status: "answered"
)

// 프리뷰용 답변
let previewAnswer = ChatBox(
    id: "preview_answer_id",
    messageType: .answer,
    userId: "preview_mentor_id",
    senderName: "멘토",
    content: "답변 내용",
    sentDate: Date(),
    isFromMe: false,
    mentorId: previewMentor.id,
    bookmarkCount: 0,
    questionId: previewQuestion.id,
    status: nil
)
