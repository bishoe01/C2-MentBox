import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ZStack {
                Image("BG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    HomeView()
                        .padding(.bottom, 20)
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
            }

            ZStack {
                Image("BG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    MentBoxHeader(title: "STARS")
                    SavedView()
                        .padding(.bottom, 20)
                }
            }
            .tabItem {
                Image(systemName: "star.fill")
            }

            ZStack {
                Image("BG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    MentBoxHeader(title: "MYLETTER")
                    MyLetterView()
                        .padding(.bottom, 20)
                }
            }
            .tabItem {
                Image(systemName: "envelope.fill")
            }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("Primary"))
                .clipShape(Capsule())
                .offset(y: -70),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
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
