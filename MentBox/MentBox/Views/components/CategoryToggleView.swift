import SwiftUI

enum Category: String, CaseIterable {
    case all = "All"
    case tech = "Tech"
    case design = "Design"
    case business = "Business"
}

struct CategoryToggleView: View {
    @Binding var selectedCategory: Category
    let title: String
    let onSeeAll: () -> Void
    let showSeeAll: Bool
    
    init(
        selectedCategory: Binding<Category>,
        title: String,
        onSeeAll: @escaping () -> Void,
        showSeeAll: Bool = true
    ) {
        self._selectedCategory = selectedCategory
        self.title = title
        self.onSeeAll = onSeeAll
        self.showSeeAll = showSeeAll
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                if showSeeAll {
                    Button(action: onSeeAll) {
                        Text("See All")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Category.allCases, id: \.self) { category in
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
        }
        .padding(.vertical)
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        CategoryToggleView(
            selectedCategory: .constant(.all),
            title: "카테고리",
            onSeeAll: {},
            showSeeAll: true
        )
    }
} 
