import Foundation

enum UserCategory: String, CaseIterable, Identifiable {
    case tech = "Tech"
    case design = "Design"
    case business = "Business"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tech: return "테크"
        case .design: return "디자인"
        case .business: return "비즈니스"
        }
    }
} 
