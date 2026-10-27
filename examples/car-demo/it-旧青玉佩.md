---
id: it-旧青玉佩
type: item
status: draft
created: 2026-10-27
updated: 2026-10-27
name: 旧青玉佩
first_appearance: chapter-003
owner: ac-角色-甲
last_seen: chapter-012
advanced_mode: false
blackbox:
  physical: {材质: 青玉, 尺寸: "5cm×3cm", 耐久: 高}
  perceptual: {tactile: 持握微凉, visual: 温润青光}
  abstract: [tl-family-secret]
physics:
  bounding: {h: 0.05, w: 0.03, d: 0.01}
  mass: 0.08
  hardness: 6
  portable: true
  penetrable: false
state_list:
  - state_name: default
    description: 常态静置，无异常
    linked_sensory_cue_id: null
  - state_name: active
    description: 触碰发热，青光微亮
    linked_sensory_cue_id: su-jade-warm-01
perception_trace:
  tactile: 持握微凉，激活后转温热
  visual: 常态温润青光，激活后亮度提升
  perception_alias: ""
foreshadow_timeline:
  pre_plant: chapter-003
  pickup: chapter-005
  hint_degree: 4
interact_rule: 持有者体温 >37°C 且情绪激动时触发发热
owner_history:
  - chapter: chapter-003
    owner_id: ac-角色-乙
    event_note: 遗落物被角色-甲拾获
  - chapter: chapter-005
    owner_id: ac-角色-甲
    event_note: 正式收为己物
cross_ref: []
---

# 道具-旧青玉佩（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 一句话

一块来历不明的旧青玉佩，持有者情绪激动时会微微发热——车内争吵的导火索。

## 黑盒三层建模

- **物理层**：青玉质地，5cm×3cm，硬度 6，可携带，不可穿透
- **感知层**：触觉（持握微凉→激活转温热）+ 视觉（温润青光→激活亮度提升）
- **抽象层**：绑定 tl-family-secret（家族秘密动线）

## 状态切换

| 状态 | 描述 | 关联感官标记 |
|---|---|---|
| default | 常态静置，无异常 | — |
| active | 触碰发热，青光微亮 | su-jade-warm-01 |

deep 模式下 PROP_001 校验状态连续性：default → active 需有触发桥段支撑（pp-车内争吵中角色-甲情绪激动触发）。simple 模式仅登记不校验。
