import SwiftUI

struct TileView: View {
    let value: Int
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 10)
                .fill(value == 0 ? Color(hex: "#cdc1b4") : TileTheme.backgroundColor(for: value))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 3)

            if value != 0 {
                // 右下角猫爪装饰
                Text("🐾")
                    .font(.system(size: size * 0.18))
                    .opacity(0.25)
                    .padding(4)

                // 数值 + emoji
                VStack(spacing: 2) {
                    Text(TileTheme.emoji(for: value))
                        .font(.system(size: size * 0.3))
                        .lineLimit(1)
                    Text("\(value)")
                        .font(.system(size: valueFontSize, weight: .black))
                        .foregroundColor(TileTheme.textColor(for: value))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: size, height: size)
    }

    private var valueFontSize: CGFloat {
        switch value {
        case 0..<100:   return size * 0.35
        case 100..<1000: return size * 0.28
        default:         return size * 0.22
        }
    }
}
