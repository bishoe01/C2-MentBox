import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView에서 기본 TabBar 숨기기
            TabView(selection: $selectedTab) {
                HomeTabView()
                    .tag(0)
                StarsTabView()
                    .tag(1)
                MyLetterTabView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            Spacer()
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 26, weight: .bold))
                }
                .foregroundColor(selectedTab == 0 ? Color("Primary") : .white.opacity(0.5))
            }
            Spacer()
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 26, weight: .bold))
                }
                .foregroundColor(selectedTab == 1 ? Color("Primary") : .white.opacity(0.5))
            }
            Spacer()
            Button(action: { selectedTab = 2 }) {
                VStack {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 26, weight: .bold))
                }
                .foregroundColor(selectedTab == 2 ? Color("Primary") : .white.opacity(0.5))
            }
            Spacer()
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
        .shadow(radius: 10)
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
                .ignoresSafeArea()
            content
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
        }
    }
}

struct HomeTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                HomeView()
                Spacer(minLength: 0)
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
                Spacer(minLength: 0)
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
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    ContentView()
}
