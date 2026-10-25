---
id: tend-<slug>
type: character_tendency
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
target_role: ac-<slug>        # 依附的角色 id（ac-*），本卡刻画该角色的某条倾向维度
dimension: <克制↔放荡>         # 倾向维度名，两端语义须明确
baseline: 0                   # 基准刻度（故事起点时的初始倾向位置，通常为 0）
direction_rule: <长期趋势方向>  # 如「长期向放荡偏移」「总体回稳」
# baseline_prototype: <原型 key>  # 可选：人格基线原型（如 npd-grandiose），取值须经 nc-注册 写入 registry/tendency-prototypes.yaml
current_value: 0              # 当前刻度值（= history[] 最后一条的 value）
history:                      # 变动历史数组，每条绑定一个具体桥段事件作为推手
  - value: 1
    trigger_plot: pp-<slug>   # 引用已存在的桥段卡 id（pp-*），禁止凭空变性格
    description: <该次变动的触发事件与心理变化描述>
notes: <补充说明：与其他维度的联动、作者备注等>
---

# 角色动向 · <slug>

## 定位

`character_tendency`（`tend-`，存放于 `cards/tendencies/`）：刻画角色性格 / 心智
倾向的**带触发事件的连续滑动标尺**——有基准刻度、长期趋势方向、当前刻度，每一次
变动绑定一个具体桥段事件作为推手，而非凭空变性格。

> **铁律**：
> - 本卡**依附角色**（`target_role` 引用 `ac-*`），只记录**变化过程**，MUST NOT
>   替代角色基础卡（基线初始状态仍存于 `actor` 卡）。
> - `history[]` 每一条 MUST 绑定一个**已存在**的桥段卡（`trigger_plot` 引用真实
>   `pp-*` id）作为推手事件，禁止无事件推手的凭空变性格。
> - `current_value` 必须等于 `history[]` 最后一条的 `value`，二者保持一致。

## 字段说明

| 字段 | 必填 | 说明 |
|---|---|---|
| `target_role` | ✅ | 依附的角色 id（`ac-*`） |
| `dimension` | ✅ | 倾向维度名（如「克制↔放荡」「信任↔戒备」），两端语义须明确 |
| `baseline` | ✅ | 基准刻度（通常为 0） |
| `direction_rule` | ❌ | 长期趋势方向描述 |
| `baseline_prototype` | ❌ | 可选：人格病理类稳定基线原型 key（registry-backed 枚举，如 `npd-grandiose`），须经 `nc-注册` 写入 `registry/tendency-prototypes.yaml`；创作参考锚点，非临床诊断 |
| `current_value` | ✅ | 当前刻度值（= history[] 最后一条的 value） |
| `history` | ✅ | 变动历史数组，每条含 `{value, trigger_plot, description}` |
| `notes` | ❌ | 补充说明（与其他维度的联动等） |

## 人格基线原型（可选，baseline_prototype）

刻画带**人格病理类稳定基线**的角色（如自恋型人格的浮夸型 / 脆弱型创作原型）时，
可用可选字段 `baseline_prototype` 声明该维度标尺的滑动边界锚点：

- **取值须注册**：key MUST 先经 `nc-注册` 写入使用方工程 `registry/tendency-prototypes.yaml`
  （条目含 `label` / `description` / `boundary_hints[]`：`dimension_keywords` 子串匹配
  本卡 `dimension` → `constrained_direction`（`higher`/`lower`/`both`）+ `max_drift`
  容差 + `note` 提醒文案）；未注册由 `nc-动向` 拦截。skill 不内置锁死枚举，
  `npd-*` 等词表仅为示例。
- **只作边界锚点**：维度与滑动逻辑仍完全由 `dimension` / `baseline` /
  `direction_rule` / `history[]` 表达，本字段不替代任何现有字段语义。
- **`nc-校阅` 检查 ④**：沿受限方向漂移超 `max_drift` 时输出建议级提醒（附原型
  `note` 文案），提示而非禁止——作者可刻意写「受限维度缓慢松动」的反常弧光。
- 同一角色的多张 tend- 卡可共享同一原型 key，也可仅对受限维度的卡声明；
  未声明的卡行为完全不变。

## 最小示例（克制→放荡滑动标尺）

```yaml
id: tend-lead-restraint
type: character_tendency
status: draft
created: 2026-10-23
updated: 2026-10-23
target_role: ac-frog-lead
dimension: 克制↔放荡
baseline: 0
direction_rule: 长期向放荡偏移
current_value: 3
history:
  - value: 1
    trigger_plot: pp-ch03-betrayal
    description: 被挚友背叛后第一次失控，开始怀疑自我约束的意义
  - value: 2
    trigger_plot: pp-ch17-fall
    description: 经历坠落与放纵，主动放弃部分克制
  - value: 3
    trigger_plot: pp-ch31-embrace
    description: 彻底接纳放荡面，不再压抑本能
notes: 与「信任↔戒备」维度联动，放荡度上升时戒备度同步下降
```

## 扩展示例（人格基线原型声明）

`npd-*` 为文档示例，需经 `nc-注册` 写入 `registry/tendency-prototypes.yaml` 后方可使用：

```yaml
id: tend-<slug>-empathy
type: character_tendency
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
target_role: ac-<slug>
dimension: 冷漠↔共情
baseline: -4
baseline_prototype: npd-grandiose   # 示例取值，须先经 nc-注册
direction_rule: 共情端滑动受限；表演性关怀不计入共情上调
current_value: -3
history:
  - value: -3
    trigger_plot: pp-<slug>
    description: <假意安抚换取利益，表面上的「共情」小步上浮；漂移未超 max_drift>
notes: <原型共情 hint 的 constrained_direction / max_drift 引用与提醒预期>
```

## 关联技能

- **建卡 / 编辑**：`nc-动向`(nc-tendency)
- **检索**：`nc-检索 type:character_tendency role:ac-*`（拉取某角色全部动向标尺与变动历史）
- **校验**：`nc-校阅`(nc-review) 检查动向逻辑冲突（偏移无推手、方向与 direction_rule 矛盾）
- **推演下一步刻度**：`nc-研判`(nc-analyze) 出方案 A/B/C，作者选定后经 `nc-动向` 落地
- **批量迭代**：`nc-编排`(nc-compose) 跨多桥段联动偏移
