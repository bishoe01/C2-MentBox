import SwiftUI

struct CategoryButtonStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(backgroundView)
            .foregroundColor(isSelected ? Color.black : Color.white.opacity(0.9))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.yellow : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }

    // 조건부로 뷰 스타일 바꿔줄때  너무 중첩대있으면 에러 뜨니까 이렇게 변경
    @ViewBuilder
    var backgroundView: some View {
        if isSelected {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow,
                    Color.yellow.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.clear
        }
    }
}
