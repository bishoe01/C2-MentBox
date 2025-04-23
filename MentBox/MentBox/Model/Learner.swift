import Foundation

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
