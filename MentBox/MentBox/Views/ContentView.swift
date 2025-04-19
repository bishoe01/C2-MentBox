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

