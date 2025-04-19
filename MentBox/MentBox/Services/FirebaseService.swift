import FirebaseFirestore
import Foundation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private let mockDataUploadedKey = "mockDataUploaded"
    
    private init() {}
    
    func uploadMockData() {
        // 이미 업로드된 경우 중복 업로드 방지
        if defaults.bool(forKey: mockDataUploadedKey) {
            print("✅ 더미 데이터가 이미 업로드되어 있습니다.")
            return
        }
        
        // 멘토 데이터 업로드
        for mentor in MockChatBoxData.mentors {
            let mentorData: [String: Any] = [
                "name": mentor.name,
                "bio": mentor.bio,
                "profileImage": mentor.profileImage,
                "expertise": mentor.expertise
            ]
            
            self.db.collection("mentors").document(mentor.id).setData(mentorData) { error in
                if let error = error {
                    print("❌ 멘토 데이터 업로드 실패: \(error)")
                } else {
                    print("✅ 멘토 데이터 업로드 성공: \(mentor.name)")
                }
            }
        }
        
        // 질문과 답변 데이터 업로드
        for pair in MockChatBoxData.chatPairs {
            // 질문 업로드
            let questionData: [String: Any] = [
                "senderName": pair.question.senderName,
                "content": pair.question.content,
                "sentDate": Timestamp(date: pair.question.sentDate),
                "mentorId": pair.question.mentorId,
                "status": pair.question.status ?? "pending",
                "isBookmarked": pair.question.isBookmarked,
                "bookmarkCount": pair.question.bookmarkCount
            ]
            
            self.db.collection("questions").document(pair.question.id).setData(questionData) { error in
                if let error = error {
                    print("❌ 질문 데이터 업로드 실패: \(error)")
                } else {
                    print("✅ 질문 데이터 업로드 성공")
                }
            }
            
            // 답변 업로드
            let answerData: [String: Any] = [
                "questionId": pair.question.id,
                "senderName": pair.answer.senderName,
                "content": pair.answer.content,
                "sentDate": Timestamp(date: pair.answer.sentDate),
                "mentorId": pair.answer.mentorId,
                "isBookmarked": pair.answer.isBookmarked,
                "bookmarkCount": pair.answer.bookmarkCount
            ]
            
            self.db.collection("answers").document(pair.answer.id).setData(answerData) { error in
                if let error = error {
                    print("❌ 답변 데이터 업로드 실패: \(error)")
                } else {
                    print("✅ 답변 데이터 업로드 성공")
                }
            }
        }
        
        self.defaults.set(true, forKey: mockDataUploadedKey)
        print("✅ 모든 더미 데이터 업로드 완료")
    }
    
    // 멘토 목록 가져오기
    func fetchMentors(completion: @escaping ([Mentor]) -> Void) {
        self.db.collection("mentors").getDocuments { snapshot, error in
            if let error = error {
                print("❌ 멘토 데이터 가져오기 실패: \(error)")
                completion([])
                return
            }
            
            var mentors: [Mentor] = []
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                if let name = data["name"] as? String,
                   let bio = data["bio"] as? String,
                   let profileImage = data["profileImage"] as? String,
                   let expertise = data["expertise"] as? String
                {
                    let mentor = Mentor(
                        id: document.documentID,
                        name: name,
                        bio: bio,
                        profileImage: profileImage,
                        expertise: expertise
                    )
                    mentors.append(mentor)
                }
            }
            completion(mentors)
        }
    }
    
    // 특정 멘토의 질문-답변 쌍 가져오기
    func fetchQuestionAnswerPairs(for mentorId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        // 멘토 정보 가져오기
        self.db.collection("mentors").document(mentorId).getDocument { mentorDoc, error in
            guard let mentorData = mentorDoc?.data(),
                  let mentorName = mentorData["name"] as? String,
                  let mentorBio = mentorData["bio"] as? String,
                  let mentorProfileImage = mentorData["profileImage"] as? String,
                  let mentorExpertise = mentorData["expertise"] as? String
            else {
                completion([])
                return
            }
            
            let mentor = Mentor(
                id: mentorId,
                name: mentorName,
                bio: mentorBio,
                profileImage: mentorProfileImage,
                expertise: mentorExpertise
            )
            
            // 질문 가져오기
            self.db.collection("questions")
                .whereField("mentorId", isEqualTo: mentorId)
                .whereField("status", isEqualTo: "answered")
                .order(by: "sentDate", descending: true)
                .getDocuments { questionSnapshot, error in
                    if let error = error {
                        print("❌ 질문 데이터 가져오기 실패: \(error)")
                        completion([])
                        return
                    }
                    
                    var pairs: [(question: ChatBox, answer: ChatBox)] = []
                    let group = DispatchGroup()
                    
                    for questionDoc in questionSnapshot?.documents ?? [] {
                        let questionData = questionDoc.data()
                        guard let senderName = questionData["senderName"] as? String,
                              let content = questionData["content"] as? String,
                              let sentDate = (questionData["sentDate"] as? Timestamp)?.dateValue(),
                              let isBookmarked = questionData["isBookmarked"] as? Bool,
                              let bookmarkCount = questionData["bookmarkCount"] as? Int,
                              let status = questionData["status"] as? String
                        else { continue }
                        
                        let question = ChatBox(
                            id: questionDoc.documentID,
                            messageType: .question,
                            senderName: senderName,
                            content: content,
                            sentDate: sentDate,
                            isFromMe: true,
                            mentorId: mentorId,
                            isBookmarked: isBookmarked,
                            bookmarkCount: bookmarkCount,
                            questionId: nil,
                            status: status
                        )
                        
                        group.enter()
                        // 해당 질문의 답변 가져오기
                        self.db.collection("answers")
                            .whereField("questionId", isEqualTo: questionDoc.documentID)
                            .getDocuments { answerSnapshot, error in
                                if let answerDoc = answerSnapshot?.documents.first {
                                    let answerData = answerDoc.data()
                                    if let senderName = answerData["senderName"] as? String,
                                       let content = answerData["content"] as? String,
                                       let sentDate = (answerData["sentDate"] as? Timestamp)?.dateValue(),
                                       let isBookmarked = answerData["isBookmarked"] as? Bool,
                                       let bookmarkCount = answerData["bookmarkCount"] as? Int
                                    {
                                        let answer = ChatBox(
                                            id: answerDoc.documentID,
                                            messageType: .answer,
                                            senderName: senderName,
                                            content: content,
                                            sentDate: sentDate,
                                            isFromMe: false,
                                            mentorId: mentorId,
                                            isBookmarked: isBookmarked,
                                            bookmarkCount: bookmarkCount,
                                            questionId: questionDoc.documentID,
                                            status: nil
                                        )
                                        pairs.append((question: question, answer: answer))
                                    }
                                }
                                group.leave()
                            }
                    }
                    
                    group.notify(queue: .main) {
                        completion(pairs.sorted { $0.question.sentDate > $1.question.sentDate })
                    }
                }
        }
    }
    
    // 모든 질문-답변 쌍 가져오기 (홈 화면용)
    func fetchAllQuestionAnswerPairs(completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        var allPairs: [(question: ChatBox, answer: ChatBox)] = []
        let group = DispatchGroup()
        
        // 모든 멘토 가져오기
        self.fetchMentors { mentors in
            for mentor in mentors {
                group.enter()
                self.fetchQuestionAnswerPairs(for: mentor.id) { pairs in
                    allPairs.append(contentsOf: pairs)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // 북마크 수가 많은 순으로 정렬
                completion(allPairs.sorted { $0.answer.bookmarkCount > $1.answer.bookmarkCount })
            }
        }
    }
}
