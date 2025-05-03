import Foundation

struct UserTypeOption {
    let userType: UserType
    let iconName: String
    let title: String
    let description: String
}

enum UserTypeConstants {
    static let options: [UserTypeOption] = [
        UserTypeOption(
            userType: .learner,
            iconName: "person.fill",
            title: "Learner",
            description: "멘토에게 질문하고 답변을 받습니다."
        ),
        UserTypeOption(
            userType: .mentor,
            iconName: "person.fill.checkmark",
            title: "Mentor",
            description: "학습자의 질문에 답변해주세요"
        )
    ]
} 
