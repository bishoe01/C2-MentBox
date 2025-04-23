import SwiftUI

enum MenterFontStyle {
    case logoHeader // 32
    case header // 26 Bold
    case subtitle // 20 Semibold
    case body // 16 Regular
    case caption // 14 Regular
    case tag // 12 Regular
    case smallest // 10 Regular
    case custom(CGFloat, Font.Weight)

    var font: Font {
        switch self {
        case .logoHeader:
            return .custom("PretendardVariable-Bold", size: 32)
        case .header:
            return .custom("PretendardVariable-Bold", size: 26)
        case .subtitle:
            return .custom("PretendardVariable-SemiBold", size: 20)
        case .body:
            return .custom("PretendardVariable-Regular", size: 16)
        case .caption:
            return .custom("PretendardVariable-Regular", size: 14)
        case .tag:
            return .custom("PretendardVariable-Regular", size: 12)
        case .smallest:
            return .custom("PretendardVariable-Regular", size: 10)
        case .custom(let size, let weight):
            return .custom(weight.fontName, size: size)
        }
    }

    var color: Color {
        switch self {
        case .header, .subtitle, .logoHeader:
            return Color(hex: "#EFEFEA")
        case .body, .caption, .tag, .smallest:
            return Color(hex: "#A5A5A5")
        case .custom:
            return Color(hex: "#EFEFEA")
        }
    }
}

extension Font.Weight {
    var fontName: String {
        switch self {
        case .black:
            return "PretendardVariable-Black"
        case .heavy:
            return "PretendardVariable-ExtraBold"
        case .bold:
            return "PretendardVariable-Bold"
        case .semibold:
            return "PretendardVariable-SemiBold"
        case .medium:
            return "PretendardVariable-Medium"
        case .regular:
            return "PretendardVariable-Regular"
        case .light:
            return "PretendardVariable-Light"
        case .thin:
            return "PretendardVariable-Thin"
        case .ultraLight:
            return "PretendardVariable-ExtraLight"
        default:
            return "PretendardVariable-Regular"
        }
    }
}

extension View {
    func menterFont(_ style: MenterFontStyle) -> some View {
        self.font(style.font)
            .foregroundColor(style.color)
    }
}

// HEX컬러 먹이기 위한 extension
extension Color {
    init(hex: String, opacity: Double = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self = Color.gray
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            .sRGB,
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
            opacity: opacity
        )
    }
}
