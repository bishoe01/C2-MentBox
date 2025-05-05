import SwiftUI

struct LearnerMainView: View {
    @State private var selectedTab = 0
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)

                    MyLetterView()
                        .tag(1)

                    LearnerProfileView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.bottom, 70)

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        FirebaseService.shared.fetchMentors { fetchedMentors in
            Task { @MainActor in
                self.mentors = fetchedMentors
                self.isLoading = false
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            Spacer()
            Button(action: { selectedTab = 0 }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundColor(selectedTab == 0 ? Color("Primary") : .white.opacity(0.5))

            Spacer()
            Button(action: { selectedTab = 1 }) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundColor(selectedTab == 1 ? Color("Primary") : .white.opacity(0.5))

            Spacer()
            Button(action: { selectedTab = 2 }) {
                Image(systemName: "person.fill")
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundColor(selectedTab == 2 ? Color("Primary") : .white.opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        // 2) 배경 그대로 유지
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("btn_dark").opacity(0.95),
                    Color("btn_light").opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        // 3) 둥근 모서리·그림자 제거 → 하단 공백 X
        //    필요하면 그림자만 남겨도 OK
        // .shadow(radius: 10)
        // 4) Safe Area 무시 → 홈 인디케이터까지 덮음
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct LearnerMainView_Previews: PreviewProvider {
    static var previews: some View {
        LearnerMainView()
    }
}
