import SwiftUI

struct MentorMainView: View {
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
                    // 사연답변 탭
                    MentorStoriesView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("사연")
                        }
                        .tag(0)
                    
                    // 프로필 탭
                    MentorProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("프로필")
                        }
                        .tag(1)
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

struct MentorMainView_Previews: PreviewProvider {
    static var previews: some View {
        MentorMainView()
    }
}
