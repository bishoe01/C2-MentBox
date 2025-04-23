import FirebaseFirestore
import Foundation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // 멘토들 목록 가져옴
    func fetchMentors(completion: @escaping ([Mentor]) -> Void) {
        self.db.collection("mentors").getDocuments { snapshot, error in
            if let error = error {
                print(" 멘토 데이터 가져오기 실패: \(error)")
                completion([])
                return // 필요성 ?
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
    
    // Mentor DetailView에서 멘토의 질문-답변 페어로 묶어서 가져오기
    func fetchQuestionAnswerPairs(for mentorId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        // 멘토정보 먼저 가져오기
        self.db.collection("mentors").document(mentorId).getDocument { mentorDoc, error in
            if let error = error {
                print(" 멘토 데이터 가져오기 실패: \(error)")
                completion([])
                return
            }
            
            guard let mentorData = mentorDoc?.data() else {
                completion([])
                return
            }
            
            print(" 멘토 데이터 가져오기 성공: \(mentorData)")
            
            let mentor = Mentor(
                id: mentorId,
                name: mentorData["name"] as? String ?? "",
                bio: mentorData["bio"] as? String ?? "",
                profileImage: mentorData["profileImage"] as? String ?? "",
                expertise: mentorData["expertise"] as? String ?? ""
            )
            
            // 멘토가져왔으니 그 필드값 기준으로 질문 가져오기
            self.db.collection("questions")
                .whereField("mentorId", isEqualTo: mentorId)
                .whereField("status", isEqualTo: "answered")
                .getDocuments { questionSnapshot, error in
                    if let error = error {
                        print(" 질문 데이터 가져오기 실패: \(error)")
                        completion([])
                        return
                    }
                    
                    var pairs: [(question: ChatBox, answer: ChatBox)] = []
                    let group = DispatchGroup()
                    
                    for questionDoc in questionSnapshot?.documents ?? [] {
                        let questionData = questionDoc.data()
                        guard let userId = questionData["userId"] as? String,
                              let senderName = questionData["senderName"] as? String,
                              let content = questionData["content"] as? String,
                              let sentDate = (questionData["sentDate"] as? Timestamp)?.dateValue(),
                              let bookmarkCount = questionData["bookmarkCount"] as? Int,
                              let status = questionData["status"] as? String
                        else {
                            continue
                        }
                        
                        let question = ChatBox(
                            id: questionDoc.documentID,
                            messageType: .question,
                            userId: userId,
                            senderName: senderName,
                            content: content,
                            sentDate: sentDate,
                            isFromMe: true,
                            mentorId: mentorId,
                            bookmarkCount: bookmarkCount,
                            questionId: nil,
                            status: status
                        )
                        
                        group.enter()
                        // 해당 질문의 답변 가져오기
                        self.db.collection("answers")
                            .whereField("questionId", isEqualTo: questionDoc.documentID)
                            .getDocuments { answerSnapshot, error in
                                defer { group.leave() }
                                
                                if let error = error {
                                    print(" 답변 데이터 가져오기 실패: \(error)")
                                    return
                                }
                                
                                guard let answerDoc = answerSnapshot?.documents.first else {
                                    return
                                }
                                
                                let answerData = answerDoc.data()
                                if let userId = answerData["userId"] as? String,
                                   let senderName = answerData["senderName"] as? String,
                                   let content = answerData["content"] as? String,
                                   let sentDate = (answerData["sentDate"] as? Timestamp)?.dateValue(),
                                   let bookmarkCount = answerData["bookmarkCount"] as? Int
                                {
                                    let answer = ChatBox(
                                        id: answerDoc.documentID,
                                        messageType: .answer,
                                        userId: userId,
                                        senderName: senderName,
                                        content: content,
                                        sentDate: sentDate,
                                        isFromMe: false,
                                        mentorId: mentorId,
                                        bookmarkCount: bookmarkCount,
                                        questionId: questionDoc.documentID,
                                        status: nil
                                    )
                                    pairs.append((question: question, answer: answer))
                                } else {
                                    print("에러 - answerId: \(answerDoc.documentID)")
                                }
                            }
                    }
                    
                    group.notify(queue: .main) {
                        completion(pairs.sorted { $0.question.sentDate > $1.question.sentDate })
                    }
                }
        }
    }
    
    // MARK: 상위 질문 질문 답변 가져오기 ( HomeView 하단에 들어갈 것 - 아마 3개 ?)

    func fetchAllQuestionAnswerPairs(completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        var allPairs: [(question: ChatBox, answer: ChatBox)] = []
        let group = DispatchGroup()
        
        // 모든 질문 가져오기 (답변된 것만)
        self.db.collection("questions")
            .whereField("status", isEqualTo: "answered")
            .getDocuments { questionSnapshot, error in
                if let error = error {
                    print(" 질문 데이터 가져오기 실패: \(error)")
                    completion([])
                    return
                }
                
                guard let questions = questionSnapshot?.documents else {
                    print("질문 데이터가 없습니다")
                    completion([])
                    return
                }
                
                print(" 질문 데이터 가져오기: \(questions.count)개")
                
                for questionDoc in questions {
                    let questionData = questionDoc.data()
                    guard let userId = questionData["userId"] as? String,
                          let senderName = questionData["senderName"] as? String,
                          let content = questionData["content"] as? String,
                          let sentDate = (questionData["sentDate"] as? Timestamp)?.dateValue(),
                          let mentorId = questionData["mentorId"] as? String,
                          let bookmarkCount = questionData["bookmarkCount"] as? Int,
                          let status = questionData["status"] as? String
                    else {
                        print("질문 데이터 형식이 이상함 questionId: \(questionDoc.documentID)")
                        continue
                    }
                    
                    let question = ChatBox(
                        id: questionDoc.documentID,
                        messageType: .question,
                        userId: userId,
                        senderName: senderName,
                        content: content,
                        sentDate: sentDate,
                        isFromMe: true,
                        mentorId: mentorId,
                        bookmarkCount: bookmarkCount,
                        questionId: nil,
                        status: status
                    )
                    
                    group.enter()
                    // 해당 질문의 답변 가져오기
                    self.db.collection("answers")
                        .whereField("questionId", isEqualTo: questionDoc.documentID)
                        .getDocuments { answerSnapshot, error in
                            defer { group.leave() }
                            
                            if let error = error {
                                print(" 답변 데이터 가져오기 실패: \(error)")
                                return
                            }
                            
                            guard let answerDoc = answerSnapshot?.documents.first else {
                                return
                            }
                            
                            let answerData = answerDoc.data()
                            if let userId = answerData["userId"] as? String,
                               let senderName = answerData["senderName"] as? String,
                               let content = answerData["content"] as? String,
                               let sentDate = (answerData["sentDate"] as? Timestamp)?.dateValue(),
                               let bookmarkCount = answerData["bookmarkCount"] as? Int
                            {
                                let answer = ChatBox(
                                    id: answerDoc.documentID,
                                    messageType: .answer,
                                    userId: userId,
                                    senderName: senderName,
                                    content: content,
                                    sentDate: sentDate,
                                    isFromMe: false,
                                    mentorId: mentorId,
                                    bookmarkCount: bookmarkCount,
                                    questionId: questionDoc.documentID,
                                    status: nil
                                )
                                allPairs.append((question: question, answer: answer))

                            } else {
                                print("답변 데이터 형식이 이상 answerId: \(answerDoc.documentID)")
                            }
                        }
                }
                
                group.notify(queue: .main) {
                    print(" 모든 질문-답변 페어 :  \(allPairs.count)개")
                    // 북마크 수가 많은 순으로 정렬하고 상위 3개만 선택
                    let sortedPairs = allPairs.sorted { $0.answer.bookmarkCount > $1.answer.bookmarkCount }
                    let topThreePairs = Array(sortedPairs.prefix(3))
                    completion(topThreePairs)
                }
            }
    }

    // MARK: - 편지 제한 확인 메서드

    func canSendQuestion(userId: String, mentorId: String, completion: @escaping (Bool) -> Void) {
        self.db.collection("questions")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" 질문 확인 실패: \(error)")
                    completion(false)
                    return
                }
                // pending 상태인 질문이 없으면 true (새 질문 가능)
                completion(snapshot?.documents.isEmpty ?? true)
            }
    }
    
    // MARK: - 북마크 관련 메서드

    // 북마크 추가
    func addBookmark(questionId: String, userId: String) async throws {
        let db = Firestore.firestore()
        
        let bookmarkData: [String: Any] = [
            "questionId": questionId,
            "userId": userId,
            "createdAt": Date()
        ]
        
        try await db.collection("bookmarks").addDocument(data: bookmarkData)
        
        let userRef = db.collection("learners").document(userId)
        try await userRef.updateData([
            "bookmarkedQuestions": FieldValue.arrayUnion([questionId])
        ])
        
        let questionRef = db.collection("questions").document(questionId)
        try await questionRef.updateData([
            "bookmarkCount": FieldValue.increment(Int64(1))
        ])
        
        let answerQuery = db.collection("answers")
            .whereField("questionId", isEqualTo: questionId)
        
        let answerSnapshot = try await answerQuery.getDocuments()
        if let answerDoc = answerSnapshot.documents.first {
            try await answerDoc.reference.updateData([
                "bookmarkCount": FieldValue.increment(Int64(1))
            ])
        }
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("BookmarkChanged"),
                object: nil,
                userInfo: ["questionId": questionId, "action": "add"]
            )
        }
    }
    
    // 북마크 제거
    func removeBookmark(questionId: String, userId: String) async throws {
        let db = Firestore.firestore()
        
        // 북마크 문서 삭제
        let query = db.collection("bookmarks")
            .whereField("questionId", isEqualTo: questionId)
            .whereField("userId", isEqualTo: userId)
        
        let snapshot = try await query.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        // MARK: bookmarkedQuestions 배열

        let userRef = db.collection("learners").document(userId)
        try await userRef.updateData([
            "bookmarkedQuestions": FieldValue.arrayRemove([questionId])
        ])
        
        let questionRef = db.collection("questions").document(questionId)
        try await questionRef.updateData([
            "bookmarkCount": FieldValue.increment(Int64(-1))
        ])
        
        let answerQuery = db.collection("answers")
            .whereField("questionId", isEqualTo: questionId)
        
        let answerSnapshot = try await answerQuery.getDocuments()
        if let answerDoc = answerSnapshot.documents.first {
            try await answerDoc.reference.updateData([
                "bookmarkCount": FieldValue.increment(Int64(-1))
            ])
        }
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("BookmarkChanged"),
                object: nil,
                userInfo: ["questionId": questionId, "action": "remove"]
            )
        }
    }
    
    // USER BOOK MARK 가져오는 함수  ->  learner 컬렉션에서 bookmarkedQuestions 필드 값 가져오기
    func getBookmarkedQuestions(userId: String) async throws -> [String] {
        let db = Firestore.firestore()
        let userDoc = try await db.collection("learners").document(userId).getDocument()
        
        if let bookmarkedQuestions = userDoc.data()?["bookmarkedQuestions"] as? [String] {
            return bookmarkedQuestions
        }
        return []
    }

    private func fetchQuestionAnswerPair(questionId: String) async throws -> (question: ChatBox, answer: ChatBox)? {
        let questionDoc = try await db.collection("questions").document(questionId).getDocument()
        guard let questionData = questionDoc.data() else { return nil }
        
        let question = ChatBox(
            id: questionDoc.documentID,
            messageType: .question,
            userId: questionData["userId"] as? String ?? "",
            senderName: questionData["senderName"] as? String ?? "",
            content: questionData["content"] as? String ?? "",
            sentDate: (questionData["sentDate"] as? Timestamp)?.dateValue() ?? Date(),
            isFromMe: true,
            mentorId: questionData["mentorId"] as? String ?? "",
            bookmarkCount: questionData["bookmarkCount"] as? Int ?? 0,
            questionId: nil,
            status: questionData["status"] as? String
        )
        
        let answerSnapshot = try await db.collection("answers")
            .whereField("questionId", isEqualTo: questionId)
            .getDocuments()
        
        guard let answerDoc = answerSnapshot.documents.first else { return nil }
        let answerData = answerDoc.data()
        
        let answer = ChatBox(
            id: answerDoc.documentID,
            messageType: .answer,
            userId: answerData["userId"] as? String ?? "",
            senderName: answerData["senderName"] as? String ?? "",
            content: answerData["content"] as? String ?? "",
            sentDate: (answerData["sentDate"] as? Timestamp)?.dateValue() ?? Date(),
            isFromMe: false,
            mentorId: question.mentorId,
            bookmarkCount: answerData["bookmarkCount"] as? Int ?? 0,
            questionId: questionId,
            status: nil
        )
        
        return (question: question, answer: answer)
    }

    // 북마크
    func fetchBookmarkedQuestionAnswerPairs(userId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        Task {
            do {
                let bookmarkedQuestionIds = try await getBookmarkedQuestions(userId: userId)
                var pairs: [(question: ChatBox, answer: ChatBox)] = []
                
                for questionId in bookmarkedQuestionIds {
                    if let pair = try await fetchQuestionAnswerPair(questionId: questionId) {
                        pairs.append(pair)
                    }
                }
                
                completion(pairs.sorted { $0.question.sentDate > $1.question.sentDate })
            } catch {
                completion([])
            }
        }
    }

    // 보낸 질문
    func fetchSentQuestionAnswerPairs(userId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox?)]) -> Void) {
        Task {
            do {
                let questions = try await db.collection("questions")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                
                var pairs: [(question: ChatBox, answer: ChatBox?)] = []
                
                for questionDoc in questions.documents {
                    let questionData = questionDoc.data()
                    let question = ChatBox(
                        id: questionDoc.documentID,
                        messageType: .question,
                        userId: questionData["userId"] as? String ?? "",
                        senderName: questionData["senderName"] as? String ?? "",
                        content: questionData["content"] as? String ?? "",
                        sentDate: (questionData["sentDate"] as? Timestamp)?.dateValue() ?? Date(),
                        isFromMe: true,
                        mentorId: questionData["mentorId"] as? String ?? "",
                        bookmarkCount: questionData["bookmarkCount"] as? Int ?? 0,
                        questionId: nil,
                        status: questionData["status"] as? String
                    )
                    
                    // 답변된 질문인 경우에만 답변을 가져옴
                    if question.status == "answered" {
                        if let pair = try await fetchQuestionAnswerPair(questionId: questionDoc.documentID) {
                            pairs.append((question: pair.question, answer: pair.answer))
                        }
                    } else {
                        // 답변 대기 중인 질문은 answer를 nil로 설정
                        pairs.append((question: question, answer: nil))
                    }
                }
                
                completion(pairs.sorted { $0.question.sentDate > $1.question.sentDate })
            } catch {
                completion([])
            }
        }
    }
    
    // MARK: - 사용자 관련 메서드
    
    // 기존 회원인지 파악
    func checkExistingUser(userId: String) async throws -> Bool {
        // learners 에서 한번 보고  -> 이래서 둘다 겹칠때 러너로 접속됨
        let learnerDoc = try await db.collection("learners").document(userId).getDocument()
        if learnerDoc.exists {
            return true
        }
        // mentors 컬렉션에서 보기
        let mentorDoc = try await db.collection("mentors").document(userId).getDocument()
        return mentorDoc.exists
    }
    
    // 유저 생성할때 데이터
    func createLearner(learner: Learner) async throws {
        print("🔍 학습자 데이터 저장 시작: \(learner.name)")
        let learnerData: [String: Any] = [
            "id": learner.id,
            "name": learner.name,
            "email": learner.email,
            "profileImage": learner.profileImage as Any,
            "category": learner.category,
            "letterCount": learner.letterCount,
            "bookmarkedCount": learner.bookmarkedCount,
            "createdAt": Timestamp(date: learner.createdAt),
            "lastLoginAt": Timestamp(date: learner.lastLoginAt),
            "bookmarkedQuestions": learner.bookmarkedQuestions,
            "sentQuestions": learner.sentQuestions
        ]
        
        try await self.db.collection("learners").document(learner.id).setData(learnerData)
        print(" 학습자 데이터 저장 완료: \(learner.name), 카테고리: \(learner.category)")
    }
    
    // 멘토 생성
    func createMentor(mentor: Mentor) async throws {
        print("🔍 멘토 데이터 저장 시작: \(mentor.name)")
        let mentorData: [String: Any] = [
            "id": mentor.id,
            "name": mentor.name,
            "bio": mentor.bio,
            "profileImage": mentor.profileImage,
            "expertise": mentor.expertise,
            "createdAt": Timestamp(date: Date()),
            "lastLoginAt": Timestamp(date: Date())
        ]
        
        try await self.db.collection("mentors").document(mentor.id).setData(mentorData)
        print(" 멘토 데이터 저장 완료: \(mentor.name), 전문분야: \(mentor.expertise)")
    }
    
    // 유저 정보 가져오기
    func fetchLearner(userId: String) async throws -> Learner? {
        let document = try await db.collection("learners").document(userId).getDocument()
        
        guard let data = document.data() else { return nil }
        
        return Learner(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            email: data["email"] as? String ?? "",
            profileImage: data["profileImage"] as? String,
            category: data["category"] as? String ?? "",
            letterCount: data["letterCount"] as? Int ?? 0,
            bookmarkedCount: data["bookmarkedCount"] as? Int ?? 0,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastLoginAt: (data["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date(),
            bookmarkedQuestions: data["bookmarkedQuestions"] as? [String] ?? [],
            sentQuestions: data["sentQuestions"] as? [String] ?? []
        )
    }
 
    // 답변 대기 중인 질문 가져오기
    func fetchPendingQuestions(userId: String, completion: @escaping ([(question: ChatBox, mentor: Mentor)]) -> Void) {
        Task {
            do {
                let questions = try await db.collection("questions")
                    .whereField("userId", isEqualTo: userId)
                    .whereField("status", isEqualTo: "pending")
                    .getDocuments()
                
                var pendingQuestions: [(question: ChatBox, mentor: Mentor)] = []
                
                for questionDoc in questions.documents {
                    let questionData = questionDoc.data()
                    let question = ChatBox(
                        id: questionDoc.documentID,
                        messageType: .question,
                        userId: questionData["userId"] as? String ?? "",
                        senderName: questionData["senderName"] as? String ?? "",
                        content: questionData["content"] as? String ?? "",
                        sentDate: (questionData["sentDate"] as? Timestamp)?.dateValue() ?? Date(),
                        isFromMe: true,
                        mentorId: questionData["mentorId"] as? String ?? "",
                        bookmarkCount: questionData["bookmarkCount"] as? Int ?? 0,
                        questionId: nil,
                        status: questionData["status"] as? String
                    )
                    
                    // 멘토 정보 가져오기
                    if let mentorDoc = try? await db.collection("mentors").document(question.mentorId).getDocument(),
                       let mentorData = mentorDoc.data()
                    {
                        let mentor = Mentor(
                            id: mentorDoc.documentID,
                            name: mentorData["name"] as? String ?? "",
                            bio: mentorData["bio"] as? String ?? "",
                            profileImage: mentorData["profileImage"] as? String ?? "",
                            expertise: mentorData["expertise"] as? String ?? ""
                        )
                        pendingQuestions.append((question: question, mentor: mentor))
                    }
                }
                
                completion(pendingQuestions.sorted { $0.question.sentDate > $1.question.sentDate })
            } catch {
                print(" 답변 대기 중인 질문 가져오기 실패: \(error)")
                completion([])
            }
        }
    }

    // 답변 대기 중인 질문 삭제
    func deletePendingQuestion(questionId: String, userId: String) async throws {
        let db = Firestore.firestore()
        
        try await db.collection("questions").document(questionId).delete()
        
        let userRef = db.collection("learners").document(userId)
        try await userRef.updateData([
            "sentQuestions": FieldValue.arrayRemove([questionId])
        ])
    }
    
    // 멘토의 대기 중인 질문 가져오기
    func fetchPendingQuestionsForMentor(mentorId: String, completion: @escaping ([(question: ChatBox, learner: Learner)]) -> Void) {
        Task {
            do {
                var pendingPairs: [(question: ChatBox, learner: Learner)] = []
                
                let questionsSnapshot = try await db.collection("questions")
                    .whereField("mentorId", isEqualTo: mentorId)
                    .whereField("status", isEqualTo: "pending")
                    .getDocuments()
                
                for document in questionsSnapshot.documents {
                    let data = document.data()
                    if let userId = data["userId"] as? String,
                       let content = data["content"] as? String,
                       let sentDate = (data["sentDate"] as? Timestamp)?.dateValue()
                    {
                        let question = ChatBox(
                            id: document.documentID,
                            messageType: .question,
                            userId: userId,
                            senderName: data["senderName"] as? String ?? "",
                            content: content,
                            sentDate: sentDate,
                            isFromMe: false,
                            mentorId: mentorId,
                            bookmarkCount: data["bookmarkCount"] as? Int ?? 0,
                            questionId: nil,
                            status: "pending"
                        )
                        
                        if let learner = try? await fetchLearner(userId: userId) {
                            pendingPairs.append((question: question, learner: learner))
                        }
                    }
                }
                
                await MainActor.run {
                    completion(pendingPairs)
                }
            } catch {
                await MainActor.run {
                    completion([])
                }
            }
        }
    }
    
    // 답변 제출
    func submitAnswer(questionId: String, mentorId: String, content: String) async throws {
        let db = Firestore.firestore()
        let answerId = UUID().uuidString
        
        let answerData: [String: Any] = [
            "id": answerId,
            "messageType": "answer",
            "userId": mentorId,
            "senderName": "멘토",
            "content": content,
            "sentDate": Timestamp(date: Date()),
            "isFromMe": true,
            "mentorId": mentorId,
            "bookmarkCount": 0,
            "questionId": questionId
        ]
        
        try await db.collection("answers").document(answerId).setData(answerData)
        
        try await db.collection("questions").document(questionId).updateData([
            "status": "answered",
            "answerId": answerId
        ])
    }
}
