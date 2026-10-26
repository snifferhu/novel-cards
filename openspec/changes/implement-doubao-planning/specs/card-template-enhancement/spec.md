# Spec Delta

## Purpose

增强六套既有卡片模板（sensory_cue / pose-bank / item / plotpoint / faction / snapshot）的字段契约，使其承载 doubao 对话中提出的深度建模能力：五感信号组与时序动线、姿态包围盒与多视角、道具物理层与伏笔时序图谱、桥段张力参数与因果链路、势力关系网络与感官招牌、多视角快照与认知偏差。所有新增字段 MUST 保持向后兼容——存量卡缺失新字段时按默认值处理，行为不变。

## ADDED Requirements

### Requirement: 感官标记卡五感信号组

`sensory_cue` 卡（su-）MAY 含 `sensory_signals[]` 数组，每条含 `sense_channel`（sight/hearing/smell/taste/touch）/ `perception_alias`（玄幻灵觉映射别名，写实留空）/ `signal_content` / `base_intensity`（1~10）/ `attenuation_rule`（distance/static/trigger）/ `max_distance` / `maskable` / `fade_note`。一条 cue MUST 可含多条跨通道信号；全部信号根 MUST 落在原生五感之一（延续五感公理硬规则），玄幻衍生感知经 `perception_alias` 建模为子标签变体。

#### Scenario: 丁春秋随行靡乐

- **WHEN** sensory_cue 卡含 hearing（丝竹乐曲 intensity 5 max_distance 30 maskable true）+ smell（腐花香 intensity 4 max_distance 15）两条信号
- **THEN** deep 模式 nc-校阅 校验距离衰减与同通道掩蔽；simple 模式仅做素材登记

### Requirement: 感官标记时序动线

`sensory_cue` 卡 MAY 含 `timeline_trace`（`pre_visible_delay` 秒数 + `sequence_rule[]`）实现「人未到声先至」；deep 模式 SHALL 校验时序合理性（信号先于本体抵达），simple 模式只记录不校验。

#### Scenario: 声音先行登场

- **WHEN** cue `pre_visible_delay: 3`，`sequence_rule: [听觉先抵达, 嗅觉次之, 看见人影最后]`
- **THEN** deep 模式校验 3 秒延迟与角色位置 / 距离是否自洽；违和抛 L2_WARN（CUE_001）

### Requirement: 姿态库包围盒与多视角

`pose` 卡（po-）MAY 含 `pose_bounds`（h/w/d 对接 actor_bounding 空间校验）、`part_detail`（head/shoulder/hand_arm/torso/leg_foot/facial_tendency）、`multi_view_module`（view_self/view_front/view_side/view_back/view_distant）、`fit_mood` / `unfit_mood`、`variant_text`（short/full）。deep 模式 SHALL 调用 space_snapshot 校验姿态包围盒是否超出场景净空间；simple 模式仅作描写素材调用。

#### Scenario: 斜倚握扇姿态

- **WHEN** pose 卡 `pose_bounds: {h:1.65, w:0.65, d:0.75}`，绑定角色处于 `scene_car_01`（净高 1.15m）
- **THEN** deep 模式 SPACE_001 判定该姿态无法在车内呈现，抛 L2_WARN 提示换场景或换姿态

### Requirement: 道具卡物理层与伏笔时序

`item` 卡（it-）MAY 含 `physics`（bounding/mass/hardness/portable/penetrable）、`state_list[]`、`perception_trace`、`foreshadow_timeline`、`interact_rule`、`owner_history[]` 六组可选增强字段（逐字段定义见下方场景）。deep 模式 SHALL 校验状态切换逻辑与预埋-回收时序完整性；simple 模式仅登记。黑盒三层（physical/perceptual/abstract）铁律 MUST NOT 因新增字段而改变；新字段全部可选，缺失时 MUST 按现有行为处理（向后兼容）。

#### Scenario: 旧青玉佩状态切换

- **WHEN** item 卡 state_list 含 default（常态静置）/ active（触碰发热 linked cue_jade_warm_01）
- **THEN** deep 模式校验状态切换逻辑与 foreshadow_timeline 预埋-回收时序（第 3 章埋 → 第 27 章收）是否断裂

### Requirement: 桥段卡张力与因果链路

`plotpoint` 卡（pp-）MAY 含 `tension_base`（1~10）/ `is_strategic_climax` / `beat_type`（normal/foreshadow/payoff/turning/climax/resolution）/ `sequence_index` / `precondition_beat_ids[]` / `postcondition_beat_ids[]` / `foreshadow_link`（plant_beat_id/payoff_beat_id）/ `mood_shift_summary` / `personality_trigger_actor_ids[]` / `actor_involved_ids[]` / `prop_involved_ids[]` / `cue_trigger_ids[]` / `space_id` / `pose_refs[]`。deep 模式 SHALL 校验前置桥段是否提前发生、单章节爆点密度（战略爆点豁免）、预埋-回收链路完整性；simple 模式仅登记。

#### Scenario: 章节张力过密

- **WHEN** deep 模式，某章含 5 个 `tension_base ≥ 7` 且非 strategic_climax 的桥段
- **THEN** BEAT_001 抛 L2_WARN：张力密度过高，建议分散或标注战略爆点豁免

### Requirement: 势力卡关系网络与推演基线

`faction` 卡（fa-）MAY 含 `core_purpose` / `core_rule` / `value_axis` / `leader_actor_id` / `core_member_ids[]` / `relation_map[]`（target_faction_id/relation_type: ally/rival/hostile/subordinate/secret_collude/relation_note）/ `signature_cue_ids[]` / `default_reaction` / `restraint_factor` / `inner_factions[]`（sub_faction_name/advocate/leader_id/divergence_note）/ `controlled_prop_ids[]` / `controlled_scene_ids[]`。deep 模式 SHALL 校验敌对势力友好行为、盟友互相损害利益等逻辑矛盾；可 override_note 标记伪装 / 秘密交易豁免。

#### Scenario: 敌对势力异常友好

- **WHEN** deep 模式，faction A 与 B relation_type: hostile，但桥段描述 A 主动向 B 提供关键资源
- **THEN** FACTION_001 抛 L2_WARN：敌对关系下友好行为违和，需补充 secret_collude 标注或 override_note

### Requirement: 快照卡多视角与客观真相

`snapshot` 卡（sn-）MAY 含 `beat_id`（依附桥段）/ `moment_tag`（实拍/回忆/幻觉/传闻/梦境）/ `base_space_id` / `active_cue_ids[]` / `active_props[]` / `perspectives[]`（pov_actor_id/perception_text/cognition_bias/focus_point/known_info[]/unknown_info[]）/ `objective_fact` / `reuse_plans`（recall_beat_ids[]/retell_by_actor_ids[]）。deep 模式 SHALL 对比各 POV 描述与 objective_fact，检查无法解释的硬矛盾；认知偏差属正常主观滤镜不告警；矛盾可 override_note 标记幻境 / 错觉豁免。

#### Scenario: 双视角信息差

- **WHEN** snapshot 卡男主视角 unknown_info 含「对方内心是恐惧而非挑衅」，对手视角 cognition_bias 为「放大对方攻击性」，objective_fact 为「男主无动手意图」
- **THEN** deep 模式校验两视角与客观真相无硬矛盾（偏差属主观滤镜），不告警
