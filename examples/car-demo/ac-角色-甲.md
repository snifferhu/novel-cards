---
id: ac-角色-甲
type: actor
status: draft
created: 2026-10-27
updated: 2026-10-27
name: 角色-甲
classification: human
base_bounds:
  height: 1.72
  width: 0.55
  depth: 0.30
pose_bounding_map:
  sit: {h: 1.20, w: 0.60, d: 0.80}
  slouch: {h: 1.45, w: 0.70, d: 0.85}
  stand: {h: 1.72, w: 0.55, d: 0.30}
sensory_mask:
  sight: enabled
  hearing: enabled
  smell: enabled
  taste: enabled
  touch: enabled
  vestibular: enabled
  interoception: enabled
cross_ref: []
---

# 角色-甲（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 基础设定

- **身高**：1.72m（站立姿态 h: 1.72m > 车厢净高 1.15m → SPACE_001 L1_HARD）
- **感官通道**：全七通道 enabled（无感知缺陷）
- **姿态包围盒**：sit（坐姿 h:1.20m）/ slouch（斜倚 h:1.45m）/ stand（站立 h:1.72m）

## 空间校验预期

deep 模式下：
- 角色-甲在 sc-车厢（净高 1.15m）中站立 → SPACE_001 L1_HARD（stand h:1.72m > 1.15m）
- 角色-甲斜倚（slouch h:1.45m > 1.15m）→ SPACE_001 L2_WARN（可 override_note 豁免）
- 角色-甲坐姿（sit h:1.20m ≈ 1.15m，临界）→ 不告警
simple 模式：仅拦穿墙硬错，不校验包围盒，上述均不告警
