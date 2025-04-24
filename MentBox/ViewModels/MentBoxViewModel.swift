import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MentBoxViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        setupFirestoreListener()
    }
    
    private func setupFirestoreListener() {
        listener = db.collection("posts")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.posts = documents.compactMap { document -> Post? in
                    try? document.data(as: Post.self)
                }
            }
    }
    
    func loadPosts() {
        isLoading = true
        db.collection("posts").getDocuments { [weak self] snapshot, error in
            self?.isLoading = false
            if let error = error {
                self?.error = error
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self?.posts = documents.compactMap { document -> Post? in
                try? document.data(as: Post.self)
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
} 
