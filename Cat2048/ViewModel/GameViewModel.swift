import SwiftUI

enum SwipeDirection {
    case left, right, up, down
}

class GameViewModel: ObservableObject {
    // MARK: - Published State
    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var showWinModal: Bool = false
    @Published var showGameOverModal: Bool = false
    @Published var showLeaderboard: Bool = false
    @Published var leaderboardRecords: [ScoreRecord] = []

    // MARK: - Internal Flags
    private var hasWon: Bool = false
    private var gameEndRecorded: Bool = false

    // MARK: - Init
    init() {
        highScore = StorageService.loadHighScore()
        startNewGame()
    }

    // MARK: - Public Interface
    func startNewGame() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        hasWon = false
        gameEndRecorded = false
        showWinModal = false
        showGameOverModal = false
        addRandomTile()
        addRandomTile()
    }

    func handleSwipe(_ direction: SwipeDirection) {
        let changed = applyMove(direction)
        guard changed else { return }

        addRandomTile()
        checkWin()
        checkGameOver()

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func dismissWinModal() {
        showWinModal = false
    }

    func dismissGameOverModal() {
        showGameOverModal = false
    }

    func toggleLeaderboard() {
        leaderboardRecords = StorageService.loadLeaderboard()
        showLeaderboard.toggle()
    }

    // MARK: - Merge Logic
    func mergeLine(_ line: [Int]) -> (result: [Int], gained: Int) {
        var filtered = line.filter { $0 != 0 }
        var gained = 0
        var i = 0
        while i < filtered.count - 1 {
            if filtered[i] == filtered[i + 1] {
                filtered[i] *= 2
                gained += filtered[i]
                filtered.remove(at: i + 1)
            }
            i += 1
        }
        while filtered.count < 4 { filtered.append(0) }
        return (filtered, gained)
    }

    // MARK: - Move Application
    @discardableResult
    private func applyMove(_ direction: SwipeDirection) -> Bool {
        var newBoard = board
        var totalGained = 0
        var changed = false

        switch direction {
        case .left:
            for r in 0..<4 {
                let (result, gained) = mergeLine(newBoard[r])
                if result != newBoard[r] { changed = true }
                newBoard[r] = result
                totalGained += gained
            }
        case .right:
            for r in 0..<4 {
                let (result, gained) = mergeLine(newBoard[r].reversed())
                let reversed = Array(result.reversed())
                if reversed != newBoard[r] { changed = true }
                newBoard[r] = reversed
                totalGained += gained
            }
        case .up:
            for c in 0..<4 {
                let col = (0..<4).map { newBoard[$0][c] }
                let (result, gained) = mergeLine(col)
                if result != col { changed = true }
                for r in 0..<4 { newBoard[r][c] = result[r] }
                totalGained += gained
            }
        case .down:
            for c in 0..<4 {
                let col = (0..<4).map { newBoard[$0][c] }
                let (result, gained) = mergeLine(col.reversed())
                let reversed = Array(result.reversed())
                if reversed != col { changed = true }
                for r in 0..<4 { newBoard[r][c] = reversed[r] }
                totalGained += gained
            }
        }

        if changed {
            board = newBoard
            score += totalGained
            if score > highScore {
                highScore = score
                StorageService.saveHighScore(highScore)
            }
        }
        return changed
    }

    // MARK: - Random Tile
    private func addRandomTile() {
        var empty: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if board[r][c] == 0 { empty.append((r, c)) }
            }
        }
        guard !empty.isEmpty else { return }
        let (r, c) = empty.randomElement()!
        board[r][c] = Double.random(in: 0..<1) < 0.9 ? 2 : 4
    }

    // MARK: - Win / Game Over
    private func checkWin() {
        guard !hasWon else { return }
        for r in 0..<4 {
            for c in 0..<4 {
                if board[r][c] >= 2048 {
                    hasWon = true
                    showWinModal = true
                    return
                }
            }
        }
    }

    private func checkGameOver() {
        guard !canMove(), !gameEndRecorded else { return }
        gameEndRecorded = true
        if score > 0 { recordScore() }
        showGameOverModal = true
    }

    func canMove() -> Bool {
        // 有空格
        for r in 0..<4 {
            for c in 0..<4 {
                if board[r][c] == 0 { return true }
            }
        }
        // 水平相邻相同
        for r in 0..<4 {
            for c in 0..<3 {
                if board[r][c] == board[r][c + 1] { return true }
            }
        }
        // 垂直相邻相同
        for c in 0..<4 {
            for r in 0..<3 {
                if board[r][c] == board[r + 1][c] { return true }
            }
        }
        return false
    }

    // MARK: - Leaderboard
    private func recordScore() {
        var records = StorageService.loadLeaderboard()
        records.append(ScoreRecord(score: score, date: Date()))
        records.sort { a, b in
            a.score != b.score ? a.score > b.score : a.date < b.date
        }
        if records.count > 5 { records = Array(records.prefix(5)) }
        StorageService.saveLeaderboard(records)
        leaderboardRecords = records
    }
}
