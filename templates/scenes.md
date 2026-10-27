---
id: sc-<slug>
type: scene
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: 场景-甲
location: <地点描述>
time_of_day: <时刻 / 时段 / 天气>
associated_chapters: []
atmosphere: <基调关键词>
# 空间快照可选字段（v1.0 增量，space_snapshot 子形态；密闭/狭小场景才需声明，开阔场景可全缺省）：
# usable_clearance:            # 净空尺寸（米），供 SPACE_001 包围盒校验
#   width: 0.0                 # 可用宽度
#   depth: 0.0                 # 可用深度
#   height: 0.0                # 可用净高
# mobility_constraint:         # 活动约束（boolean），缺省 = 无约束
#   can_stand: true
#   can_jump: true
#   can_spread_arms_wide: true
# obstacle_list:               # 障碍物清单；penetrable: false 的障碍 MUST NOT 被角色穿过（双模式共用硬规则）
#   - name: <障碍物名>
#     penetrable: false
# env_note: <环境备注，如「密闭车厢，头顶距座椅约 30cm」>
---

# 场景-甲

## 一句话

<这个场景在故事里承担什么功能。>

## 空间描述

- **地理**：<地点位置 / 与其他场景的相邻关系>
- **氛围**：<基调、气味、光线、温度>
- **符号意义**：<这个空间象征什么>

## 时间特征

- 时段：<晨 / 昼 / 黄昏 / 夜 / 特定节日>
- 天气 / 气候：<常态与异常>
- 时间流速：<是否与主线不同步>

## 关联章节

- <章节-001>：<此场景在此章节中的角色>
- <章节-00X>：<再次出现>

## 出没角色

- `<ac-xxx>`：<常在此活动 / 有故事发生>（actor id，前缀 ac-）

## 环境参数（供快照/词频引用）

- 光照基调：<自然光 / 顶冷白光 / 烛光摇曳 ……>（可被 `tl-light` 动线与 `sn-*` 快照引用）
- 温度 / 声响 / 气味基调：<……>（五感公理：根落在视觉/听觉/嗅觉/味觉/触觉之一）

## 空间快照（space_snapshot，可选）

> 仅密闭 / 狭小场景（小轿车 / 电梯 / 轿厢 / 密室等）需声明；开阔场景全缺省即可。
> 声明后该场景成为 SPACE_001 空间校验输入：deep 模式对绑定桥段做姿态包围盒 vs 净空间
> L1 推演，simple 模式仅拦离谱穿墙 / 穿固体。字段均为可选，存量卡缺失行为不变。

```yaml
usable_clearance: {width: <米>, depth: <米>, height: <米>}   # 可用净空尺寸
mobility_constraint: {can_stand: <true/false>, can_jump: <true/false>, can_spread_arms_wide: <true/false>}
obstacle_list:
  - name: <障碍物名>
    penetrable: <true/false>   # false = 不可穿透，角色穿过即触发 SPACE_001 L1_HARD（双模式共用）
env_note: <环境备注>
```

**假名示例**（小轿车车厢，结构占位非真实内容）：

```yaml
usable_clearance: {width: 1.4, depth: 2.5, height: 1.15}
mobility_constraint: {can_stand: false, can_jump: false, can_spread_arms_wide: true}
obstacle_list:
  - name: 车顶内衬
    penetrable: false
  - name: 前排座椅靠背
    penetrable: false
env_note: 密闭车厢，后排头顶距座椅约 30cm，无法直立
```

## 暗线视角

- 暗线中的对应场景：<参见 darklayer 卡 `dk-xxx`；如无填「无」。暗线通过 `references_to_main`
  单向引用本场景 id，本卡不反向链接 dk-*（hard-rules.md 规则 4）>
