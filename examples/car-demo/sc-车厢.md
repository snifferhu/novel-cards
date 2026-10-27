---
id: sc-车厢
type: scene
status: draft
created: 2026-10-27
updated: 2026-10-27
name: 场景-车厢
location: 城市道路·行驶中轿车内
time_of_day: 夜
usable_clearance:
  height: 1.15
  width: 1.4
  depth: 0.9
mobility_constraint:
  can_stand: false
  can_turn_around: true
obstacle_list:
  - {name: 前排座椅靠背, penetrable: false}
  - {name: 车门玻璃, penetrable: false}
  - {name: 方向盘, penetrable: false}
env_note: 密闭狭小空间，夜间行驶，车灯间歇照亮车内
---

# 场景-车厢（示例占位非真实内容）

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的假名占位卡，仅用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名，不对应任何真实作品或人物。

## 环境参数

- **净高**：1.15m（后排坐姿头顶距车顶约 10cm）
- **宽深**：1.4m × 0.9m（后排横向可坐两人，纵向腿部空间极有限）
- **活动约束**：不可站立（can_stand: false），可转身（can_turn_around: true）
- **障碍物**：前排座椅靠背 / 车门玻璃 / 方向盘（均 penetrable: false）
- **环境备注**：夜间行驶，车灯间歇从挡风玻璃透入，车内昏暗

## 空间校验预期

deep 模式下，绑定此场景的桥段将触发 SPACE_001 包围盒校验：
- 角色身高 > 1.15m 时站立姿态 → L1_HARD（净高不足直立）
- 斜倚握扇姿态（h: 1.65m）→ L2_WARN（超出净空，建议换场景或换姿态）
- simple 模式仅拦穿墙硬错，不校验包围盒
