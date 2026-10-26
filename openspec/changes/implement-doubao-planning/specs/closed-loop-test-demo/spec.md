# Spec Delta

## Purpose

提供小轿车闭环测试 Demo 能力：一套可直接落盘的 6 张卡片（space_snapshot / actor_bounding / character_tendency / item / plotpoint / snapshot）+ 测试调用指令 + 预期输出对照，用于验证「建卡 → 校阅 → 研判 → 检索 → 导出」整条链路在双模式下的行为是否符合规则库定义，作为使用方工程初始化后的冒烟测试资产。

## ADDED Requirements

### Requirement: 测试 Demo 卡片集

系统 SHALL 提供小轿车案例的 6 张完整填充卡片作为参考样例（存放于本仓库 `examples/` 或使用方工程 `drafts/` 由用户落盘），覆盖：scene_car_01（净高 1.15m 密闭车厢）、actor_01（男主 1.72m 七通道全 ok）、trace_actor01_01（稳守型基线六轴）、prop_jade_01（旧青玉佩 default/active 双态 + 第 3 章埋第 27 章收）、beat_car_quarrel_01（车内争吵 tension 7）、snapshot_car_quarrel_01（男主/对手双视角）。所有卡片 id 互相引用 MUST 无悬空 ID。

#### Scenario: Demo 卡片 ID 完整性

- **WHEN** 对 6 张 Demo 卡执行 nc-校阅 --full
- **THEN** 无悬空 ID 告警；beat_car_quarrel_01 引用的 space_id/prop_involved_ids/actor_involved_ids/snapshot beat_id 全部可解析

### Requirement: 测试调用指令

Demo SHALL 配套 4 条标准测试调用指令：`nc-校阅 beat_car_quarrel_01` / `nc-研判 event=男主暴怒想在车内站起身踩座椅跳舞视线锁定玉佩` / `nc-检索 旧青玉佩` / `nc-导出 format=markdown`，供使用方工程初始化后逐条执行验证链路。

#### Scenario: 校阅触发预期告警

- **WHEN** deep 模式执行 `nc-校阅 beat_car_quarrel_01`
- **THEN** 输出含 SPACE_001 L1_HARD（车内无法站直）+ PERSON_001 L2_WARN（稳守型无触发事件直接暴怒偏离标尺）+ FOCUS_001 L2_WARN（强刺激下焦点锁定不起眼玉佩缺动机标注）

#### Scenario: simple 模式无硬错

- **WHEN** simple 模式执行同一校阅指令
- **THEN** 无 L1/L2 告警，仅 L3 启发提示（爽文特权生效）

### Requirement: 预期输出对照文档

Demo SHALL 附预期输出对照说明，明确 deep / simple 两种模式下各规则的预期触发结果，作为回归验证基准；后续规则库迭代时 MUST 同步更新该对照表。

#### Scenario: 规则迭代后对照表同步

- **WHEN** review-rules.json 新增或修改某条规则逻辑
- **THEN** 小轿车 Demo 的预期输出对照表 MUST 同步更新，否则视为回归验证失效
