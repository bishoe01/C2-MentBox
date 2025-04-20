import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor
    @Environment(\.presentationMode) private var presentationMode
    @State private var chatPairs: [(question: ChatBox, answer: ChatBox)] = []
    @State private var questionText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // 멘토 프로필 섹션
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Image(mentor.profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mentor.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(mentor.expertise)
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal)
                            
                            Text(mentor.bio)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("btn_dark").opacity(0.3),
                                            Color("btn_light").opacity(0.3)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("lightGray"), lineWidth: 1)
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        // 멘토가 답변한 사연들
                        VStack(alignment: .leading, spacing: 20) {
                            Text("답변한 사연")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                ForEach(chatPairs.indices, id: \.self) { index in
                                    let pair = chatPairs[index]
                                    ChatCardView(question: pair.question, answer: pair.answer)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // 편지 작성 영역
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        ZStack(alignment: .center) {
                            if questionText.isEmpty {
                                Text("\(mentor.name) 멘토에게 편지를 작성해주세요")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $questionText)
                                .frame(height: 40)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Button(action: {
                            submitQuestion()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("btn_dark"), Color("btn_light")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        .disabled(questionText.isEmpty || isSubmitting)
                        .opacity(questionText.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.black.opacity(0.5))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadChatPairs()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    private func submitQuestion() {
        guard !questionText.isEmpty else { return }
        
        isSubmitting = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            alertMessage = "편지가 성공적으로 전송되었습니다."
            showAlert = true
            questionText = ""
        }
    }
    
    private func loadChatPairs() {
        print("🔍 MentorDetailView - loadChatPairs 시작 - mentorId: \(mentor.id)")
        FirebaseService.shared.fetchQuestionAnswerPairs(for: mentor.id) { pairs in
            print("✅ MentorDetailView - 데이터 로드 완료 - pairs 개수: \(pairs.count)")
            self.chatPairs = pairs
        }
    }
}

struct MentorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MentorDetailView(mentor: Mentor(
                id: "preview_mentor_id",
                name: "김멘토",
                bio: "10년차 iOS 개발자",
                profileImage: "profile_image",
                expertise: "테크"
            ))
        }
    }
}
