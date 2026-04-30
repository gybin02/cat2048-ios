import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            // 背景色
            Color(hex: "#faf8ef").ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部得分栏
                ScoreHeaderView(
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    onNewGame: { viewModel.startNewGame() },
                    onLeaderboard: { viewModel.toggleLeaderboard() }
                )

                // 棋盘
                BoardView(viewModel: viewModel)
                    .padding(.top, 8)

                // 游戏说明
                Text("📋 滑动合并相同数字，合成 2048 召唤大猫咪！")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#776e65"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#eee4da"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                Spacer()
            }

            // 胜利弹窗
            if viewModel.showWinModal {
                WinModalView(
                    onContinue: { viewModel.dismissWinModal() },
                    onNewGame: { viewModel.startNewGame() }
                )
                .transition(.opacity)
                .zIndex(1)
            }

            // 游戏结束弹窗
            if viewModel.showGameOverModal {
                GameOverModalView(
                    score: viewModel.score,
                    onNewGame: { viewModel.startNewGame() }
                )
                .transition(.opacity)
                .zIndex(1)
            }

            // 排行榜弹窗
            if viewModel.showLeaderboard {
                LeaderboardModalView(
                    records: viewModel.leaderboardRecords,
                    onClose: { viewModel.toggleLeaderboard() }
                )
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.showWinModal)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showGameOverModal)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showLeaderboard)
    }
}
