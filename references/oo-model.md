# 面向对象概念模型（oo-model.md）

novel-cards v1.0 的**面向对象（OO）透镜**：把全部叙事资产统一为抽象基类
`NcObject` 的实例，技能是对象的方法，流程是对象间消息传递，校验是类的断言与钩子。
本文档是**概念契约**——用 Markdown 表格 + 最小示例表达类层次与方法签名，由 AI 在执行
`nc-` 指令时读取并据此提案。**不要求存在同名运行时类**；落地形态见
`references/event-inference.md`（事件推演流程）与 `tools/nc_validate.py`（可选只读校验器）。

> **核心心智**：文字只是视图，真相在对象实例里。改剧情 = 修改对象状态，而非修改字符串；
> 正文是对象状态流转之后 `render()` 序列化出的投影。底层字段契约、技能集合、六组分类、
> 四层数据分层**逐字不变**，本文件只换「对象 / 方法 / 消息 / 状态流转 / 渲染」叙述框架。

## 1. NcObject 抽象基类

所有卡片资产都是 `NcObject` 的子类实例。基类定义**公共属性**与**公共方法契约**，
子类各自实现差异化的属性与方法。

### 1.1 公共属性（对齐 frontmatter 通用五字段）

| 属性 | 对应 frontmatter 字段 | 类型 | 说明 |
|---|---|---|---|
| `id` | `id` | string | 唯一标识，含类型前缀，全局唯一；**前缀 MUST 与该类型的注册前缀一致**（见 `card-schema.md` 类型与前缀总表） |
| `type` | `type` | enum | 对象类别，决定其属于哪个子类（见 §2 映射表） |
| `status` | `status` | enum | 生命周期状态（见 `card-schema.md` 状态生命周期节） |
| `created` | `created` | date | 首次创建时间（ISO 8601） |
| `updated` | `updated` | date | 最近一次更新时间（ISO 8601），每次内容变更后同步 |

> 缺失任一公共属性视为非法对象实例（等价于缺 frontmatter 五字段）。`nc-校阅` /
> `tools/nc_validate.py validate` 审计时标记为 schema 违规并输出意见书。

**概念别名（MUST NOT 作为 frontmatter 字段落地）**：草稿中的 `name` / `tags` /
`private` / `remark` 仅作为 OO 视角下的可选扩展概念出现，**不得**新增到任何卡的
frontmatter；它们要么已被现有专属字段承载（如 `actor.name`、`corpus.tags`），要么
纯属概念描述。详见 §5 命名对齐表。

### 1.2 公共方法四件套

每个 `NcObject` 实例都暴露四个公共方法。其中 `render()` 是**抽象方法**（基类不实现，
子类各自实现），其余三个是具体方法（基类给出默认语义，子类可覆写）。

| 方法 | 抽象? | 语义 | 对应技能 / 工具 |
|---|---|---|---|
| `render()` | ✅ 抽象 | 把对象当前状态序列化为文本投影（各子类产出不同：角色→人物描写片段、场景→环境铺陈、桥段→情节段落…）。正文 = 参与对象按 timeline 顺序 `render()` 拼接的结果 | `nc-成稿`(nc-draft) 的 render 阶段 |
| `validate()` | ❌ 具体 | 自检内部冲突：必填字段齐全、type 与 id 前缀一致、专属字段合法、伏笔二选一、动向 trigger_plot 指向真实桥段等 | `nc-校阅`(nc-review) 内置能力 + `tools/nc_validate.py validate` |
| `snapshot()` | ❌ 具体 | 生成当前状态快照存入 `history/<card-id>/<date>.md`（只读快照），供回滚与前后对比 | `nc-定稿`(nc-finalize) 的工程快照归档 |
| `patch()` | ❌ 具体 | 增量修改对象状态并记录变更日志（CHANGELOG 追加 + latest.md 更新 + history 快照）；**绝不静默覆盖**，实质差异先归档再出新版提案 | 各本体技能的「更新已有卡」路径（走提案制，作者落盘） |

> **铁律**：`patch()` 永远走提案制——AI 出完整草案、用户确认后由用户落盘；对象自身
> **MUST NOT** 自动覆盖自己。这与 `hard-rules.md` 规则 1/2/21 完全一致。

## 2. 八个核心业务子类 ↔ 现有卡类型一一映射

八个核心业务子类，每个 MUST 对应一个已存在的 v1.0 卡类型（或明确的卡类型组合），
**不凭空引入无落地载体的新卡类型**。子类自有属性与方法签名 MUST 能在
`references/card-schema.md` 字段中找到承载。

| OO 子类 | 对应 type | id 前缀 | 目录 | 中文名 |
|---|---|---|---|---|
| `Role` | `actor` | `ac-` | `cards/characters/` | 角色（叙事行动单元） |
| `Prop` | `item` | `it-` | `cards/items/` | 道具（黑盒三层） |
| `Scene` | `scene` | `sc-` | `cards/scenes/` | 场景 |
| `SensoryCue` | `sensory_cue` | `su-` | `cards/custom/sensory_cue/` | 感官标记 |
| `PlotBeat` | `plotpoint` | `pp-` | `cards/plotpoints/` | 桥段 |
| `StoryTrack` | `timeline` | `tl-` | `cards/timeline/` | 动线（积木驱动） |
| `DarkLine` | `darklayer` | `dk-` | `cards/darklayer/` | 暗线（独立命名空间） |
| `Snapshot` | `snapshot` | `sn-` | `cards/snapshots/` | 快照（时间锚点状态切片） |

> **非八核心但同属 `NcObject` 体系**的类型（不在八核心之列，但同样是 `NcObject` 实例，
> 共享 §1 公共属性与方法）：`faction`(`fa-`)、`module`(`md-`)、`lexstat`(`lx-`)、
> `corpus`(`co-`)、`metric`(`mt-`)、`pose`(`po-`)、`refwork`(`rw-`)、
> `character_tendency`(`tend-`)、`reflection`(`rf-`)。它们的专属字段契约见
> `card-schema.md`，OO 视角下同样具备 `render()/validate()/snapshot()/patch()`。

### 2.1 Role（角色）

- **对应**：`actor`(`ac-`)。拥有独立主观视角、可参与桥段、可绑定感知/抽象动线、
  具备状态变化的叙事行动单元，**与是否人类无关**。
- **特有属性**：`classification`（分类标签）、`affiliation`（势力 id）、
  `first_appearance`、`cross_ref`（与 item 互引，器灵觉醒场景）。
- **方法**：
  - `act(trigger_event)` — 响应触发事件：沿 `character_tendency`(`tend-`) 动向标尺滑动
    + 切换 `pose`(`po-`) 姿态。**性格/心智倾向的连续滑动 MUST 通过引用独立的
    `character_tendency` 卡表达**（草稿 `disposition_slide:Track` 为其概念别名），
    MUST NOT 把动向塞进 `actor` 卡字段；基线初始状态仍存于 `actor` 卡。
  - `perceive(scene)` — 捕获场景内广播的 `SensoryCue` 信号，更新自身感知状态。
  - `get_pose(state_id)` — 调取某 `pose` 卡的插槽填充值（P1>P2>P3 优先级），保证跨场景姿态一致。

### 2.2 Prop（道具）

- **对应**：`item`(`it-`)。黑盒三层（physical/perceptual/abstract），默认被动。
- **特有属性**：`owner`（持有者）、`origin`、`last_seen`、`blackbox`（三层结构）、
  `advanced_mode`、`cross_ref`。
- **方法**：
  - `move_to(scene, position)` — 动线位置变更；变更时 MUST 触发关联伏笔/动线节点检查
    （跨动线同步走 `module` 的 `trigger_map`，禁止零散联动）。
  - `emit_sensory()` — 释放感知层感官信号（经 `SensoryCue.broadcast()` 扩散）。
- **区分铁律**：一旦道具拥有独立意志主动行动，SHALL 建模为 `Role`（`object-spirit`），
  原 `Prop` 保留物理本体，两对象经 `cross_ref` 互引。

### 2.3 Scene（场景）

- **对应**：`scene`(`sc-`)。
- **特有属性**：`location`、`first_appearance`、`atmosphere`、`recurrence`。
- **方法**：
  - `enter(role)` — 角色进入：刷新环境插槽（光源/气味/声响），并向场内广播相关 `SensoryCue`。
  - `refresh_env()` — 刷新环境变量插槽（时段/天气/光源状态），供 pose 插槽 P2 填充消费。

### 2.4 SensoryCue（感官标记）

- **对应**：`sensory_cue`(`su-`)。声音/乐曲/气味/光影等氛围触发器，**本身不是剧情事件**。
- **特有属性**：`cue_type`（sound/music/scent/light/atmosphere）、`bind_target`（角色/场景 id）、`description`。
- **方法**：
  - `broadcast()` — 向绑定范围内的 `Role` 广播，范围内角色自动 `perceive()` 捕获。

### 2.5 PlotBeat（桥段）

- **对应**：`plotpoint`(`pp-`)。剧情核心载体。
- **特有属性**：`chapter`、`summary`、`participants`、`lexstat_bind`、`module_list`、
  `pose_refs`、`foreshadow_links`、`strategic_burst`、`pivotal`。
- **方法**：
  - `fire()` — 前置条件满足时引爆：派发事件给场内 `Role`/`Prop`/`SensoryCue`，
    触发连锁状态变更（详见 `event-inference.md`）。桥段三态 `official`/`candidate`/`archive`，
    备选方案不会自动替换主线。

### 2.6 StoryTrack（动线）

- **对应**：`timeline`(`tl-`)。单一对象跨章节轨迹，节点由 `module` 积木驱动。
- **特有属性**：`track`（追踪对象类型）、`target`（被追踪对象 id）、`first_seen`、
  `nodes[]`（每节点 `node_id`/`bind_module`/`trigger_foreshadow`/爆点标注）。
- **方法**：
  - `step(timeline)` — 沿时间轴推进：输出下一节点的状态变更（经 `bind_module` 联动多对象）。

### 2.7 DarkLine（暗线）

- **对应**：`darklayer`(`dk-`)。**独立命名空间**，不与主书人物链共享 id。
- **特有属性**：`name`、`truth`、`surface_hint`、`implicit_kind`、`references_to_main`
  （**唯一**允许的连接方式，单向串接主书卡）、`reveal_chapter`、`reveal_tier`。
- **方法**：
  - `check_converge()` — 扫描全场判断所挂接的伏笔/桥段是否集齐、暗线可否回收揭示。
- **隔离铁律**：与主书对象**只**通过 `references_to_main` 单向引用；MUST NOT 在主书卡里
  反向写 `references_to_darklayer`（保持「暗」的语义，避免暗线泄漏）。

### 2.8 Snapshot（快照）

- **对应**：`snapshot`(`sn-`)。某确定章节/时间锚点上锁定的瞬时全局状态切片。
- **特有属性**：`chapter`（锚点）、`focus`、`summary`、`used_pose`、`related_cards`。
- **方法**：
  - `restore()` — 回滚整套对象到该快照记录的状态（供前后对比与逻辑校验：「这一刻角色
    知不知道秘密？伤势多重？」）。
- **与 StoryTrack 区别**：`StoryTrack` = 变化过程（曲线）；`Snapshot` = 时间轴上钉点，
  拍下此刻所有变量值。

## 3. StoryWorld 全局容器

`StoryWorld` 是整个叙事世界的运行沙盒：挂载全部对象实例并持有世界级状态。它是**容器 +
调度中枢**，多数 `nc-` 技能表述为它的方法。容器的属性与方法 MUST 与既有工程结构及技能
职责对齐。

### 3.1 容器属性

| 属性 | 承载 | 对应工程结构 |
|---|---|---|
| `objects` | 全部资产注册表（`NcObject` 实例集合） | `index/card-graph.json` 图森林（机器真值）+ `cards/**`（人类编辑源头） |
| `timeline` | 全局章节时序（章节 → 参与对象 → 事件） | `manuscript/` 章节顺序 + 各卡 `chapter`/`first_appearance` 字段 |
| `inbox` | 待入库原始素材封存区 | `res/inbox/` |
| `config` | 项目配置：`lang` / 安全黑名单 / 篇幅模式 short-mid-long / pipeline_option | `config/project.yaml` + `registry/*.yaml` |
| `safety_guard` | 安全校验实例（隐私 + 合规扫描） | `nc-守卫`(nc-safetyguard) |

> **OO ↔ 四层分层**：`.md`（`cards/**`）= 对象实例的人类编辑载体（业务源头）；
> `.json`（`index/card-graph.json`）= `StoryWorld.objects` 注册表的**机器投影**（图森林
> 真值）；`.yaml`（`registry/`）= `config` 白名单；`.html`（`graph/`）= 图森林的纯展示
> 投影。详见 `references/data-layering.md`。

> **多本作品对齐**：一个工程 MAY 容纳多本书，表述为 `StoryWorld` 下挂多个「作品子容器」
> （每个子容器自身也是一组 `NcObject` + 局部 `index` 图森林，对应 `works/<work-id>/`
> 子空间）。这是 `StoryWorld` 容器的天然延伸——**不新增 `NcObject` 基类 / 子类，不改变
> 八核心类层次与技能→方法映射**；`--work <id>` 即选定在哪个子容器上调用方法。详见
> `references/layout.md` §多本作品工作区。

### 3.2 容器方法 ↔ 既有技能映射

| StoryWorld 方法 | 对应技能 | 语义 |
|---|---|---|
| `constructor()` | `nc-初始化`(nc-init) | 实例化世界：生成目录骨架 + agents/quickstart/skill-reference 三文档 + config |
| `query(filter)` | `nc-检索`(nc-query) | 检索素材与全部卡片资产（含 `type:character_tendency`、按角色过滤），返回候选池 |
| `import_raw(source, content)` | `nc-素材`(nc-material) | 原素材收纳入库（入库前过通胀过滤器 gate） |
| `clean_object(obj)` | `nc-清洗`(nc-clean) | 素材降噪预处理，生成独立干净副本，原始素材不动 |
| `plan_modify(change_request)` | `nc-编排`(nc-compose) | 批量剧情编排三段式（compose_plan → 审核 → 执行），前置 nc-校阅 扫冲突 |
| `audit()` | `nc-校阅`(nc-review) | 全局批量审计（设定/pose/动线/伏笔/动机/OOC + 动向逻辑冲突，内置 nc-节奏） |
| `deliberate()` | `nc-研判`(nc-analyze) | 单点创作推演，出方案 A/B/C（只出建议报告，绝不改卡） |
| `export()` | `nc-导出`(nc-export) / `nc-成稿`(nc-draft) 的 render 阶段 | 按 timeline 顺序调各对象 `render()` 序列化正文 / 跨平台导出 PDF/Word |

## 4. 技能 → 方法完整映射表（33 技能 + 分析模式）

每个 `nc-` 技能都能表述为 `StoryWorld` 或某个子类的成员方法。**技能集合、六组分类、
`auto_invokable` 标记逐字不变**，本表仅换 OO 视角表述。`auto_invokable=true` 仅
`nc-量化` / `nc-图谱` / `nc-节奏` 三项。

| # | 技能（中文/英文） | 六组 | auto_invokable | OO 归属方法 |
|---|---|---|---|---|
| 1 | `nc-初始化` / nc-init | A | false | `StoryWorld.constructor()` |
| 2 | `nc-素材` / nc-material | A | false | `StoryWorld.import_raw()` |
| 3 | `nc-清洗` / nc-clean | A | false | `StoryWorld.clean_object()` |
| 4 | `nc-检索` / nc-query | A | false | `StoryWorld.query()` |
| 5 | `nc-注册` / nc-reg | A | false | `StoryWorld.config.register_type()`（写 registry 白名单） |
| 6 | `nc-更名` / nc-rename | A | false | `StoryWorld.rename_identifier()`（先预览后批量替换） |
| 7 | `nc-角色` / nc-role | B | false | `Role` 实例 `create`/`patch`（`NcObject.patch()`） |
| 8 | `nc-姿态` / nc-pose | B | false | `Role.get_pose()` 消费的 `pose`(`po-`) 对象维护 |
| 9 | `nc-道具` / nc-item | B | false | `Prop` 实例 `create`/`patch`（黑盒三层拆解） |
| 10 | `nc-场景` / nc-scene | B | false | `Scene` 实例 `create`/`patch` |
| 11 | `nc-感官标记` / nc-sensorycue | B | false | `SensoryCue` 实例 `create`/`patch` |
| 12 | `nc-动向` / nc-tendency | B | false | `Role.act()` 依赖的 `character_tendency`(`tend-`) 对象维护 |
| 13 | `nc-桥段` / nc-plot | C | false | `PlotBeat` 实例 `create`/`patch` |
| 14 | `nc-伏笔` / nc-foreshadow | C | false | `PlotBeat.fire()` 前置的 `foreshadow`(`fs-`) 对象维护（四方对齐） |
| 15 | `nc-快照` / nc-snapshot | C | false | `Snapshot` 实例 `create`（`snapshot()` 产物） |
| 16 | `nc-势力` / nc-faction | C | false | `faction`(`fa-`) 对象维护 |
| 17 | `nc-暗线` / nc-thread | C | false | `DarkLine` 实例 `create`/`patch`（`check_converge()`） |
| 18 | `nc-积木` / nc-module | C | false | `module`(`md-`) 的 `trigger_map` 编排（跨动线同步的唯一通道） |
| 19 | `nc-研判` / nc-analyze | C | false | `StoryWorld.deliberate()`（单点推演，出方案 A/B/C） |
| 20 | `nc-编排` / nc-compose | C | false | `StoryWorld.plan_modify()`（批量三段式 compose_plan；MAY 读谱系按 follow 时序批量生成并挂靠谱系） |
| 21 | `nc-谱系新增` / nc-lineage-add | C | false | `StoryWorld.lineage_add()`（登记卷/章节/物料进 index.yaml 绑定从属） |
| 22 | `nc-谱系修改` / nc-lineage-edit | C | false | `StoryWorld.lineage_edit()`（改 index.yaml 逻辑关系，默认不动文件名） |
| 23 | `nc-谱系移除` / nc-lineage-del | C | false | `StoryWorld.lineage_del()`（默认软删除 archived:true，--hard 需确认） |
| 24 | `nc-谱系查询` / nc-lineage-query | C | false | `StoryWorld.lineage_query()`（输出文字谱系树，读取前 fail-loud 校验） |
| 25 | `nc-量化` / nc-metric | D | **true** | `metric`(`mt-`) 对象维护 + `StoryWorld.audit()` 数值维度 |
| 26 | `nc-图谱` / nc-graph | D | **true** | `StoryWorld.objects` 图森林 → `graph/*.html` 渲染（`render()` 的可视化投影） |
| 27 | `nc-成稿` / nc-draft | D | false | `StoryWorld.export()` 的 render 阶段（按 timeline 调各对象 `render()` 拼正文） |
| 28 | `nc-词频` / nc-wordfreq | D | false | `lexstat`(`lx-`) 约束向量（`render()` 的强约束输入，不出正文） |
| 29 | `nc-校阅` / nc-review | E | false | `NcObject.validate()` + `StoryWorld.audit()`（只出意见不改稿；支持 --uid 限定单卷/章并读 follow 前置卷设定） |
| 30 | `nc-节奏` / nc-rhythm | E | **true** | `StoryWorld.audit()` 的节奏模块（被 nc-校阅 内置调用） |
| 31 | `nc-守卫` / nc-safetyguard | E | false | `StoryWorld.safety_guard.scan()`（只告警不改文） |
| 32 | `nc-定稿` / nc-finalize | F | false | `NcObject.snapshot()` 批量 + 工程锁定标记 |
| 33 | `nc-导出` / nc-export | F | false | `StoryWorld.export()` 的序列化落盘（PDF/Word） |
| — | `nc-对标` / nc-refwork（分析模式专用，不计入六组 33） | analysis | false | `refwork`(`rw-`) 对象维护（独立 `tree_id` 隔离） |

> **映射完整性**：33 个六组技能 + 1 个分析模式技能，每行有且仅有一个主归属方法
> （允许「子类方法 + 容器方法」组合，如 `nc-校阅`→`NcObject.validate()`+`StoryWorld.audit()`）。
> 本表与 `references/skill-catalog.md` 六组分类、双语别名 JSON、`auto_invokable` 取值零差异。

## 5. 草稿新命名 → 现有 schema 对齐表

草稿（OO 设计稿）中出现的新命名 MUST 显式对齐到现有 v1.0 schema，**以现有 schema 为准**，
草稿命名仅作概念别名，**MUST NOT 作为 frontmatter 字段名落地**。

| 草稿新命名 | 对齐到现有 schema | 说明 |
|---|---|---|
| `uuid` | `id`（含类型前缀） | 全局唯一标识；前缀 MUST 与类型注册前缀一致（`ac-`/`pp-`/…） |
| `create_at` | `created` | ISO 8601 |
| `update_at` | `updated` | ISO 8601，每次内容变更后同步 |
| `disposition_slide: Track` | `character_tendency`(`tend-`) 卡 | 角色性格/心智倾向滑动标尺；`Role.act()` 经 `target_role` 引用 `ac-*`、经 `trigger_plot` 引用 `pp-*` 推手 |
| `pose_bank[]`（Role 属性） | 独立 `pose`(`po-`) 卡，经 `pose_refs` 引用 | 姿态库是独立对象集合，桥段/快照经 `pose_refs`/`used_pose` 串接，三级优先级 P1>P2>P3 |
| `MoodLine` | 无 v1.0 直接对应 → 映射到 `lexstat`(`lx-`) 张力曲线 + `metric`(`mt-`) 量化指标 | 标注为**概念别名**：情绪/张力走向由 `lexstat.tension_curve`（0~10 标尺）与 `metric` 数值承载 |
| `status` 枚举【草稿/备选/生效/归档/废弃】 | 现有通用生命周期 `draft → active → archived`（一般卡）+ 各类型特殊态（foreshadow: planted/developing/resolved/unresolved/abandoned；darklayer: hint/hinted/confirmed/revealed；plotpoint 额外三态 official/candidate/archive；reflection: draft/reviewed/closed） | MUST NOT 引入与现有 `status` 冲突的新枚举值；「备选」概念对齐 plotpoint 的 `candidate`，「废弃」对齐 `archived` / foreshadow 的 `abandoned` |

> **对齐铁律**：任何草稿命名只能在本文件与 `event-inference.md` 中以「别名」形式出现，
> 用于帮作者建立 OO 心智；落到使用方工程的卡片 frontmatter 时，一律使用右列的现有字段名。
