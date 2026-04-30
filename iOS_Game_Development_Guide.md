# iOS 休闲游戏开发指南

> 基于实际讨论整理，面向有 iOS/Swift 开发经验、零游戏开发经验的开发者。

---

## 一、引擎选择

### 对有 Swift 经验的 iOS 开发者，推荐 SpriteKit

- Apple 官方框架，Swift 原生，零切换成本
- 内置物理引擎（`SKPhysicsBody`），弹弓抛物线、碰撞检测开箱即用
- 与 UIKit/SwiftUI 无缝集成
- 不需要额外工具链，Xcode 直接开发

### 主流引擎对比

| 引擎 | 语言 | 跨平台 | 2D能力 | 3D能力 | 学习成本（对Swift开发者）| 免费程度 |
|---|---|---|---|---|---|---|
| SpriteKit | Swift | 仅 Apple | ⭐⭐⭐ | ❌ | 低 | 免费 |
| Unity | C# | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 中 | 基本免费 |
| Godot | GDScript/C# | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 中 | 完全免费 |
| Cocos Creator | JS/TS | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | 高 | 免费 |

### 选择建议

- 只做 iOS，快速出原型 → **SpriteKit**
- 想同时发 Android，长期做游戏 → **Unity**
- 开源党，做 2D 独立游戏 → **Godot**
- 做微信小游戏 → **Cocos Creator**

---

## 二、SpriteKit 核心概念

### 节点树结构

```
SKView（UIView 子类）
  └── SKScene（场景/关卡）
        ├── SKSpriteNode（图片精灵）
        ├── SKLabelNode（文字）
        ├── SKShapeNode（几何形状）
        └── SKNode（空节点，用于分组）
```

### 坐标系
- 原点在**左下角**，Y 轴向上（与 UIKit 相反）

### 关键 API 速查

```swift
// 物理体
node.physicsBody = SKPhysicsBody(circleOfRadius: 20)
node.physicsBody?.applyImpulse(CGVector(dx: 300, dy: 400))

// 动作系统
let move = SKAction.move(to: point, duration: 0.5)
let fade = SKAction.fadeOut(withDuration: 0.3)
node.run(SKAction.sequence([move, fade]))

// 碰撞检测
class GameScene: SKScene, SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) { }
}

// 每帧更新
override func update(_ currentTime: TimeInterval) { }
```

### 与 SwiftUI 混用

```swift
struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = GameScene(size: UIScreen.main.bounds.size)
        view.presentScene(scene)
        return view
    }
    func updateUIView(_ uiView: SKView, context: Context) {}
}
```

### UI 分工建议

| 界面 | 推荐技术 |
|---|---|
| 主菜单、设置、关卡选择 | SwiftUI |
| 游戏内 HUD（分数/暂停） | SKLabelNode / SKSpriteNode |
| 游戏内弹窗 | SKScene 叠加层 |
| 结算页 | SwiftUI sheet |

---

## 三、SpriteKit 劣势

1. **平台锁定**：只支持 Apple 平台，Android 市场（70%+）完全放弃
2. **无可视化关卡编辑器**：策划无法独立工作，全靠程序员
3. **生态匮乏**：没有类似 Unity Asset Store 的资源市场
4. **更新缓慢**：Apple 不重视，核心功能多年无大更新
5. **缺少高级功能**：寻路、骨骼动画、网络多人等需自行实现
6. **调试工具弱**：性能分析不如 Unity Profiler 直观

---

## 四、游戏设计核心知识

### 核心游戏循环（Core Loop）

```
行动 → 反馈 → 奖励 → 再行动
```

愤怒的小鸟示例：`瞄准发射 → 碰撞效果 → 消灭猪/得分 → 下一关`

设计原则：循环要短（30秒内），反馈要即时，奖励要清晰。

### 关卡设计：3-3-3-1 结构

```
关卡 1-3：新手区（教学，必须成功）
关卡 4-6：进阶区（引入新机制）
关卡 7-9：熟练区（组合挑战）
关卡 10 ：高潮关（综合考验 + 特别庆祝）
```

**黄金法则：**
- 每关只引入一个新概念
- 每 3 关设一个喘息关
- 三星标准：1星=通关，2星=少用资源，3星=完美清场

### 难度曲线

```
难度 ↑
     |                    ★ 10
     |               ● 9
     |          ● 8
     |     ● 7
     |  ●      ↘喘息
     |●
     +------------------------→ 关卡
      1 2 3 4 5 6 7 8 9 10
```

### 休闲游戏设计原则

- 一只手可以玩（单手操作）
- 5 秒内能上手（无需教程）
- 失败不惩罚（死了立刻重来）
- 会话长度可控（随时可停）
- 离线可玩

---

## 五、手感打磨

### 音效

```swift
let sound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
node.run(sound)
```

- 每个交互都要有声音（发射、飞行、碰撞、破碎、消灭）
- 碰撞力度不同，音效要有变化
- 免费资源：[freesound.org](https://freesound.org)、[kenney.nl](https://kenney.nl)

### 震动（Haptics）

```swift
// 碰撞
UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

// 通关
UINotificationFeedbackGenerator().notificationOccurred(.success)

// 失败
UINotificationFeedbackGenerator().notificationOccurred(.error)
```

### 摄像机震动

```swift
func shakeCamera(intensity: CGFloat = 10, duration: Double = 0.3) {
    var actions: [SKAction] = []
    for _ in 0..<6 {
        let dx = CGFloat.random(in: -intensity...intensity)
        let dy = CGFloat.random(in: -intensity...intensity)
        actions.append(SKAction.moveBy(x: dx, y: dy, duration: duration / 6))
    }
    actions.append(SKAction.move(to: .zero, duration: 0.1))
    camera?.run(SKAction.sequence(actions))
}
```

### 慢动作

```swift
physicsWorld.speed = 0.2  // 关键碰撞时拉慢
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    self.physicsWorld.speed = 1.0
}
```

### 手感打磨优先级

1. 音效（最快，效果最明显）
2. 摄像机震动
3. 粒子爆炸
4. 震动反馈
5. 慢动作 + 飘字

---

## 六、变现策略

### 方案对比

| 方案 | 优点 | 缺点 | 适合场景 |
|---|---|---|---|
| 买断制（$0.99-$2.99）| 体验好，无打扰 | 下载量低 | 精品游戏 |
| 免费+广告 | 下载门槛低 | 体验有打扰 | 高下载量游戏 |
| 免费+内购 | 收入上限高 | 设计复杂 | 有持续内容更新 |

### 第一款游戏推荐组合

```
免费下载
  + 激励视频广告（自愿看，换奖励）
  + 插屏广告（每 3 关一次）
  + $2.99 一次性去广告
  + 关卡包内购（$0.99 解锁额外 10 关）
```

### 变现时机设计

```
下载 → 玩3关（不打扰）
→ 第4关结束：第一次插屏广告
→ 关卡失败：弹出"看广告复活"
→ 第10关通关：弹出"解锁更多关卡"
→ 第15关：弹出去广告优惠
```

**绝对不要做：** 第1关就弹广告、强制插屏（无关闭按钮）、付费墙卡关键剧情。

---

## 七、用户留存设计

### 留存核心指标

```
次日留存（Day 1）：游戏够不够好玩
7日留存（Day 7） ：有没有理由回来
30日留存（Day 30）：有没有长期目标
```

### 连续登录奖励

```
Day 1: 小奖励
Day 2-6: 递增奖励
Day 7: 最大奖励（稀有道具/皮肤）← 驱动7日留存
```

### 每日任务（3个，10-15分钟完成）

```swift
struct DailyTask {
    let description: String
    let target: Int
    var progress: Int
    let reward: Reward
    let expiresAt: Date  // 明天0点
}
```

### 成就系统分类

- **进度成就**：完成第1关、完成10关（给所有玩家）
- **技巧成就**：一发消灭3只猪、连续5关三星（给核心玩家）
- **隐藏成就**：意外触发，制造惊喜

### 第一款游戏留存优先级

```
必做：连续登录奖励 + 每日3任务 + 基础成就
有余力：赛季活动关卡 + Game Center 排行榜
成熟期：好友系统 + PVP
```

---

## 八、塔防游戏核心实现（Kingdom Rush 拆解）

### 路径系统

```swift
// 敌人沿路径点移动
class Enemy: SKSpriteNode {
    var waypointIndex = 0

    func moveToNextWaypoint(path: LevelPath) {
        guard waypointIndex < path.waypoints.count else {
            reachCastle(); return
        }
        let target = path.waypoints[waypointIndex].position
        let distance = hypot(target.x - position.x, target.y - position.y)
        let move = SKAction.move(to: target, duration: TimeInterval(distance / speed))
        let next = SKAction.run { [weak self] in
            self?.waypointIndex += 1
            self?.moveToNextWaypoint(path: path)
        }
        run(SKAction.sequence([move, next]))
    }
}
```

### 目标选择策略

```swift
enum TargetStrategy {
    case first      // 最靠近终点（默认）
    case strongest  // 血量最多
    case weakest    // 血量最少
    case closest    // 距离塔最近
}
```

### Kingdom Rush 设计亮点

- 塔的分支升级（两条路线，不同策略）
- 英雄单位（玩家手动操控的强力单位）
- 全局技能（空袭/召唤，有冷却，关键时刻救场）

---

## 九、成功案例参考

### SpriteKit
- **isowords**（[github.com/pointfreeco/isowords](https://github.com/pointfreeco/isowords)）— 真实上架 App Store 的单词游戏，完整商业级代码，MIT 开源

### Godot
- **Brotato** — 单人开发，Steam 收入超 $1000 万，销量超 1000 万份
- **Cassette Beasts** — 怪物收集 RPG，上架 Xbox Game Pass
- **Dome Keeper** — 挖矿防守，Steam 热销

### 历史案例
- **Kingdom Rush** — 原版 Flash，Steam 版 Unity，移动版自研
- **植物大战僵尸** — PopCap 自研框架（2009年，无第三方引擎）
- **愤怒的小鸟** — Rovio 自研引擎

> 爆款游戏的成功从来不是因为用了什么引擎，而是游戏设计本身。

---

## 十、开源参考项目

| 项目 | 技术 | 说明 |
|---|---|---|
| [MakeSchool-Tutorials/Orange-Tree](https://github.com/MakeSchool-Tutorials/Orange-Tree-SpriteKit-Swift4) | SpriteKit | 愤怒的小鸟同类，教程配套，代码质量好 |
| [dscyrescotti/Hoop](https://github.com/dscyrescotti/Hoop) | SpriteKit+SwiftUI | 篮球投篮，混用架构参考 |
| [pointfreeco/isowords](https://github.com/pointfreeco/isowords) | SwiftUI+SceneKit | 商业级架构，MIT |
| [cocoatoucher/Glide](https://github.com/cocoatoucher/Glide) | SpriteKit | 2D游戏框架，MIT，可商用 |
| [twostraws/ShaderKit](https://github.com/twostraws/ShaderKit) | SpriteKit | 视觉特效着色器库，MIT |

---

## 十一、推荐学习资源

### 书籍
- 《The Art of Game Design》Jesse Schell — 游戏设计圣经

### 视频
- [Game Maker's Toolkit](https://www.youtube.com/@GMTK) — 游戏设计分析，强烈推荐
- GDC Vault — 搜索 "Juice it or Lose it"（手感设计经典演讲）

### 免费美术/音效资源
- [kenney.nl](https://kenney.nl) — 游戏专用免费资源，完全商用
- [freesound.org](https://freesound.org) — 免费音效库

### 广告 SDK
- Google AdMob — 填充率最高
- AppLovin MAX — 聚合多家，收益更高

---

*整理日期：2026-04-30*
