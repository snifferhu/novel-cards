---
id: tl-<slug>
type: timeline
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
title: <动线主题名>
track: character       # character | item | faction | place | other | 已注册的自定义类型（经 nc-注册 写入 registry/tracks-registry.yaml）
target: ac-<slug>      # 被追踪对象的主书 id（与 track 匹配；track: other 时可省或填自由字符串）
first_seen: chapter-XX
graph: null            # 关联图谱 HTML 相对路径（如 graph/tl-xxx-graph.html），无则留空
---

# <动线主题名>

## 概览

一段话说清这条动线在追踪什么、为什么值得单独拉出来。
关系细节请在下方 `mentions` 段简要记录；更复杂的交互
请在 `graph/` 目录下生成 HTML 关系图谱。

**track 枚举说明**：

| track 值 | target 指向 | 示例 |
|---|---|---|
| `character` | `ac-*` id | 角色成长弧线 |
| `item` | `it-*` id | 道具流向 |
| `faction` | `fa-*` id | 势力兴衰 |
| `place` | `sc-*` id | 场景变迁 |
| `other` | 无固定类型 id | 跨对象主题线（季节/天气） |
| 自定义类型 | 经 `nc-注册` 写入白名单后使用 | `temperature-field`（温度场） |

自定义 track MUST 先经 `nc-注册` 注册再建卡（hard-rules.md 规则 16）。

## 节点结构（nodes）——由积木驱动

每个节点 SHOULD 通过 `bind_module` 字段绑定一个 pose/module 积木；未绑定 module
的孤立节点仅允许用于简单线性记录。**跨动线同步变化 MUST 走 module 积木模块**，
禁止在正文或动线卡里零散写联动（hard-rules.md 规则 19）。

```yaml
nodes:
  - chapter: 3
    node_id: node_01
    desc: <一句话状态描述>
    bind_module: md-<slug>          # 绑定的积木模块 id
    trigger_foreshadow: fs-<slug>   # 触发的伏笔 id（可选）
    burst: null                     # 爆点标注（strategic-burst / 中型情绪爆点 / blank-transition 等，需经 registry/burst-tags-registry.yaml 注册）
  - chapter: 14
    node_id: node_02
    desc: <一句话状态描述>
    bind_module: md-<slug>
    burst: 中型情绪爆点
```

**最小示例（发型动线）**：

```yaml
nodes:
  - chapter: 3
    node_id: node_01
    desc: 高髻严整，玉簪固定
    bind_module: md-action-entry
    trigger_foreshadow: fs-hairpin
  - chapter: 14
    node_id: node_02
    desc: 玉簪取下，长发散落
    bind_module: md-action-unpin
    burst: 中型情绪爆点
```

## 变化轨迹（表格视图，与 nodes 等价的人类可读形式）

| 章节 | node_id | 状态 | 位置/持有者 | 关键事件 | bind_module |
|---|---|---|---|---|---|
| chapter-003 | node_01 | 出现 | <场景/持有者> | <一句话事件> | `md-xxx` |
| chapter-015 | node_02 | 转移 | <场景/持有者> | <一句话事件> | `md-yyy` |
| chapter-042 | node_03 | 现身 | <场景/持有者> | <一句话事件> | `md-zzz` |

## 简要关系记录（mentions）

仅记录这条动线**必须提及**的关系交汇点，不做详细展开。
详细双向互动请用 `graph/` 目录下的 HTML 关系图谱表达。

- 与 `ac-su-ye`：<一段话说清交汇>（见 graph/tl-bronze-key-graph.html）
- 与 `fa-shenzhi-hui`：<一段话说清交汇>

## 关联卡片

- `fs-<slug>`（伏笔）
- `pp-<slug>`（桥段）
- `md-<slug>`（积木模块）
- `lx-<slug>`（词频张力，若本动线参与长线四方对齐）

## 备注

- 若涉及跨时间线或跨叙事视角，此处说明
- 若未来计划生成图谱，标注目标文件名
- 感知类动线的 track root MUST 落在五感之一（hard-rules.md 规则 13）
