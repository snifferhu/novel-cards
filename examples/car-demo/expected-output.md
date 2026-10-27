# 小轿车闭环测试 Demo · 预期告警对照表

> 本文件为 `examples/car-demo/` 闭环测试 Demo 的预期输出对照表，用于验证
> nc-校阅 / nc-研判 / nc-检索 / nc-导出 四技能在 deep/simple 双模式下的行为差异。
> 所有角色/道具/桥段均为虚构假名（角色-甲 / 角色-乙 / 旧青玉佩 / 车厢），
> 不对应任何真实作品或人物。

## 1. 测试卡片清单（6 张，id 引用闭环）

| # | 文件 | id | type | 关键引用 |
|---|---|---|---|---|
| 1 | `sc-车厢.md` | `sc-车厢` | scene | usable_clearance.height: 1.15, can_stand: false |
| 2 | `ac-角色-甲.md` | `ac-角色-甲` | actor | base_bounds.height: 1.72, pose_bounding_map(sit/slouch/stand), sensory_mask 全 enabled |
| 3 | `tend-角色-甲.md` | `tend-角色-甲` | character_tendency | target_role: ac-角色-甲, baseline_prototype: steadfast, history[].trigger_plot: pp-车内争吵 |
| 4 | `it-旧青玉佩.md` | `it-旧青玉佩` | item | owner: ac-角色-甲, state_list[].linked_sensory_cue_id: su-jade-warm-01, foreshadow_timeline.pre_plant: chapter-003 |
| 5 | `pp-车内争吵.md` | `pp-车内争吵` | plotpoint | participants: [ac-角色-甲, ac-角色-乙, it-旧青玉佩, sc-车厢], space_id: sc-车厢, pose_refs: [po-斜倚握扇] |
| 6 | `sn-定格.md` | `sn-定格` | snapshot | beat_id: pp-车内争吵, base_space_id: sc-车厢, perspectives[] 双视角, objective_fact |

**id 引用闭环验证**：
- `tend-角色-甲`.target_role → `ac-角色-甲` ✅
- `tend-角色-甲`.history[].trigger_plot → `pp-车内争吵` ✅
- `it-旧青玉佩`.owner → `ac-角色-甲` ✅
- `pp-车内争吵`.participants → `ac-角色-甲` / `it-旧青玉佩` / `sc-车厢` ✅
- `pp-车内争吵`.space_id → `sc-车厢` ✅
- `sn-定格`.beat_id → `pp-车内争吵` ✅
- `sn-定格`.base_space_id → `sc-车厢` ✅
- `sn-定格`.perspectives[].pov_actor_id → `ac-角色-甲` / `ac-角色-乙` ⚠️（ac-角色-乙 无独立卡，属悬空引用——Demo 故意保留以验证 nc-校阅 能否检出）

## 2. deep/simple 双模式预期告警对照表

| 规则 ID | 校验域 | deep 模式预期 | simple 模式预期 | 触发条件 |
|---|---|---|---|---|
| SPACE_001 | SPACE | 🔴 L1_HARD：角色-甲 stand h:1.72m > sc-车厢净高 1.15m（若桥段含站立动作）；🔵 L2_WARN：slouch h:1.45m > 1.15m（可 override_note 豁免） | 仅拦穿墙硬错（penetrable: false 障碍被穿过），不校验包围盒 → **无 L1/L2** | sc-车厢.usable_clearance + ac-角色-甲.pose_bounding_map 均存在 |
| SENSE_001 | SENSE | 全七通道严格校验：角色-甲 sensory_mask 全 enabled → **不告警** | 仅拦失明硬错：sight: enabled → **不告警** | ac-角色-甲.sensory_mask 存在 |
| FOCUS_001 | FOCUS | 完整注意力权重验算：角色-甲 sight: enabled，视觉焦点动线合法 → **不告警** | 仅拦失明角色配置视觉焦点动线：sight: enabled → **不告警** | ac-角色-甲.sensory_mask.sight + pp-车内争吵.participants |
| PERSON_001 | PERSON | trust 轴 4→2 漂移 -2 在 max_drift:3 内 → **不告警**；若后续累计漂移 >3 → 🔵 L2_WARN | 不读取 prototype_note 约束 → **不告警** | tend-角色-甲.baseline_prototype: steadfast + registry/tendency-prototypes.yaml |
| CUE_001 | CUE | 感官标记触发条件未满足却广播 → 🔵 L2_WARN（若 su-jade-warm-01 触发条件与 pp-车内争吵 描述不符） | 不校验 → **不告警** | it-旧青玉佩.state_list[].linked_sensory_cue_id + pp-车内争吵.cue_trigger_ids |
| PROP_001 | PROP | 道具状态跳变无过渡 → 🔵 L2_WARN（若 default→active 无触发桥段支撑） | 不校验 → **不告警** | it-旧青玉佩.state_list + pp-车内争吵.participants |
| BEAT_001 | BEAT | tension_base:7 单章密度合理 → **不告警**；若同章 ≥5 个 tension≥7 非 strategic_climax → 🔵 L2_WARN | 不校验 → **不告警** | pp-车内争吵.tension_base + is_strategic_climax |
| FACTION_001 | FACTION | 势力关系网络一致性：本 Demo 无 faction 卡 → **不适用** | 不校验 → **不适用** | — |
| SNAP_001 | SNAP | 两视角 vs objective_fact：认知偏差属主观滤镜 → **不告警**；硬矛盾（如「拔刀」vs「无人持械」）→ 🔵 L2_WARN | 不校验 → **不告警** | sn-定格.perspectives[] + objective_fact |
| CAUSAL_001 | CAUSAL | 因果链完整性：pp-车内争吵.precondition_beat_ids: [pp-玉佩拾取] → 若 pp-玉佩拾取 不存在 → 🔴 L1_HARD | 同 deep（L1 双模式共用） | pp-车内争吵.precondition_beat_ids |

### 汇总

| 模式 | L1_HARD | L2_WARN | L3_INSPIRATION |
|---|---|---|---|
| **deep** | SPACE_001（若含站立动作）+ CAUSAL_001（若前置桥段缺失） | SPACE_001（slouch 超净空）+ PERSON_001（若漂移超限）+ CUE_001 + PROP_001 + BEAT_001 + SNAP_001（视具体数据） | 💡 五感细节增强建议 |
| **simple** | CAUSAL_001（若前置桥段缺失）+ SENSE_001（若失明硬错） | **无**（simple 档 L2 全关闭） | 💡 同上 |

> **关键差异**：deep 模式启用全部六子模块校验（check_visual_focus / check_vestibular /
> check_interoception / check_hormone_mutex / check_perception_defect / check_space_physics
> 全 true），simple 模式仅拦 L1 硬错（穿墙 + 失明 + 因果断裂），L2_WARN 全关闭。

## 3. 四条测试调用指令

以下四条指令在使用方工程中执行，验证四技能在 deep/simple 双模式下的行为差异：

### 3.1 nc-校阅（审计校验）

```bash
# deep 模式（config/project.yaml: world_base_profile: deep）
nc-校阅 --work <work-id>
# 预期输出：🔴 L1_HARD 区块（SPACE_001 站立超净空 / CAUSAL_001 前置桥段缺失）
#          + 🔵 L2_WARN 区块（SPACE_001 slouch 超净空 / PERSON_001 漂移 / CUE_001 / PROP_001 / BEAT_001 / SNAP_001）
#          + 💡 L3_INSPIRATION 区块（五感细节增强建议）

# simple 模式（config/project.yaml: world_base_profile: simple 或缺省）
nc-校阅 --work <work-id>
# 预期输出：仅 🔴 L1_HARD 区块（CAUSAL_001 前置桥段缺失 / SENSE_001 失明硬错）
#          + 💡 L3_INSPIRATION 区块
#          无 🔵 L2_WARN 区块
```

### 3.2 nc-研判（单点推演）

```bash
# deep 模式
nc-研判 --work <work-id> "角色-甲在车厢内站起来会怎样？"
# 预期输出：结构化分析报告 + 方案 A/B/C
#   方案 A：换场景（移至宽敞空间）
#   方案 B：换姿态（保持坐姿/sit h:1.20m ≈ 净高 1.15m 临界）
#   方案 C：override_note 豁免（玄幻体质/专项训练）
#   附 SPACE_001 L1_HARD 告警 + 修改建议

# simple 模式
nc-研判 --work <work-id> "角色-甲在车厢内站起来会怎样？"
# 预期输出：仅做素材登记，不做包围盒推演
#   报告不含 SPACE_001 告警（simple 档不校验包围盒）
```

### 3.3 nc-检索（资产检索）

```bash
# 跨类型检索
nc-检索 --work <work-id> "旧青玉佩"
# 预期输出：返回候选资产池
#   [item] it-旧青玉佩（owner: ac-角色-甲, state: default/active）
#   [plotpoint] pp-车内争吵（participants 含 it-旧青玉佩）
#   [snapshot] sn-定格（active_props 含 it-旧青玉佩）
#   [foreshadow] fs-jade-origin（关联伏笔）

# 按角色过滤
nc-检索 --work <work-id> --role ac-角色-甲
# 预期输出：返回角色-甲相关的全部资产
#   [actor] ac-角色-甲
#   [character_tendency] tend-角色-甲（target_role: ac-角色-甲）
#   [plotpoint] pp-车内争吵（personality_trigger_actor_ids 含 ac-角色-甲）
#   [snapshot] sn-定格（perspectives[].pov_actor_id: ac-角色-甲）
```

### 3.4 nc-导出（归档导出）

```bash
# 导出 chapter-012 相关卡片为 Markdown 合集
nc-导出 --work <work-id> --chapter chapter-012 --format md
# 预期输出：export/chapter-012-export.md
#   包含：sc-车厢 / ac-角色-甲 / tend-角色-甲 / it-旧青玉佩 / pp-车内争吵 / sn-定格
#   按 timeline 顺序排列（scene → actor → tendency → item → plotpoint → snapshot）
#   每卡含 frontmatter + 正文，末尾附 export_request.json 元数据

# 导出为 PDF（需 pandoc 环境）
nc-导出 --work <work-id> --chapter chapter-012 --format pdf
# 预期输出：release/chapter-012.pdf
#   build.sh 生成 export_request.json（include_cards: true, include_draft: false, include_index: true）
#   pandoc 渲染（build.sh 不调 pandoc，渲染交给 nc-导出）
```

## 4. 向后兼容验证

- **存量卡无新字段**：删除全部新增可选字段（usable_clearance / pose_bounding_map /
  sensory_mask / baseline_prototype / slide_axes / tension_base / perspectives[] 等）后，
  nc-校阅 行为与引入本能力前完全一致，MUST NOT 因缺字段报错
- **rules.json 缺失**：删除 config/review-rules.json 后，nc-校阅 降级纸面校验，
  不报错、不阻断
- **profile_override 覆写**：全局 deep + 某桥段卡 profile_override: simple →
  该桥段按 simple 规则校验，其余卡片仍按 deep 校验
