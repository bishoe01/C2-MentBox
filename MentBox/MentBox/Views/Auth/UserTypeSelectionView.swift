import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var selectedUserType: UserType?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationManager: NavigationManager
    
    init(selectedUserType: Binding<UserType?>) {
        self._selectedUserType = selectedUserType
        
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
                    ForEach(UserTypeConstants.options, id: \.userType) { item in
                        NavigationLink {
                            UserInfoInputView(userType: item.userType) {
                                navigationManager.setMainRoot(userType: item.userType)
                            }
                        } label: {
                            UserTypeSelectView(
                                iconName: item.iconName,
                                title: item.title,
                                description: item.description
                            )
                        }
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
