# 机器可读校阅规则库（review-rules.md）

novel-cards v1.0 提供**机器可读校阅规则库**能力：使用方工程 `config/review-rules.json`
承载结构化规则集，作为 nc-校阅 / nc-研判 / nc-编排 的规则驱动源，使校验逻辑从散落的
自然语言描述收敛为结构化、可版本化、可跨端复用的规则集。本仓库内该文件只以骨架 /
模板形式存在（`templates/review-rules.json`），真实取值由使用方工程经 `nc-初始化` 生成。

## 1. 规则库文件契约

`config/review-rules.json` 顶层结构：

| 字段 | 类型 | 说明 |
|---|---|---|
| `spec_version` | string | 规则库 schema 版本号（如 `1.0`），用于向后兼容判定 |
| `global_switch` | object | 全局开关：`world_base_profile`（simple/deep）/ `profile_override`（不在此处声明，走各卡 frontmatter）/ 六个 `check_*` 子模块开关 |
| `auto_enable_map` | object | simple / deep 两套子模块默认值映射表（见 §2） |
| `error_level` | object | 三级错误分级定义（见 §3） |
| `rule_set` | array | 规则条目数组（见 §4），每条含 `rule_id` / `title` / `level` / `simple` / `deep` / `deps` 六字段 |
| `personality_baseline_pool` | array | 人格基线原型池引用（指向 `registry/tendency-prototypes.yaml` 的 key 列表） |
| `personality_slide_axes` | object | 六轴定义（risk/empathy/impulse_control/trust/desire_orient/aggression，取值 -10~+10） |

### 缺失降级铁律

- **WHEN** 使用方工程无 `config/review-rules.json`
- **THEN** nc-校阅 降级为纸面校验（按 SKILL.md 硬规则 + references 自然语言规则执行），
  不报错、不阻断；行为与引入本能力前完全一致
- **WHEN** `config/review-rules.json` 存在但 JSON 损坏（解析失败）
- **THEN** nc-校阅 抛出 L2_WARN 提示「规则库 JSON 损坏，已降级纸面校验」，继续执行
  既有纸面校验逻辑，不阻断流程
- **WHEN** `config/review-rules.json` 存在且 JSON 合法
- **THEN** nc-校阅 按 `rule_set` 逐条匹配卡片 frontmatter 字段执行校验，输出结果带
  `rule_id` 标注

## 2. auto_enable_map 联动表

切换 `world_base_profile` 时，系统 SHALL 按以下映射自动启用 / 关闭六个子模块校验开关：

| 子模块开关 | simple 档默认 | deep 档默认 |
|---|---|---|
| `check_visual_focus` | false（仅拦失明硬错） | true（完整权重验算） |
| `check_vestibular` | false | true |
| `check_interoception` | false | true |
| `check_hormone_mutex` | false | true |
| `check_perception_defect` | false | true |
| `check_space_physics` | false（仅拦离谱穿墙/穿固体） | true（包围盒/位移/重心全推演） |

**显式覆盖优先**：作者 MAY 在 `config/project.yaml` 或 `config/review-rules.json` 的
`global_switch` 中显式设置任一子模块开关以突破默认联动；显式覆盖值 MUST 优先于
auto_enable_map 自动联动结果。

详见 `references/data-layering.md` §3 与 `references/hard-rules.md` 规则 27。

## 3. 三级错误分级

| 级别 | 标识 | 语义 | 输出格式 | 豁免机制 |
|---|---|---|---|---|
| `L1_HARD` | 🔴 | 客观硬性冲突，必须修改 | 附具体修改方案（如「移除焦点动线或修正 sensory_mask」） | **不可豁免**，必须修改卡片或桥段描述 |
| `L2_WARN` | 🔵 | 合理性商榷，可填 override_note 豁免 | 附两种处理选项：①「补充动机备注豁免」（填 `override_note`）②「微调描写贴合逻辑」 | `override_note` + `change_log` 记录触发事件 |
| `L3_INSPIRATION` | 💡 | 创作启发，非校验项 | 附启发建议（如「此处可考虑加入五感细节增强沉浸感」） | 不适用（非告警） |

nc-校阅 输出 MUST 按三级分组呈现：先 🔴 L1_HARD 区块，再 🔵 L2_WARN 区块，最后
💡 L3_INSPIRATION 区块。L1 区块每条附修改方案；L2 区块每条附「补充动机备注豁免」或
「微调描写贴合逻辑」两种处理选项。

## 4. 12 条核心规则条目

`rule_set` SHALL 至少包含以下 12 条规则，覆盖十二个校验域。每条含 `rule_id` /
`title` / `level` / `simple` / `deep` / `deps` 六字段。

| # | rule_id | 校验域 | title | level | simple 行为 | deep 行为 | deps |
|---|---|---|---|---|---|---|---|
| 1 | SENSE_001 | SENSE | 感官通道权限校验 | L1_HARD | 仅拦失明硬错（`sensory_mask.sight: disabled` 却写视觉描写） | 全七通道严格校验（sight/hearing/smell/taste/touch/vestibular/interoception） | actor.sensory_mask, scene.env_note |
| 2 | FOCUS_001 | FOCUS | 视觉焦点注意力权重校验 | L1_HARD(simple) / L2_WARN(deep) | 仅拦失明角色配置视觉焦点动线（L1_HARD） | 完整注意力权重验算：焦点顺序违背权重 → L2_WARN（可 `override_note` 豁免） | actor.sensory_mask, plotpoint.participants, pose.multi_view |
| 3 | HORMONE_001 | HORMONE | 激素互斥组合合理性校验 | L2_WARN | 不校验 | 检测生理状态矛盾组合（如「极度疲惫」与「肾上腺素飙升同时持续 3 章」）→ L2_WARN | actor.base_bounds, snapshot.summary |
| 4 | COG_001 | COG | 认知一致性校验 | L2_WARN | 不校验 | 角色已知信息 vs 后续行为矛盾（如「已知对方是敌人仍无条件信任」无铺垫）→ L2_WARN | snapshot.known_info, plotpoint.summary |
| 5 | CAUSAL_001 | CAUSAL | 因果链完整性校验 | L1_HARD | 拦截因果断裂（A 导致 B 但中间缺关键因果环节） | 同 simple + 连锁因果推演（A→B→C 链每环须有桥段支撑） | plotpoint.participants, foreshadow.planted_at/payoff_chapter |
| 6 | SPACE_001 | SPACE | 空间物理合理性校验 | L1_HARD | 仅拦离谱穿墙/穿固体（`penetrable: false` 障碍被穿过） | 姿态包围盒 vs 场景净空 L1 推演 + 重心/平衡 L2 商榷（可 `override_note` 豁免） | scene.usable_clearance/mobility_constraint/obstacle_list, actor.base_bounds/pose_bounding_map |
| 7 | PERSON_001 | PERSON | 人格基线原型边界漂移校验 | L2_WARN | 不读取 prototype_note 约束（轴可自由飘动） | 沿受限方向漂移超 max_drift → L2_WARN（需 `override_note` + `change_log`）；多原型叠加 → L1_HARD | tend.baseline_prototype, registry/tendency-prototypes.yaml |
| 8 | CUE_001 | CUE | 感官标记触发规则校验 | L2_WARN | 不校验 | 感官标记触发条件未满足却广播 / 终止条件已触发仍持续 → L2_WARN | sensory_cue.cue_type/bind_target, plotpoint.pose_refs |
| 9 | PROP_001 | PROP | 道具状态连续性校验 | L2_WARN | 不校验 | 道具状态跳变无过渡（如「完好」直接到「破碎」无破坏桥段）→ L2_WARN | item.state_list, plotpoint.participants |
| 10 | BEAT_001 | BEAT | 桥段张力参数合理性校验 | L2_WARN | 不校验 | 张力曲线突变无铺垫（tension 从 2 直跳 9 无 rising 段）→ L2_WARN | lexstat.tension_curve, plotpoint.is_strategic_climax |
| 11 | FACTION_001 | FACTION | 势力关系网络一致性校验 | L2_WARN | 不校验 | 势力间声明关系 vs 实际桥段行为矛盾（如「同盟」却互相攻击无叛变铺垫）→ L2_WARN | faction.relation_map, plotpoint.participants |
| 12 | SNAP_001 | SNAP | 快照状态切片一致性校验 | L2_WARN | 不校验 | 快照定格状态 vs 前后章节实际状态矛盾（如「快照显示持剑」但下一章「手中空空」无解释）→ L2_WARN | snapshot.related_cards, plotpoint.participants |

### 规则 ID 永久稳定原则

`rule_id` MUST 永久不变——后续版本迭代修改某条规则的校验逻辑时，只改 `simple` /
`deep` 行为描述与 `deps` 依赖列表，**MUST NOT 更改 `rule_id`**。这保证历史告警
可追溯：旧版 nc-校阅 输出的 `SPACE_001` 告警与新版输出的 `SPACE_001` 告警指向同一
校验域，作者可在 CHANGELOG 中追踪规则逻辑演变。

### 规则跟随剖面切换

- **WHEN** `world_base_profile` 由 simple 切 deep
- **THEN** 各规则的 effective level 按 auto_enable_map 升级（如 FOCUS_001 从「仅拦失明」
  升级为「完整权重验算」，PERSON_001 从「不校验」升级为「边界漂移 L2_WARN」）
- **WHEN** 单卡 `profile_override: simple` 覆写全局 deep
- **THEN** 该卡及其直接关联资产按 simple 规则校验，其余卡片仍按 deep 校验

## 5. 与既有硬规则的协同

本规则库**不替代** `references/hard-rules.md` 的 28 条硬规则，而是为其提供**机器可读
的结构化驱动层**：

- hard-rules.md 是**自然语言权威**（人类可读的完整规则描述）
- review-rules.json 是**机器真值**（Agent 可解析执行的结构化规则集）
- 二者 MUST 保持一致：新增 / 修改 hard-rules.md 规则时，同步更新 review-rules.json
  对应条目；反之亦然
- 当二者冲突时，**hard-rules.md 优先**（它是人类权威），nc-校阅 应报告冲突并降级
  纸面校验

## 6. 骨架模板

本仓库 `templates/review-rules.json` 提供骨架示例（字段结构 + 占位，`rule_set` 给 1-2
条示例结构不给全量真实取值）。使用方工程经 `nc-初始化` 生成完整的 12 条规则取值。

```json
{
  "spec_version": "1.0",
  "global_switch": {
    "world_base_profile": "simple",
    "check_visual_focus": false,
    "check_vestibular": false,
    "check_interoception": false,
    "check_hormone_mutex": false,
    "check_perception_defect": false,
    "check_space_physics": false
  },
  "auto_enable_map": {
    "simple": {
      "check_visual_focus": false,
      "check_vestibular": false,
      "check_interoception": false,
      "check_hormone_mutex": false,
      "check_perception_defect": false,
      "check_space_physics": false
    },
    "deep": {
      "check_visual_focus": true,
      "check_vestibular": true,
      "check_interoception": true,
      "check_hormone_mutex": true,
      "check_perception_defect": true,
      "check_space_physics": true
    }
  },
  "error_level": {
    "L1_HARD": "客观硬性冲突，必须修改，不可豁免",
    "L2_WARN": "合理性商榷，可填 override_note 豁免",
    "L3_INSPIRATION": "创作启发，非校验项"
  },
  "rule_set": [
    {
      "rule_id": "SENSE_001",
      "title": "感官通道权限校验",
      "level": "L1_HARD",
      "simple": "仅拦失明硬错（sensory_mask.sight: disabled 却写视觉描写）",
      "deep": "全七通道严格校验（sight/hearing/smell/taste/touch/vestibular/interoception）",
      "deps": ["actor.sensory_mask", "scene.env_note"]
    },
    {
      "rule_id": "SPACE_001",
      "title": "空间物理合理性校验",
      "level": "L1_HARD",
      "simple": "仅拦离谱穿墙/穿固体（penetrable: false 障碍被穿过）",
      "deep": "姿态包围盒 vs 场景净空 L1 推演 + 重心/平衡 L2 商榷（可 override_note 豁免）",
      "deps": ["scene.usable_clearance", "scene.mobility_constraint", "scene.obstacle_list", "actor.base_bounds", "actor.pose_bounding_map"]
    }
  ],
  "personality_baseline_pool": [],
  "personality_slide_axes": {
    "risk": {"range": [-10, 10], "semantic": "负=规避风险/正=冒险"},
    "empathy": {"range": [-10, 10], "semantic": "负=冷漠/正=高共情"},
    "impulse_control": {"range": [-10, 10], "semantic": "负=易冲动/正=克制"},
    "trust": {"range": [-10, 10], "semantic": "负=戒备/正=开放"},
    "desire_orient": {"range": [-10, 10], "semantic": "负=克制欲望/正=即时满足"},
    "aggression": {"range": [-10, 10], "semantic": "负=温和/正=好斗"}
  }
}
```

> 以上 `rule_set` 仅给 2 条示例结构（SENSE_001 / SPACE_001），完整 12 条由使用方工程
> 经 `nc-初始化` 生成。`personality_baseline_pool` 为空数组（零预置，经 `nc-注册` 填充）。
