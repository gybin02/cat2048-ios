# 需求文档

## 简介

将基于 HTML/JavaScript 的猫咪2048游戏移植为 iOS 原生应用。游戏采用 4×4 网格，玩家通过滑动手势合并相同数字的方块，目标是合成数值为 2048 的方块。移植版本需保留原版全部功能，并充分利用 iOS 平台特性（原生手势、UserDefaults 本地存储、SwiftUI 动画等）。

**技术选型确认：**
- UI 框架：SwiftUI（纯 SwiftUI，不使用 SpriteKit）
- 游戏结束提示：弹窗形式
- 退出后不恢复棋盘状态（每次启动重新开始）

---

## 词汇表

- **Game**：游戏主体，负责协调所有子系统
- **Board**：4×4 游戏棋盘，管理所有方块的位置与数值
- **Tile**：棋盘上的单个方块，携带数值与对应的猫咪 emoji
- **Score_Manager**：负责当前分数与最高分的计算和持久化
- **Leaderboard**：排行榜，存储并展示前5名历史得分记录
- **Win_Modal**：胜利弹窗，在玩家合成2048时显示
- **Gesture_Handler**：处理上下左右四方向滑动手势
- **Storage**：iOS 本地持久化层（UserDefaults）

---

## 需求

### 需求 1：游戏棋盘初始化

**用户故事：** 作为玩家，我希望启动游戏时看到一个已初始化的4×4棋盘，以便立即开始游戏。

#### 验收标准

1. WHEN 游戏启动，THE Board SHALL 创建一个4×4的空白网格
2. WHEN 游戏启动，THE Board SHALL 在随机两个空格中各放置一个初始方块（数值为2或4，其中数值2的概率为90%，数值4的概率为10%）
3. THE Board SHALL 将所有空格显示为背景色 `#eee4da` 的占位格
4. WHEN 点击"新游戏"按钮，THE Board SHALL 清空所有方块并重新执行初始化流程

---

### 需求 2：方块移动与合并

**用户故事：** 作为玩家，我希望通过滑动手势移动方块，以便合并相同数字并推进游戏进程。

#### 验收标准

1. WHEN 玩家向左滑动，THE Board SHALL 将每行所有方块向左移动并合并相邻的相同数值方块
2. WHEN 玩家向右滑动，THE Board SHALL 将每行所有方块向右移动并合并相邻的相同数值方块
3. WHEN 玩家向上滑动，THE Board SHALL 将每列所有方块向上移动并合并相邻的相同数值方块
4. WHEN 玩家向下滑动，THE Board SHALL 将每列所有方块向下移动并合并相邻的相同数值方块
5. WHEN 一次移动导致棋盘状态发生变化，THE Board SHALL 在随机一个空格中新增一个数值为2或4的方块
6. WHEN 一次移动未导致棋盘状态发生变化，THE Board SHALL 不新增方块也不更新分数
7. THE Board SHALL 在同一行/列的一次移动中，每个方块最多参与一次合并

---

### 需求 3：得分系统

**用户故事：** 作为玩家，我希望实时看到当前得分和历史最高分，以便了解自己的游戏表现。

#### 验收标准

1. WHEN 两个方块合并，THE Score_Manager SHALL 将合并后方块的数值累加到当前得分
2. THE Score_Manager SHALL 在界面顶部实时显示当前得分
3. WHEN 当前得分超过历史最高分，THE Score_Manager SHALL 更新最高分并通过 Storage 持久化到 UserDefaults
4. THE Score_Manager SHALL 在界面顶部持续显示历史最高分
5. WHEN 玩家开始新游戏，THE Score_Manager SHALL 将当前得分重置为0，最高分保持不变

---

### 需求 4：猫咪主题视觉呈现

**用户故事：** 作为玩家，我希望每个数值的方块都有独特的猫咪 emoji 和背景色，以便获得有趣的视觉体验。

#### 验收标准

1. THE Tile SHALL 根据数值显示对应的背景色，映射关系如下：2→`#eee4da`、4→`#ede0c8`、8→`#f2b179`、16→`#f59563`、32→`#f67c5f`、64→`#f65e3b`、128→`#edcf72`、256→`#edcc61`、512→`#edc850`、1024→`#edc53f`、2048→`#edc22e`
2. THE Tile SHALL 根据数值显示对应的猫咪 emoji，映射关系如下：2→😿、4→😺、8→😈（猫）、16→😽、32→😼、64→🙀、128→😻、256→😩（猫）、512→😾、1024→😈、2048→🐈⬛✨
3. THE Tile SHALL 对数值为2和4的方块使用深色文字（`#776e65`），对其余数值使用浅色文字（`#f9f6f2`）
4. THE Tile SHALL 在方块右下角显示半透明的猫爪装饰图标

---

### 需求 5：胜利弹窗

**用户故事：** 作为玩家，我希望合成2048时看到胜利提示，以便获得成就感。

#### 验收标准

1. WHEN 任意两个方块合并后数值达到2048，THE Win_Modal SHALL 显示胜利弹窗
2. THE Win_Modal SHALL 在同一局游戏中只显示一次（即使后续继续合成出更高数值）
3. WHEN 玩家点击胜利弹窗中的确认按钮，THE Win_Modal SHALL 关闭弹窗并允许玩家继续当前游戏
4. WHEN 玩家点击"新游戏"按钮，THE Win_Modal SHALL 关闭弹窗并重置游戏状态

---

### 需求 6：排行榜

**用户故事：** 作为玩家，我希望查看历史前5名得分记录，以便追踪自己的最佳成绩。

#### 验收标准

1. THE Leaderboard SHALL 通过 Storage 持久化存储最多5条历史得分记录，每条记录包含分数和日期
2. WHEN 游戏结束（棋盘无法继续移动）且当前得分大于0，THE Leaderboard SHALL 自动将当前得分记录写入排行榜
3. THE Leaderboard SHALL 按分数从高到低排序，分数相同时按记录时间从早到晚排序，并只保留前5条
4. WHEN 本地无排行榜数据，THE Leaderboard SHALL 初始化5条得分为0的默认记录，日期依次递减一天
5. WHEN 玩家点击"排行榜"按钮，THE Leaderboard SHALL 显示排行榜弹窗，列出当前前5名记录（含排名、分数、日期）
6. WHEN 玩家点击关闭按钮或弹窗背景区域，THE Leaderboard SHALL 关闭排行榜弹窗

---

### 需求 7：iOS 手势交互

**用户故事：** 作为 iOS 用户，我希望通过自然的滑动手势操控游戏，以便获得流畅的原生体验。

#### 验收标准

1. THE Gesture_Handler SHALL 识别上、下、左、右四个方向的滑动手势（swipe gesture）
2. WHEN 滑动距离小于10pt，THE Gesture_Handler SHALL 忽略该手势，不触发方块移动
3. THE Gesture_Handler SHALL 支持多点触控环境下的单指滑动操作
4. WHERE 设备支持触觉反馈（Haptic Feedback），THE Gesture_Handler SHALL 在每次有效移动时触发轻量级触觉反馈

---

### 需求 8：游戏结束检测

**用户故事：** 作为玩家，我希望游戏在无法继续时给出提示，以便了解游戏已结束。

#### 验收标准

1. WHEN 棋盘已满且不存在任何相邻相同数值的方块，THE Game SHALL 判定游戏结束
2. WHEN 游戏结束，THE Game SHALL 自动触发得分记录写入排行榜（若得分大于0）
3. WHEN 游戏结束，THE Game SHALL 以弹窗形式向玩家展示游戏结束提示，弹窗包含当前得分并提供"新游戏"按钮
4. THE Game SHALL 确保同一局游戏的结束得分只被记录一次

---

### 需求 9：本地数据持久化

**用户故事：** 作为玩家，我希望最高分和排行榜数据在退出应用后仍然保留，以便下次继续查看。

#### 验收标准

1. THE Storage SHALL 使用 UserDefaults 持久化存储最高分，键名为 `cat2048_highScore`
2. THE Storage SHALL 使用 UserDefaults 持久化存储排行榜数据（JSON 格式），键名为 `cat2048_rank`
3. WHEN 应用重新启动，THE Storage SHALL 从 UserDefaults 读取并恢复最高分和排行榜数据
4. IF UserDefaults 中的排行榜数据格式无效，THEN THE Storage SHALL 忽略损坏数据并使用默认的5条0分记录初始化

---

### 需求 10：界面布局与适配

**用户故事：** 作为 iOS 用户，我希望游戏界面在不同尺寸的 iPhone 上都能正常显示，以便在任何设备上流畅游玩。

#### 验收标准

1. THE Game SHALL 支持 iPhone SE（4.7英寸）至 iPhone Pro Max（6.7英寸）全系列屏幕尺寸
2. THE Board SHALL 根据屏幕宽度自适应调整棋盘和方块尺寸，确保4×4网格完整显示
3. THE Game SHALL 支持竖屏（Portrait）方向，锁定横屏以保证布局一致性
4. THE Game SHALL 遵循 iOS 安全区域（Safe Area）规范，避免内容被刘海或底部指示条遮挡
