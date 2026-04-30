import SwiftUI

struct GameOverModalView: View {
    let score: Int
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("😿")
                    .font(.system(size: 60))

                Text("游戏结束")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Color(hex: "#a0522d"))

                Text("得分：\(score)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#776e65"))

                Button(action: onNewGame) {
                    Text("🐱 再来一局")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#f0b27a"))
                        .clipShape(Capsule())
                }
            }
            .padding(36)
            .background(Color(hex: "#fef9f0"))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 20)
            .padding(.horizontal, 32)
        }
    }
}
