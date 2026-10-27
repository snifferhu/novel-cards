---
id: sn-定格
type: snapshot
status: draft
created: 2026-10-27
updated: 2026-10-27
chapter: chapter-012
focus: scene
summary: 密闭车厢内角色-甲与角色-乙因旧玉佩归属爆发争执的瞬时定格
used_pose: po-斜倚握扇
related_cards: [ac-角色-甲, ac-角色-乙, it-旧青玉佩, sc-车厢]
timeline_state: climax
prev_snapshot: null
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
  recall_beat_ids: []
  retell_by_actor_ids: [ac-角色-丙]
---

# 快照-定格（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 一句话

chapter-012 车内争吵高潮瞬间的全局状态切片：两人对峙、玉佩发热、气氛紧绷到临界。

## 时间线状态

`climax` — 本章高潮锚点。

## 多视角对比

| 维度 | 角色-甲视角 | 角色-乙视角 | 客观真相 |
|---|---|---|---|
| 感知 | 对方在挑衅，目光轻蔑 | 对方在炫耀，居高临下 | 双方均无动手意图 |
| 认知偏差 | 放大对方攻击性 | 将防御解读为傲慢 | 信息不对称导致误判 |
| 注意力焦点 | 对方紧握玉佩的手 | 对方斜倚的姿态 | 玉佩是争议核心 |
| 已知 | 对方想要玉佩、曾偷过东西 | 玉佩是家族遗物、对方声称继承权 | — |
| 未知 | 对方内心恐惧、有己方把柄 | 对方在调查玉佩来历、有关键证据 | — |

## SNAP_001 校验预期

deep 模式下：
- 两视角描述与 objective_fact 对比：角色-甲「觉得对方挑衅」vs 客观「无动手意图」→ 认知偏差属正常主观滤镜，**不告警**
- 角色-乙「觉得对方炫耀」vs 客观「在克制情绪」→ 同上，主观滤镜，**不告警**
- 若出现硬矛盾（如某视角称「对方拔刀」但 objective_fact 为「无人持械」且无幻境标记）→ SNAP_001 L2_WARN
simple 模式：不做多视角矛盾校验，仅登记
