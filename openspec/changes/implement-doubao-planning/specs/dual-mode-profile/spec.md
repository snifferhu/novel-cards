# Spec Delta

## Purpose

提供双模式剖面开关（simple/deep）能力，通过 `world_base_profile` 全局配置与 `profile_override` 单卡片局部覆写，控制 nc-校阅 / nc-研判 / nc-编排 三个技能的校验松紧度，使同一套卡片体系既能服务爽文快节奏创作，也能支撑深度写实推演。

## ADDED Requirements

### Requirement: 全局剖面开关

系统 SHALL 在 `config/project.yaml` 中支持 `world_base_profile` 字段，取值为 `simple` 或 `deep`，作为全局校验松紧度的唯一来源。未声明该字段的存量工程 MUST 视为隐式 `simple` 模式，全部技能行为与引入本能力前完全一致；MUST NOT 因缺字段报错或强制迁移。

#### Scenario: 显式声明 deep 模式

- **WHEN** `config/project.yaml` 含 `world_base_profile: deep`
- **THEN** nc-校阅 / nc-研判 / nc-编排 按 deep 规则集执行全链路严格校验（感官通道 + 前庭觉 + 内感受 + 激素互斥 + 感知缺陷 + 空间物理 + 性格滑动）

#### Scenario: 显式声明 simple 模式

- **WHEN** `config/project.yaml` 含 `world_base_profile: simple`
- **THEN** nc-校阅 / nc-研判 / nc-编排 仅拦截 L1 硬错误（感官权限冲突 / 空间穿墙 / 因果断裂），关闭前庭觉、内感受、激素互斥、动机一致性、感知缺陷精细校验

#### Scenario: 存量工程无该字段

- **WHEN** `config/project.yaml` 不含 `world_base_profile`
- **THEN** 系统按隐式 `simple` 处理，不报错、不强制迁移，技能行为与 v1.0 主体一致

### Requirement: 单卡片局部覆写

每张卡片 frontmatter MAY 含 `profile_override` 字段（取值 `simple` / `deep` / 缺省）。当 `profile_override` 存在且非空时，MUST 优先于全局 `world_base_profile` 生效，仅作用于该卡片及其直接关联的桥段 / 快照 / 动线节点；不得污染其他卡片的校验上下文。

#### Scenario: deep 工程中单段切 simple

- **WHEN** 全局 `world_base_profile: deep`，某桥段卡 frontmatter 含 `profile_override: simple`
- **THEN** 该桥段及其绑定资产按 simple 规则校验（关闭权重验算 / 激素互斥 / 空间包围盒精细推演），其余卡片仍按 deep 校验

#### Scenario: simple 工程中单段切 deep

- **WHEN** 全局 `world_base_profile: simple`，某幻境 / 心理博弈桥段卡 frontmatter 含 `profile_override: deep`
- **THEN** 该桥段按 deep 规则完整校验（启用注意力权重 / 感知缺陷 / 激素组合合理性），其余卡片仍按 simple 校验

#### Scenario: profile_override 非法值

- **WHEN** 某卡 `profile_override` 取值不在 `{simple, deep}` 集合内
- **THEN** nc-校阅 抛出 L2_WARN 提示非法取值，按全局 `world_base_profile` 兜底处理，不阻断流程

### Requirement: 子模块自动开关联动

切换 `world_base_profile` 时，系统 SHALL 按 auto_enable_map 预设映射自动启用 / 关闭六个子模块校验开关（simple 档五关全 false、`check_visual_focus` 仅拦失明硬错；deep 档五关全 true、`check_visual_focus` 升级完整权重验算），作者无需逐项手动配置。作者 MAY 在 `config/project.yaml` 显式覆盖任一子模块开关以突破默认联动；显式覆盖值 MUST 优先于自动联动结果。

#### Scenario: 切 deep 自动全开

- **WHEN** `world_base_profile` 由 `simple` 改为 `deep`，且作者未显式覆盖任何子模块
- **THEN** 五个子模块开关全部自动置 true，`check_visual_focus` 升级为完整权重验算

#### Scenario: 切 simple 自动精简

- **WHEN** `world_base_profile` 由 `deep` 改为 `simple`，且作者未显式覆盖任何子模块
- **THEN** 五个子模块开关全部自动置 false，`check_visual_focus` 降级为仅拦失明硬错

#### Scenario: 作者显式覆盖

- **WHEN** `world_base_profile: simple` 但作者显式设 `check_space_physics: true`
- **THEN** 空间物理校验保持开启，其余子模块仍按 simple 默认关闭
