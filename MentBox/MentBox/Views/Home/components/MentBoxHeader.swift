import SwiftUI

struct MentBoxHeader: View {
    let title: String
    var isPadding: Bool = true

    var body: some View {
        HStack {
            Text(title)
                .font(.title.bold())
                .foregroundColor(Color("Primary"))

            Spacer()
        }
        .padding(.horizontal, isPadding ? 16 : 0)
    }
}
