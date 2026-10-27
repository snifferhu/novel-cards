# 卡片 Schema（card-schema.md）

novel-cards v1.0 全部卡片类型的 frontmatter schema：通用五字段、各类型专属
字段、actor 非人类行动单元分类、item 黑盒三层建模与五感公理、pose 插槽填充
机制、module 积木 trigger_map、timeline 节点 bind_module 联动，以及 lexstat /
corpus / metric / sensory_cue / refwork 等新增类型的完整字段契约。

所有卡片必须包含「通用五字段」；各类型专属字段列在下方。模板位于 `templates/`。

> **面向对象透镜**：本 schema 描述的每张卡都是一个 `NcObject` 子类实例——通用五字段
> 是基类公共属性，各类型专属字段是子类特有属性，`render()` 把对象状态序列化为文本投影
> （正文 = 参与对象按 timeline 顺序 `render()` 拼接的结果）。完整类层次、方法契约与
> 「技能 → 方法」映射见 `references/oo-model.md`；事件驱动的连锁推演见
> `references/event-inference.md`。**OO 视角不改变任何字段契约**，仅换叙述框架。

## 通用五字段（必备）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 卡片唯一标识，含类型前缀，全局唯一；**前缀 MUST 与该类型的注册前缀一致** |
| `type` | enum | 卡片类型，见下方类型总表 |
| `status` | enum | 卡片生命周期状态，见「状态生命周期」节 |
| `created` | date | 首次创建时间（ISO 8601） |
| `updated` | date | 最近一次更新时间（ISO 8601），每次内容变更后同步 |

缺失任一字段视为非法卡。`nc-校阅` 审计时标记为 schema 违规并输出意见书。

### 类型与前缀总表

| type | id 前缀 | 目录 | 中文名 |
|---|---|---|---|
| `actor` | `ac-` | `cards/characters/` | 角色（叙事行动单元） |
| `plotpoint` | `pp-` | `cards/plotpoints/` | 桥段 |
| `item` | `it-` | `cards/items/` | 道具 |
| `scene` | `sc-` | `cards/scenes/` | 场景 |
| `foreshadow` | `fs-` | `cards/foreshadow/` | 伏笔 |
| `timeline` | `tl-` | `cards/timeline/` | 动线 |
| `faction` | `fa-` | `cards/factions/` | 势力 |
| `snapshot` | `sn-` | `cards/snapshots/` | 快照 |
| `darklayer` | `dk-` | `cards/darklayer/` | 暗线 |
| `module` | `md-` | `cards/modules/` | 积木模块 |
| `lexstat` | `lx-` | `cards/lexstats/` | 词频张力 |
| `corpus` | `co-` | `cards/corpus/` | 语料 |
| `metric` | `mt-` | `cards/metrics/` | 量化指标 |
| `pose` | `po-` | `cards/pose-bank/` | 姿态 |
| `sensory_cue` | `su-` | `cards/custom/sensory_cue/` | 感官标记 |
| `refwork` | `rw-` | `cards/custom/refwork/` | 对标作品档案 |
| `character_tendency` | `tend-` | `cards/tendencies/` | 角色动向（性格/心智倾向滑动标尺） |
| `reflection` | `rf-` | `reflections/`（**不进入 `cards/`**） | 反思卡 |

自定义类型经 `nc-注册` 写入 registry 白名单后，存放于 `cards/custom/<type>/`。

## 设定卡检索：容错、多候选与差异归档（v1.0 新增约定）

作者口述或输入设定对象时，**拼写错误、记忆偏差、同物异名**是常态。`nc-检索`
（及所有「更新已有卡」类技能）MUST 按以下规则处理，避免误伤或静默覆盖：

1. **模糊匹配 + 多候选返回**：检索不应只返回单一「最像」的结果。当存在多个
   可能对应同一设定的记录时（同名不同卡 / 别名 / 拼写近似），AI MUST 列出
   **全部候选**（含各自 id、关键差异点），请作者确认「是哪一张」或「其实是新
   设定」。禁止 AI 自行拍板选定唯一候选后直接改写。
2. **无历史 → 新建；有历史 → 填充**：若检索不到任何匹配，走「新建卡」流程；
   若命中已有卡，走「内容填充/更新」流程，复用其 id 与既有字段。
3. **差异不直接覆盖，先归档 history**：当要更新的卡与现有内容存在**实质差异**
   （非纯笔误修正）时，AI MUST NOT 原地覆盖。流程为：先把旧版本复制一份到
   `history/<card-id>/<updated-date>.md`（保留原 frontmatter + 正文快照），再
   出新版提案。这样任意一次设定变更都可回溯、可回滚。
4. **纯笔误/格式修正**可直接出更新提案，无需归档（在提案里注明「仅修正 X」）。

> 该约定对**所有卡类型**生效（actor / item / scene / faction / darklayer …）。
> `history/` 目录由 `install.sh --project` 预建；归档文件无 frontmatter 校验
> 要求，仅作只读快照。详见 `references/hard-rules.md` 与 `USAGE.md` FAQ。

## 状态生命周期

一般卡片（除 foreshadow、darklayer、reflection 外）：

```
draft → active → archived
```

- `draft`：初稿，正在完善中
- `active`：已进入正文使用，是主书的一部分
- `archived`：已废弃或替换，保留历史不删除

**特殊状态**：

- **foreshadow**：`planted` / `developing` / `resolved` / `unresolved` / `abandoned`
- **darklayer**：`hint` / `hinted` / `confirmed` / `revealed`
- **reflection**：`draft` / `reviewed` / `closed`
  - `draft`：初稿，`action_items` 尚未处理
  - `reviewed`：用户审阅完毕，`action_items` 处理中或部分处理
  - `closed`：全部 `action_items` 已处理（含跳过），反思卡归档
- **plotpoint**：额外支持 `official` / `candidate` / `archive` 三态（备选方案不会自动替换主线剧情）

## actor（角色卡，替代原 character）

> **OO 视角**：本卡 = `Role` 子类实例；`render()` 产出其人物描写投影。性格/心智倾向的
> 连续滑动经 `character_tendency`(`tend-`) 引用表达（`Role.act()`），姿态经 `pose`(`po-`)
> / `pose_refs` 引用（`Role.get_pose()`）。详见 `references/oo-model.md` §2.1。

`actor`（`ac-`）替代原 `character`（`ch-`）。定义为「拥有独立主观视角、可参与
桥段、可绑定感知/抽象动线、具备状态变化的叙事行动单元」，**与是否人类无关**。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 显示名 |
| `aliases` | ❌ | 别名字符串数组 |
| `classification` | ✅ | 分类标签（不锁死枚举），见下 |
| `affiliation` | ❌ | 所属势力 id |
| `first_appearance` | ✅ | 首次出场章节 |
| `cross_ref` | ❌ | 与 item 等的互相引用 id 数组（器灵觉醒场景用） |
| `base_bounds` | ❌ | 角色基础包围盒：`height` / `width` / `depth`（米），供 SPACE_001 校验；缺省 = 不做空间推演 |
| `pose_bounding_map` | ❌ | 各姿态包围盒映射，键为姿态名（如 `stand` / `sit` / `crouch`），值为 `{h, w, d}`；deep 模式据此判定姿态是否超出所在场景净空间 |
| `sensory_mask` | ❌ | 七通道感官掩码对象：`sight` / `hearing` / `smell` / `taste` / `touch` / `vestibular` / `interoception`，取值 `ok` / `disabled`；某通道 `disabled` 时该角色禁止生成对应感官描写与动线（nc-校阅 抛 SENSE_001 L1_HARD） |

**分类标签**（frontmatter 打标，不锁死枚举）：

| 标签 | 含义 |
|---|---|
| `protagonist` | 主角 |
| `supporting` | 配角 |
| `extra` | 路人 |
| `creature` | 生灵（蛤蟆·异兽） |
| `object-spirit` | 器物灵体（会跑的桌子·宝剑器灵） |
| `force` | 抽象意志 |
| `phantom` | 幻影残魂 |

**actor 与 item 的区分规则**：

- `actor` = 主动：能发起动作、有主观感知、有欲望动机
- `item` = 默认被动
- 一旦道具拥有独立意志主动行动，SHALL 建模为 `actor`（标签 `object-spirit`），
  原 `item` 卡保留物理本体描述，两卡通过 `cross_ref` 互相引用

最小示例（蛤蟆主角）：

```yaml
---
id: ac-frog-lead
type: actor
status: draft
created: 2026-10-22
updated: 2026-10-22
name: 蛤蟆甲
classification: creature
first_appearance: chapter-001
---
```

## plotpoint（桥段卡）

> **OO 视角**：本卡 = `PlotBeat` 子类实例；`render()` 产出其情节段落投影，`fire()` 在
> 前置条件满足时引爆并派发事件给在场对象。详见 `references/oo-model.md` §2.5。

| 字段 | 必填 | 说明 |
|---|---|---|
| `chapter` | ✅ | 所在章节 |
| `summary` | ✅ | 一句话摘要 |
| `participants` | ✅ | 相关对象 id 数组（actor/item/scene） |
| `lexstat_bind` | ❌ | 绑定的词频张力卡 id（`lx-*`） |
| `module_list` | ❌ | 引用的积木模块 id 数组（`md-*`） |
| `pose_refs` | ❌ | 引用的姿态卡 id 数组（`po-*`） |
| `foreshadow_links` | ❌ | 关联伏笔 id 数组（`fs-*`） |
| `strategic_burst` | ❌ | 是否战略爆点（boolean，触发节奏豁免） |
| `pivotal` | ❌ | 是否关键转折（boolean） |
| `tension_base` | ❌ | 基础张力值 1~10（BEAT_001 张力密度校验依据） |
| `is_strategic_climax` | ❌ | 是否战略高潮（与 `strategic_burst` 语义等价，二选一使用；同时为 true 时以 `strategic_burst` 为准） |
| `beat_type` | ❌ | 桥段类型：`normal` / `foreshadow` / `payoff` / `turning` / `climax` / `resolution` |
| `sequence_index` | ❌ | 章节内顺序索引（BEAT_001 张力曲线排序） |
| `precondition_beat_ids[]` | ❌ | 前置桥段 id 数组（pp-*），本桥段发生前 MUST 已发生 |
| `postcondition_beat_ids[]` | ❌ | 后置桥段 id 数组（pp-*），依赖本桥段结果 |
| `foreshadow_link` | ❌ | 伏笔链路对象：`plant_beat_id` / `payoff_beat_id`（pp-*） |
| `mood_shift_summary` | ❌ | 情绪转变摘要（如「从容→警觉」） |
| `personality_trigger_actor_ids[]` | ❌ | 触发性格变动的角色 id 数组（ac-*），联动 tend-* 动向卡 |
| `actor_involved_ids[]` | ❌ | 参与角色 id 数组（ac-*） |
| `prop_involved_ids[]` | ❌ | 参与道具 id 数组（it-*） |
| `cue_trigger_ids[]` | ❌ | 触发的感官标记 id 数组（su-*） |
| `space_id` | ❌ | 场景 id（sc-*），SPACE_001 空间校验依据 |

最小示例：

```yaml
---
id: pp-entry-scene
type: plotpoint
status: draft
created: 2026-10-22
updated: 2026-10-22
chapter: chapter-003
summary: 女主入场名场面，多感官同步启动
participants: [ac-female-lead, ac-host]
lexstat_bind: lx-ch03
module_list: [md-action-entry]
foreshadow_links: [fs-hairpin]
strategic_burst: false
---
```

## item（道具卡，黑盒三层建模）

> **OO 视角**：本卡 = `Prop` 子类实例；`render()` 产出其道具描写投影，`move_to()` 表达
> 动线位置变更、`emit_sensory()` 释放感知层信号。一旦拥有独立意志主动行动则升级为
> `Role`（object-spirit），原 `Prop` 保留物理本体，经 `cross_ref` 互引。详见
> `references/oo-model.md` §2.2。

`item`（`it-`）SHALL 支持黑盒三层内部结构。默认黑盒模式：作者只自然描述道具，
skill 自动拆解写入图森林；高级模式开关打开后展示三层分区并允许手动调整感知
track 绑定。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 道具名 |
| `owner` | ❌ | 当前持有者 id（可为空表示无主） |
| `origin` | ✅ | 来源描述 |
| `last_seen` | ✅ | 最近出现章节 |
| `blackbox` | ❌ | 三层结构对象（见下），黑盒模式由 skill 自动填充 |
| `advanced_mode` | ❌ | boolean，打开后展示三层分区并允许手动调整感知 track 绑定 |
| `cross_ref` | ❌ | 与觉醒 actor 的互相引用 id |
| `physics` | ❌ | 物理参数对象：`bounding`（h/w/d）/ `mass` / `hardness` / `portable` / `penetrable`（SPACE_001 穿墙校验依据） |
| `state_list[]` | ❌ | 道具状态列表，每条含 `state_name` / `description` / `linked_sensory_cue_id`（su-*） |
| `perception_trace` | ❌ | 五感感知轨迹对象（visual/auditory/olfactory/gustatory/tactile + `perception_alias`） |
| `foreshadow_timeline` | ❌ | 伏笔时序图谱：`pre_plant` / `pickup` / `hint_degree`（1~10） |
| `interact_rule` | ❌ | 交互规则描述 |
| `owner_history[]` | ❌ | 持有者流转历史，每条含 `chapter` / `owner_id`（ac-*）/ `event_note` |

**黑盒三层**（`blackbox` 对象内部分区）：

- **物理层**（`physical`）：材质、尺寸、耐久、限制、使用条件、客观规则
- **感知层**（`perceptual`）：五感映射（visual / auditory / olfactory / gustatory / tactile）
- **抽象非感知层**（`abstract`）：绑定权力、秘密、记忆、宿命、信任等抽象 timeline，道具作为符号载体

最小示例（黑盒模式，作者自然描述后 skill 自动拆解）：

```yaml
---
id: it-cursed-sword
type: item
status: draft
created: 2026-10-22
updated: 2026-10-22
name: 血脉诅咒之剑
origin: 旧宅密室取得
last_seen: chapter-042
blackbox:
  physical: {material: 玄铁, rule: 持握发烫}
  perceptual: {tactile: 温感, visual: 族徽}
  abstract: [tl-fate-line, tl-blood-secret]
---
```

### 五感公理

感知动线的根（track root）**MUST 落在人类原生五感之一**：视觉 / 听觉 / 嗅觉 /
味觉 / 触觉（温·压·痛·肌理）。玄幻衍生感知 SHALL 建模为对应五感的子标签变体，
**MUST NOT 新增脱离五感底层的独立感知大类**：

| 玄幻衍生感知 | 归入五感根 | 子标签形态 |
|---|---|---|
| 灵识/神念扫描 | 触觉 | 回声定位型探测（雷达·声呐） |
| 神视/天眼 | 视觉 | 延伸（穿透·望远·透视·多波段） |
| 灵嗅/辨息 | 嗅觉 | 超距高分率版 |
| 灵味/道韵尝感 | 味觉 | 抽象化 |
| 神魂刺痛/震颤 | 触觉 | 痛觉/压力投射到精神层面 |

非感知抽象动线（权力/秘密/记忆/欲望/宿命/张力/信任）与感知动线平行，互不侵占，
可通过 `nc-注册` 自由扩展。

## scene（场景卡）

> **OO 视角**：本卡 = `Scene` 子类实例；`render()` 产出其环境铺陈投影，`enter(role)`
> 刷新环境插槽并向场内广播 `SensoryCue`、`refresh_env()` 更新环境变量供 pose 插槽 P2
> 填充消费。详见 `references/oo-model.md` §2.3。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 场景名 |
| `location` | ✅ | 地理或叙事位置描述 |
| `first_appearance` | ✅ | 首次出现章节 |
| `atmosphere` | ❌ | 基调关键词 |
| `recurrence` | ❌ | 是否重复出现 |
| `usable_clearance` | ❌ | 空间净空对象：`width` / `depth` / `height`（米），供 SPACE_001 包围盒校验；缺省 = 不触发空间物理推演 |
| `mobility_constraint` | ❌ | 活动约束对象：`can_stand` / `can_jump` / `can_spread_arms_wide`（boolean）；缺省 = 无约束 |
| `obstacle_list` | ❌ | 障碍物数组，每项含 `name` / `penetrable`（boolean）；`penetrable: false` 的障碍 MUST NOT 被角色穿过（双模式共用硬规则） |
| `env_note` | ❌ | 环境备注（如「密闭车厢，头顶距座椅约 30cm」） |

**space_snapshot 子形态**（v1.0 增量，复用 `scene` type，不新建类型）：对密闭 / 狭小场景
（小轿车 / 电梯 / 轿厢 / 密室等）声明 `usable_clearance` + `mobility_constraint` +
`obstacle_list` 后，该场景即成为 SPACE_001 空间校验的输入。deep 模式下绑定此场景的桥段
将触发姿态包围盒 vs 净空间的 L1 推演；simple 模式仅拦离谱穿墙 / 穿固体。开阔场景
（`usable_clearance` 各维度 ≥ 3.0 且 `mobility_constraint` 全 true）不触发任何空间告警。
存量 scene 卡缺失上述字段时行为不变（向后兼容）。

## foreshadow（伏笔卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 伏笔简述 |
| `planted_at` | ✅ | 埋设章节 |
| `payoff_chapter` | 条件必填 | 回收章节（与 `status: unresolved` 二选一） |
| `seed_character` | ❌ | 埋设人物 id |
| `related_items` | ❌ | 相关道具 id 数组 |
| `reveal_tier` | ❌ | `early` / `mid` / `finale` 暗示回收时机 |

**硬规则约束**：`status: resolved` 时必须有 `payoff_chapter`；
`status: unresolved` 时 `payoff_chapter` 可缺。详见 `hard-rules.md`。

## timeline（动线卡，节点由积木驱动）

> **OO 视角**：本卡 = `StoryTrack` 子类实例；`step(timeline)` 沿时间轴推进输出下一节点
> 状态变更（经 `bind_module` 联动多对象）。详见 `references/oo-model.md` §2.6。

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 动线主题名 |
| `track` | ✅ | 追踪对象类型：`character` / `item` / `faction` / `place` / `other` / 已注册的自定义类型 |
| `target` | 条件必填 | 追踪对象 id（`ac-*` / `it-*` / `fa-*` / `sc-*`；`track: other` 时可省） |
| `first_seen` | ✅ | 首次出现章节 |
| `nodes` | ✅ | 节点数组，每节点 SHOULD 含 `node_id` / `bind_module` / `trigger_foreshadow` / 爆点标注 |
| `mentions` | ❌ | 简要关系交汇点数组 |
| `graph` | ❌ | 关联图谱 HTML 相对路径 |

**节点结构**：每个节点 SHOULD 通过 `bind_module` 字段绑定一个 pose/module 积木；
未绑定 module 的孤立节点仅允许用于简单线性记录。

最小示例（发型动线，节点绑定积木）：

```yaml
---
id: tl-hairstyle
type: timeline
status: draft
created: 2026-10-22
updated: 2026-10-22
title: 女主发型动线图谱
track: character
target: ac-female-lead
first_seen: chapter-003
nodes:
  - chapter: 3
    node_id: node_01
    desc: 高髻严整，玉簪固定
    bind_module: md-action-entry
    trigger_foreshadow: fs-hairpin
  - chapter: 14
    node_id: node_02
    desc: 玉簪取下，长发散落
    bind_module: md-action-unpin
    burst: 中型情绪爆点
---
```

## faction（势力卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 势力名 |
| `leader` | ❌ | 领袖人物 id |
| `members` | ❌ | 成员人物 id 数组 |
| `goals` | ✅ | 势力目标描述 |
| `influence` | ❌ | 影响范围文本 |
| `core_purpose` | ❌ | 势力核心目的 |
| `core_rule` | ❌ | 势力核心规则 |
| `value_axis` | ❌ | 价值取向轴 |
| `leader_actor_id` | ❌ | 领袖角色 id（ac-*），与 `members[]` 互补 |
| `relation_map[]` | ❌ | 关系网络数组：`target_faction_id` / `relation_type`（ally/rival/hostile/subordinate/secret_collude）/ `relation_note` |
| `signature_cue_ids[]` | ❌ | 感官招牌 id 数组（su-*） |
| `default_reaction` | ❌ | 默认反应模式 |
| `restraint_factor` | ❌ | 克制因素 |
| `inner_factions[]` | ❌ | 内部派系数组：`sub_faction_name` / `advocate` / `leader_id` / `divergence_note` |
| `controlled_prop_ids[]` | ❌ | 控制的道具 id 数组（it-*） |
| `controlled_scene_ids[]` | ❌ | 控制的场景 id 数组（sc-*） |

## snapshot（快照卡，时间锚点状态切片）

> **OO 视角**：本卡 = `Snapshot` 子类实例；`restore()` 回滚整套对象到该快照记录的状态，
> 供前后对比与逻辑校验。详见 `references/oo-model.md` §2.8。

❌ **不是**：姿势库、插画、动态素材库。
✅ **定义**：在某确定章节/时间锚点上，一套锁定的、瞬时的全局状态切片；可单聚焦
actor，也可定格场景内多方角色/道具/势力/动线状态。用途：前后对比、校验逻辑
（"这一刻角色知不知道秘密？伤势多重？手里拿着什么？"）。

与 timeline 区别：timeline = 变化过程（曲线）；snapshot = 时间轴上钉点，拍下此刻
所有变量值。

| 字段 | 必填 | 说明 |
|---|---|---|
| `chapter` | ✅ | 快照对应的章节锚点 |
| `focus` | ✅ | 快照关注点（`world` / `faction` / `character-arc` 等） |
| `summary` | ✅ | 快照正文摘要 |
| `used_pose` | ❌ | 引用姿态卡 id（校阅时校验「此刻状态能否支撑该 pose」） |
| `related_cards` | ✅ | 关联卡片 id 数组 |
| `beat_id` | ❌ | 依附桥段 id（pp-*），本快照定格该桥段的瞬时状态 |
| `moment_tag` | ❌ | 时刻标签：`实拍` / `回忆` / `幻觉` / `传闻` / `梦境`（非实拍时 deep 模式放宽矛盾校验） |
| `base_space_id` | ❌ | 基础场景 id（sc-*），SPACE_001 空间校验依据 |
| `active_cue_ids[]` | ❌ | 此刻活跃的感官标记 id 数组（su-*） |
| `active_props[]` | ❌ | 此刻活跃道具 id 数组（it-*） |
| `perspectives[]` | ❌ | 多视角数组：`pov_actor_id` / `perception_text` / `cognition_bias` / `focus_point` / `known_info[]` / `unknown_info[]` |
| `objective_fact` | ❌ | 客观真相（独立于任何 POV 的事实描述，deep 模式矛盾校验基准） |
| `reuse_plans` | ❌ | 复用计划对象：`recall_beat_ids[]`（pp-*）/ `retell_by_actor_ids[]`（ac-*） |

## darklayer（暗线卡）

> **OO 视角**：本卡 = `DarkLine` 子类实例，独立命名空间；`check_converge()` 扫描全场判断
> 所挂接伏笔/桥段是否集齐、可否回收揭示。与主书对象**只**经 `references_to_main` 单向
> 引用串接。详见 `references/oo-model.md` §2.7。

> **语义定义（v1.0 扩展）**：暗线**不是仅指代角色**。它是「整条明面叙事中，
> 没有明说、需要读者自行推敲的隐性逻辑」——可以是一条贯穿全书的隐秘设定、
> 一组桥段背后的真实因果、一个角色的隐藏动机链，或多种混合。一张暗线卡
> 可以同时挂接多类主书对象（设定 / 桥段 / 角色 / 道具 / 势力），通过
> `references_to_main` 显式串接。判断标准：**读者读完全文后回看能发现「原来
> 如此」的那条暗逻辑**，就是暗线。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 暗线主题名 |
| `truth` | ✅ | 真相摘要（读者不可见的核心信息） |
| `surface_hint` | ✅ | 表面层如何暗示此暗线（可含多类对象的暗示点） |
| `implicit_kind` | ❌ | 隐性逻辑类型：`setting`（隐秘设定）/ `plot`（桥段真实因果）/ `character`（角色隐藏动机）/ `mixed`（混合，默认） |
| `references_to_main` | ✅ | 显式引用主书卡片 id 的数组（**唯一允许的连接方式**；可混合 ac-/pp-/it-/fa-/sc- 等多类前缀） |
| `reveal_chapter` | ❌ | 计划回收章节（未定时省略） |
| `reveal_tier` | ❌ | 揭示强度：`hint` / `hinted` / `confirmed` / `revealed` |

**硬规则约束**：暗线卡必须位于 `cards/darklayer/`；id 必须以 `dk-` 开头；
与主书卡片只通过 `references_to_main` 单向串接（**MUST NOT** 反向在主书卡里
写 `references_to_darklayer`，保持命名空间隔离）。详见 `hard-rules.md`。

## module（积木模块卡，最小调度单元）

> **OO 视角**：本卡是跨动线同步的唯一通道——`StoryTrack.step()` 经 `bind_module` 联动
> 多对象状态变更；`Prop.move_to()` 的跨动线同步 MUST 走 `trigger_map`，禁止零散写联动。
> 详见 `references/oo-model.md` §2.6 与 `references/event-inference.md` §2.2。

`module`（`md-`）是最小调度单元，其 `trigger_map` SHALL 可自由绑定任意数量、
任意 track 类型的 timeline 节点 + pose + 自定义类型卡片（symbol/metric 等），
**MUST NOT 锁死固定四感组合**。同一 module 可在不同章节复用，通过修改绑定的
动线节点产生不同效果。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 积木名称（如"推门入场姿态模块"） |
| `bind_scene` | ❌ | 绑定场景 id |
| `trigger_map` | ✅ | 积木联动：键为 timeline id，值为 `node_id`（+ 可选 pose/自定义卡引用） |
| `view_mod` | ❌ | 多视角视图模块（host_view / self_view / hidden_view 等） |
| `trigger_expect` | ❌ | 爆点预期：铺垫哪一级爆点 |

**跨动线同步变化 MUST 走 module 积木模块**，禁止在正文或动线卡里零散写联动。

最小示例（进门积木）：

```yaml
---
id: md-action-entry
type: module
status: draft
created: 2026-10-22
updated: 2026-10-22
name: 推门入场姿态模块
bind_scene: sc-main-parlor
trigger_map:
  tl-hairstyle: node_01   # 高髻固定，发簪就位
  tl-scent: node_01       # 冷木质香随气流扩散
  tl-light: node_01       # 自然光切断，切换室内顶冷白光
  tl-costume: node_01     # 挺括长裙，线条收敛
view_mod:
  host_view: 房主视角看到的画面（端庄、有距离感）
  self_view: 女主自我感知（清楚自己正在扮演符号）
  hidden_view: 暗线视角（dk-power-gaze：正在进入凝视结构）
trigger_expect: 情绪基线铺垫，为后续第14章发簪摘落爆点蓄力
---
```

## lexstat（词频张力卡）

> **OO 视角**：本卡是 `render()`（nc-成稿）的强约束输入——提供词频向量与感官均衡约束，
> 本身不出正文。草稿中的 `MoodLine`（情绪/张力走向）是其概念别名之一，映射到本卡的
> `tension_curve`（0~10 标尺）+ `metric`(`mt-`) 数值承载，MUST NOT 作为 frontmatter 字段
> 落地。详见 `references/oo-model.md` §5。

`lexstat`（`lx-`）是写稿环节的核心控制点，强约束：爆点段落高密词集中释放，
爆点之后强制留白，禁止持续堆叠感官描写。

| 字段 | 必填 | 说明 |
|---|---|---|
| `bind_chapter` | ✅ | 绑定章节 |
| `bind_plotpoint` | ❌ | 绑定桥段 id |
| `high_density_words` | ✅ | 高存在感、强冲击词（爆点区域使用） |
| `low_density_words` | ✅ | 淡词、留白词（过渡、收束、留白段落使用） |
| `forbidden_words` | ✅ | 破坏氛围、直白说教的词，本章禁用 |
| `tension_curve` | ✅ | 0~10 张力标尺：`start` / `rising` / `climax` / `release` |
| `blank_rule` | ✅ | 留白规则：爆点后强制留白段落数、禁止同句堆砌四种感官等 |
| `checklist` | ✅ | 校验指标清单 |

最小示例：

```yaml
---
id: lx-ch03
type: lexstat
status: draft
created: 2026-10-22
updated: 2026-10-22
bind_chapter: chapter-003
bind_plotpoint: pp-entry-scene
high_density_words: [审视, 灼热, 绷紧]
low_density_words: [静, 微凉, 缓]
forbidden_words: [哲学旁白, 直白说教]
tension_curve: {start: 3, rising: 6, climax: 9, release: 4}
blank_rule:
  climax_after_para: 爆点后强制留白 2 段，不继续堆描写
  avoid_overdescribe: [不要同时堆砌 4 种感官在同一个句子]
checklist:
  - 感官词密度是否超标
  - 隐喻词是否只留给可读懂暗线的读者
  - 是否存在直接哲学旁白
---
```

## corpus（语料卡）

`corpus`（`co-`）存放参考语料、风格样本，按语义标签分类，作为选词池。

| 字段 | 必填 | 说明 |
|---|---|---|
| `tags` | ✅ | 语义标签数组（感官描写/香氛/室内光影/克制情欲/留白短句等） |
| `source` | ✅ | 来源（摘抄/片段/参考文本/URL） |
| `purpose` | ❌ | 服务的桥段/动线 id |
| `text` | ✅ | 原始参考语料文本 |
| `extract` | ❌ | 人工萃取：可用词组、句式、氛围感表达（写作时直接参考） |
| `notes` | ❌ | 区分表层情欲描写词与深层思辨隐喻词，两类分开标记防止混同 |

最小示例：

```yaml
---
id: co-candlelight
type: corpus
status: draft
created: 2026-10-22
updated: 2026-10-22
tags: [室内光影, 感官描写]
source: 参考文本摘抄
purpose: 服务 tl-light
text: |
  烛火摇曳，光影在墙上拉长又缩短……
extract: |
  可用句式：「烛火 + 动词 + 光影位置变化」
notes: 表层光影词与深层凝视隐喻词分开标记
---
```

## metric（量化指标卡）

`metric`（`mt-`）挂载张力、爆点、信息载荷等量化指标，供长篇深度打磨与批量统计
分析使用；数值索引同步写入 `index/metric-index.json`。

| 字段 | 必填 | 说明 |
|---|---|---|
| `bind_range` | ✅ | 绑定的章节区间 |
| `dimensions` | ✅ | 指标维度（张力/爆点密度/信息载荷/五感释放节奏等） |
| `values` | ✅ | 各维度的数值条目 |

## pose（姿态卡，招牌动作库）

> **OO 视角**：本卡是 `Role.get_pose(state_id)` 消费的独立对象集合——桥段/快照经
> `pose_refs` / `used_pose` 引用，插槽填充遵循 P1>P2>P3 优先级。草稿中的 `pose_bank[]`
> （作为 Role 属性）是其概念别名，MUST NOT 作为 frontmatter 字段落地。详见
> `references/oo-model.md` §5。

`pose`（`po-`，存放于 `cards/pose-bank/`）解决跨场景复用一致性。一个 pose =
【固定内核（招牌不变）+ 环境变量插槽（每次调用替换）+ 多视角文案 + 使用约束】。
内核锁死不改，保证辨识度统一；插槽随环境/伤势/情绪变化，适配场景，不出戏。

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | ✅ | 姿态名 |
| `pose_tag` | ✅ | `signature` / `habit` / `combat` / `relax` / `special` |
| `core` | ✅ | 固定内核（招牌不变的部分） |
| `slots` | ✅ | 环境变量插槽定义（每次调用替换） |
| `slot_default` | ✅ | P3 兜底值（未绑定快照时用） |
| `multi_view` | ❌ | 多视角文案（host/self/hidden 等） |
| `extra_constraint` | ❌ | 使用约束（如"水下不可鼓腮"） |
| `pose_bounds` | ❌ | 姿态包围盒 `{h, w, d}`（米），对接 actor_bounding 空间校验；deep 模式 SPACE_001 据此判定 |
| `part_detail` | ❌ | 六部位细节对象：`head` / `shoulder` / `hand_arm` / `torso` / `leg_foot` / `facial_tendency` |
| `multi_view_module` | ❌ | 五视角文案对象：`view_self` / `view_front` / `view_side` / `view_back` / `view_distant` |
| `fit_mood` | ❌ | 适配情绪列表 |
| `unfit_mood` | ❌ | 不适配情绪列表 |
| `variant_text` | ❌ | 长短两版描写文本对象 `{short, full}` |

**插槽填充三级优先级**（MUST 遵循）：

1. **P1** 桥段本地手动覆写（`slot_override`）> 覆盖一切自动值
2. **P2** 当前时间锚点快照状态自动填充（默认，作者零填写，全章统一）
3. **P3** pose 默认兜底（`slot_default`，未绑定快照时，短篇常见）

填充后 MUST 跑 `extra_constraint` 校验（如"水下不可鼓腮"），冲突进入 `nc-校阅`
意见，不自动改文字。

最小示例：

```yaml
---
id: po-guard-stance
type: pose
status: draft
created: 2026-10-22
updated: 2026-10-22
name: 招牌戒备姿态
pose_tag: signature
core: 重心下沉，双肘护胸，目光锁定对方咽喉
slots:
  left_arm: {default: 垂落}
  right_hand: {default: 持械}
slot_default: {left_arm: 垂落, right_hand: 持械}
extra_constraint: 左臂受伤时左臂不得抬起
---
```

## sensory_cue（感官标记卡）

> **OO 视角**：本卡 = `SensoryCue` 子类实例；`broadcast()` 向绑定范围内 `Role` 广播
> 氛围信号，范围内角色自动 `perceive()` 捕获。详见 `references/oo-model.md` §2.4。

`sensory_cue`（`su-`，存放于 `cards/custom/sensory_cue/`）：声音/乐曲/气味/光影
等氛围触发器，可绑定角色/场景，供桥段引用；**本身不是剧情事件**，用于塑造标志性
氛围信号。

| 字段 | 必填 | 说明 |
|---|---|---|
| `cue_type` | ✅ | `sound` / `music` / `scent` / `light` / `atmosphere` |
| `bind_target` | ✅ | 绑定的角色/场景 id |
| `description` | ✅ | 氛围信号描述 |
| `sensory_signals[]` | ❌ | 五感信号数组，每条含 `sense_channel`（sight/hearing/smell/taste/touch）/ `perception_alias`（玄幻映射别名，写实留空）/ `signal_content` / `base_intensity`（1~10）/ `attenuation_rule`（distance/static/trigger）/ `max_distance` / `maskable` / `fade_note`；全部信号根 MUST 落在原生五感之一（延续五感公理） |
| `timeline_trace` | ❌ | 时序动线对象：`pre_visible_delay`（秒数）/ `sequence_rule[]`（信号到达顺序），实现「人未到声先至」；deep 模式校验时序合理性（CUE_001） |
| `attention_bias` | ❌ | 该信号对注意力的偏向影响 |
| `induced_mood_tendency` | ❌ | 诱导的情绪倾向 |
| `hormone_tendency` | ❌ | 激素反应倾向 |

最小示例（王熙凤笑声）：

```yaml
---
id: su-wang-laugh
type: sensory_cue
status: draft
created: 2026-10-22
updated: 2026-10-22
cue_type: sound
bind_target: ac-wang-xifeng
description: 人还没进院子，笑声先传过来，所有人安静下来
---
```

## refwork（对标作品档案卡）

`refwork`（`rw-`，存放于 `cards/custom/refwork/`）：外部参考作品档案，登记基础
信息，用于对标拆解。拆解产物带独立 `tree_id` 存于 card-graph.json 森林，与原创
主线隔离。

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 作品名 |
| `author` | ❌ | 作者 |
| `genre` | ❌ | 题材 |
| `study_focus` | ✅ | 拆解学习重点（伏笔回收手法/节奏/世界观等） |
| `tree_id` | ✅ | 归属子图标记（与原创主线隔离） |

## character_tendency（角色动向卡，性格/心智倾向滑动标尺）

> **OO 视角**：本卡是 `Role.act()` 依赖的独立对象——刻画角色性格/心智倾向的带触发事件
> 连续滑动标尺，依附角色（`target_role` 引用 `ac-*`）、经 `trigger_plot` 引用 `pp-*` 推手。
> 草稿中的 `disposition_slide:Track` 是其概念别名，MUST NOT 作为 frontmatter 字段落地。
> 详见 `references/oo-model.md` §2.1 与 §5。

`character_tendency`（`tend-`，存放于 `cards/tendencies/`）：刻画角色性格 / 心智
倾向的**带触发事件的连续滑动标尺**——有基准刻度、长期趋势方向、当前刻度，每一次
变动绑定一个具体桥段事件作为推手，而非凭空变性格。该卡**依附角色**（`target_role`
引用 `ac-` id），引用桥段（`trigger_plot` 引用 `pp-` id）作为变动原因。它 MUST NOT
替代角色基础卡（基线初始状态仍存于 `actor` 卡）。`nc-检索` 支持
`type:character_tendency` 与按角色过滤；`nc-校阅` 可校验动向逻辑冲突。

| 字段 | 必填 | 说明 |
|---|---|---|
| `target_role` | ✅ | 依附的角色 id（`ac-*`），本卡刻画该角色的某条倾向维度 |
| `dimension` | ✅ | 倾向维度名（如「克制↔放荡」「信任↔戒备」），两端语义须明确 |
| `baseline` | ✅ | 基准刻度（通常为 0，表示故事起点时的初始倾向位置） |
| `direction_rule` | ❌ | 长期趋势方向描述（如「长期向放荡偏移」「总体回稳」） |
| `current_value` | ✅ | 当前刻度值（= history[] 最后一条的 value） |
| `history` | ✅ | 变动历史数组，每条含 `{value, trigger_plot, description}`；`trigger_plot` 引用 `pp-*` 桥段 id 作为该次变动的推手事件 |
| `baseline_prototype` | ❌ | 可选：人格基线原型声明（registry-backed 枚举 key）。v1.0 提供爽文默认 6 原型（steadfast/fierce/cunning/righteous/reckless/greedy）+ deep 扩展 10 原型（avoidant/anxious/npd-grandiose/npd-vulnerable/bpd/aspd/hpd/melancholic/zealot/stoic），共 16 个原型，每个含六轴初始值（risk/empathy/impulse_control/trust/desire_orient/aggression，取值 -10~+10）+ `prototype_note`（滑动方向约束 + 适用身份 + 避雷点）。取值 MUST 经 `nc-注册` 写入 `registry/tendency-prototypes.yaml` 后方可使用；**一人一原型铁律**：一个角色 MUST 只绑定一个 `baseline_prototype`，MUST NOT 同时标记两个原型（多原型叠加抛 L1_HARD）；想要混合特质时选主原型后手动微调六轴数值。障碍类原型（bpd/aspd/npd-* 等）仅小说创作基线，不能作为临床诊断。详见 `references/personality-prototypes.md` |
| `notes` | ❌ | 补充说明（作者备注、与其他维度的联动等） |

> **铁律**：`history[]` 中每一条 MUST 绑定一个**已存在**的桥段卡（`trigger_plot`
> 指向真实 `pp-*` id），禁止无事件推手的凭空变性格。详见
> `references/hard-rules.md`「动向每次变动必须绑定已存在桥段」。

> **人格基线原型（可选）**：`baseline_prototype` 声明该维度标尺依附角色的人格基线
> 原型，只作**滑动边界的声明锚点**：维度与滑动逻辑仍完全由 `dimension` / `baseline` /
> `direction_rule` / `history[]` 表达，本字段 MUST NOT 替代或修改任何现有滑动字段
> 语义。v1.0 提供 16 个原型（爽文默认 6 + deep 扩展 10），每个含六轴初始值
> （risk/empathy/impulse_control/trust/desire_orient/aggression，取值 -10~+10）+
> `prototype_note`（滑动方向约束 + 适用身份 + 避雷点）。取值须先经 `nc-注册` 写入
> 使用方工程 `registry/tendency-prototypes.yaml`（条目含 `six_axes` 六轴初始值 +
> `prototype_note` + `boundary_hints`：`dimension_keywords` 子串匹配维度名 →
> `constrained_direction`（`higher`/`lower`/`both`）+ `max_drift` 容差 +
> `note` 提醒文案）；`nc-校阅` 检查 ④ 据此做**建议级**边界漂移提醒（沿受限方向
> 漂移超 `max_drift` 时提示而非禁止，作者可刻意写「受限维度缓慢松动」的反常弧光）。
> **一人一原型铁律**：一个角色 MUST 只绑定一个 `baseline_prototype`，MUST NOT 同时
> 标记两个原型（多原型叠加抛 L1_HARD）；想要混合特质时选主原型后手动微调六轴数值。
> 障碍类原型（bpd/aspd/npd-* 等）仅小说创作基线，不能作为临床诊断。
> 同一角色（同一 `target_role`）的多张 tend- 卡可共享同一原型 key，也可仅对受限
> 维度的卡声明；未声明的卡与存量卡行为完全不变。skill 仓库不内置锁死枚举，
> 16 原型的完整定义（六轴初始值 + prototype_note + 选型提问清单 + 快速对照表）
> 见 `references/personality-prototypes.md`。

最小示例（克制→放荡滑动标尺）：

```yaml
---
id: tend-lead-restraint
type: character_tendency
status: draft
created: 2026-10-23
updated: 2026-10-23
target_role: ac-frog-lead
dimension: 克制↔放荡
baseline: 0
direction_rule: 长期向放荡偏移
current_value: 3
history:
  - value: 1
    trigger_plot: pp-ch03-betrayal
    description: 被挚友背叛后第一次失控，开始怀疑自我约束的意义
  - value: 2
    trigger_plot: pp-ch17-fall
    description: 经历坠落与放纵，主动放弃部分克制
  - value: 3
    trigger_plot: pp-ch31-embrace
    description: 彻底接纳放荡面，不再压抑本能
notes: 与「信任↔戒备」维度联动，放荡度上升时戒备度同步下降
---
```

扩展示例（人格基线原型声明；`npd-*` 为文档示例，需经 `nc-注册` 写入
`registry/tendency-prototypes.yaml` 后方可使用）：

```yaml
---
id: tend-npd-empathy
type: character_tendency
status: draft
created: 2026-10-24
updated: 2026-10-24
target_role: ac-<slug>
dimension: 冷漠↔共情
baseline: -4
baseline_prototype: npd-grandiose
direction_rule: 共情端滑动受限；表演性关怀不计入共情上调
current_value: -3
history:
  - value: -3
    trigger_plot: pp-<slug>
    description: 假意安抚合作伙伴换取利益，表面上的「共情」小步上浮（漂移 1，未超 max_drift 2）
notes: npd-grandiose 共情 hint：constrained_direction higher、max_drift 2；漂移超 2（升至 -1 及以上）将触发 nc-校阅 检查④提醒
---
```

## reflection（反思卡）

| 字段 | 必填 | 说明 |
|---|---|---|
| `chapter` | ✅ | 复盘对象的章节 id（如 `chapter-050`） |
| `title` | ✅ | 复盘标题（一般等于章节标题 + 「复盘」） |

**正文结构（硬规则约束）**：正文必须包含以下五个二级标题，按顺序出现：

| 二级标题 | 内容 |
|---|---|
| `## stuck` | 卡点：写作过程中出现的具体卡点 |
| `## shone` | 亮点：本章写得顺畅、出彩、超出预期的段落 |
| `## why` | 归因：把卡点与亮点的根本原因拎出来 |
| `## insights` | 新认知：本章沉淀出的新认知 |
| `## action_items` | 反哺动作：把新认知落到具体的卡片修改上，markdown 任务列表 |

**位置约束**：必须位于 `reflections/`，**不得**放入 `cards/`。
**id 前缀**：`rf-`，命名 `rf-<chapter-id>`。

详见 `hard-rules.md` 与 `references/loop.md`。

## 长线四方对齐

长线道具/感官爆点 MUST 满足四方对齐：伏笔 `fs-` 卡、动线 `tl-` 节点、模块
`md-`、词频 `lx-` 卡提前 ≥8 章预埋，缺一即视为预埋不完整。`nc-校阅` 校验四方齐全。

例：第 3 章植入 `fs-hairpin`，计划第 14 章回收 → 该链路上 MUST 存在对应的
`tl-hairstyle` 节点、`md-action-entry`/`md-action-unpin` 模块、`lx-ch03`/`lx-ch14`
词频卡。

## 署名与多笔名（pen-name signing）

多书工程下，作品 / 章节的署名主体是「本工程署名 / 笔名」，经 `registry/pen-names.yaml`
白名单管理（骨架 only，经 `nc-注册` 写入；未注册取值拦截）。**与 `refwork.author` 正交**：
后者指外部对标作品的作者，本节约束的是本工程自身落款。

- **作品默认笔名**：`config/project.yaml` 的 `works[].default_pen_name` 引用
  `pen-names.yaml` 的 key（可选）；缺省时回落到工程级作者名（若有），否则留空，MUST NOT 报错。
- **章节级覆写**：`manuscript/chapter-*.md` 的 frontmatter MAY 含可选字段 `pen_name`
  （引用已注册笔名 key），覆写该章署名；未声明则用所属作品的 `default_pen_name`。
  这是与五必备字段并列的**可选项**，不改变任何卡片类型契约。
- **落款时机**：`nc-导出` 出成品、`nc-成稿` 提案头部按「章节 `pen_name` > 作品
  `default_pen_name` > 工程级作者名 > 留空」优先级取生效笔名。

## 字段命名规范

- 一律 snake_case
- 数组字段命名用复数（`participants` / `members` / `nodes`）
- 引用其他卡 id 的字段命名 `xxx_id` 或复数 `xxx_ids` / `xxx_list` / `xxx_refs` / `xxx_links`
- 时间字段统一 ISO 8601：`2025-01-15` 或 `2025-01-15T10:30:00Z`
