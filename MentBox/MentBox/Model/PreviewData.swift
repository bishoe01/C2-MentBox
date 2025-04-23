import Foundation

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
