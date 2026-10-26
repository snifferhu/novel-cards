# Spec Delta

## Purpose

提供空间规则校验能力（SPACE_001），通过 `space_snapshot` 场景空间卡与 `actor_bounding` 角色包围盒卡，对密闭 / 狭小场景中的角色位移、肢体舒展、碰撞穿墙做物理合理性校验，防止「小轿车里站起来跳舞」类空间矛盾进入正文。

## ADDED Requirements

### Requirement: 场景空间快照卡

系统 SHALL 支持 `space_snapshot` 卡片类型（type: `scene`，复用现有 scenes 目录或经 nc-注册 扩展子类型），frontmatter 至少含五字段（id/type/status/created/updated）及空间专属字段：`usable_clearance`（width/depth/height）、`mobility_constraint`（can_stand/can_jump/can_spread_arms_wide）、`obstacle_list`（name/penetrable）、`env_note`。

#### Scenario: 小轿车场景声明

- **WHEN** 作者创建 space_snapshot 卡，`usable_clearance.height: 1.15`，`mobility_constraint.can_stand: false`
- **THEN** 该场景被标记为「净高不足直立」，后续绑定此场景的桥段在 deep 模式下触发 SPACE_001 校验

#### Scenario: 开阔场景无约束

- **WHEN** space_snapshot 卡 `usable_clearance` 各维度 ≥ 3.0 且 `mobility_constraint` 全 true
- **THEN** 该场景不触发任何空间 L1/L2 告警

### Requirement: 角色包围盒卡

系统 SHALL 支持 `actor_bounding` 数据（可作为 actor 卡扩展字段或独立卡），含 `base_bounds.height`、`pose_bounding_map`（各姿态 h/w/d）、`sensory_mask`（sight/hearing/smell/taste/touch/vestibular/interoception 七通道 ok/disabled）。

#### Scenario: 感官掩码联动

- **WHEN** 某角色 `sensory_mask.sight: disabled`
- **THEN** 该角色禁止生成视觉描写与视觉焦点动线；nc-校阅 检测到相关描写时抛出 L1_HARD（SENSE_001）

#### Scenario: 姿态包围盒映射

- **WHEN** 角色 `pose_bounding_map.stand = {h:1.72, w:0.46, d:0.32}`，所在场景 `usable_clearance.height: 1.15`
- **THEN** deep 模式判定站立姿态包围盒超出净空间，SPACE_001 抛 L1_HARD

### Requirement: 空间碰撞与位移校验

deep 模式下，nc-校阅 SHALL 对桥段中描述的角色动作执行空间推演：角色当前姿态包围盒 MUST 落在场景可用净空间内；位移路径 MUST NOT 被不可穿透障碍物完全封死而无通道说明。simple 模式仅拦截离谱穿墙 / 穿固体，大量玄幻爽文特权保留。

#### Scenario: 小轿车站立跳舞（deep）

- **WHEN** deep 模式，桥段描述男主在 `scene_car_01`（净高 1.15m）内「站起身踩座椅跳舞」
- **THEN** SPACE_001 抛 L1_HARD：内部净高不足成年人直立，包围盒冲突

#### Scenario: 小轿车站立跳舞（simple）

- **WHEN** simple 模式，同一桥段
- **THEN** 无 L1 硬错（爽文特权），最多 L3 启发提示

#### Scenario: 穿墙位移

- **WHEN** 任意模式，桥段描述角色穿过 `penetrable: false` 的障碍物完成移动
- **THEN** SPACE_001 抛 L1_HARD（双模式共用硬规则）

### Requirement: 狭小空间动作商榷（deep 专属）

deep 模式下，狭小环境中大幅度动作若无描写 / 心理铺垫，SHALL 抛 L2_WARN 提示触碰周边物体 / 重心失衡风险；可填 `override_note`（专项训练 / 刻意控制）豁免。

#### Scenario: 狭窄支点高难度动作

- **WHEN** deep 模式，角色在窄窗台做高难度平衡动作，无训练标注
- **THEN** SPACE_001 抛 L2_WARN：重心 / 平衡约束违和，建议补充铺垫或 override_note
