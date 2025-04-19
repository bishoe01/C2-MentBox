import SwiftUI

struct MentorListView: View {
    @State private var mentors: [Mentor] = []
    @State private var selectedExpertise: String? = nil
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // ... existing code ...
        }
        .onAppear {
            loadMentors()
        }
    }
    
    private func loadMentors() {
        FirebaseService.shared.fetchMentors { fetchedMentors in
            self.mentors = fetchedMentors
        }
    }
    
    // ... existing code ...
} 
