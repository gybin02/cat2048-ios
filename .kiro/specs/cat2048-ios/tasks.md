# 实现计划：猫咪2048 iOS

## 概述

基于 MVVM 架构，使用纯 SwiftUI（iOS 16+）实现猫咪2048游戏。按照 Model → ViewModel → View 的顺序逐层构建，每层完成后通过测试验证，最终集成手势与触觉反馈。

## 任务

- [x] 1. 搭建 Xcode 项目结构与基础配置
  - 创建 Xcode 项目，Bundle ID 设为 `com.yourname.Cat2048`，最低支持 iOS 16.0
  - 按设计文档创建目录结构：`Model/`、`ViewModel/`、`View/`、`Cat2048Tests/`
  - 在 `Cat2048App.swift` 中配置 App 入口，通过 `UIApplicationDelegateAdaptor` 或 `Info.plist` 锁定竖屏（Portrait）
  - 在 `Cat2048Tests` Target 中通过 Swift Package Manager 添加 SwiftCheck 依赖（`https://github.com/typelift/SwiftCheck`）
  - _需求：10.3_

- [x] 2. 实现 Model 层
  - [x] 2.1 实现 `ScoreRecord.swift`
    - 定义 `ScoreRecord: Codable, Equatable` 结构体，包含 `score: Int` 和 `date: Date` 字段
    - _需求：6.1_

  - [x] 2.2 实现 `TileTheme.swift`
    - 实现 `TileTheme` 结构体，包含三个静态方法：`backgroundColor(for:) -> Color`、`textColor(for:) -> Color`、`emoji(for:) -> String`
    - 按需求 4.1、4.2、4.3 完整实现11个数值（2~2048）及 >2048 的映射，2和4使用深色文字 `#776e65`，其余使用浅色文字 `#f9f6f2`
    - _需求：4.1、4.2、4.3_

  - [ ]* 2.3 为 TileTheme 编写属性测试
    - **属性 6：方块视觉属性映射完整性**
    - **验证需求：4.1、4.2、4.3**
    - 在 `PropertyTests.swift` 中枚举所有有效数值（2、4、8、16、32、64、128、256、512、1024、2048），断言三个映射函数返回确定性结果，且2和4返回深色文字，其余返回浅色文字
    - 注释标签：`// Feature: cat2048-ios, Property 6: 方块视觉属性映射完整性`

  - [x] 2.4 实现 `StorageService.swift`
    - 实现 `StorageService` 结构体，包含静态方法：`saveHighScore(_:)`、`loadHighScore() -> Int`、`saveLeaderboard(_:)`、`loadLeaderboard() -> [ScoreRecord]`
    - 键名：`cat2048_highScore`（Int）、`cat2048_rank`（JSON Data）
    - `loadLeaderboard()` 在 UserDefaults 无数据、JSON 解码失败时返回5条0分默认记录，日期依次递减一天
    - _需求：9.1、9.2、9.3、9.4、6.4_

  - [ ]* 2.5 为 StorageService 编写属性测试
    - **属性 11：持久化 Round Trip**
    - **验证需求：9.1、9.2、9.3**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机 Int 和随机 `[ScoreRecord]`，断言保存后加载的数据与原始值相等
    - 注释标签：`// Feature: cat2048-ios, Property 11: 持久化 Round Trip`

  - [ ]* 2.6 为 StorageService 编写单元测试
    - 在 `StorageServiceTests.swift` 中测试：首次加载返回5条0分记录（`testDefaultLeaderboard`）、损坏 JSON 返回默认记录（`testCorruptedLeaderboardFallback`）
    - _需求：9.4、6.4_

- [x] 3. 实现 GameViewModel 核心逻辑
  - [x] 3.1 实现 `GameViewModel.swift` 基础结构与状态属性
    - 定义 `SwipeDirection` 枚举（left、right、up、down）
    - 创建 `GameViewModel: ObservableObject`，声明所有 `@Published` 属性：`board: [[Int]]`、`score: Int`、`highScore: Int`、`showWinModal: Bool`、`showGameOverModal: Bool`、`showLeaderboard: Bool`
    - 声明内部标志：`private var hasWon: Bool`、`private var gameEndRecorded: Bool`
    - 在 `init()` 中从 `StorageService` 加载 `highScore`，调用 `startNewGame()`
    - _需求：1.1、3.4_

  - [x] 3.2 实现 `mergeLine` 与四方向移动逻辑
    - 实现 `private func mergeLine(_ line: [Int]) -> (result: [Int], gained: Int)`：过滤零值 → 从左到右扫描合并（每位置最多一次）→ 补零到长度4
    - 实现 `private func applyMove(_ direction: SwipeDirection) -> Bool`：向左直接 mergeLine；向右 reverse→merge→reverse；向上转置→merge→转置；向下转置→reverse→merge→reverse→转置；返回棋盘是否发生变化
    - _需求：2.1、2.2、2.3、2.4、2.7_

  - [ ]* 3.3 为 mergeLine 编写属性测试
    - **属性 2：行合并的幂等性与正确性**
    - **验证需求：2.1、2.2、2.3、2.4、2.7**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机长度4的 `[Int]`（值为0或2的幂次），断言：结果长度为4、非零值靠左、无相邻相同非零值、非零值总和不变
    - 注释标签：`// Feature: cat2048-ios, Property 2: 行合并的幂等性与正确性`

  - [ ]* 3.4 为 mergeLine 编写单元测试
    - 在 `MergeLogicTests.swift` 中测试边界用例（`testMergeLineEdgeCases`）：全零行、全相同值行 `[2,2,2,2]→[4,4,0,0]`、`[4,4,4,0]→[8,4,0,0]` 只合并一次、`[2,0,2,4]→[4,4,0,0]`
    - _需求：2.7_

  - [x] 3.5 实现 `addRandomTile`、`startNewGame` 与初始化
    - 实现 `private func addRandomTile()`：从所有值为0的格子中随机选一个，90%填2，10%填4；棋盘已满时静默返回
    - 实现 `func startNewGame()`：重置 board 为全零、score 为0、hasWon/gameEndRecorded 为 false、关闭所有弹窗，调用两次 `addRandomTile()`
    - _需求：1.1、1.2、1.4、3.5、5.4_

  - [ ]* 3.6 为初始棋盘编写属性测试
    - **属性 1：初始棋盘恰好有两个非零方块**
    - **验证需求：1.1、1.2**
    - 在 `PropertyTests.swift` 中多次调用 `startNewGame()`，断言非零方块数量恰好为2，且每个值为2或4
    - 注释标签：`// Feature: cat2048-ios, Property 1: 初始棋盘恰好有两个非零方块`

  - [x] 3.7 实现 `canMove`、`checkWin`、`checkGameOver`
    - 实现 `private func canMove() -> Bool`：存在空格返回 true；存在水平相邻相同值返回 true；存在垂直相邻相同值返回 true；否则返回 false
    - 实现 `private func checkWin()`：若任意格子值 ≥ 2048 且 `!hasWon`，设 `hasWon = true`，`showWinModal = true`
    - 实现 `private func checkGameOver()`：若 `!canMove()` 且 `!gameEndRecorded`，设 `gameEndRecorded = true`，将当前得分写入排行榜（score > 0 时），设 `showGameOverModal = true`
    - _需求：8.1、8.2、8.3、8.4、5.1、5.2_

  - [ ]* 3.8 为 canMove 编写属性测试
    - **属性 10：canMove 正确性**
    - **验证需求：8.1**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机4×4棋盘，断言 `canMove()` 返回 true 当且仅当存在空格或存在水平/垂直相邻相同非零值
    - 注释标签：`// Feature: cat2048-ios, Property 10: canMove 正确性`

  - [x] 3.9 实现 `handleSwipe` 与分数更新
    - 实现 `func handleSwipe(_ direction: SwipeDirection)`：调用 `applyMove`，若棋盘变化则累加得分、更新 highScore（超过时持久化）、调用 `addRandomTile()`、`checkWin()`、`checkGameOver()`
    - 实现 `func dismissWinModal()`、`func dismissGameOverModal()`、`func toggleLeaderboard()`
    - _需求：2.5、2.6、3.1、3.2、3.3、3.4、5.3_

  - [ ]* 3.10 为移动后棋盘变化编写属性测试
    - **属性 3：移动后棋盘变化当且仅当新增一个方块**
    - **验证需求：2.5、2.6**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机棋盘和随机方向，断言：棋盘变化时非零方块数量恰好增加1；棋盘不变时非零方块数量不变
    - 注释标签：`// Feature: cat2048-ios, Property 3: 移动后棋盘变化当且仅当新增一个方块`

  - [ ]* 3.11 为分数累加编写属性测试
    - **属性 4：分数累加正确性**
    - **验证需求：3.1、3.3**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机可合并棋盘，断言每次移动后分数增量等于本次所有合并产生的新方块数值之和
    - 注释标签：`// Feature: cat2048-ios, Property 4: 分数累加正确性`

  - [ ]* 3.12 为新游戏重置分数编写属性测试
    - **属性 5：新游戏重置分数**
    - **验证需求：3.5**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机游戏状态，调用 `startNewGame()` 后断言 `score == 0` 且 `highScore` 不小于重置前的值
    - 注释标签：`// Feature: cat2048-ios, Property 5: 新游戏重置分数`

  - [ ]* 3.13 为胜利状态编写属性测试
    - **属性 7：胜利状态只触发一次**
    - **验证需求：5.1、5.2、5.4**
    - 在 `PropertyTests.swift` 中构造包含2048合并的操作序列，断言 `hasWon` 在同一局中只从 false 变为 true 一次；`startNewGame()` 后 `hasWon` 重置为 false
    - 注释标签：`// Feature: cat2048-ios, Property 7: 胜利状态只触发一次`

  - [ ]* 3.14 为游戏结束记录编写属性测试
    - **属性 9：游戏结束得分只记录一次**
    - **验证需求：6.2、8.2、8.4**
    - 在 `PropertyTests.swift` 中构造游戏结束场景，多次触发检测，断言排行榜中该局得分记录只新增一条
    - 注释标签：`// Feature: cat2048-ios, Property 9: 游戏结束得分只记录一次`

  - [ ]* 3.15 为 GameViewModel 编写单元测试
    - 在 `GameViewModelTests.swift` 中测试：`testHighScoreNotDecreasedOnNewGame`（新游戏后最高分不降低）、`testGameOverModalShown`（棋盘满且无合并时显示结束弹窗）
    - _需求：3.5、8.3_

- [ ] 4. 检查点 —— 确保所有测试通过
  - 运行全部单元测试与属性测试，确保通过后再进入 View 层实现。如有问题请向用户反馈。

- [x] 5. 实现排行榜逻辑
  - [x] 5.1 在 `GameViewModel` 中实现排行榜更新方法
    - 实现私有方法 `private func recordScore()`：从 `StorageService` 加载当前排行榜，追加新记录，按分数降序/日期升序排序，截取前5条，保存回 `StorageService`
    - 在 `checkGameOver()` 中调用 `recordScore()`（score > 0 时）
    - _需求：6.1、6.2、6.3、8.2_

  - [ ]* 5.2 为排行榜排序编写属性测试
    - **属性 8：排行榜排序与容量约束**
    - **验证需求：6.1、6.3**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机 `[ScoreRecord]` 数组，经过排行榜更新逻辑后断言：记录数量 ≤ 5、按分数降序、分数相同时按日期升序
    - 注释标签：`// Feature: cat2048-ios, Property 8: 排行榜排序与容量约束`

- [x] 6. 实现 View 层基础组件
  - [x] 6.1 实现 `TileView.swift`
    - 接收 `value: Int` 和 `size: CGFloat`，从 `TileTheme` 获取背景色、文字色、emoji
    - 使用 `ZStack` 叠加：圆角矩形背景、数值文字（居中）、emoji（居中或上方）、右下角半透明猫爪 🐾
    - value 为0时显示占位格（背景色 `#eee4da`，无文字）
    - _需求：4.1、4.2、4.3、4.4、1.3_

  - [x] 6.2 实现 `ScoreHeaderView.swift`
    - 接收 `score: Int`、`highScore: Int`、`onNewGame: () -> Void`、`onLeaderboard: () -> Void`
    - 显示当前分数、最高分，以及"新游戏"和"排行榜"按钮
    - _需求：3.2、3.4_

  - [x] 6.3 实现 `BoardView.swift`
    - 接收 `@ObservedObject var viewModel: GameViewModel`
    - 使用 `GeometryReader` 计算棋盘宽度，方块尺寸 = (棋盘宽 - 间距) / 4
    - 用 `LazyVGrid` 或嵌套 `ForEach` 渲染4×4网格，每格调用 `TileView`
    - 附加 `DragGesture(minimumDistance: 10)` 在整个棋盘上，`.onEnded` 中调用 `detectDirection` 并转发给 `viewModel.handleSwipe`
    - _需求：2.1~2.4、7.1、7.2、7.3、10.2_

  - [x] 6.4 实现手势方向判断与触觉反馈
    - 在 `BoardView` 或 `GameViewModel` 中实现 `detectDirection(translation: CGSize) -> SwipeDirection?`：`abs(dx) > abs(dy)` 时判断左右，否则判断上下
    - 在 `GameViewModel.handleSwipe` 中，若移动有效则调用 `UIImpactFeedbackGenerator(style: .light).impactOccurred()`
    - _需求：7.1、7.2、7.4_

  - [ ]* 5.3 为手势方向判断编写属性测试
    - **属性 12：手势方向判断阈值**
    - **验证需求：7.2**
    - 在 `PropertyTests.swift` 中使用 SwiftCheck 生成随机小位移向量（水平和垂直分量绝对值均 < 10pt），断言 `detectDirection` 返回 `nil`
    - 注释标签：`// Feature: cat2048-ios, Property 12: 手势方向判断阈值`

- [x] 7. 实现弹窗视图
  - [x] 7.1 实现 `WinModalView.swift`
    - 接收 `onContinue: () -> Void` 和 `onNewGame: () -> Void`
    - 显示胜利标题、猫咪 emoji 装饰、"继续游戏"和"新游戏"两个按钮
    - _需求：5.1、5.3、5.4_

  - [x] 7.2 实现 `GameOverModalView.swift`
    - 接收 `score: Int` 和 `onNewGame: () -> Void`
    - 显示游戏结束标题、当前得分、"新游戏"按钮
    - _需求：8.3_

  - [x] 7.3 实现 `LeaderboardModalView.swift`
    - 接收 `records: [ScoreRecord]` 和 `onClose: () -> Void`
    - 列出前5名记录（排名、分数、日期格式化为 `yyyy-MM-dd`）
    - 点击关闭按钮或背景区域时调用 `onClose`
    - _需求：6.5、6.6_

- [x] 8. 实现 `GameView.swift` 与主界面集成
  - 创建 `GameView`，持有 `@StateObject var viewModel = GameViewModel()`
  - 垂直布局：`ScoreHeaderView` → `BoardView`，使用 `.padding` 和 `Spacer` 适配安全区域
  - 使用 `.sheet` 或 `.overlay` 展示 `WinModalView`（绑定 `viewModel.showWinModal`）
  - 使用 `.sheet` 或 `.overlay` 展示 `GameOverModalView`（绑定 `viewModel.showGameOverModal`）
  - 使用 `.sheet` 或 `.overlay` 展示 `LeaderboardModalView`（绑定 `viewModel.showLeaderboard`）
  - 在 `Cat2048App.swift` 中将 `GameView` 设为 `WindowGroup` 的根视图
  - _需求：10.1、10.2、10.4、5.3、6.5、6.6_

- [x] 9. 最终检查点 —— 确保所有测试通过
  - 运行全部单元测试与属性测试，确保通过。如有问题请向用户反馈。

## 备注

- 标有 `*` 的子任务为可选测试任务，可跳过以加快 MVP 进度
- 每个任务均引用具体需求条款以保证可追溯性
- 属性测试使用 SwiftCheck，每个测试至少运行100次迭代
- 单元测试与属性测试互补，共同保证覆盖率
- 检查点确保每个阶段的增量验证
