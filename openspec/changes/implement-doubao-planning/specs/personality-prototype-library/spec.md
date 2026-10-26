# Spec Delta

## Purpose

提供人格基线原型库能力：爽文默认 6 原型 + deep 完整版 10 原型，配套六轴滑动标尺（risk/empathy/impulse_control/trust/desire_orient/aggression）、原型选型提问清单与快速选型对照表。原型取值 MUST 经 `nc-注册` 写入 registry 白名单后方可用于 `character_tendency` 卡的 `baseline_prototype` 字段，延续 v1.0 已有的「注册前置」铁律。

## ADDED Requirements

### Requirement: 爽文默认 6 原型

系统 SHALL 在 `registry/tendency-prototypes.yaml` 中提供 6 个爽文默认原型定义（steadfast/fierce/cunning/righteous/reckless/greedy），每个原型含：六轴初始值（-10~+10）、`prototype_note`（性格描述 + 滑动方向约束）。simple 模式下原型仅作素材参考，不读取 `prototype_note` 的滑动约束；deep 模式下突破轴边界抛 L2_WARN。

#### Scenario: 新建角色选 steadfast

- **WHEN** 作者经 nc-注册 确认使用 `steadfast` 原型，创建 character_tendency 卡 `baseline_prototype: steadfast`
- **THEN** 六轴初始值按原型定义加载（risk:-2/empathy:7/impulse:7/trust:4/desire:3/aggression:-2）

#### Scenario: simple 模式轴自由飘

- **WHEN** `world_base_profile: simple`，角色 `baseline_prototype: fierce`，某桥段后 aggression 从 6 跳到 9
- **THEN** 无告警（simple 不读 prototype_note 约束）

#### Scenario: deep 模式越界告警

- **WHEN** `world_base_profile: deep`，npd-grandiose 角色 empathy 从 -8 试图拉到 +2
- **THEN** PERSON_001 抛 L2_WARN：NPD 共情上限锁死，需 override_note + change_log 记录触发事件

### Requirement: Deep 完整版 10 原型

系统 SHALL 提供 10 个 deep 扩展原型（avoidant/anxious/npd-grandiose/npd-vulnerable/bpd/aspd/hpd/melancholic/zealot/stoic），每个原型含六轴初始值、`prototype_note`（含轴上下限约束）、适用身份说明、避雷点。所有障碍类原型 MUST 标注「仅小说创作基线，不能作为临床诊断」。

#### Scenario: BPD 大幅波动合法

- **WHEN** deep 模式，bpd 角色短时间内 risk 从 5 跳到 8、empathy 从 3 跳到 -2
- **THEN** 无告警（BPD 波动幅度极大是固有特征，prototype_note 声明允许）

#### Scenario: 回避型突然黏人

- **WHEN** deep 模式，avoidant 角色在无触发事件情况下 trust 从 -5 跳到 +5
- **THEN** PERSON_001 抛 L2_WARN：回避依恋不会突然疯狂黏人，需补充触发事件或 override_note

### Requirement: 一人一原型

一个角色 MUST 只绑定一个 `baseline_prototype`；MUST NOT 同时标记两个原型。想要混合特质时，SHALL 选主原型后手动微调六轴数值。

#### Scenario: 双原型叠加拒绝

- **WHEN** 某 character_tendency 卡 frontmatter 含 `baseline_prototype: [npd-vulnerable, bpd]`
- **THEN** nc-校阅 抛 L1_HARD：不支持多原型叠加，须选单一主原型

### Requirement: 原型选型辅助工具

系统 SHALL 提供原型选型提问清单（前置 Q0 模式选择 + 核心 5 问驱动力/情绪反应/信任模式/冲突策略/欲望导向）与快速选型对照表（适合身份/叙事优势/避雷点/推荐模式），作为 nc-角色 建卡时的引导参考，输出可直接入库的 baseline_prototype + 初始六轴建议。

#### Scenario: 选型问卷驱动建卡

- **WHEN** 作者说「新建一个写情感拉扯的女主」
- **THEN** nc-角色 引导回答选型问卷，推荐 avoidant 或 anxious 原型 + 对应六轴初始值，走提案制等用户确认
