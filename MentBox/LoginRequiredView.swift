import SwiftUI

struct LoginRequiredView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 20) {
            MentBoxHeader(title: "MENTBOX", isPadding: false)
            
            Spacer()
            
            Text("로그인이 필요한 서비스입니다")
                .font(.title2)
                .foregroundColor(.white)
            
            Button(action: {
                navigationManager.setAuthRoot()
            }) {
                Text("로그인하러가기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
    }
}
