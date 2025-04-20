import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                }

            StarsTabView()
                .tabItem {
                    Image(systemName: "star.fill")
                }

            MyLetterTabView()
                .tabItem {
                    Image(systemName: "envelope.fill")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

struct BackgroundView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

struct HomeTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                HomeView()
                    .padding(.bottom, 20)
            }
        }
    }
}

struct StarsTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                MentBoxHeader(title: "STARS")
                SavedView()
                    .padding(.bottom, 20)
            }
        }
    }
}

struct MyLetterTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                MentBoxHeader(title: "MYLETTER")
                MyLetterView()
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
