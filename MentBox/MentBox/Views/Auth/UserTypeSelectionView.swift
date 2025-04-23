import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var selectedUserType: UserType?
    let onSelection: (UserType) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showUserInfoInput = false
    
    init(selectedUserType: Binding<UserType?>, onSelection: @escaping (UserType) -> Void) {
        self._selectedUserType = selectedUserType
        self.onSelection = onSelection
        
        // 다크 모드 강제 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("회원 유형을 선택해주세요")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 20) {
                    Button {
                        selectedUserType = .learner
                        showUserInfoInput = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                            Text("학습자")
                                .font(.title3)
                            Text("멘토에게 질문하고 답변을 받아보세요")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary").opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button {
                        selectedUserType = .mentor
                        showUserInfoInput = true
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.system(size: 40))
                            Text("멘토")
                                .font(.title3)
                            Text("학습자들의 질문에 답변해주세요")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary").opacity(0.1))
                        .cornerRadius(10)
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
