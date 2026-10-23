# Spec Delta

## Purpose

定义 novel-cards 体系全部卡片类型的 frontmatter schema：通用五字段、各类型专属字段、actor 非人类行动单元分类、item 黑盒三层建模与五感公理、pose 插槽填充机制、module 积木 trigger_map、timeline 节点 bind_module 联动，以及 lexstat / corpus / metric / sensory_cue / refwork / character_tendency（角色动向滑动标尺）等新增类型的完整字段契约。

## ADDED Requirements

### Requirement: 通用五字段必备

所有卡片（含新增类型）的 frontmatter MUST 至少包含 `id` / `type` / `status` / `created` / `updated` 五个字段；缺失任一视为非法卡。`id` 前缀 MUST 与该类型的注册前缀一致。

#### Scenario: 缺少 updated 字段
- **WHEN** 一张卡的 frontmatter 只有 `id` / `type` / `status` / `created`
- **THEN** `nc-校阅` 审计时标记为 schema 违规，输出意见书指出缺失字段

### Requirement: actor 类型替代 character

系统 SHALL 以 `actor`（id 前缀 `ac-`）替代原 `character`（`ch-`），定义为「拥有独立主观视角、可参与桥段、可绑定感知/抽象动线、具备状态变化的叙事行动单元」，与是否人类无关。frontmatter MUST 支持分类标签字段（不锁死枚举）：`protagonist` / `supporting` / `extra` / `creature` / `object-spirit` / `force` / `phantom`。

actor 与 item 的区分规则：actor = 主动（能发起动作、有主观感知、有欲望动机）；item = 默认被动；一旦道具拥有独立意志主动行动，SHALL 建模为 actor，原道具卡保留物理本体，两者通过 `cross_ref` 互相引用。

#### Scenario: 蛤蟆主角建卡
- **WHEN** 作者需要为一个蛤蟆主角建卡
- **THEN** 使用 `type: actor`、`id: ac-xxx`、分类标签 `creature`，无需另建特殊类型

#### Scenario: 器灵觉醒
- **WHEN** 某道具（宝剑）在剧情中觉醒独立意志并主动行动
- **THEN** 新建 `type: actor` 卡（标签 `object-spirit`），原 `type: item` 卡保留物理本体描述，两卡 `cross_ref` 互指

### Requirement: item 黑盒三层建模

`item` 卡（`it-`）SHALL 支持黑盒三层内部结构：物理层（材质、尺寸、耐久、限制、使用条件、客观规则）、感知层（五感映射：visual / auditory / olfactory / gustatory / tactile）、抽象非感知层（绑定权力、秘密、记忆、宿命、信任等抽象 timeline）。默认黑盒模式：作者只自然描述道具，skill 自动拆解写入图森林；高级模式开关打开后展示三层分区并允许手动调整感知 track 绑定。

#### Scenario: 黑盒模式录入道具
- **WHEN** 作者用自然语言描述一把「会发烫、刻着族徽、象征血脉诅咒的剑」
- **THEN** skill 提案自动拆分为：物理层（剑体规则）、感知层（tactile 温感 + visual 族徽）、抽象层（绑定「宿命」「血缘秘密」timeline）

### Requirement: 五感公理

感知动线的根（track root）MUST 落在人类原生五感之一（视觉 / 听觉 / 嗅觉 / 味觉 / 触觉）；玄幻衍生感知（灵识扫描、神视、灵嗅、道韵尝感、神魂震颤等）SHALL 建模为对应五感的子标签变体（如灵识 = 触觉+回声定位型探测，神视 = 视觉延伸），MUST NOT 新增脱离五感底层的独立感知大类。非感知抽象动线（权力/秘密/记忆/欲望/宿命/张力/信任）与感知动线平行，互不侵占，可通过 `nc-注册` 自由扩展。

#### Scenario: 灵识扫描动线
- **WHEN** 作者创建一条「主角以灵识扫视房间」的感知动线
- **THEN** 该动线 track 根登记为触觉（回声定位型探测子标签），而非新建「灵觉」大类

### Requirement: pose 姿态库

`pose` 卡（`po-`，存放于 `cards/pose-bank/`）SHALL 由四部分组成：固定内核（招牌不变）、环境变量插槽（每次调用替换）、多视角文案、使用约束（`extra_constraint`）。`pose_tag` 枚举：`signature` / `habit` / `combat` / `relax` / `special`。

插槽填充 MUST 遵循三级优先级：P1 桥段本地手动覆写（`slot_override`）> P2 当前时间锚点快照状态自动填充 > P3 pose 默认兜底（`slot_default`）。填充后 MUST 跑 `extra_constraint` 校验（如「水下不可鼓腮」），冲突进入 `nc-校阅` 意见，不自动改文字。

#### Scenario: 快照自动填插槽
- **WHEN** 桥段引用 `po-001`（招牌戒备姿态）且绑定了某章节快照，快照记录角色左臂受伤
- **THEN** pose 渲染时插槽自动填入「左臂垂落、右手持械」的适配变体，作者零填写

#### Scenario: 约束冲突
- **WHEN** 某 pose 的 `extra_constraint` 声明「水下不可鼓腮」，但桥段场景为水下且 slot_override 指定了鼓腮动作
- **THEN** `nc-校阅` 输出冲突意见，不自动修改任何文本

### Requirement: module 积木模块

`module` 卡（`md-`）是最小调度单元，其 `trigger_map` SHALL 可自由绑定任意数量、任意 track 类型的 timeline 节点 + pose + 自定义类型卡片（symbol/metric 等），MUST NOT 锁死固定四感组合。同一 module 可在不同章节复用，通过修改绑定的动线节点产生不同效果。跨动线同步变化 MUST 走 module 积木模块，禁止在正文或动线卡里零散写联动。

#### Scenario: 进门积木
- **WHEN** 定义 `md-action-entry`（推门入场），`trigger_map` 同时拨动 tl-hairstyle / tl-scent / tl-light / tl-costume 四条动线的 node_01
- **THEN** 第 3 章桥段引用该 module 时，四条动线节点同步更新，形成多感官联动名场面

### Requirement: timeline 节点由积木驱动

`timeline` 卡（`tl-`）的每个节点 SHOULD 通过 `bind_module` 字段绑定一个 pose/module 积木；`track` 字段 MUST 声明追踪对象类型（`character` / `item` / `faction` / `place` / `other` / 已注册的自定义类型），`target` 指向具体对象 id。未绑定 module 的孤立节点仅允许用于简单线性记录。

#### Scenario: 发型动线节点
- **WHEN** tl-hairstyle 第 14 章节点「玉簪取下，长发散落」
- **THEN** 该节点 `bind_module: md-action-unpin` 并标注触发中型情绪爆点

### Requirement: lexstat 词频张力卡

`lexstat` 卡（`lx-`）SHALL 包含：`bind_chapter` / `bind_plotpoint` 绑定关系、`high_density_words`（爆点区域强冲击词）、`low_density_words`（过渡留白淡词）、`forbidden_words`（本章禁用词）、`tension_curve`（0~10 张力标尺：start / rising / climax / release）、`blank_rule`（爆点后强制留白段落数、禁止同句堆砌四种感官等规则）、`checklist`（校验指标清单）。词频张力卡是强约束：爆点段落高密词集中释放，爆点之后强制留白，禁止持续堆叠感官描写。

#### Scenario: 爆点后留白校验
- **WHEN** 某章 climax 张力 9 之后连续三段仍高密度感官描写
- **THEN** `nc-校阅` 依据 lx 卡 `blank_rule` 标记违反留白规则

### Requirement: corpus 语料卡

`corpus` 卡（`co-`）SHALL 包含：`tags`（语义标签，如感官描写/香氛/室内光影/克制情欲/留白短句）、`source`（来源）、`purpose`（服务的桥段/动线 id）、`text`（原始参考语料）、`extract`（人工萃取的可用词组/句式/氛围表达）、`notes`（区分表层情欲描写词与深层思辨隐喻词，两类分开标记防止混同）。

#### Scenario: 语料入库打标签
- **WHEN** 作者提交一段关于烛火光影的参考文本
- **THEN** `nc-素材` 入库生成 `co-` 卡，自动建议标签 `[室内光影, 感官描写]`，等待作者确认

### Requirement: metric 量化指标卡

`metric` 卡（`mt-`）SHALL 挂载张力、爆点、信息载荷等量化指标，供长篇深度打磨与批量统计分析使用；数值索引同步写入 `index/metric-index.json`。

#### Scenario: 章节信息载荷统计
- **WHEN** 执行 `nc-量化` 对第 10~20 章做信息投放节奏分析
- **THEN** 产出 mt- 卡并在 `index/metric-index.json` 中追加对应数值条目

### Requirement: 其他新增类型

`sensory_cue`（感官标记：声音/乐曲/气味/光影等氛围触发器，可绑定角色/场景，供桥段引用，本身不是剧情事件）、`refwork`（外部参考作品档案，登记基础信息，用于对标拆解）、`snapshot`（时间锚点全局状态切片：在某确定章节定格角色伤势/情报/环境等多方状态，区别于 timeline 的变化曲线）SHALL 各有独立模板与字段定义，均遵守通用五字段。

#### Scenario: 王熙凤笑声
- **WHEN** 作者说「王熙凤人还没进院子笑声先传过来」
- **THEN** Agent 推荐 `nc-感官标记`，创建 sound 类 sensory_cue 卡绑定该角色，后续桥段可直接引用

### Requirement: 长线四方对齐

长线道具/感官爆点 MUST 满足四方对齐：伏笔 `fs-` 卡、动线 `tl-` 节点、模块 `md-`、词频 `lx-` 卡提前 ≥8 章预埋，缺一即视为预埋不完整。

#### Scenario: 发簪伏笔链
- **WHEN** 第 3 章植入 fs-hairpin，计划第 14 章回收
- **THEN** 该链路上 MUST 存在对应的 tl-hairstyle 节点、md-action-entry/md-action-unpin 模块、lx-ch03/lx-ch14 词频卡，`nc-校阅` 校验四方齐全

### Requirement: character_tendency 角色动向滑动标尺卡

`character_tendency`（`tend-`，存放于 `cards/tendencies/`）SHALL 记录角色性格 / 心智倾向的**带触发事件的连续滑动标尺**，刻画渐进式人物弧光，区别于静态写死在 `actor` 卡上的固定基线性格。frontmatter 专属字段：

- `target_role`：绑定的 `ac-*` 角色 id（依附角色，不独立存在）
- `dimension`：性格维度（如「克制 ↔ 放荡」）
- `baseline`：初始基线刻度（角色刚出场的值）
- `direction_rule`：长期趋势方向规则（如「整体长期向放荡偏移，不强制每次向右」）
- `current_value`：当前刻度
- `history`：变动历史数组，每条含 `{value, trigger_plot, description}`——`trigger_plot` MUST 引用已存在的 `pp-*` 桥段 id，每一次变动绑定具体剧情事件作为推手
- `notes`：约束说明（如「允许短期小幅回弹，但主线趋势不变」）

该卡 MUST 遵守通用五字段；MUST NOT 替代 `actor` 基础卡（基线初始状态仍存于 actor 卡）。`nc-校阅` SHALL 校验动向逻辑冲突：① `trigger_plot` 引用的桥段不存在；② 短期变化与标注的长期趋势严重冲突（提示风险而非禁止，作者可刻意写反转）；③ 同一角色同一维度有多条互相矛盾的动向规则。

#### Scenario: 克制→放荡弧光建卡
- **WHEN** 作者为某角色建一张「本性克制、逐步向放荡偏移」的动向卡
- **THEN** 生成 `tend-*` 卡：`target_role: ac-*`、`dimension: 克制↔放荡`、`baseline: 0`、`direction_rule: 长期向放荡偏移`、`history[]` 首条 `{value:+1, trigger_plot: pp-*, description: 当众违背礼教}`

#### Scenario: 动向引用缺失桥段
- **WHEN** 某 `tend-*` 卡的 `history[].trigger_plot` 指向一个不存在的 `pp-*` id
- **THEN** `nc-校阅` 标记「动向引用的桥段不存在」告警

### Requirement: 暗线 = 整条明面叙事的隐性逻辑

`darklayer`（`dk-`）卡 SHALL 表达「整条明面叙事中没有明说、需要读者自行推敲的隐性逻辑」，MUST NOT 被窄化为「仅指代角色」。一张暗线卡可通过 `references_to_main` 混合挂接多类主书对象（`ac-` 角色 / `pp-` 桥段 / `it-` 道具 / `fa-` 势力 / `sc-` 场景）。frontmatter SHALL 支持 `implicit_kind` 字段标注主导类型（`setting` / `plot` / `character` / `mixed`，默认 `mixed`）。判断标准：读者读完全文回看能发现「原来如此」的那条暗逻辑。

#### Scenario: 设定类暗线
- **WHEN** 作者建一条「世界规则内幕」暗线，它通过多个场景与桥段暗示，而非绑定某个角色
- **THEN** 暗线卡 `implicit_kind: setting`，`references_to_main` 混合引用 `sc-*` 与 `pp-*`，不强制要求 `ac-*`

#### Scenario: 混合暗线
- **WHEN** 一条暗线同时涉及角色隐藏动机 + 桥段真实因果 + 隐秘设定
- **THEN** `implicit_kind: mixed`，`references_to_main` 同时含 `ac-*` / `pp-*` / `sc-*` 多类前缀

### Requirement: 设定卡检索容错与差异归档

所有「更新已有卡」类技能（含 `nc-检索` 触发的填充流程）SHALL 对作者口述 / 输入的设定对象做模糊匹配；命中多个可能对应同一设定的记录时 MUST 返回全部候选（含各自 id 与关键差异点）请作者确认，MUST NOT 自行拍板选定唯一候选后直接改写。当要更新的卡与现有内容存在实质差异（非纯笔误修正）时，MUST NOT 原地覆盖：先把旧版本快照复制到 `history/<card-id>/<updated-date>.md`（只读快照），再出新版提案。纯笔误 / 格式修正可直接出更新提案并注明「仅修正 X」。该约定对全部卡类型生效。

#### Scenario: 同物异名多候选
- **WHEN** 作者说「更新青铜钥匙」，工程中存在 `it-bronze-key` 与 `it-bronze-key-v2` 两张近似卡
- **THEN** skill 列出两张候选及差异请作者确认，不自行选定

#### Scenario: 实质差异先归档
- **WHEN** 作者确认更新 `it-bronze-key` 且新内容与现有内容有实质差异
- **THEN** skill 先把旧版本复制到 `history/it-bronze-key/<date>.md`，再出新版提案
