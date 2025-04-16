import SwiftUI

struct SavedView: View {
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("저장 화면")
                    .foregroundColor(.white)
            }
        }
    }
}
