---
id: pp-车内争吵
type: plotpoint
status: draft
created: 2026-10-27
updated: 2026-10-27
title: 车内争吵
chapter: chapter-012
summary: 角色-甲与角色-乙在密闭车厢内因旧玉佩归属爆发争执
participants: [ac-角色-甲, ac-角色-乙, it-旧青玉佩, sc-车厢]
lexstat_bind: lx-chapter-012-tension
module_list: []
pose_refs: [po-斜倚握扇]
foreshadow_links: [fs-jade-origin]
strategic_burst: false
pivotal: true
tension_base: 7
is_strategic_climax: false
beat_type: turning
sequence_index: 3
precondition_beat_ids: [pp-玉佩拾取]
postcondition_beat_ids: [pp-玉佩断裂]
foreshadow_link:
  plant_beat_id: pp-玉佩拾取
  payoff_beat_id: pp-玉佩断裂
mood_shift_summary: 表面从容→暗流涌动→爆发
personality_trigger_actor_ids: [ac-角色-甲]
actor_involved_ids: [ac-角色-甲, ac-角色-乙]
prop_involved_ids: [it-旧青玉佩]
cue_trigger_ids: [su-jade-warm-01]
space_id: sc-车厢
---

# 桥段-车内争吵（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 一句话

密闭行驶中的轿车后座，角色-甲与角色-乙因一块旧青玉佩的归属权爆发激烈争执，玉佩在情绪激动中微微发热。

## 章节定位

- 所在章节：chapter-012
- 章节内位置：中段转折

## 涉及角色

- `ac-角色-甲` — 玉佩持有者，坚忍型人格，克制中爆发
- `ac-角色-乙` — 玉佩原主，试探底线，放大对方攻击性

## 桥段展开

1. **触发**：角色-乙突然提及玉佩是家族遗物，质疑角色-甲的持有合法性
2. **过程**：角色-甲斜倚座位持扇不动，表面从容；角色-乙紧握玉佩不放，语气渐厉；玉佩在两人争夺中微微发热（active 状态触发 su-jade-warm-01）
3. **结果**：争执未分胜负但关系彻底破裂，为后续 pp-玉佩断裂 埋下伏笔

## 联动绑定

- **词频张力** `lx-chapter-012-tension`：本章张力曲线峰值
- **姿态引用** `po-斜倚握扇`：角色-甲的招牌松弛姿态（deep 模式 SPACE_001 校验：slouch h:1.45m > 车厢净高 1.15m → L2_WARN）
- **伏笔关联** `fs-jade-origin`：玉佩来历伏笔（chapter-003 埋 → chapter-027 收）
- **感官标记** `su-jade-warm-01`：玉佩发热时的触觉+视觉信号

## 张力参数

- `tension_base: 7`（高张力桥段）
- `is_strategic_climax: false`（非战略爆点，BEAT_001 不豁免）
- `beat_type: turning`（转折点）
- 前置：pp-玉佩拾取（MUST 已发生）
- 后置：pp-玉佩断裂（依赖本桥段结果）

## 校验预期

deep 模式下：
- SPACE_001：角色-甲 slouch 姿态 h:1.45m > sc-车厢净高 1.15m → L2_WARN（可 override_note 豁免）
- FOCUS_001：角色-甲 sight: enabled，视觉焦点动线合法 → 不告警
- PERSON_001：trust 轴 4→2 漂移 -2 在 max_drift:3 内 → 不告警
- BEAT_001：tension_base:7 单章密度合理 → 不告警
simple 模式：仅拦穿墙硬错 + 失明硬错，上述均不告警
