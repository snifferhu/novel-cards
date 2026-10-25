# Spec Delta

## Purpose

为 `character_tendency` 角色动向滑动标尺卡增补可选人格基线原型声明字段 `baseline_prototype` 的字段契约，作为滑动边界约束的声明锚点。本 delta 只追加增量关切，不改写既有 `character_tendency 角色动向滑动标尺卡` requirement 的任何现有字段语义。

## ADDED Requirements

### Requirement: character_tendency 可选人格基线原型声明

`character_tendency`（`tend-`）frontmatter SHALL 支持可选字段 `baseline_prototype`：声明该动向卡依附角色在本条倾向维度上的人格病理类稳定基线原型。约束：

- 取值 MUST 是使用方工程 `registry/tendency-prototypes.yaml` 中已注册的原型 key；未注册取值 MUST 被 `nc-动向` 拦截并提示先经 `nc-注册` 写入白名单（注册前置，同 track 标签机制）。
- 该字段 MUST 为创作参考锚点：原型语义与滑动边界提示由 registry 条目的 `boundary_hints` 承载，维度与滑动逻辑仍完全由现行 `dimension` / `baseline` / `direction_rule` / `current_value` / `history[]` 表达，本字段 MUST NOT 替代或修改任何现有滑动字段的语义。
- 字段可选：不声明 `baseline_prototype` 的 tend- 卡行为与现状完全一致，零迁移。
- 同一角色（同一 `target_role`）的多张 tend- 卡 SHALL 可共享同一原型 key，也可仅对受限维度的卡声明；跨维度声明不同原型属允许的建模自由。
- 文档与模板中出现的具体词表（如 `npd-grandiose` / `npd-vulnerable`）SHALL 仅以示例形式呈现并标注「需经 nc-注册 后方可使用」；skill 仓库 MUST NOT 内置锁死枚举，也不得在安装骨架中预置具体原型条目。

#### Scenario: 建卡声明已注册原型

- **WHEN** 作者经 `nc-注册` 将 `npd-grandiose`（含共情维度 `boundary_hints`）写入 `registry/tendency-prototypes.yaml` 后，用 `nc-动向` 为某角色建「共情↔冷漠」维度卡并传 `baseline_prototype: npd-grandiose`
- **THEN** 生成的 `tend-*` 卡 frontmatter 含 `baseline_prototype: npd-grandiose`，其余滑动字段照常填写

#### Scenario: 未注册原型拦截

- **WHEN** 作者建卡时传 `baseline_prototype: npd-vulnerable`，但该 key 未出现在 `registry/tendency-prototypes.yaml`
- **THEN** `nc-动向` 拦截本次建卡，提示「先经 `nc-注册` 将该原型写入 registry/tendency-prototypes.yaml」，不产出卡提案

#### Scenario: 不声明原型零影响

- **WHEN** 存量 tend- 卡或新建卡均未填写 `baseline_prototype`
- **THEN** 全部现行行为（建卡、编辑、检索、校阅检查 ①②③）保持不变
