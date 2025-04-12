import SwiftUI

struct ContentView: View {
//    let firestoreService = FirestoreService()

    var body: some View {
        VStack {
            Text("MentBox 연결 테스트 완료!")
            Text("MentBox 연결 테스트 완료!")
                .padding()
                .font(.custom("PretendardVariable-Regular", size: 24))
            Text("MentBox 연결 테스트 완료!")
                .padding()
                .font(.custom("Geologica-Bold", size: 24))
        }
//        .onAppear {
//            firestoreService.addTestDocument { error in
//                if let error = error {
//                    print("❌ Firestore 저장 실패: \(error)")
//                } else {
//                    print("✅ Firestore 저장 성공!")
//                }
//            }
//        }
    }
}

#Preview {
    ContentView()
}
