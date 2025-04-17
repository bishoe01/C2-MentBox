import SwiftUI

struct CategoryButtonStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(backgroundView)
            .foregroundColor(isSelected ? Color.black : Color.white.opacity(0.9))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.yellow : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if isSelected {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow,
                    Color.yellow.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.clear
        }
    }
}

struct MentorsSection: View {
    @State private var selectedCategory: MentorCategory = .all
    
    let mentors = MockMentorData.mentors
    
    var filteredMentors: [Mentor] {
        if selectedCategory == .all {
            return mentors
        }
        return mentors.filter { $0.expertise.lowercased() == selectedCategory.rawValue.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("운영중인 멘토")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("See All")
                    .foregroundColor(.yellow)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(MentorCategory.allCases, id: \.self) { category in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category.rawValue)
                                .modifier(CategoryButtonStyle(isSelected: selectedCategory == category))
                        }
                    }
                }
                .padding(.vertical, 4)
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
