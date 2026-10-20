---
id: fs-<slug>
type: foreshadow
status: unresolved
created: YYYY-MM-DD
updated: YYYY-MM-DD
title: <伏笔标题>
setup_chapter: 章节-001
payoff_chapter: null
payoff_by: null
planted_by: null
---

# <伏笔标题>

> **硬规则**：本卡必须满足 **`payoff_chapter` 有值** 或 **`status: unresolved`**
> 之一。两者皆缺视为非法卡，必须补齐或明确标 unresolved。

## 一句话

<这个伏笔想说什么，读者何时会发现。>

## 埋点

- **章节**：<章节-001>
- **形态**：<具体以什么方式埋下 —— 一句台词 / 一个物件 / 一个细节>
- **可辨识度**：low（隐晦）/ medium / high（明确）

## 回收方案

- **计划章节**：<章节-00X>（`payoff_chapter`）
- **回收形态**：<一句话揭露 / 关键道具揭示 / 反转 / 悲剧化>
- **执行者**：`<ch-xxx>`

## 状态说明

`status` 生命周期：

- `planted` — 已埋下，尚未回收
- `developing` — 埋下后被再次提及，铺垫中
- `resolved` — 已回收，`payoff_chapter` 必须非空
- `unresolved` — **明确决定不回收**，`payoff_chapter` 可为 null
- `abandoned` — 作者决定放弃此伏笔（保留在档案中便于回溯）

**非法状态**：`status` 为 `planted` / `developing` / `resolved` 但
`payoff_chapter` 为空且未标 `unresolved`。

## 与其他伏笔的关系

- 前置伏笔：`<fs-xxx>`
- 后续伏笔：`<fs-yyy>`

## 与暗线的关联

- 是否属于暗线叙事：<参见 darklayer 卡 `dk-xxx`；如无填「无」>
