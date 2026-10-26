# Spec Delta: event-driven-inference

## Purpose

定义「驱动世界对象演化、最后渲染」的事件驱动剧情推演流程：作者输入意图 → 世界派发事件 → 对象连锁响应（enter/perceive/act/fire）→ 汇总为 ChangePlan → 作者审核 → patch 批量落地 → render 序列化为正文。文字是视图，真相在对象实例里；改剧情 = 改对象状态而非改字符串。

## ADDED Requirements

### Requirement: 事件派发与连锁调用

系统 SHALL 支持以「事件」为单位驱动叙事世界演化：作者表达一个意图（如「让角色 A 进入房间 X 触发桥段 Y」），世界将其解析为事件并派发给相关对象，对象按各自方法契约产生连锁状态变更。该机制 MUST 以文档约定 + （可选）轻量运行时纸面模拟承载，MUST NOT 要求存在真实事件循环运行时。

#### Scenario: 单事件连锁推演

- **WHEN** 作者输入「让角色 A 进入场景 RoomX」
- **THEN** 世界 MUST 依次触发：`RoomX.enter(A)`（更新场景环境插槽、广播场内 SensoryCue）→ `A.perceive(RoomX)`（捕获感官信号）→ `A.act()`（沿 `character_tendency` 动向标尺滑动、切换 pose 姿态）→ 扫描场内所有 `PlotBeat` 检查前置条件，满足者进入待触发列表
- **AND** 连锁过程中产生的每一项状态变更 MUST 被记录为候选变更项，MUST NOT 直接写回任何卡片文件

#### Scenario: 多对象交互

- **WHEN** 一个事件同时涉及多个 Role / Prop / SensoryCue
- **THEN** 世界 MUST 对每个受影响对象分别调用其响应方法，并汇总全部对象的变更项
- **AND** 跨对象联动（如道具动线变化触发伏笔检查）MUST 通过既有 `module`(`md-`)积木 `trigger_map` 表达，MUST NOT 在事件推演中零散硬编码联动

### Requirement: ChangePlan 汇总与作者审批权

系统 SHALL 把一次事件推演产生的全部候选变更汇总为一份结构化 `ChangePlan`，交作者审核后才落地。`ChangePlan` 是 AI 与作者之间的结构化中介，对应 `nc-编排` 的 compose_plan 产物。对象本身 MUST NOT 自动覆盖自己。

#### Scenario: ChangePlan 内容

- **WHEN** 事件推演完成
- **THEN** `ChangePlan` MUST 逐项列明：哪些 `Role` 属性变更（含动向刻度新值 + 推手桥段）、哪个 `Prop` 动线移动、哪个 `SensoryCue` 激活、哪个 `PlotBeat` 待引爆、哪些 `DarkLine` 进度变化
- **AND** 每项 MUST 标注目标卡 id 与变更前后差异，供作者逐条增删/调整/标记拒绝

#### Scenario: 审批前绝不落地

- **WHEN** `ChangePlan` 尚未获作者确认
- **THEN** 系统 MUST NOT 写入任何 `cards/**` / `manuscript/` / `index/` 文件
- **AND** 作者确认后 MUST 走 `patch` 批量更新各 `NcObject` 实例，并自动写 CHANGELOG、生成 history 快照（沿用提案制：AI 出草案、用户落盘）

### Requirement: 冲突处理三选一且决定权归作者

系统 SHALL 在 `clean_object` / `plan_modify` 落地前对比新旧两个对象实例的属性与轨道节点；检出实质冲突时抛出差异对比面板，由作者在三种处置中择一。对象 MUST NOT 静默覆盖自身。

#### Scenario: 冲突检出与处置

- **WHEN** 新素材或新剧情与既有对象实例存在实质差异（非纯笔误）
- **THEN** 系统 MUST 输出差异对比面板（旧值 vs 新值，逐字段），并提供三个选项：① 保留旧实例 ② 覆盖为新实例 ③ 合并取部分字段
- **AND** 选择 MUST 由作者做出；选「覆盖」时 MUST 先把旧版本归档到 `history/<card-id>/<date>.md` 再写新版（沿用 v1.0 差异归档约定）
- **AND** 纯笔误/格式修正 MAY 直接出更新提案而无需归档

### Requirement: 渲染阶段与文字即视图

系统 SHALL 在对象状态确定后，按 timeline 顺序调用参与对象的 `render()` 方法序列化拼接为章节正文。正文 MUST 是对象模型的可视化投影，底层资产模型才是唯一可信源。

#### Scenario: 渲染产出正文

- **WHEN** `ChangePlan` 已 patch 落地且对象状态稳定
- **THEN** `StoryWorld.export()` / `nc-成稿` MUST 按 timeline 顺序遍历参与对象，依次调用各自 `render()` 拼接成 `manuscript/chapter-*.md` 初稿（走提案制，作者校阅后落盘）
- **AND** 渲染 MUST 消费对象当前状态（人设/道具/感官信号/动向刻度），使同姿态跨场景一致、不出现 OOC 或前后矛盾
- **AND** 文稿落盘后 MUST 保留底层对象模型不变；后续改剧情 MUST 改对象状态再重新渲染，MUST NOT 直接手改正文导致对象与文本脱节

### Requirement: 长短篇模式对方法集的门控

系统 SHALL 依据 `StoryWorld.config.mode`（short/mid/long）门控哪些子类方法启用，与既有 `registry/work-length-config.yaml` 分级矩阵对齐。

#### Scenario: 模式门控

- **WHEN** `mode: short`
- **THEN** MUST 禁用复杂 `DarkLine.check_converge()` 暗线收敛跟踪与长期 `disposition_slide` 动向轨道，仅保留 `Role`/`Prop`/`Scene`/`PlotBeat` 轻量化实例
- **AND** `mode: mid` MUST 启用基础暗线与简单动向轨道
- **AND** `mode: long` MUST 全量启用：快照 `restore()`、时序 `step()`、感官 cue 衰减、伏笔收敛校验
- **AND** 门控结果 MUST 与 `references/loop.md` 长短篇分级矩阵及 `config/skills.yaml` 技能启用集一致，不得出现 OO 门控与既有分级矩阵互相矛盾
