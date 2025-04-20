import SwiftUI

struct MentorsSection: View {
    @State private var selectedCategory: Category = .all
    let mentors: [Mentor]
    @Binding var selectedMentor: Mentor?
    
    var filteredMentors: [Mentor] {
        if selectedCategory == .all {
            return mentors
        }
        return mentors.filter { $0.expertise.lowercased() == selectedCategory.rawValue.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CategoryToggleView(
                selectedCategory: $selectedCategory,
                title: "운영중인 멘토",
                onSeeAll: {},
                showSeeAll: false
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredMentors) { mentor in
                        Button(action: {
                            selectedMentor = mentor
                        }) {
                            MentorCardView(mentor: mentor)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MentorsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MentorsSection(mentors: [], selectedMentor: .constant(nil))
        }
    }
}
