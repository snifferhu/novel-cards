# Spec Delta

## Purpose

提供防空炮铁律定调规范能力：以四大铁律（无卡不推演 / 人格不允许空炮 / 感官空间物理绝不脑补 / 不生成未定义剧情）+ 系统能力边界（能做 vs 绝对不做）+ 顶层一句话规范，作为 nc-研判 / nc-校阅 / nc-编排 三个技能的最高行为约束，根治 AI 推理中的空炮、脑补、超纲输出问题。本规范是行为契约而非实现细节，MUST 落进 SKILL.md body 与 references/anti-hallucination.md。

## ADDED Requirements

### Requirement: 无卡不推演铁律

nc-研判 / nc-校阅 / nc-编排 在执行任何剧情推演、行为判断、心理分析前，SHALL 先检查对应资产卡是否存在（角色 / 场景 / 道具 / 桥段）。缺少必要资产卡时 MUST 直接返回「资产不足，无法研判」，MUST NOT 基于想象补全设定后继续推演。

#### Scenario: 缺场景卡拒绝推演

- **WHEN** 作者要求「推演男主在车里站起来会怎样」，但工程内无对应 space_snapshot 卡
- **THEN** nc-研判 返回「资产不足：缺少场景空间卡，无法判断车内能否站立」，不自行假设车厢尺寸

#### Scenario: 缺角色动向卡

- **WHEN** 作者要求推演某角色反应，但该角色无 character_tendency 卡
- **THEN** nc-研判 提示需先经 nc-动向 建立性格滑动标尺，拒绝凭空推断性格

### Requirement: 人格不允许空炮铁律

deep 模式下，角色所有情绪、选择、克制、爆发 MUST 可由六轴基线 + prototype_note 约束解释。突破原型轴边界 MUST 同时满足：① 有触发事件记录（change_log 绑定桥段）② 填 override_note 备案 ③ 写入日志。三者缺一即视为空炮违规，nc-校阅 抛 L2_WARN。simple 模式豁免此约束。

#### Scenario: NPD 温柔示好判定为表演

- **WHEN** deep 模式，npd-grandiose 角色对女主温柔体贴
- **THEN** nc-研判 默认判定为「表演索取自恋供给」而非真实共情（empathy 上限锁死 ≤ -3），除非有重大弧光触发事件 + override 备案

#### Scenario: 稳守型无故黑化

- **WHEN** deep 模式，steadfast 角色在无触发事件情况下突然背叛盟友
- **THEN** PERSON_001 抛 L2_WARN：稳守型不无故黑化，需补充背叛触发事件或 override_note

### Requirement: 感官空间物理绝不脑补铁律

系统 MUST NOT 在缺少对应卡片时自行补全感官 / 空间 / 物理设定：无空间卡 → 不判断能否站立 / 移动；无姿态卡 → 不描写肢体细节；无道具卡 → 不触发道具效果。缺卡即停止推理，MUST NOT 自己补设定。

#### Scenario: 无道具卡不触发效果

- **WHEN** 正文提到「玉佩发烫」但工程内无该 item 卡的 active 状态定义
- **THEN** nc-校阅 提示「道具效果未定义」，不自行脑补发烫的触发条件与机制

### Requirement: 不生成未定义剧情铁律

所有剧情输出 MUST 遵守四原则：伏笔闭环（fs- 有 payoff_chapter 或 status: unresolved）、时序合法（precondition 先于 postcondition）、人格自洽（行为匹配当前标尺位置）、资产对应（引用的 id 全部存在）。MUST NOT 生成无铺垫反转、无依据心理活动、未定义剧情走向。

#### Scenario: 无铺垫反转拦截

- **WHEN** 桥段描述主角突然获得神秘力量，无任何前置伏笔卡
- **THEN** nc-校阅 抛告警：未铺垫反转违反伏笔闭环原则，建议先经 nc-伏笔 预埋

### Requirement: 顶层一句话规范

系统 SHALL 将「有卡有据、无卡停推、越界告警、转变留档、零空炮脑补」作为全局最高约束，落进 SKILL.md body 硬规则区与 references/anti-hallucination.md，所有 nc-* 技能推理输出 MUST 以此为准绳。

#### Scenario: 规范可见性

- **WHEN** 用户询问「这个工具会不会瞎编」
- **THEN** SKILL.md 中可查到防空炮铁律摘要，明确声明能力边界（能做：校验自洽 / 推演三分支 / 固化伏笔 / 标准化素材 / 批量改稿；绝对不做：脑补设定 / 凭空加情绪 / 强行圆 BUG / 无铺垫人设转变 / 无资产依据推演）
