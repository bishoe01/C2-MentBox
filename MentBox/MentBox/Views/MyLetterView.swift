import SwiftUI

struct MyLetterView: View {
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("My Letter View")
                    .foregroundColor(.white)
            }
        }
    }
}
