import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("홈 화면")
                    .foregroundColor(.white)
            }
        }
    }
}
