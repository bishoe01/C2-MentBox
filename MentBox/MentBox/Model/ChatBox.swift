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
    let id: String 
    let messageType: MessageType
    let userId: String 
    let senderName: String 
    let content: String 
    let sentDate: Date
    let isFromMe: Bool 
    let mentorId: String 
    let bookmarkCount: Int 
    
    var questionId: String? 
    var status: String? 
}

struct Mentor: Identifiable {
    let id: String 
    let name: String 
    let bio: String 
    let profileImage: String 
    let expertise: String 
}

struct Learner: Identifiable {
    let id: String 
    let name: String 
    let email: String 
    let profileImage: String? 
    let category: String 
    let letterCount: Int 
    let bookmarkedCount: Int 
    let createdAt: Date 
    let lastLoginAt: Date 
    let bookmarkedQuestions: [String] 
    let sentQuestions: [String] 
}


let previewMentor = Mentor(
    id: "preview_mentor_id",
    name: "김멘토",
    bio: "10년차 iOS 개발자",
    profileImage: "profile_image",
    expertise: "테크"
)


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
