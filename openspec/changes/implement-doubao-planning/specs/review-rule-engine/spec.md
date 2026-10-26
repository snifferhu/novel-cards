# Spec Delta

## Purpose

提供机器可读校阅规则库（rules.json）能力：全局开关配置 + auto_enable_map 自动联动 + 三级错误分级（L1_HARD/L2_WARN/L3_INSPIRATION）+ 12 条规则条目（SENSE/FOCUS/HORMONE/COG/CAUSAL/SPACE/PERSON/CUE/PROP/BEAT/FACTION/SNAP），作为 nc-校阅 的规则驱动源，使校验逻辑从散落的自然语言描述收敛为结构化、可版本化、可跨端复用的规则集。

## ADDED Requirements

### Requirement: 规则库文件契约

系统 SHALL 在使用方工程 `config/review-rules.json`（或等价路径）承载机器可读规则库，顶层结构含：`spec_version` / `global_switch`（world_base_profile/profile_override/各 check_* 开关）/ `auto_enable_map`（simple/deep 两套子模块默认值）/ `error_level`（三级定义）/ `rule_set`（规则条目数组）/ `personality_baseline_pool` / `personality_slide_axes`。本仓库内该文件只以骨架 / 模板形式存在，真实取值由使用方工程经 nc-初始化 生成。

#### Scenario: 规则库缺失降级

- **WHEN** 使用方工程无 `config/review-rules.json`
- **THEN** nc-校阅 降级为纸面校验（按 SKILL.md 硬规则 + references 自然语言规则执行），不报错、不阻断

#### Scenario: 规则库加载

- **WHEN** `config/review-rules.json` 存在且 JSON 合法
- **THEN** nc-校阅 按 rule_set 逐条匹配卡片 frontmatter 字段执行校验，输出结果带 rule_id 标注

### Requirement: 三级错误分级

每条规则 MUST 声明 `level` 取值之一：`L1_HARD`（客观硬性冲突，必须修改）/ `L2_WARN`（合理性商榷，可填 override_note 豁免）/ `L3_INSPIRATION`（创作启发，非校验项）。nc-校阅 输出 MUST 按三级分组呈现，L1 附修改方案，L2 附「补充动机备注豁免」或「微调描写贴合逻辑」两种处理选项。

#### Scenario: L1 硬错输出

- **WHEN** 失明角色配置视觉焦点动线（FOCUS_001 L1_HARD）
- **THEN** nc-校阅 输出 🔴 L1_HARD 区块，附具体修改方案（移除焦点动线或修正 sense_mask）

#### Scenario: L2 商榷豁免

- **WHEN** 焦点顺序违背注意力权重（FOCUS_001 deep L2_WARN），作者填 `override_note: "主角刻意搜寻玉佩"`
- **THEN** 该校验项被豁免，不再出现在告警列表

### Requirement: 12 条核心规则条目

rule_set SHALL 至少包含 12 条规则，覆盖 SENSE / FOCUS / HORMONE / COG / CAUSAL / SPACE / PERSON / CUE / PROP / BEAT / FACTION / SNAP 十二个校验域，每条含 `rule_id` / `title` / `level` / `simple` / `deep` / `deps` 六字段。其中 SENSE_001 / CAUSAL_001 / SPACE_001 为 L1_HARD，FOCUS_001 在 simple 档为 L1_HARD（仅拦失明）、deep 档权重违和降 L2_WARN，其余八条均为 L2_WARN。

#### Scenario: 规则 ID 永久稳定

- **WHEN** 后续版本迭代修改某条规则的校验逻辑
- **THEN** rule_id MUST 保持不变（只改逻辑不改 ID），保证历史告警可追溯

#### Scenario: 规则跟随剖面切换

- **WHEN** `world_base_profile` 由 simple 切 deep
- **THEN** 各规则的 effective level 按 auto_enable_map 升级（如 FOCUS_001 从「仅拦失明」升级为「完整权重验算」）
