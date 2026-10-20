# 卡片 Schema（card-schema.md）

九类卡的完整字段定义与 `status` 生命周期。所有卡片必须包含"通用五字段"；
各类型专属字段列在下方。

## 通用五字段（必备）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 卡片唯一标识，含类型前缀，全局唯一 |
| `type` | enum | `character` / `plotpoint` / `item` / `scene` / `foreshadow` / `relationship` / `faction` / `snapshot` / `darklayer` |
| `status` | enum | 卡片生命周期状态，见"状态生命周期"节 |
| `created` | date | 首次创建时间（ISO 8601） |
| `updated` | date | 最近一次更新时间（ISO 8601） |

## 状态生命周期

一般卡片（除 foreshadow 与 darklayer 外）：

```
draft → active → archived
```

- `draft`：初稿，正在完善中
- `active`：已进入正文使用，是主书的一部分
- `archived`：已废弃或替换，保留历史不删除

## 九类卡专属字段

### character（人物卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 显示名 |
| `aliases` | ❌ | 别名字符串数组 |
| `faction` | ❌ | 所属势力 id |
| `first_appearance` | ✅ | 首次出场章节 |
| `role` | ✅ | `protagonist` / `deuteragonist` / `antagonist` / `supporting` |
| `age` | ❌ | 年龄或年龄段 |

### plotpoint（桥段卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `chapter` | ✅ | 所在章节 |
| `summary` | ✅ | 一句话摘要 |
| `participants` | ✅ | 相关人物 id 数组 |
| `pivotal` | ❌ | 是否关键转折（boolean） |

### item（道具卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 道具名 |
| `owner` | ❌ | 当前持有者 id（可能为空表示无主） |
| `origin` | ✅ | 来源描述 |
| `power` | ❌ | 特殊能力描述 |
| `last_seen` | ✅ | 最近出现章节 |

### scene（场景卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 场景名 |
| `location` | ✅ | 地理或叙事位置描述 |
| `first_appearance` | ✅ | 首次出现章节 |
| `recurrence` | ❌ | 是否重复出现 |

### foreshadow（伏笔卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 伏笔简述 |
| `planted_at` | ✅ | 埋设章节 |
| `payoff_chapter` | 条件必填 | 回收章节（与 `status: unresolved` 二选一） |
| `seed_character` | ❌ | 埋设人物 id |
| `related_items` | ❌ | 相关道具 id 数组 |
| `reveal_tier` | ❌ | `early` / `mid` / `finale` 暗示回收时机 |

**硬规则约束**：`status: resolved` 时必须有 `payoff_chapter`；
`status: unresolved` 时 `payoff_chapter` 可缺。详见 `hard-rules.md` 规则 3。

### relationship（关系动态卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `from` | ✅ | 关系起点人物 id |
| `to` | ✅ | 关系终点人物 id |
| `nature` | ✅ | 关系性质文本描述 |
| `arcs` | ✅ | 关系变化轨迹数组（每项含 `chapter` / `state`） |
| `current_state` | ✅ | 当前关系快照 |

### faction（势力卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 势力名 |
| `leader` | ❌ | 领袖人物 id |
| `members` | ❌ | 成员人物 id 数组 |
| `goals` | ✅ | 势力目标描述 |
| `influence` | ❌ | 影响范围文本 |

### snapshot（状态快照卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `chapter` | ✅ | 快照对应的章节 |
| `focus` | ✅ | 快照关注点（`world` / `faction` / `character-arc` 等） |
| `summary` | ✅ | 快照正文摘要 |
| `related_cards` | ✅ | 关联卡片 id 数组 |

### darklayer（暗线卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 暗线主题名 |
| `truth` | ✅ | 真相摘要（读者不可见的核心信息） |
| `surface_hint` | ✅ | 表面层如何暗示此暗线 |
| `references_to_main` | ✅ | 显式引用主书卡片 id 的数组（**唯一允许的连接方式**） |
| `reveal_chapter` | ❌ | 计划回收章节（未定时省略） |
| `reveal_tier` | ❌ | 揭示强度：`hint` / `hinted` / `confirmed` / `revealed` |

**硬规则约束**：暗线卡必须位于 `cards/darklayer/`；id 必须以 `dk-` 开头；
与主书卡片只通过 `references_to_main` 单向串接。详见 `hard-rules.md` 规则 4。

## 字段命名规范

- 一律 snake_case
- 数组字段命名用复数（`participants` / `members` / `arcs`）
- 引用其他卡 id 的字段命名 `xxx_id` 或复数 `xxx_ids`（如 `faction` 直接用 string，`members` 用 array）
- 时间字段统一 ISO 8601：`2025-01-15` 或 `2025-01-15T10:30:00Z`

## 字段示例

一份完整的 character 卡：

```yaml
---
id: ch-jiang-li
type: character
status: active
created: 2025-01-15
updated: 2025-02-20
name: 姜璃
aliases: [小璃, 阿璃]
faction: fa-shenzhi-hui
first_appearance: chapter-003
role: protagonist
age: 24
---

## 性格

外冷内热，理性至上，但在关键时刻会突破既定判断。

## 目标

- 短期：查明孤儿院失踪事件真相
- 长期：建立独立调查网络

## 关系

- 与 `ch-su-ye` 是师徒，见 `rel-shi-tu`
```
