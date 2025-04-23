import Foundation

struct ChatBox: Identifiable {
    let id: String
    let messageType: MessageType
    let userId: String
    let senderName: String
    let content: String
    let sentDate: Date
    let isFromMe: Bool
    let mentorId: String
    var bookmarkCount: Int

    var questionId: String?
    let status: String?
}
