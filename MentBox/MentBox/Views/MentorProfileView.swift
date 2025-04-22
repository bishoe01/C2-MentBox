import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MentorProfileView: View {
    @State private var mentor: Mentor?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignInView = false
    
    var body: some View {
        BackgroundView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 5) {
                        VStack(spacing: 5) {
                            MentBoxHeader(title: "MENTBOX", isPadding: false)

                            HStack {
                                Text("러너 프로필").menterFont(.header)
                                Spacer()
                            }.padding(.top, 16)
                        }.padding(.horizontal, 16)
                        
                        // 프로필 섹션
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Image(mentor?.profileImage ?? "default_profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mentor?.name ?? "멘토")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(mentor?.expertise ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if let mentor = mentor {
                                Text(mentor.bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 12)
                        
                        // 로그아웃 버튼
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                showSignInView = true
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
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
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
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
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
}

struct MentorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MentorProfileView()
    }
}
