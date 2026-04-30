import SwiftUI

struct ScoreHeaderView: View {
    let score: Int
    let highScore: Int
    let onNewGame: () -> Void
    let onLeaderboard: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // 标题
            Text("猫咪2048 🐾")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(hex: "#776e65"))

            Spacer()

            // 得分
            ScoreBadge(label: "得分", value: score)
            ScoreBadge(label: "最高", value: highScore)

            // 按钮
            Button(action: onNewGame) {
                Text("新游戏")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#8f7a6b"))
                    .clipShape(Capsule())
            }

            Button(action: onLeaderboard) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(hex: "#8f7a6b"))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct ScoreBadge: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            Text("\(value)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: "#bbada0"))
        .clipShape(Capsule())
    }
}
