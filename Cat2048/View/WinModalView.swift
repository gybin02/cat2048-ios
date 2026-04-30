import SwiftUI

struct WinModalView: View {
    let onContinue: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { onContinue() }

            VStack(spacing: 20) {
                Text("😻😹😸")
                    .font(.system(size: 50))

                Text("恭喜！合成了宇宙无敌大猫咪！")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color(hex: "#a0522d"))
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("继续游戏")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#bbada0"))
                            .clipShape(Capsule())
                    }

                    Button(action: onNewGame) {
                        Text("🐱 新游戏")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#f0b27a"))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(32)
            .background(Color(hex: "#fef9f0"))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 20)
            .padding(.horizontal, 32)
        }
    }
}
