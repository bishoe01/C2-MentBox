import SwiftUI

struct MentorMainView: View {
    @State private var selectedTab = 0
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true
    @EnvironmentObject var navigationManager: NavigationManager
    
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
                // 메인 탭 콘텐츠
                TabView(selection: $selectedTab) {
                    MentorStoriesView()
                        .tag(0)
                    
                    MentorProfileView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.bottom, 70) // 화면 하단 내용 가리는거 제거
            }
            
            MentorTabBar(selectedTab: $selectedTab)
        }
        .onAppear {
            print("MENTORVBIEW 나타남")
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

struct MentorTabBar: View {
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
                Image(systemName: "person.fill")
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundColor(selectedTab == 1 ? Color("Primary") : .white.opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
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
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct MentorMainView_Previews: PreviewProvider {
    static var previews: some View {
        MentorMainView()
    }
}
