import SwiftUI
import FirebaseAuth

struct ChatCard: View {
    let question: ChatBox
    let answer: ChatBox?
    @State private var isPressed = false
    @State private var mentor: Mentor? = nil
    @State private var isBookmarked = false
    @State private var showBookmarkAnimation = false
    
    var body: some View {
        // 버튼을 버튼답게하는 간단한 애니메이션인데, 이거보다 그냥 테두리에 장난치는게 더 나을듯 ? -> 아마 Primary컬러로 blur주던지 그건 추후 
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                toggleBookmark()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Q.")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text(question.content)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("btn_dark").opacity(0.3),
                            Color("btn_light").opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                if let answer = answer {
                    // 멘토 답변이 담길 부분인데, 따로 분리해줄필요 있나 ? 
                    VStack(alignment: .leading, spacing: 16) {
                        
                        HStack(spacing: 12) {
                            if let mentor = mentor {
                                Image(mentor.profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                // name 
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mentor.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(mentor.expertise)
                                        .font(.system(size: 12))
                                        .foregroundColor(.yellow)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            // MARK : 북마크 토클 함수 
                                            toggleBookmark()
                                        }
                                    }) {
                                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                            .font(.system(size: 12))
                                            .foregroundColor(isBookmarked ? .yellow : .yellow.opacity(0.8))
                                            .scaleEffect(showBookmarkAnimation ? 1.2 : 1.0)
                                    }
                                    
                                    if answer.bookmarkCount > 0 {
                                        Text("\(answer.bookmarkCount)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.yellow.opacity(0.8))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        Text(answer.content)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("btn_dark").opacity(0.95),
                                Color("btn_light").opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                } else {
                    // 답변이 없는 경우의 UI
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            Text("답변 대기 중...")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.vertical, 12)
                            Spacer()
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("btn_dark").opacity(0.95),
                                Color("btn_light").opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isBookmarked ? Color.yellow.opacity(0.6) : Color("lightGray").opacity(0.6),
                                isBookmarked ? Color.yellow.opacity(0.3) : Color("lightGray").opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isBookmarked ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if let answer = answer {
                fetchMentor()
            }
            checkBookmarkStatus()
        }
    }
    
    private func fetchMentor() {
        FirebaseService.shared.fetchMentors { mentors in
            self.mentor = mentors.first { $0.id == answer?.mentorId }
        }
    }
    
    private func checkBookmarkStatus() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let bookmarkedQuestions = try await FirebaseService.shared.getBookmarkedQuestions(userId: userId)
                isBookmarked = bookmarkedQuestions.contains(question.id)
            } catch {
                print(" 북마크 상태 확인 실패: \(error)")
            }
        }
    }
    
    private func toggleBookmark() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showBookmarkAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showBookmarkAnimation = false
            }
        }
        
        Task {
            do {
                if isBookmarked {
                    try await FirebaseService.shared.removeBookmark(questionId: question.id, userId: userId)
                } else {
                    try await FirebaseService.shared.addBookmark(questionId: question.id, userId: userId)
                }
                withAnimation {
                    isBookmarked.toggle()
                }
            } catch {
                print(" 북마크 토글 실패: \(error)")
            }
        }
    }
}

#Preview {
    let previewMentor = Mentor(
        id: "preview_mentor_id",
        name: "데이지",
        bio: "UX 디자이너",
        profileImage: "Daisy",
        expertise: "디자인"
    )
    
    let previewQuestion = ChatBox(
        id: "preview_question_id",
        messageType: .question,
        userId: "preview_user_id",
        senderName: "사용자",
        content: "UX 디자인을 시작하려고 하는데, 어떤 것부터 시작하면 좋을까요?",
        sentDate: Date(),
        isFromMe: true,
        mentorId: previewMentor.id,
        bookmarkCount: 5,
        questionId: nil,
        status: "answered"
    )
    
    let previewAnswer = ChatBox(
        id: "preview_answer_id",
        messageType: .answer,
        userId: previewMentor.id,
        senderName: "데이지",
        content: "UX 디자인을 시작하시는 거라면, 먼저 사용자 리서치와 기본적인 디자인 원칙을 이해하는 것이 중요해요. 실제 사례를 분석하고 작은 프로젝트부터 시작해보는 것을 추천드립니다.",
        sentDate: Date(),
        isFromMe: false,
        mentorId: previewMentor.id,
        bookmarkCount: 5,
        questionId: previewQuestion.id,
        status: nil
    )
    
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        VStack {
            ChatCard(question: previewQuestion, answer: previewAnswer)
                .padding()
            ChatCard(question: previewQuestion, answer: nil)
                .padding()
        }
    }
}
