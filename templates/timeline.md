---
id: tl-<slug>
type: timeline
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
title: <动线主题名>
track: character       # character | item | faction | place | other
target: ch-<slug>      # 被追踪对象的主书 id（与 track 匹配）
first_seen: chapter-XX
---

# <动线主题名>

## 概览

一段话说清这条动线在追踪什么、为什么值得单独拉出来。
关系细节请在下方 `mentions` 段简要记录；更复杂的交互
请在 `graph/` 目录下生成 HTML 关系图谱。

## 变化轨迹

| 章节 | 状态 | 位置/持有者 | 关键事件 |
|---|---|---|---|
| chapter-003 | 出现 | <场景/持有者> | <一句话事件> |
| chapter-015 | 转移 | <场景/持有者> | <一句话事件> |
| chapter-042 | 现身 | <场景/持有者> | <一句话事件> |

## 简要关系记录（mentions）

仅记录这条动线**必须提及**的关系交汇点，不做详细展开。
详细双向互动请用 `graph/` 目录下的 HTML 关系图谱表达。

- 与 `ch-su-ye`：<一段话说清交汇>（见 graph/tl-bronze-key-graph.html）
- 与 `fa-shenzhi-hui`：<一段话说清交汇>

## 关联卡片

- `fs-<slug>`（伏笔）
- `pp-<slug>`（桥段）

## 备注

- 若涉及跨时间线或跨叙事视角，此处说明
- 若未来计划生成图谱，标注目标文件名
