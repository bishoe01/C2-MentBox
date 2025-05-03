import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var selectedUserType: UserType?
    let onSelection: (UserType) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showUserInfoInput = false
    
    init(selectedUserType: Binding<UserType?>, onSelection: @escaping (UserType) -> Void) {
        self._selectedUserType = selectedUserType
        self.onSelection = onSelection
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("회원 유형을 선택해주세요")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 20) {
                    Button {
                        selectedUserType = .learner
                        showUserInfoInput = true
                    } label: {
                        UserTypeSelectView(iconName: "person.fill", title: "Learner", description: "멘토에게 질문하고 답변을 받습니다.")
                    }
                    
                    Button {
                        selectedUserType = .mentor
                        showUserInfoInput = true
                    } label: {
                        UserTypeSelectView(iconName: "person.fill.checkmark", title: "Mentor", description: "학습자의 질문에 답변해주세요")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showUserInfoInput) {
                if let userType = selectedUserType {
                    UserInfoInputView(userType: userType) {
                        dismiss()
                        onSelection(userType)
                    }
                }
            }
        }
    }
}

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
