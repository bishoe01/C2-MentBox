import SwiftUI

struct UserTypeSelectView: View {
    var iconName: String
    let title: String
    let description: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: self.iconName)
                .font(.system(size: 40))
            Text(self.title)
                .font(.title3)
            Text(self.description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("Primary").opacity(0.1))
        .cornerRadius(10)
    }
}
