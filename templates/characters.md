---
id: ac-<slug>
type: actor
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: 角色-甲
aliases: []
classification: protagonist   # protagonist / supporting / extra / creature / object-spirit / force / phantom（不锁死枚举，可经 nc-注册 扩展）
affiliation: null            # 所属势力 id（fa-*），无则留空
first_appearance: chapter-001
cross_ref: []                # 与 item 等的互相引用 id（器灵觉醒场景：actor ↔ item 双向引用）
---

# 角色-甲

## 概述

<一句话定位：在故事中的作用、在叙事结构中的地位。>

## 分类说明

`actor`（`ac-`）替代原 `character`（`ch-`）。定义为「拥有独立主观视角、可参与
桥段、可绑定感知/抽象动线、具备状态变化的叙事行动单元」，**与是否人类无关**。

| classification | 含义 | 示例 |
|---|---|---|
| `protagonist` | 主角 | 姜璃 |
| `supporting` | 配角 | 苏叶 |
| `extra` | 路人 | 无名侍卫 |
| `creature` | 生灵（蛤蟆·异兽） | 蛤蟆甲 |
| `object-spirit` | 器物灵体（会跑的桌子·宝剑器灵） | 青铜剑灵 |
| `force` | 抽象意志 | 深渊低语 |
| `phantom` | 幻影残魂 | 旧宅残影 |

**actor 与 item 的区分**：`actor` = 主动（能发起动作、有主观感知、有欲望动机）；
`item` = 默认被动。一旦道具拥有独立意志主动行动，SHALL 建模为 `actor`
（标签 `object-spirit`），原 `item` 卡保留物理本体描述，两卡通过 `cross_ref`
互相引用。

## 外貌 / 特征

- <可辨认特征>
- <习惯 / 口癖 / 招牌动作（可绑定 pose 卡 po-*）>

## 性格与动机

- **核心动机**：<为什么做他想做的事>
- **恐惧 / 软肋**：<最不愿面对什么>
- **成长弧线**：<从「起点状态」→「终点状态」（参见 timeline 卡 tl-*）>

## 关系要点

- 与 `<ac-xxx>` 的关系：<参见动线卡 `tl-xxx` 的 mentions 段，复杂交互见 `graph/`>
- 所属势力：<参见 faction 卡 `fa-xxx`>
- 器灵关联：<若 classification: object-spirit，注明 cross_ref 指向的 item 卡 it->*>

## 章节出场

- 首出场：<章节-001>
- 关键节点：<章节-00X>
- 结局 / 状态：<章节-00X>

## 备注

- <写作时容易忘的点，如：他习惯用右手但左利手是伪装的>
