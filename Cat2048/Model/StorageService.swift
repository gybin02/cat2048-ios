import Foundation

struct StorageService {
    private static let highScoreKey = "cat2048_highScore"
    private static let rankKey = "cat2048_rank"

    // MARK: - High Score
    static func saveHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: highScoreKey)
    }

    static func loadHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }

    // MARK: - Leaderboard
    static func saveLeaderboard(_ records: [ScoreRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: rankKey)
        }
    }

    static func loadLeaderboard() -> [ScoreRecord] {
        guard
            let data = UserDefaults.standard.data(forKey: rankKey),
            let records = try? JSONDecoder().decode([ScoreRecord].self, from: data)
        else {
            return defaultRecords()
        }
        return records
    }

    // 首次运行：5条0分记录，日期依次递减一天
    private static func defaultRecords() -> [ScoreRecord] {
        let now = Date()
        return (0..<5).map { i in
            ScoreRecord(score: 0, date: now.addingTimeInterval(Double(-i) * 86400))
        }
    }
}
