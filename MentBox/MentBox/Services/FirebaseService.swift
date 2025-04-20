import FirebaseFirestore
import Foundation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private let mockDataUploadedKey = "mockDataUploadedKey"
    private let migrationCompletedKey = "migrationCompletedKey"
    
    private init() {}
    
    // MARK: - 데이터 초기화 및 재업로드

    func resetAndUploadData() async throws {
        print("데이터 초기화 시작")
        
        // 기존 데이터 삭제 (learners는 제외)
        try await deleteCollection("mentors")
        try await deleteCollection("questions")
        try await deleteCollection("answers")
        try await deleteCollection("bookmarks")
        
        // UserDefaults 초기화
        UserDefaults.standard.removeObject(forKey: "lastQuestionDate")
        UserDefaults.standard.removeObject(forKey: "lastQuestionId")
        
        // 새로운 데이터 업로드
        try await uploadMockData()
        
        print("✅ 데이터 초기화 완료")
    }
    
    private func deleteCollection(_ collection: String) async throws {
        let snapshot = try await db.collection(collection).getDocuments()
        let batch = db.batch()
        
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
        print("✅ \(collection) 삭제 완료")
    }
    
    // MARK: userDefaults 초기화

    func resetMockDataUploaded() {
        self.defaults.removeObject(forKey: self.mockDataUploadedKey)
        print("✅ mockDataUploadedKey 초기화 완료")
    }
    
    func uploadMockData() async throws {
        // 멘토 데이터 업로드
        for mentor in MockChatBoxData.mentors {
            let mentorData: [String: Any] = [
                "id": mentor.id,
                "name": mentor.name,
                "bio": mentor.bio,
                "profileImage": mentor.profileImage,
                "expertise": mentor.expertise
            ]
            
            try await db.collection("mentors").document(mentor.id).setData(mentorData)
            print("✅ 멘토 데이터 업로드 성공: \(mentor.name)")
        }
        
        // 질문과 답변 데이터 업로드
        for pair in MockChatBoxData.chatPairs {
            let questionData: [String: Any] = [
                "id": pair.question.id,
                "userId": pair.question.userId,
                "senderName": pair.question.senderName,
                "content": pair.question.content,
                "sentDate": Timestamp(date: pair.question.sentDate),
                "mentorId": pair.question.mentorId,
                "status": pair.question.status ?? "pending",
                "bookmarkCount": pair.question.bookmarkCount
            ]
            
            try await db.collection("questions").document(pair.question.id).setData(questionData)
            print("✅ 질문 데이터 업로드 성공: \(pair.question.id)")
            
            // 답변 업로드
            let answerData: [String: Any] = [
                "id": pair.answer.id,
                "userId": pair.answer.userId,
                "questionId": pair.question.id,
                "senderName": pair.answer.senderName,
                "content": pair.answer.content,
                "sentDate": Timestamp(date: pair.answer.sentDate),
                "mentorId": pair.answer.mentorId,
                "bookmarkCount": pair.answer.bookmarkCount
            ]
            
            try await db.collection("answers").document(pair.answer.id).setData(answerData)
            print("✅ 답변 데이터 업로드 성공: \(pair.answer.id)")
        }
        
        // 현재 사용자의 Learner 데이터 업로드
        let learner = MockChatBoxData.currentLearner
        let learnerData: [String: Any] = [
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
        
        try await db.collection("learners").document(learner.id).setData(learnerData)
        print("✅ 사용자 데이터 업로드 성공: \(learner.name)")
        
        print("✅ 모든 더미 데이터 업로드 완료")
    }
    
    // 멘토들 목록 가져옴
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
    
    // Mentor DetailView에서 멘토의 질문-답변 페어로 묶어서 가져오기
    func fetchQuestionAnswerPairs(for mentorId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        print("🔍 fetchQuestionAnswerPairs 시작 - mentorId: \(mentorId)")
        
        // 멘토정보 먼저 가져오기
        self.db.collection("mentors").document(mentorId).getDocument { mentorDoc, error in
            if let error = error {
                print("❌ 멘토 데이터 가져오기 실패: \(error)")
                completion([])
                return
            }
            
            guard let mentorData = mentorDoc?.data() else {
                print("⚠️ 멘토 데이터가 존재하지 않습니다. mentorId: \(mentorId)")
                completion([])
                return
            }
            
            print("✅ 멘토 데이터 가져오기 성공: \(mentorData)")
            
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
                        print("❌ 질문 데이터 가져오기 실패: \(error)")
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
                            print("⚠️ 질문 데이터 형식이 올바르지 않습니다. questionId: \(questionDoc.documentID)")
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
                                    print("❌ 답변 데이터 가져오기 실패: \(error)")
                                    return
                                }
                                
                                guard let answerDoc = answerSnapshot?.documents.first else {
                                    print("⚠️ 답변 없음 - questionId: \(questionDoc.documentID)")
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
                                    print("⚠️ 답변 데이터 형식이 올바르지 않습니다. answerId: \(answerDoc.documentID)")
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
        print("🔍 fetchAllQuestionAnswerPairs 시작")
        var allPairs: [(question: ChatBox, answer: ChatBox)] = []
        let group = DispatchGroup()
        
        // 모든 질문 가져오기 (답변된 것만)
        self.db.collection("questions")
            .whereField("status", isEqualTo: "answered")
            .getDocuments { questionSnapshot, error in
                if let error = error {
                    print("❌ 질문 데이터 가져오기 실패: \(error)")
                    completion([])
                    return
                }
                
                guard let questions = questionSnapshot?.documents else {
                    print("⚠️ 질문 데이터가 없습니다")
                    completion([])
                    return
                }
                
                print("✅ 질문 데이터 가져오기 성공: \(questions.count)개")
                
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
                        print("⚠️ 질문 데이터 형식이 올바르지 않습니다. questionId: \(questionDoc.documentID)")
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
                                print("❌ 답변 데이터 가져오기 실패: \(error)")
                                return
                            }
                            
                            guard let answerDoc = answerSnapshot?.documents.first else {
                                print("⚠️ 답변 없음 - questionId: \(questionDoc.documentID)")
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
                                print("⚠️ 답변 데이터 형식이 올바르지 않습니다. answerId: \(answerDoc.documentID)")
                            }
                        }
                }
                
                group.notify(queue: .main) {
                    print("✅ 모든 질문-답변 쌍 가져오기 완료: \(allPairs.count)개")
                    // 북마크 수가 많은 순으로 정렬하고 상위 3개만 선택
                    let sortedPairs = allPairs.sorted { $0.answer.bookmarkCount > $1.answer.bookmarkCount }
                    let topThreePairs = Array(sortedPairs.prefix(3))
                    print("✅ 홈뷰 3개 고르기 완료 ")
                    completion(topThreePairs)
                }
            }
    }
    
    // 데이터 구조 바꿀때 사용 (필드값)
    func migrateDatabase() {
        if self.defaults.bool(forKey: self.migrationCompletedKey) {
            print("마이그레이션 끝 ")
            return
        }
        
        print("마이그레이션 시작")
        
        // questions 컬렉션 마이그레이션
        self.db.collection("questions").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("마이그레이션 실패: \(error)")
                return
            }
            
            let batch = self.db.batch()
            var count = 0
            
            for document in snapshot?.documents ?? [] {
                // senderName을 userId로 복사 (임시로)
                let userId = document.data()["senderName"] as? String ?? "unknown"
                
                batch.updateData([
                    "userId": userId
                ], forDocument: document.reference)
                
                count += 1
            }
            
            batch.commit { error in
                if let error = error {
                    print("questions 업데이트 실패: \(error)")
                } else {
                    print("✅ questions 마이그레이션 완료: \(count)개 업뎃댐")
                }
            }
        }
        
        // answers 컬렉션 마이그레이션
        self.db.collection("answers").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ answers 마이그레이션 실패: \(error)")
                return
            }
            
            let batch = self.db.batch()
            var count = 0
            
            for document in snapshot?.documents ?? [] {
                // senderName을 userId로 복사 (임시로)
                let userId = document.data()["senderName"] as? String ?? "unknown"
                
                batch.updateData([
                    "userId": userId
                ], forDocument: document.reference)
                
                count += 1
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ answers 배치 업데이트 실패: \(error)")
                } else {
                    print("✅ answers 마이그레이션 완료: \(count)개 문서 업데이트")
                    self.defaults.set(true, forKey: self.migrationCompletedKey)
                }
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
                    print("❌ 질문 확인 실패: \(error)")
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
        
        // 북마크 문서 생성
        let bookmarkData: [String: Any] = [
            "questionId": questionId,
            "userId": userId,
            "createdAt": Date()
        ]
        
        try await db.collection("bookmarks").addDocument(data: bookmarkData)
        
        // 사용자의 bookmarkedQuestions 배열 업데이트
        let userRef = db.collection("learners").document(userId)
        try await userRef.updateData([
            "bookmarkedQuestions": FieldValue.arrayUnion([questionId])
        ])
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
        
        // 사용자의 bookmarkedQuestions 배열 업데이트
        let userRef = db.collection("learners").document(userId)
        try await userRef.updateData([
            "bookmarkedQuestions": FieldValue.arrayRemove([questionId])
        ])
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

    // 공통 함수
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
    func fetchSentQuestionAnswerPairs(userId: String, completion: @escaping ([(question: ChatBox, answer: ChatBox)]) -> Void) {
        Task {
            do {
                let questions = try await db.collection("questions")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                
                var pairs: [(question: ChatBox, answer: ChatBox)] = []
                
                for questionDoc in questions.documents {
                    if let pair = try await fetchQuestionAnswerPair(questionId: questionDoc.documentID) {
                        pairs.append(pair)
                    }
                }
                
                completion(pairs.sorted { $0.question.sentDate > $1.question.sentDate })
            } catch {
                completion([])
            }
        }
    }
    
    // MARK: - 사용자 관련 메서드
    
    // 유저 생성할때 데이터 
    func createLearner(learner: Learner) async throws {
        let learnerData: [String: Any] = [
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
        
        try await db.collection("learners").document(learner.id).setData(learnerData)
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
    
    
    // 사용자의 보낸 질문-답변 쌍 가져오기
   
    
    // USER SENT QUESTION 가져오는 함수  ->  learner 컬렉션에서 sentQuestions 필드 값 가져오기  
    func getSentQuestions(userId: String) async throws -> [String] {
        let db = Firestore.firestore()
        let userDoc = try await db.collection("learners").document(userId).getDocument()
        
        if let sentQuestions = userDoc.data()?["sentQuestions"] as? [String] {
            return sentQuestions
        }
        return []
    }
}
