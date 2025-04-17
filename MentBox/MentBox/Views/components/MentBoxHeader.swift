import SwiftUI

struct MentBoxHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title.bold())
                .foregroundColor(Color("Primary"))

            Spacer()
        }
        .padding()
    }
}
