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

## 多视角与客观真相增强（可选字段）

deep 模式 SHALL 对比各 POV 描述与 `objective_fact`，检查无法解释的硬矛盾；认知偏差属
正常主观滤镜不告警；矛盾可 `override_note` 标记幻境 / 错觉豁免。新字段全部可选，缺失时
MUST 按现有行为处理（向后兼容）。时间锚点状态切片定位不变。

| 字段 | 类型 | 说明 |
|---|---|---|
| `beat_id` | string | 依附桥段 id（pp-*），本快照定格该桥段的瞬时状态 |
| `moment_tag` | enum | 时刻标签：`实拍` / `回忆` / `幻觉` / `传闻` / `梦境`（非实拍时 deep 模式放宽矛盾校验） |
| `base_space_id` | string | 基础场景 id（sc-*），SPACE_001 空间校验依据 |
| `active_cue_ids[]` | array | 此刻活跃的感官标记 id 数组（su-*） |
| `active_props[]` | array | 此刻活跃道具 id 数组（it-*） |
| `perspectives[]` | array | 多视角数组，每条含以下字段 |
| `perspectives[].pov_actor_id` | string | 视角角色 id（ac-*） |
| `perspectives[].perception_text` | string | 该视角的感知描述文本 |
| `perspectives[].cognition_bias` | string | 认知偏差（如「放大对方攻击性」/「选择性忽略威胁」） |
| `perspectives[].focus_point` | string | 注意力焦点（如「对方手中的玉佩」） |
| `perspectives[].known_info[]` | array | 该角色已知信息列表 |
| `perspectives[].unknown_info[]` | array | 该角色未知信息列表（信息差来源） |
| `objective_fact` | string | 客观真相（独立于任何 POV 的事实描述，deep 模式矛盾校验基准） |
| `reuse_plans` | object | 复用计划：`recall_beat_ids[]`（后续回忆桥段 pp-*）/ `retell_by_actor_ids[]`（后续转述角色 ac-*） |

### 最小示例（车内争吵双视角，假名占位）

```yaml
chapter: chapter-012
focus: scene
summary: 密闭车厢内角色-甲与角色-乙因旧玉佩归属爆发争执的瞬时定格
used_pose: po-斜倚握扇
related_cards: [ac-角色-甲, ac-角色-乙, it-旧青玉佩, sc-车厢]
timeline_state: climax
prev_snapshot: sn-chapter-011-end
beat_id: pp-车内争吵
moment_tag: 实拍
base_space_id: sc-车厢
active_cue_ids: [su-jade-warm-01]
active_props: [it-旧青玉佩]
perspectives:
  - pov_actor_id: ac-角色-甲
    perception_text: 觉得对方在挑衅，目光里满是轻蔑
    cognition_bias: 放大对方攻击性
    focus_point: 对方紧握玉佩的手
    known_info: [对方一直想要这块玉佩, 对方上次偷过自己东西]
    unknown_info: [对方内心其实是恐惧而非挑衅, 对方手里有己方把柄]
  - pov_actor_id: ac-角色-乙
    perception_text: 觉得对方在炫耀，语气居高临下
    cognition_bias: 将防御姿态解读为傲慢
    focus_point: 对方斜倚的姿态
    known_info: [玉佩是家族遗物, 对方声称有继承权]
    unknown_info: [对方正在暗中调查玉佩来历, 对方已找到关键证据]
objective_fact: 双方均无动手意图，争执源于对玉佩归属的信息不对称；角色-甲实际在克制情绪，角色-乙实际在试探底线
reuse_plans:
  recall_beat_ids: [pp-第三章回忆]
  retell_by_actor_ids: [ac-角色-丙]
```
