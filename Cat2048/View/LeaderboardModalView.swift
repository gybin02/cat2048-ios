import SwiftUI

struct LeaderboardModalView: View {
    let records: [ScoreRecord]
    let onClose: () -> Void

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM-dd"
        return f
    }()

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                Text("🏆 猫咪排行榜")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(Color(hex: "#a0522d"))

                VStack(spacing: 8) {
                    ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                        HStack {
                            // 排名徽章
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#bbada0"))
                                    .frame(width: 30, height: 30)
                                Text("\(index + 1)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("\(record.score) 分")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#a0522d"))

                            Spacer()

                            Text(dateFormatter.string(from: record.date))
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#8f7a6b"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#f5efe7"))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#eee4da"))
                        .clipShape(Capsule())
                    }
                }

                Button(action: onClose) {
                    Text("关闭")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#bbada0"))
                        .clipShape(Capsule())
                }
            }
            .padding(28)
            .background(Color(hex: "#fef9f0"))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 20)
            .padding(.horizontal, 24)
        }
    }
}
