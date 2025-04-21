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
                ProfileView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.all)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.all)
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
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
            Button(action: { selectedTab = 3 }) {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 26, weight: .bold))
                }
                .foregroundColor(selectedTab == 3 ? Color("Primary") : .white.opacity(0.5))
            }
            Spacer()
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 0)
        .padding(.bottom, 8)
        .shadow(radius: 10)
        .ignoresSafeArea(.all)
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
                .ignoresSafeArea(.all)
            content
                .padding(.top, 44)
        }
        .statusBar(hidden: true)
        .ignoresSafeArea(.all)
    }
}

struct HomeTabView: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                HomeView()
                    .padding(.top, 44)
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
                    .padding(.top, 44)
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
                    .padding(.top, 44)
                MyLetterView()
                Spacer(minLength: 0)
            }
        }
    }
}

struct ProfileView: View {
    @State private var showSignInView = false
    
    var body: some View {
        BackgroundView {
            VStack {
                Spacer()
                
                Button(action: {
                    SignInView.signOut()
                    showSignInView = true
                }) {
                    Text("로그아웃")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
        }
    }
}

#Preview {
    ContentView()
}
