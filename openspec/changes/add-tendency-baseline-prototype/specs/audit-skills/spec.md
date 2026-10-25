# Spec Delta

## Purpose

为 `nc-校阅` 动向逻辑冲突检查增补第 ④ 项：人格基线原型边界漂移的建议级检查。本 delta 只追加增量关切，不改写既有 `nc-校阅 审计维度` requirement 的检查 ①②③ 与输出契约。

## ADDED Requirements

### Requirement: nc-校阅 原型边界漂移建议级检查

`nc-校阅` SHALL 在动向逻辑冲突检查中新增第 ④ 项——原型边界漂移检查，作用于声明了 `baseline_prototype` 的 `tend-*` 卡：

- **数据源**：该卡 `baseline_prototype` key 在 `registry/tendency-prototypes.yaml` 中的注册条目，特别是其 `boundary_hints[]`（每条含 `dimension_keywords` / `constrained_direction` / `max_drift` / `note`）。
- **匹配**：某 hint 的 `dimension_keywords` 以子串方式命中该卡 `dimension` 字段即视为适用；命中多条 hints 时逐条独立检查。
- **判定**：沿 `constrained_direction`（`higher` / `lower` / `both`）受限方向，`|current_value - baseline|` 超过该 hint 的 `max_drift` 时输出提醒，提醒内容 SHALL 含该 hint 的 `note` 文案与当前漂移量。
- **分级**：与检查 ②（短期变化与长期趋势严重冲突）同级——SHALL 输出为建议级提醒（提示风险而非禁止），作者可刻意书写「受限维度缓慢松动」的反常弧光；MUST NOT 阻断流程或改写任何卡片。
- **静默条件**：卡未声明 `baseline_prototype`、原型条目无 `boundary_hints`、keywords 未命中该卡 `dimension`、或 `registry/tendency-prototypes.yaml` 文件缺失时，检查 ④ SHALL 静默跳过，MUST NOT 报错，且 MUST NOT 影响检查 ①②③ 的执行。

#### Scenario: 共情维度超阈值漂移提醒

- **WHEN** 某 tend- 卡声明 `baseline_prototype: npd-grandiose`，registry 中该原型的共情维度 hint 设 `max_drift: 2`，而卡内共情维度从 `baseline: 0` 漂移至 `current_value: 4`
- **THEN** `nc-校阅` 意见书列出检查 ④ 提醒：共情维度已超出该原型声明的滑动边界（漂移 4 > max_drift 2），附 hint 的 `note` 文案，请作者确认各次变动的桥段推手是否支撑这一跨档变化

#### Scenario: 边界内小幅回弹不提醒

- **WHEN** 同一卡的共情维度从 0 漂移至 -2（绝对漂移 = max_drift，未超过），期间 history 每条均绑定真实桥段
- **THEN** 检查 ④ 不输出提醒

#### Scenario: 无原型声明不受影响

- **WHEN** 全书 tend- 卡均未声明 `baseline_prototype`（或工程未建 `registry/tendency-prototypes.yaml`）
- **THEN** `nc-校阅` 照常执行检查 ①②③，检查 ④ 静默跳过，意见书中不出现原型相关内容
