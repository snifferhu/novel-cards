# Spec Delta

## Purpose

为 `nc-动向`(nc-tendency) 技能增补可选入参 `baseline_prototype` 及其注册前置校验契约。本 delta 只追加增量关切，不改写既有 `nc-动向 角色倾向滑动标尺（nc-tendency）` requirement 的滑动标尺语义与铁律。

## ADDED Requirements

### Requirement: nc-动向 baseline_prototype 入参与注册前置校验

`nc-动向`(nc-tendency) SHALL 接受可选入参 `baseline_prototype`，建卡/编辑时将其写入 tend- 卡 frontmatter 并执行注册前置校验：

- 取值出现在使用方工程 `registry/tendency-prototypes.yaml` 的 `prototypes` 清单中 → 校验通过，随卡提案输出。
- 取值未注册 → MUST 拦截本次操作，返回「先经 `nc-注册` 将该原型写入 `registry/tendency-prototypes.yaml`」提示，不产出卡提案。
- 未提供该入参 → 与现行建卡/编辑行为完全一致。
- 编辑已有卡移除 `baseline_prototype` 声明 SHALL 属合法编辑（字段可选），移除后检查 ④ 不再作用于该卡。

#### Scenario: 注册后建卡带原型

- **WHEN** registry 已注册 `npd-vulnerable`，作者执行 `nc-动向` 建卡并传 `baseline_prototype: npd-vulnerable`
- **THEN** 卡提案 frontmatter 含 `baseline_prototype: npd-vulnerable`，校验通过

#### Scenario: 未注册直接使用被拦截

- **WHEN** registry 不存在 `custom-prototype-x`，作者建卡时传 `baseline_prototype: custom-prototype-x`
- **THEN** `nc-动向` 拦截并提示先走 `nc-注册`，不产出任何卡提案

#### Scenario: 编辑移除声明

- **WHEN** 作者编辑一张带 `baseline_prototype` 的 tend- 卡并移除该字段
- **THEN** 更新提案中 frontmatter 不再含该字段，卡片其余字段与 history 保持不变
