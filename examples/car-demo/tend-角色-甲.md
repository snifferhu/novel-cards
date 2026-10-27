---
id: tend-角色-甲
type: character_tendency
status: draft
created: 2026-10-27
updated: 2026-10-27
target_role: ac-角色-甲
dimension: trust
baseline_prototype: steadfast
slide_axes:
  risk: -2
  empathy: 7
  impulse_control: 7
  trust: 4
  desire_orient: 3
  aggression: -2
prototype_note: 坚忍型——克制优先，信任缓慢建立，受挫后倾向隐忍而非爆发；滑动方向约束：trust 轴负向漂移需桥段推手，正向漂移幅度 ≤3
current_value: 2
history:
  - value: 4
    trigger_plot: pp-车内争吵
    chapter: chapter-012
    note: 因旧玉佩归属争执，对角色-乙的信任从 4 降至 2（仍保持克制未爆发）
---

# 动向-角色-甲（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 基线原型

- **原型**：`steadfast`（坚忍型，爽文 6 原型之一）
- **六轴初始值**：risk:-2 / empathy:7 / impulse_control:7 / trust:4 / desire_orient:3 / aggression:-2
- **一人一原型铁律**：本卡仅声明一个 baseline_prototype，MUST NOT 数组多值

## 滑动记录

| 章节 | 事件（trigger_plot） | trust 变化 | 说明 |
|---|---|---|---|
| chapter-012 | pp-车内争吵 | 4 → 2 | 玉佩归属争执，信任下降但仍克制 |

## PERSON_001 校验预期

deep 模式下：
- trust 轴从 4 降至 2（漂移 -2），在 max_drift: 3 范围内 → 不告警
- 若后续 trust 继续降至 -1（累计漂移 -5 > max_drift: 3）→ PERSON_001 L2_WARN（需 override_note + change_log）
simple 模式：不读取 prototype_note 约束，轴可自由飘动，不告警
