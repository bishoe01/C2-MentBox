import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("MentBox 연결 테스트 완료!")
                .padding()
        }
        .onAppear {
            let db = Firestore.firestore()
            db.collection("test").addDocument(data: [
                "timestamp": Date(),
                "message": "Hello from MentBox!"
            ]) { error in
                if let error = error {
                    print("❌ Firestore 저장 실패: \(error)")
                } else {
                    print("✅ Firestore 저장 성공!")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
