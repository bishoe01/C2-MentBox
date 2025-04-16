import SwiftUI

struct MentBoxHeader: View {
    let title: String

    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
            Spacer()
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            Spacer()
            Spacer() // 좌우 정렬 맞추기용
        }
        .padding()
    }
}
