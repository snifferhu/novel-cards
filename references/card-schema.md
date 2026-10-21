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

## 八类卡专属字段

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

### timeline（动线卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 动线主题名（如"青铜钥匙的流向"、"姜璃的成长弧线"） |
| `track` | ✅ | 追踪对象类型：`character` / `item` / `faction` / `place` / `other` |
| `target` | 条件必填 | 追踪对象 id（`ch-*` / `it-*` / `fa-*` / `sc-*`；`track: other` 时可省） |
| `first_seen` | ✅ | 首次出现章节 |
| `mentions` | ❌ | 简要关系交汇点数组（每项含对象 id + 一段话说清交汇） |
| `graph` | ❌ | 关联图谱 HTML 相对路径（如 `graph/tl-bronze-key-graph.html`） |
| `reveal_tier` | ❌ | 揭示强度：`hint` / `hinted` / `confirmed` / `revealed`（若为暗线动线） |

**动线卡与关系图的关系**：

- 动线卡追踪**单一对象**跨章节、跨场景的完整轨迹
- `mentions` 段记录该对象与其他对象的**简要交汇**，不做详细展开
- 复杂交互（多对象、多类型、含暗示关系）放 `graph/` 目录下 HTML 图谱
- 动线卡通过 `graph` 字段（可选）显式指向对应图谱文件


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

- 与 `ch-su-ye` 是师徒关系；详细交汇见 `tl-jiang-li-journey` 动线卡的
  `mentions` 段；复杂关系图见 `graph/tl-jiang-li-journey-graph.html`
```

## 动线卡示例

```yaml
---
id: tl-bronze-key
type: timeline
status: active
created: 2025-02-10
updated: 2025-02-25
title: 青铜钥匙的流向
track: item
target: it-bronze-key
first_seen: chapter-003
graph: graph/tl-bronze-key-graph.html
---

## 概览

追踪青铜钥匙从旧宅密室到最终审判台的完整流向。

## 变化轨迹

| 章节 | 状态 | 位置/持有者 | 关键事件 |
|---|---|---|---|
| chapter-003 | 出现 | 姜璃随身 | 从旧宅密室取得 |
| chapter-015 | 转移 | 苏叶保管 | 委托保管 |
| chapter-042 | 现身 | 月光审判台 | 关键道具 |

## 简要关系记录

- 与 `ch-jiang-li`：委托关系（chapter-015）
- 与 `ch-su-ye`：保管关系（chapter-015 起）
- 与 `sc-moonlit-arena`：现身场景（chapter-042）

## 备注

关键道具，与 `fs-key-secret` 伏笔强关联。
```

