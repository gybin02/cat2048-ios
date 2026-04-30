# 技术设计文档：猫咪2048 iOS

## 概述

本文档描述将 HTML/JavaScript 版猫咪2048游戏移植为 iOS 原生应用的技术设计方案。

技术栈：
- 语言：Swift 5.9+
- UI 框架：纯 SwiftUI（iOS 16+）
- 架构模式：MVVM
- 本地存储：UserDefaults
- 最低支持系统：iOS 16.0

游戏核心规则与原版保持一致：4×4网格，滑动合并相同数值方块，目标合成2048。

---

## 架构

采用 MVVM 架构，各层职责如下：

```
┌─────────────────────────────────────────────────────┐
│                     View 层                          │
│  ContentView → GameView → BoardView → TileView       │
│              ↘ ScoreHeaderView                       │
│              ↘ WinModalView                          │
│              ↘ GameOverModalView                     │
│              ↘ LeaderboardModalView                  │
└──────────────────────┬──────────────────────────────┘
                       │ @StateObject / @ObservedObject
┌──────────────────────▼──────────────────────────────┐
│                  ViewModel 层                        │
│                  GameViewModel                       │
│  - 游戏状态管理（棋盘、分数、弹窗标志）               │
│  - 移动/合并逻辑                                     │
│  - 手势方向判断                                      │
│  - 胜利/结束检测                                     │
│  - 调用 Model 层进行持久化                           │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                   Model 层                           │
│  Tile          - 方块数据模型                        │
│  ScoreRecord   - 排行榜记录模型                      │
│  StorageService - UserDefaults 持久化服务            │
│  TileTheme     - 颜色/Emoji 映射                     │
└─────────────────────────────────────────────────────┘
```

### 数据流

```
用户手势 → GameViewModel.handleSwipe(direction)
         → 移动/合并逻辑更新 board[][]
         → 检测胜利/结束
         → 更新分数 → StorageService 持久化
         → @Published 属性触发 SwiftUI 重绘
```

---

## 组件与接口

### GameViewModel

```swift
class GameViewModel: ObservableObject {
    // 状态
    @Published var board: [[Int]]          // 4×4 棋盘，0 表示空格
    @Published var score: Int
    @Published var highScore: Int
    @Published var showWinModal: Bool
    @Published var showGameOverModal: Bool
    @Published var showLeaderboard: Bool

    // 内部标志
    private var hasWon: Bool               // 同局只触发一次胜利弹窗
    private var gameEndRecorded: Bool      // 防止重复写入排行榜

    // 公开接口
    func startNewGame()
    func handleSwipe(_ direction: SwipeDirection)
    func dismissWinModal()
    func dismissGameOverModal()
    func toggleLeaderboard()

    // 内部逻辑
    private func mergeLine(_ line: [Int]) -> (result: [Int], gained: Int)
    private func applyMove(_ direction: SwipeDirection) -> Bool
    private func addRandomTile()
    private func canMove() -> Bool
    private func checkWin()
    private func checkGameOver()
}
```

### BoardView

```swift
struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel

    // 4×4 网格，使用 GeometryReader 计算方块尺寸
    // 手势通过 DragGesture 附加在整个棋盘上
}
```

### TileView

```swift
struct TileView: View {
    let value: Int
    let size: CGFloat

    // 根据 value 从 TileTheme 获取背景色、文字色、emoji
    // 右下角叠加半透明猫爪 🐾
}
```

### ScoreHeaderView

```swift
struct ScoreHeaderView: View {
    let score: Int
    let highScore: Int
    let onNewGame: () -> Void
    let onLeaderboard: () -> Void
}
```

### WinModalView

```swift
struct WinModalView: View {
    let onContinue: () -> Void   // 继续当前游戏
    let onNewGame: () -> Void    // 开始新游戏
}
```

### GameOverModalView

```swift
struct GameOverModalView: View {
    let score: Int
    let onNewGame: () -> Void
}
```

### LeaderboardModalView

```swift
struct LeaderboardModalView: View {
    let records: [ScoreRecord]
    let onClose: () -> Void
}
```

### StorageService

```swift
struct StorageService {
    static let highScoreKey = "cat2048_highScore"
    static let rankKey = "cat2048_rank"

    static func saveHighScore(_ score: Int)
    static func loadHighScore() -> Int
    static func saveLeaderboard(_ records: [ScoreRecord])
    static func loadLeaderboard() -> [ScoreRecord]   // 失败时返回5条0分默认记录
}
```

### TileTheme

```swift
struct TileTheme {
    static func backgroundColor(for value: Int) -> Color
    static func textColor(for value: Int) -> Color
    static func emoji(for value: Int) -> String
}
```

---

## 数据模型

### 棋盘

```swift
// 棋盘用二维数组表示，0 表示空格
var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
```

### ScoreRecord

```swift
struct ScoreRecord: Codable, Equatable {
    let score: Int
    let date: Date
}
```

排行榜排序规则：先按 score 降序，score 相同时按 date 升序（早的在前），最多保留5条。

### SwipeDirection

```swift
enum SwipeDirection {
    case left, right, up, down
}
```

### TileTheme 映射表

| 数值 | 背景色 | Emoji | 文字色 |
|------|--------|-------|--------|
| 2 | `#eee4da` | 😿 | 深色 `#776e65` |
| 4 | `#ede0c8` | 😺 | 深色 `#776e65` |
| 8 | `#f2b179` | 😈 | 浅色 `#f9f6f2` |
| 16 | `#f59563` | 😽 | 浅色 |
| 32 | `#f67c5f` | 😼 | 浅色 |
| 64 | `#f65e3b` | 🙀 | 浅色 |
| 128 | `#edcf72` | 😻 | 浅色 |
| 256 | `#edcc61` | 😩 | 浅色 |
| 512 | `#edc850` | 😾 | 浅色 |
| 1024 | `#edc53f` | 😈 | 浅色 |
| 2048 | `#edc22e` | 🐈⬛✨ | 浅色 |
| >2048 | `#3c3a32` | 🐈⬛✨ | 浅色 |

---

## 游戏逻辑

### 行合并算法

所有四个方向的移动都归约为"行合并"操作：

```
mergeLine([a, b, c, d]) -> ([result], gained_score)

步骤：
1. 过滤掉所有 0，得到紧凑数组
2. 从左到右扫描，相邻相同值合并（每个位置最多参与一次合并）
3. 合并后补 0 到长度4
4. 返回结果和本次合并得分
```

示例：
- `[2, 2, 2, 2]` → `[4, 4, 0, 0]`，得分 +8
- `[2, 0, 2, 4]` → `[4, 4, 0, 0]`，得分 +4
- `[2, 4, 2, 4]` → `[2, 4, 2, 4]`，得分 +0（无合并）
- `[4, 4, 4, 0]` → `[8, 4, 0, 0]`，得分 +8（只合并一次）

### 四方向移动

```
向左：对每行直接调用 mergeLine
向右：对每行 reverse → mergeLine → reverse
向上：转置矩阵 → 对每行 mergeLine → 转置回来
向下：转置矩阵 → 对每行 reverse → mergeLine → reverse → 转置回来
```

### 新增随机方块

移动后若棋盘发生变化，从所有空格（值为0）中随机选一个，以90%概率填入2，10%概率填入4。

### 游戏结束检测

```
canMove() -> Bool:
  1. 若存在任意空格（值为0），返回 true
  2. 若存在任意水平相邻的相同值，返回 true
  3. 若存在任意垂直相邻的相同值，返回 true
  4. 否则返回 false
```

---

## 手势处理

使用 `DragGesture` 附加在 `BoardView` 上：

```swift
.gesture(
    DragGesture(minimumDistance: 10)
        .onEnded { value in
            let direction = detectDirection(translation: value.translation)
            if let dir = direction {
                viewModel.handleSwipe(dir)
            }
        }
)
```

方向判断逻辑：

```swift
func detectDirection(translation: CGSize) -> SwipeDirection? {
    let dx = translation.width
    let dy = translation.height
    // 忽略小于 10pt 的滑动（minimumDistance 已处理）
    if abs(dx) > abs(dy) {
        return dx > 0 ? .right : .left
    } else {
        return dy > 0 ? .down : .up
    }
}
```

触觉反馈：在 `handleSwipe` 中，若移动有效（棋盘发生变化），调用：

```swift
let generator = UIImpactFeedbackGenerator(style: .light)
generator.impactOccurred()
```

---

## 数据持久化

### UserDefaults 键名

| 键名 | 类型 | 说明 |
|------|------|------|
| `cat2048_highScore` | Int | 历史最高分 |
| `cat2048_rank` | Data (JSON) | 排行榜数组 |

### 排行榜 JSON 格式

```json
[
  { "score": 4096, "date": 1700000000.0 },
  { "score": 2048, "date": 1699900000.0 }
]
```

`date` 字段存储 Unix 时间戳（`Date.timeIntervalSince1970`）。

### 容错处理

`loadLeaderboard()` 在以下情况返回5条0分默认记录：
- UserDefaults 中无对应键
- JSON 解码失败
- 解码结果不是数组类型

默认记录的日期依次递减一天（`Date() - i * 86400`，i = 0..4）。

---

## 正确性属性

*属性（Property）是在系统所有有效执行中都应成立的特征或行为——本质上是对系统应做什么的形式化陈述。属性是人类可读规范与机器可验证正确性保证之间的桥梁。*

### 属性 1：初始棋盘恰好有两个非零方块

*对于任意*新游戏实例，初始化后棋盘中非零方块的数量应恰好为2，且每个方块的值为2或4。

**验证需求：1.1、1.2**

### 属性 2：行合并的幂等性与正确性

*对于任意*长度为4的整数数组（表示一行），`mergeLine` 的结果应满足：
- 结果长度为4
- 非零值全部靠左排列
- 不存在两个相邻的相同非零值（即合并已完成）
- 结果中非零值的总和等于输入中非零值的总和

**验证需求：2.1、2.2、2.3、2.4、2.7**

### 属性 3：移动后棋盘变化当且仅当新增一个方块

*对于任意*棋盘状态和移动方向，若移动前后棋盘内容不同，则非零方块数量恰好增加1；若棋盘内容相同，则非零方块数量不变。

**验证需求：2.5、2.6**

### 属性 4：分数累加正确性

*对于任意*移动操作，操作后的分数增量应等于本次所有合并产生的新方块数值之和。

**验证需求：3.1、3.3**

### 属性 5：新游戏重置分数

*对于任意*游戏状态，调用 `startNewGame()` 后，`score` 应为0，`highScore` 应保持不变（不小于重置前的值）。

**验证需求：3.5**

### 属性 6：方块视觉属性映射完整性

*对于任意*有效方块数值（2、4、8、16、32、64、128、256、512、1024、2048），`TileTheme` 的三个映射函数（`backgroundColor`、`textColor`、`emoji`）应返回与需求文档一致的确定性结果，且2和4返回深色文字，其余返回浅色文字。

**验证需求：4.1、4.2、4.3**

### 属性 7：胜利状态只触发一次

*对于任意*游戏局，无论合并出多少次2048或更高数值，`hasWon` 标志在同一局中只从 `false` 变为 `true` 一次；调用 `startNewGame()` 后 `hasWon` 重置为 `false`。

**验证需求：5.1、5.2、5.4**

### 属性 8：排行榜排序与容量约束

*对于任意*数量的得分记录集合，经过排行榜更新逻辑后，结果应满足：
- 记录数量不超过5条
- 按分数降序排列
- 分数相同时按日期升序排列（早的在前）

**验证需求：6.1、6.3**

### 属性 9：游戏结束得分只记录一次

*对于任意*游戏局，游戏结束事件触发后，无论后续调用多少次检测函数，排行榜中该局得分记录只新增一条。

**验证需求：6.2、8.2、8.4**

### 属性 10：canMove 正确性

*对于任意*4×4棋盘状态，`canMove()` 应返回 `true` 当且仅当棋盘中存在空格，或存在水平/垂直方向上相邻的相同非零值。

**验证需求：8.1**

### 属性 11：持久化 Round Trip

*对于任意*最高分整数值和任意排行榜记录数组，经过 `StorageService` 的保存再加载操作后，应得到与原始值相等的数据。

**验证需求：9.1、9.2、9.3**

### 属性 12：手势方向判断阈值

*对于任意*位移向量，若其水平和垂直分量的绝对值均小于10pt，`detectDirection` 应返回 `nil`（不触发移动）。

**验证需求：7.2**

---

## 错误处理

| 场景 | 处理方式 |
|------|----------|
| UserDefaults 读取最高分失败 | 默认返回 0 |
| 排行榜 JSON 解码失败 | 返回5条0分默认记录，日期依次递减一天 |
| 棋盘已满无法新增方块 | `addRandomTile()` 静默返回，不崩溃 |
| 触觉反馈不支持 | `UIImpactFeedbackGenerator` 在不支持的设备上静默忽略 |
| 无效方块数值（如0） | `TileTheme` 返回占位色，不显示 emoji |

---

## 测试策略

### 双轨测试方法

单元测试和属性测试互补，共同保证覆盖率：
- 单元测试：验证具体示例、边界条件、错误路径
- 属性测试：通过随机输入验证普遍性规律

### 属性测试配置

使用 [SwiftCheck](https://github.com/typelift/SwiftCheck) 作为属性测试库（Swift 生态主流 PBT 库）。

每个属性测试至少运行 **100 次迭代**。

每个属性测试必须包含注释标签：
```
// Feature: cat2048-ios, Property N: <属性描述>
```

### 属性测试列表

| 测试名称 | 对应属性 | 生成器 |
|----------|----------|--------|
| `testInitialBoardHasTwoTiles` | 属性 1 | 无（固定调用 startNewGame） |
| `testMergeLineCorrectness` | 属性 2 | 随机长度4的 [Int] 数组（值为0或2的幂次） |
| `testMoveChangesBoard` | 属性 3 | 随机棋盘 + 随机方向 |
| `testScoreAccumulation` | 属性 4 | 随机可合并棋盘 |
| `testNewGameResetsScore` | 属性 5 | 随机游戏状态 |
| `testTileThemeMapping` | 属性 6 | 枚举所有有效数值 |
| `testWinTriggersOnce` | 属性 7 | 构造包含2048合并的序列 |
| `testLeaderboardSortAndCap` | 属性 8 | 随机 ScoreRecord 数组 |
| `testGameOverRecordedOnce` | 属性 9 | 随机游戏状态序列 |
| `testCanMoveCorrectness` | 属性 10 | 随机4×4棋盘 |
| `testStorageRoundTrip` | 属性 11 | 随机 Int + 随机 [ScoreRecord] |
| `testGestureThreshold` | 属性 12 | 随机小位移向量（< 10pt） |

### 单元测试列表

| 测试名称 | 覆盖场景 |
|----------|----------|
| `testMergeLineEdgeCases` | 全零行、全相同值行、[4,4,4,0] 只合并一次 |
| `testDefaultLeaderboard` | 首次加载返回5条0分记录 |
| `testCorruptedLeaderboardFallback` | 损坏 JSON 返回默认记录 |
| `testHighScoreNotDecreasedOnNewGame` | 新游戏后最高分不降低 |
| `testGameOverModalShown` | 棋盘满且无合并时显示结束弹窗 |

---

## 文件结构

```
Cat2048/
├── Cat2048App.swift              # App 入口，锁定竖屏
├── Model/
│   ├── ScoreRecord.swift         # 排行榜记录模型
│   ├── TileTheme.swift           # 颜色/Emoji 映射
│   └── StorageService.swift      # UserDefaults 持久化
├── ViewModel/
│   └── GameViewModel.swift       # 核心游戏逻辑与状态
├── View/
│   ├── GameView.swift            # 主游戏页面
│   ├── BoardView.swift           # 棋盘视图 + 手势
│   ├── TileView.swift            # 单个方块视图
│   ├── ScoreHeaderView.swift     # 顶部得分栏
│   ├── WinModalView.swift        # 胜利弹窗
│   ├── GameOverModalView.swift   # 游戏结束弹窗
│   └── LeaderboardModalView.swift # 排行榜弹窗
└── Cat2048Tests/
    ├── MergeLogicTests.swift     # 合并算法单元测试
    ├── GameViewModelTests.swift  # ViewModel 状态测试
    ├── StorageServiceTests.swift # 持久化测试
    └── PropertyTests.swift       # SwiftCheck 属性测试
```
