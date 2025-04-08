import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()

    func addTestDocument(completion: @escaping (Error?) -> Void) {
        db.collection("test").addDocument(data: [
            "timestamp": Date(),
            "message": "Hello from MentBox!"
        ]) { error in
            completion(error)
        }
    }
}
