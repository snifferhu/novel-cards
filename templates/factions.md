---
id: fa-<slug>
type: faction
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: 势力-甲
members: []
territory: <地域范围>
conflicts: []
---

# 势力-甲

## 一句话

<这个势力是什么、在故事中扮演什么角色。>

## 核心成员

- `<ac-xxx>` — <角色定位>（actor id，前缀 ac-）
- `<ac-yyy>` — <角色定位>

## 组织结构

- **领袖**：<谁名义上/实际上掌握决策权>
- **层级**：<是否有明确等级 / 派系>
- **外部关系**：<与哪些势力盟友 / 敌对>

## 领地 / 势力范围

- <地域>
- <象征性地盘：某个场景 `sc-xxx`>

## 冲突与博弈

- 与 `<fa-yyy>`：<关系性质>
- 与 `<ac-xxx>`：<个人冲突>（actor id，前缀 ac-）

## 兴衰弧线

- <起点状态>
- <转折点：章节-00X>
- <当前状态>
- <预期走向>

## 暗线视角

- 势力是否被暗线渗透 / 操控：<参见 darklayer 卡 `dk-xxx`>

## 关系网络与推演基线增强（可选字段）

deep 模式 SHALL 校验敌对势力友好行为、盟友互相损害利益等逻辑矛盾；可 `override_note`
标记伪装 / 秘密交易豁免。新字段全部可选，缺失时 MUST 按现有行为处理（向后兼容）。

| 字段 | 类型 | 说明 |
|---|---|---|
| `core_purpose` | string | 势力核心目的（如「守护家族秘密」/「夺取武林盟主」） |
| `core_rule` | string | 势力核心规则（如「不杀同门」/「事不过三」） |
| `value_axis` | string | 价值取向轴（如「秩序 vs 自由」/「忠诚 vs 利益」） |
| `leader_actor_id` | string | 领袖角色 id（ac-*），与既有 `members[]` 互补（members 含全部成员，leader 单指决策者） |
| `relation_map[]` | array | 关系网络数组，每条含 `target_faction_id`（fa-*）/ `relation_type`（`ally` / `rival` / `hostile` / `subordinate` / `secret_collude`）/ `relation_note`（关系备注） |
| `signature_cue_ids[]` | array | 感官招牌 id 数组（su-*），该势力的标志性氛围信号 |
| `default_reaction` | string | 默认反应模式（如「先礼后兵」/「直接动手」） |
| `restraint_factor` | string | 克制因素（如「忌惮对方长老」/「受盟约约束」） |
| `inner_factions[]` | array | 内部派系数组，每条含 `sub_faction_name` / `advocate`（主张）/ `leader_id`（ac-*）/ `divergence_note`（分歧点） |
| `controlled_prop_ids[]` | array | 控制的道具 id 数组（it-*） |
| `controlled_scene_ids[]` | array | 控制的场景 id 数组（sc-*） |

### 最小示例（逍遥派，假名占位）

```yaml
name: 逍遥派
members: [ac-角色-甲, ac-角色-丙]
territory: 东海之滨·逍遥岛
conflicts: [fa-对手-乙]
core_purpose: 守护上古秘典，维持江湖平衡
core_rule: 不主动涉入中原纷争，但弟子若遭挑衅必以牙还牙
value_axis: 自由 vs 秩序（偏自由，但底线是秘典不可外泄）
leader_actor_id: ac-角色-甲
relation_map:
  - target_faction_id: fa-对手-乙
    relation_type: hostile
    relation_note: 争夺上古秘典，已交手三次
  - target_faction_id: fa-盟友-丙
    relation_type: ally
    relation_note: 三十年前结盟，互不侵犯
  - target_faction_id: fa-暗面-丁
    relation_type: secret_collude
    relation_note: 表面无往来，暗中交换情报
signature_cue_ids: [su-island-breeze]
default_reaction: 先观察三日，确认意图后再决定应对
restraint_factor: 忌惮 fa-对手-乙 背后的世家支持
inner_factions:
  - sub_faction_name: 守秘派
    advocate: 秘典绝不可示人，宁可毁掉也不外传
    leader_id: ac-角色-丙
    divergence_note: 与掌门「以秘典制衡江湖」路线存在根本分歧
controlled_prop_ids: [it-上古秘典]
controlled_scene_ids: [sc-逍遥岛]
```
