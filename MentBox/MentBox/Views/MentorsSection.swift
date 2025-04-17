import SwiftUI

struct MentorsSection: View {
    @State private var selectedCategory: MentorCategory = .all
    
    let mentors = [
        Mentor(name: "Gommin", bio: "Senior iOS Developer", profileImage: "Gommin", expertise: "Tech"),
        Mentor(name: "Daisy", bio: "UX/UI Designer", profileImage: "Daisy", expertise: "Design"),
        Mentor(name: "Lumi", bio: "Business Consultant", profileImage: "Lumi", expertise: "Business")
    ]
    
    var filteredMentors: [Mentor] {
        if selectedCategory == .all {
            return mentors
        }
        return mentors.filter { $0.expertise.lowercased() == selectedCategory.rawValue.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Mentors")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("See All")
                    .foregroundColor(.yellow)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MentorCategory.allCases, id: \.self) { category in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategory == category ?
                                        Color.white : Color.clear
                                )
                                .foregroundColor(
                                    selectedCategory == category ?
                                        Color.black : Color.white.opacity(0.8)
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            selectedCategory == category ?
                                                Color.white :
                                                Color.white.opacity(0.3),
                                            lineWidth: selectedCategory == category ? 1.5 : 0.8
                                        )
                                )
                        }
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(filteredMentors) { mentor in
                        MentorCardView(mentor: mentor)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct MentorsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MentorsSection()
        }
    }
}
