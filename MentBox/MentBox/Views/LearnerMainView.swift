import SwiftUI

struct LearnerMainView: View {
    @State private var selectedTab = 0
    @State private var mentors: [Mentor] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                TabView(selection: $selectedTab) {
                    // 홈 탭
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("홈")
                        }
                        .tag(0)
                    
                    MyLetterView()
                        .tabItem {
                            Image(systemName: "envelope.fill")
                            Text("내 질문")
                        }
                        .tag(1)
                    
                    // 프로필 탭
                    LearnerProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("프로필")
                        }
                        .tag(2)
                }
                .accentColor(.yellow)
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

struct LearnerMainView_Previews: PreviewProvider {
    static var previews: some View {
        LearnerMainView()
    }
}
