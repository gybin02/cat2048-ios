import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel

    private let gap: CGFloat = 10
    private let padding: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height)
            let tileSize = (boardSize - padding * 2 - gap * 3) / 4

            ZStack {
                // 棋盘背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#bbada0"))

                // 方块网格
                VStack(spacing: gap) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<4, id: \.self) { col in
                                TileView(value: viewModel.board[row][col], size: tileSize)
                                    .animation(.spring(response: 0.15, dampingFraction: 0.8), value: viewModel.board[row][col])
                            }
                        }
                    }
                }
                .padding(padding)
            }
            .frame(width: boardSize, height: boardSize)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if let direction = detectDirection(value.translation) {
                            viewModel.handleSwipe(direction)
                        }
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 16)
    }

    private func detectDirection(_ translation: CGSize) -> SwipeDirection? {
        let dx = translation.width
        let dy = translation.height
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        } else {
            return dy > 0 ? .down : .up
        }
    }
}
