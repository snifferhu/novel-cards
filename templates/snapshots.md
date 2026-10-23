---
id: sn-<slug>
type: snapshot
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
chapter: chapter-001       # 快照对应的章节锚点（时间轴上的钉点）
focus: world               # 快照关注点：world / faction / character-arc / scene 等
summary: <快照正文摘要>
used_pose: null            # 引用姿态卡 id（po-*），校阅时校验「此刻状态能否支撑该 pose」
related_cards: []          # 关联卡片 id 数组
timeline_state: initial    # initial / developing / climax / falling_action / resolved / interlude
prev_snapshot: null        # 前一份快照 id，形成快照链
---

# 快照 · <chapter-001>

> **定义**：`snapshot`（`sn-`）是**时间锚点全局状态切片**——在某确定章节/时间锚点上，
> 一套锁定的、瞬时的全局状态定格；可单聚焦 actor，也可定格场景内多方角色/道具/势力/
> 动线状态。用途：前后对比、校验逻辑（"这一刻角色知不知道秘密？伤势多重？手里拿着什么？"）。
>
> **❌ 不是**：姿势库、插画、动态素材库。
>
> **与 timeline 的区别**：timeline = 变化过程（曲线）；snapshot = 时间轴上钉点，拍下此刻
> 所有变量值。pose 卡的 P2 插槽填充默认从当前时间锚点的 snapshot 自动读取状态。

## 一句话

<这一时间点世界处于什么状态。>

## 时间线状态

`timeline_state` 建议值：`initial`（起点）/ `developing` / `climax` /
`falling_action` / `resolved` / `interlude`。

## 关键实体当前状态（多方定格示例）

### 人物（引用 `cards/characters/`）

- `<ac-xxx>` — 位置：<...> · 伤势：<...> · 知情状态：<知道/不知道某秘密> · 关系变化：<...>

### 道具（引用 `cards/items/`）

- `<it-xxx>` — 持有者：<ac-xxx> · 状态：<arc 值> · 手中是否握持：<是/否>

### 场景（引用 `cards/scenes/`）

- `<sc-xxx>` — 事件：<发生了什么> · 环境参数：<光照/温度/声响基调>

### 势力（引用 `cards/factions/`）

- `<fa-xxx>` — 状态：<强盛 / 分化 / 瓦解>

### 未回收伏笔（引用 `cards/foreshadow/`）

- `<fs-xxx>` — 状态：planted / developing

## 姿态引用（used_pose）

- `used_pose: po-<slug>` —— 本快照定格的角色姿态；`nc-校阅` 校验「此刻
  伤势/环境状态能否支撑该 pose」（如水下不可鼓腮，冲突进入意见书不自动改文字）。

## 与前一份快照的差异

- **人物变化**：<...>
- **道具变化**：<...>
- **势力变化**：<...>
- **伏笔变化**：<...>

## 下一份快照计划

- 计划时间点：<chapter-00X>
