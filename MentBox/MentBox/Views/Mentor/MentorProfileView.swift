import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MentorProfileView: View {
    @State private var mentor: Mentor?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showWithdrawalAlert = false
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        VStack(spacing: 5) {
                            MentBoxHeader(title: "MENTBOX", isPadding: false)

                            HStack {
                                Text("멘토 프로필").menterFont(.header)
                                Spacer()
                            }.padding(.top, 8)
                        }.padding(.horizontal, 16)
                        
                        // 프로필 카드
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                Image(mentor?.profileImage ?? "default_profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 3)
                                    )
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(mentor?.name ?? "멘토")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                    
                                    Text(mentor?.expertise ?? "전문 분야")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow.opacity(0.9))
                                }
                                
                                Spacer()
                            }
                            
                            if let bio = mentor?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(12)
                        .padding(.all, 16)
                        
                        // 로그아웃 버튼
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                navigationManager.setAuthRoot()
                            } catch {
                                alertMessage = "로그아웃에 실패했습니다."
                                showAlert = true
                            }
                        }) {
                            Text("로그아웃")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.gray.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // 회원탈퇴 버튼
                        Button(action: {
                            showWithdrawalAlert = true
                        }) {
                            Text("회원탈퇴")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitle("MENTBOX", displayMode: .inline)
        .navigationBarHidden(true)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("회원탈퇴", isPresented: $showWithdrawalAlert) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                withdrawAccount()
            }
        } message: {
            Text("정말로 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.")
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        Task {
            do {
                let mentorDoc = try await Firestore.firestore().collection("mentors").document(userId).getDocument()
                if let mentorData = mentorDoc.data() {
                    let mentor = Mentor(
                        id: mentorDoc.documentID,
                        name: mentorData["name"] as? String ?? "",
                        bio: mentorData["bio"] as? String ?? "",
                        profileImage: mentorData["profileImage"] as? String ?? "",
                        expertise: mentorData["expertise"] as? String ?? ""
                    )
                    await MainActor.run {
                        self.mentor = mentor
                    }
                }
            } catch {
                alertMessage = "사용자 정보를 불러오는데 실패했습니다."
                showAlert = true
            }
        }
    }
    
    private func withdrawAccount() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }

        Task {
            do {
                
                try await Auth.auth().currentUser?.delete()
                
                
                try await FirebaseService.shared.deleteMentor(mentorId: userId)
                
                await MainActor.run {
                    navigationManager.setAuthRoot()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "회원탈퇴에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct MentorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MentorProfileView()
    }
}
