import SwiftUI

struct ProfileContentView: View {
    @State private var showSignInView = false
    
    var body: some View {
        BackgroundView {
            VStack {
                Spacer()
                
                Button(action: {
                    SignInView.signOut()
                    showSignInView = true
                }) {
                    Text("로그아웃")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
        }
    }
}
