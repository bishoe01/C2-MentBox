import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Menter")
                .menterFont(.header)

            Text("밤하늘 아래의 감성적인 이야기")
                .menterFont(.subtitle)

            Text("멘토가 남긴 따뜻한 답장들이 모입니다.")
                .menterFont(.body)

            Text("2025년 4월 12일")
                .menterFont(.caption)

            Text("#Tech #Design")
                .menterFont(.tag)

            Text("by Finn")
                .menterFont(.smallest)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#242A3A"), Color(hex: "#2F3547")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// struct ContentView: View {
////    let firestoreService = FirestoreService()
//
//    var body: some View {
//        VStack {
//            Text("MentBox 연결 테스트 완료!")
//            Text("MentBox 연결 테스트 완료!")
//                .padding()
//                .font(.custom("PretendardVariable-Regular", size: 24))
//            Text("MentBox 연결 테스트 완료!")
//                .padding()
//                .font(.custom("Geologica-Bold", size: 24))
//        }
////        .onAppear {
////            firestoreService.addTestDocument { error in
////                if let error = error {
////                    print("❌ Firestore 저장 실패: \(error)")
////                } else {
////                    print("✅ Firestore 저장 성공!")
////                }
////            }
////        }
//    }
// }

#Preview {
    ContentView()
}
