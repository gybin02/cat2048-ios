import SwiftUI

struct TileTheme {
    static func backgroundColor(for value: Int) -> Color {
        switch value {
        case 2:    return Color(hex: "#eee4da")
        case 4:    return Color(hex: "#ede0c8")
        case 8:    return Color(hex: "#f2b179")
        case 16:   return Color(hex: "#f59563")
        case 32:   return Color(hex: "#f67c5f")
        case 64:   return Color(hex: "#f65e3b")
        case 128:  return Color(hex: "#edcf72")
        case 256:  return Color(hex: "#edcc61")
        case 512:  return Color(hex: "#edc850")
        case 1024: return Color(hex: "#edc53f")
        case 2048: return Color(hex: "#edc22e")
        default:   return Color(hex: "#3c3a32")
        }
    }

    static func textColor(for value: Int) -> Color {
        return (value == 2 || value == 4)
            ? Color(hex: "#776e65")
            : Color(hex: "#f9f6f2")
    }

    static func emoji(for value: Int) -> String {
        switch value {
        case 2:    return "😿"
        case 4:    return "😺"
        case 8:    return "😈"
        case 16:   return "😽"
        case 32:   return "😼"
        case 64:   return "🙀"
        case 128:  return "😻"
        case 256:  return "😩"
        case 512:  return "😾"
        case 1024: return "😈"
        default:   return "🐈"  // 2048+
        }
    }
}

// MARK: - Color hex initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
