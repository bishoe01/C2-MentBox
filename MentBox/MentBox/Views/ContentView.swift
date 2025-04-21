import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeTabView()
                    .tag(0)
                StarsTabView()
                    .tag(1)
                MyLetterTabView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea()
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
        .padding(.horizontal)
        .padding(.bottom, 8)
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
                .padding(.top, 8)
        }
    }
}

struct HomeTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                HomeView()
                    .padding(.top, 8)
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
                    .padding(.top, 8)
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
                    .padding(.top, 8)
                MyLetterView()
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    ContentView()
}
