# 技能清单（skill-catalog.md）

novel-cards v1.0 提供 **29 个 `nc-` 技能**。面向用户按**六组分类**呈现（降低记忆
负担），每个技能另带 `auto_invokable` / `user_trigger_only` 内外调用属性标记。所有
技能支持中文与英文双向别名调用，新手优先中文；输入任一别名时内部自动映射，返回
提示仍以中文为主、英文名括号附带。

> **呈现收敛原则**：技能数量虽达 29 个，但日常使用**不必一次全部触发**。AI 应按
> 当前所处流水线阶段只推荐「下一步最相关的 1–3 个技能」，不一次性倾倒全部 29 个。
> 作者也可在 `agents.md` 里声明「本项目常用技能集」做进一步收敛。详见
> `references/loop.md` 的三场景分级矩阵。

## 1. 六组用户可见分类总览

> 注：原「主流程 / 素材辅助 / 校验审计 / 导出归档」四组为**内部流水线视角**；
> 六组为**用户可见分类**。两者是同一 29 技能的不同切面，本文档同时给出映射，
> 避免双轨漂移。

### A. 工程初始化 & 素材资产组

> **OO 归属列**：每个技能都能表述为 `StoryWorld` 或某个 `NcObject` 子类的成员方法，完整映射见
> `references/oo-model.md` §4。本列仅换 OO 视角表述，六组分类 / 双语别名 / auto_invokable 取值零差异。

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 1 | `nc-初始化` | `nc-init` | 新建创作工程，一键生成目录骨架、build 脚本、三份引导文档（agents/quickstart/skill-reference）、config/skills.yaml；支持 `--lang zh/en`，可指定长短篇预设 | false | `StoryWorld.constructor()` | 项目起点，一个项目只运行一次 |
| 2 | `nc-素材` | `nc-material` | 原始素材收纳入库，原样封存，分配 id + 来源/版权/分类标签；入库前过通胀过滤器 gate | false | `StoryWorld.import_raw()` | 素材录入入口 |
| 3 | `nc-清洗` | `nc-clean` | 素材降噪预处理，生成独立干净副本，原始素材保留不动 | false | `StoryWorld.clean_object()` | 素材杂乱才用，可选 |
| 4 | `nc-检索` | `nc-query` | 检索素材、全部卡片资产（含 `type:character_tendency` 与按角色过滤），返回候选资产池 | false | `StoryWorld.query()` | 系统底层自带私有查重 |
| 5 | `nc-注册` | `nc-reg` | 注册自定义卡片类型、自定义动线 track 标签、动向卡人格基线原型枚举取值（写入 registry 白名单） | false | `StoryWorld.config.register_type()` | 需要扩展类型时使用 |
| 6 | `nc-更名` | `nc-rename` | 全局标识符替换：改故事书名 / 全局代号重命名（跨卡片/伏笔/快照/桥段/图谱引用统一替换）；先出【替换预览清单】确认后批量写入，不动 res/ 原始素材与正文口语称呼 | false | `StoryWorld.rename_identifier()` | 工程维护类，非创作主线强制节点 |

### B. 叙事卡片建模组

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 7 | `nc-角色` | `nc-role` | 新建/更新叙事行动单元（人、蛤蟆、器灵、抽象意志，不限于人类） | false | `Role.create()` / `Role.patch()` | 原「nc-人物」改名 |
| 8 | `nc-姿态` | `nc-pose` | 角色招牌动作库：内核固定 + 环境插槽 + 多视角模板（P1>P2>P3 优先级） | false | `Pose.create()` / `Role.get_pose()` | 长篇精细人设 |
| 9 | `nc-道具` | `nc-item` | 新建/更新道具卡，黑盒自动拆分物理/感知/抽象三层动线 | false | `Prop.create()` / `Prop.patch()` | 黑盒优先，高级模式解锁底层 |
| 10 | `nc-场景` | `nc-scene` | 新建/更新场景卡片，记录环境基础参数 | false | `Scene.create()` / `Scene.patch()` | — |
| 11 | `nc-感官标记` | `nc-sensorycue` | 创建/编辑感官标记卡（声音、乐曲、气味、光影等氛围触发器），可绑定角色/场景，供桥段引用 | false | `SensoryCue.create()` / `SensoryCue.broadcast()` | 本身不是剧情事件 |
| 12 | `nc-动向` | `nc-tendency` | 创建/编辑 `character_tendency`（`tend-`）角色动向滑动标尺卡：刻画性格/心智倾向的带触发事件连续滑动标尺，每次变动绑定具体桥段事件作为推手；可选声明人格基线原型 `baseline_prototype`（须经 nc-注册） | false | `Tendency.create()` / `Role.act()` | 依附角色（target_role 引用 ac-），引用桥段（trigger_plot 引用 pp-） |

### C. 剧情结构组

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 13 | `nc-桥段` | `nc-plot` | 构思剧情单元、绑定角色/道具/pose、标记章节、标注战略爆点 | false | `PlotBeat.create()` / `PlotBeat.fire()` | 剧情核心载体 |
| 14 | `nc-伏笔` | `nc-foreshadow` | 预埋长线伏笔、登记预期回收位置（长线四方对齐 ≥8 章） | false | `Foreshadow.create()` / `DarkLine.check_converge()` | 短篇默认关闭 |
| 15 | `nc-快照` | `nc-snapshot` | 时间锚点全局状态切片，定格角色伤势、情报、环境等多方状态 | false | `Snapshot.create()` / `Snapshot.restore()` | 长篇群像优先 |
| 16 | `nc-势力` | `nc-faction` | 多方势力、立场、关系网络建模 | false | `Faction.create()` / `Faction.patch()` | 长篇默认开启 |
| 17 | `nc-暗线` | `nc-thread` | 整条明面叙事的隐性逻辑链路（setting/plot/character/mixed），秘密信息流 | false | `DarkLine.create()` / `DarkLine.patch()` | 长篇默认开启，独立命名空间 |
| 18 | `nc-积木` | `nc-module` | 积木编排：trigger_map 绑定动线、伏笔、pose，组装触发关系 | false | `Module.create()` / `StoryTrack.step()` | 最小调度单元 |
| 19 | `nc-研判` | `nc-analyze` | 读取选定剧情/角色/动向/感官标记资产 + 作者诉求，做创作层面推演，输出结构化分析报告 + 可选方案 A/B/C（附利弊与连锁影响）；**只出建议报告，绝不直接改动任何 cards/素材** | false | `StoryWorld.deliberate()` | 操作技能，不生成驻留卡片；与 nc-校阅 互补（校阅找茬、研判出主意） |
| 20 | `nc-编排` | `nc-compose` | 根据素材/原有剧情资产/情节目标/模式自动生成结构化【编排执行计划】（create_plot/edit_plot/archive_plot/update_tendency/bind_sensory_cue 五类任务），交作者逐条审核后前置跑 nc-校阅 扫冲突再顺序执行 | false | `StoryWorld.plan_modify()` | 批量剧情迭代三段式（计划→审核→执行），全程禁止静默修改 |

> 注：`nc-对标`(nc-refwork) 是 v1.0 主体保留的**分析模式专用技能**（外部作品拆解
> 学习，独立 `tree_id` 隔离），服务于「拆解现成外部作品」流程，**不计入**面向用户的
> 六组 29 技能分类（该流程在分析模式下按需手动触发）。它仍出现在下方双语别名映射
> JSON 与旧版对照表中，保证触发解析完整。

### D. 生成与可视化组

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 21 | `nc-量化` | `nc-metric` | 挂载张力、爆点、信息载荷等量化指标，供长篇深度打磨与批量统计 | true | `Metric.create()` / `NcObject.validate()` | 可被其他技能内部自动唤起 |
| 22 | `nc-图谱` | `nc-graph` | 渲染叙事森林时序图、角色关系、动线链路图、积木联动总图 | true | `StoryWorld.export()` 的 graph 投影 | 可被其他技能内部自动唤起 |
| 23 | `nc-成稿` | `nc-draft` | **自动出正文初稿**：读取已备好的设定/桥段/大纲/暗线/角色等卡片，按 `--length short/mid/long` 控制篇幅，生成 `manuscript/` 手稿提案供作者校阅调整 | false | `StoryWorld.export()` 的 render 阶段 | 写稿环节核心；与 nc-词频 配合（成稿出内容，词频管约束） |
| 24 | `nc-词频` | `nc-wordfreq` | 词频向量 + 感官均衡强约束校验工具（纯约束，不出正文）；为 nc-成稿 提供约束输入 | false | `LexStat.create()` / `render()` 强约束输入 | 约束工具，长篇精细打磨 |

### E. 审计校验组

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 25 | `nc-校阅` | `nc-review` | 叙事审计：设定、pose 约束、动线、伏笔、动机、OOC 一致性 + character_tendency 动向逻辑冲突检查（含原型边界漂移建议级检查④）；内置调用 nc-节奏 输出作为节奏模块 | false | `NcObject.validate()` + `StoryWorld.audit()` | 只出意见不改稿 |
| 26 | `nc-节奏` | `nc-rhythm` | 章节桥段疏密、爆点密度、留白校验，战略爆点自动豁免 | true | `Rhythm.validate()`（nc-校阅 内置模块） | 可被 nc-校阅 内部自动唤起 |
| 27 | `nc-守卫` | `nc-safetyguard` | 隐私 + 合规内容扫描，区分【渲染加害红线】/【揭露批判疑点】 | false | `StoryWorld.safety_guard.scan()` | 低频，分发前使用，默认隐藏 |

### F. 归档导出 & 复盘组

| # | 中文调用名 | 英文调用名 | 简要职责 | auto_invokable | OO 归属 | 备注 |
|---|---|---|---|---|---|---|
| 28 | `nc-定稿` | `nc-finalize` | 生成工程快照归档、打上锁定标记 | false | `StoryWorld.snapshot()` 批量 + 锁定标记 | 可选分支，自娱可跳过 |
| 29 | `nc-导出` | `nc-export` | Pandoc 底层，跨平台（Windows/Mac/Ubuntu）导出 PDF / Word | false | `StoryWorld.export()` 序列化落盘 | 需导出文件才走 |
| 30 | `nc-复盘` | `nc-retrospect` | 沉淀经验、洞察，回流素材库，开启新一轮构思 | false | `Reflection.create()` + `StoryWorld.import_raw()` 反哺 | 收尾节点 |

### 内部流水线视角 → 六组映射

| 旧四组（流水线视角） | 对应六组成员 |
|---|---|
| 主流程（流水线节点） | A 组（初始化/素材/清洗/检索/注册）+ B 组（角色/道具/场景/姿态/感官标记/动向）+ C 组（桥段/伏笔/快照/势力/暗线/积木/对标/研判/编排）+ D 组（成稿/词频/量化/图谱）+ F 组（定稿/导出/复盘） |
| 素材辅助（游离辅助） | B 组的 `nc-姿态` / `nc-感官标记` / `nc-动向` |
| 校验审计（只出意见） | E 组（校阅/节奏/守卫） |
| 导出归档（可选分支） | F 组的 `nc-定稿` / `nc-导出` |

## 2. 双语别名映射（JSON，可直接落地）

```json
{
  "nc-初始化": "nc-init",         "nc-init": "nc-初始化",
  "nc-素材": "nc-material",       "nc-material": "nc-素材",
  "nc-清洗": "nc-clean",          "nc-clean": "nc-清洗",
  "nc-检索": "nc-query",          "nc-query": "nc-检索",
  "nc-注册": "nc-reg",            "nc-reg": "nc-注册",
  "nc-更名": "nc-rename",         "nc-rename": "nc-更名",
  "nc-角色": "nc-role",           "nc-role": "nc-角色",
  "nc-姿态": "nc-pose",           "nc-pose": "nc-姿态",
  "nc-道具": "nc-item",           "nc-item": "nc-道具",
  "nc-场景": "nc-scene",          "nc-scene": "nc-场景",
  "nc-感官标记": "nc-sensorycue", "nc-sensorycue": "nc-感官标记",
  "nc-动向": "nc-tendency",       "nc-tendency": "nc-动向",
  "nc-桥段": "nc-plot",           "nc-plot": "nc-桥段",
  "nc-伏笔": "nc-foreshadow",     "nc-foreshadow": "nc-伏笔",
  "nc-快照": "nc-snapshot",       "nc-snapshot": "nc-快照",
  "nc-势力": "nc-faction",        "nc-faction": "nc-势力",
  "nc-暗线": "nc-thread",         "nc-thread": "nc-暗线",
  "nc-对标": "nc-refwork",        "nc-refwork": "nc-对标",
  "nc-积木": "nc-module",         "nc-module": "nc-积木",
  "nc-研判": "nc-analyze",        "nc-analyze": "nc-研判",
  "nc-编排": "nc-compose",        "nc-compose": "nc-编排",
  "nc-量化": "nc-metric",         "nc-metric": "nc-量化",
  "nc-图谱": "nc-graph",          "nc-graph": "nc-图谱",
  "nc-成稿": "nc-draft",          "nc-draft": "nc-成稿",
  "nc-词频": "nc-wordfreq",       "nc-wordfreq": "nc-词频",
  "nc-校阅": "nc-review",         "nc-review": "nc-校阅",
  "nc-节奏": "nc-rhythm",         "nc-rhythm": "nc-节奏",
  "nc-守卫": "nc-safetyguard",    "nc-safetyguard": "nc-守卫",
  "nc-定稿": "nc-finalize",       "nc-finalize": "nc-定稿",
  "nc-导出": "nc-export",         "nc-export": "nc-导出",
  "nc-复盘": "nc-retrospect",     "nc-retrospect": "nc-复盘"
}
```

**交互提示策略**：流程下一步推荐优先展示中文名，英文名括号附带；输入英文
别名内部自动映射，返回提示仍以中文为主。例：用户输入 `nc-wordfreq`，执行
词频约束工作流，后续推荐显示为「nc-词频(nc-wordfreq)」。

**auto_invokable 透明化**：`auto_invokable: true` 仅 `nc-量化` / `nc-图谱` /
`nc-节奏` 三个技能。前端引导面板与交互提示 MUST 只展示用户可调用的六组分类，
`auto_invokable` 属性仅在底层配置（`config/skills.yaml`）与备查文档
（`skill-reference.md`）可见，对普通作者隐藏。

## 3. 每技能入参与产物约定

下表给出每个技能的典型入参（作者提供的信息）与主要产物（落盘位置）。所有
产物均遵守提案制：AI 出完整草案，作者确认后自行落盘。

| 技能 | 典型入参 | 主要产物（相对使用方工程根） |
|---|---|---|
| `nc-初始化` | `--lang zh/en`、`--mode short/mid/long` | 工程骨架目录 + `agents.md`/`quickstart.md`/`skill-reference.md` 三份引导文档 + `config/project.yaml` + `config/skills.yaml` + build 脚本 |
| `nc-素材` | 本地文件路径 / 纯文本 / 网页 URL | `res/inbox/` 封存记录 + `cards/corpus/co-*.md` 语料卡；入库前过通胀过滤器 gate |
| `nc-清洗` | 目标素材 id | 独立干净副本（`res/` 下派生文件），原始素材不动 |
| `nc-检索` | 关键词 + 类型/标签/来源/状态筛选（支持 `type:character_tendency`、`role:ac-*`） | 候选资产池（对话输出，不落盘） |
| `nc-注册` | 自定义类型名 / track 标签名 / 动向人格基线原型 key（含 label、boundary_hints） | `registry/` 白名单追加条目 |
| `nc-更名` | 旧标识符 → 新标识符（书名或全局代号） | 【替换预览清单】→ 确认后批量写入 cards/ 各层 + history 快照 + CHANGELOG 追加 + latest.md 更新（不动 res/ 与正文口语称呼） |
| `nc-角色` | 名字、分类标签、动机、首出场 | `cards/characters/ac-*.md`（type: actor） |
| `nc-姿态` | pose_tag、内核、插槽、多视角文案 | `cards/pose-bank/po-*.md` |
| `nc-道具` | 自然语言描述 | `cards/items/it-*.md`（黑盒三层自动拆解） |
| `nc-场景` | 地点、氛围、时段 | `cards/scenes/sc-*.md` |
| `nc-感官标记` | cue 类型（sound/scent/light/atmosphere）、绑定对象 | `cards/custom/sensory_cue/su-*.md` |
| `nc-动向` | target_role(ac-)、dimension、baseline、direction_rule、history[]（每条 {value, trigger_plot: pp-*, description}）、baseline_prototype（可选，须经 nc-注册；未注册拦截） | `cards/tendencies/tend-*.md`（type: character_tendency） |
| `nc-桥段` | 章节、涉及对象、是否战略爆点 | `cards/plotpoints/pp-*.md` |
| `nc-伏笔` | 埋点章节、计划回收章节 | `cards/foreshadow/fs-*.md` |
| `nc-快照` | 章节锚点、聚焦对象 | `cards/snapshots/sn-*.md` |
| `nc-势力` | 势力名、成员、领地、冲突 | `cards/factions/fa-*.md` |
| `nc-暗线` | 主题、层级、references_to_main | `cards/darklayer/dk-*.md` |
| `nc-积木` | 动作名、trigger_map 绑定的动线/伏笔/pose | `cards/modules/md-*.md` |
| `nc-研判` | 选定资产（剧情/角色/动向/感官标记，可多个）+ 作者诉求 | 结构化分析报告 + 方案 A/B/C（对话输出，可选经 nc-素材 存库；**不改任何卡片**） |
| `nc-编排` | `--source` 素材 / `--reference` 原有资产 / `--prompt` 情节目标 / `--mode expand/rewrite/restructure` | compose_plan（create_plot/edit_plot/archive_plot/update_tendency/bind_sensory_cue 五类任务）→ 审核定稿 → 前置 nc-校阅 → 顺序执行（每步调底层技能 + CHANGELOG + latest.md）；计划存为素材（tag:compose-plan） |
| `nc-量化` | 章节区间、指标维度 | `cards/metrics/mt-*.md` + `index/metric-index.json` 追加 |
| `nc-图谱` | 对象/主题 | `graph/*.html`（由 `index/card-graph.json` 重渲染） |
| `nc-成稿` | 章节/桥段 id + `--length short/mid/long`（篇幅档位） | `manuscript/chapter-*.md` 正文初稿（走提案制，作者校阅后落盘） |
| `nc-词频` | 章节/桥段 id | `cards/lexstats/lx-*.md` 词频向量 + 感官均衡约束报告（纯约束，不出正文） |
| `nc-校阅` | 章节/范围 | `reflections/review-*.md` + `review-*.json`（只出意见；含动向逻辑冲突检查，内置调用 nc-节奏） |
| `nc-节奏` | 章节区间 | 节奏评估报告 + `reflections/rhythm-rt-*.json`（只给建议） |
| `nc-守卫` | （无，整体扫描） | `reflections/safety-check/sg-*.md` + `.json`（只告警） |
| `nc-定稿` | （无，整体操作） | `history/` 快照 + `CHANGELOG.md` 追加 + `latest.md` 更新 |
| `nc-导出` | 目标格式（pdf/docx） | `export/` 中间产物 + `release/` 成品 |
| `nc-复盘` | 章节 id | `reflections/rf-*.md`（五段结构） |
| `nc-对标`（分析模式） | 作品名、基础信息 | `cards/custom/refwork/rw-*.md`（refwork 档案，独立 tree_id） |

## 4. 旧 12 触发词 → 新 29 技能对照表

v0.x 的 12 个触发词到 v1.0 的映射。**迁移为硬切换**，不做双轨兼容逻辑；
过渡期 skill 仍应能识别旧前缀并提示新名称。

| 旧触发词（v0.x） | 新技能（v1.0） | 变化说明 |
|---|---|---|
| `nc-人物` | `nc-角色`(nc-role) | **更名**：character→actor，id 前缀 ch-→ac- |
| `nc-桥段` | `nc-桥段`(nc-plot) | 保留，新增 lexstat_bind / module_list 字段 |
| `nc-道具` | `nc-道具`(nc-item) | 保留，升级为黑盒三层建模 |
| `nc-场景` | `nc-场景`(nc-scene) | 保留 |
| `nc-伏笔` | `nc-伏笔`(nc-foreshadow) | 保留，短篇默认关闭 |
| `nc-动线` | （并入 `nc-积木` nc-module + timeline 卡） | 动线卡保留但联动改由 module 驱动；无独立 nc-动线 指令 |
| `nc-势力` | `nc-势力`(nc-faction) | 保留，长篇默认开启 |
| `nc-快照` | `nc-快照`(nc-snapshot) | 保留，语义明确为「时间锚点状态切片」（非姿势库） |
| `nc-暗线` | `nc-暗线`(nc-thread) | 中文名保留，新增英文别名 nc-thread |
| `nc-图谱` | `nc-图谱`(nc-graph) | 保留，升级为叙事森林/时序/关系链路图 |
| `nc-复盘` | `nc-复盘`(nc-retrospect) | 保留，新增英文别名 |
| `nc-过滤` | （并入 `nc-素材` nc-material 入库前 gate） | 三问逻辑并入素材入库 gate；保留手动复检能力 |

**新增技能（无旧版对应）**：`nc-初始化` / `nc-素材` / `nc-清洗` / `nc-检索` /
`nc-注册` / `nc-更名` / `nc-对标` / `nc-积木` / `nc-量化` / `nc-成稿` / `nc-词频` /
`nc-定稿` / `nc-姿态` / `nc-感官标记` / `nc-动向` / `nc-研判` / `nc-编排` /
`nc-节奏` / `nc-校阅` / `nc-守卫` / `nc-导出`。

## 5. 技能职责不重叠原则

- 每个技能有唯一的核心职责描述；跨技能的能力复用通过**显式引用**表达，
  而非复制逻辑。例：`nc-校阅` 内置调用 `nc-节奏` 的输出作为节奏审计模块，
  不重新实现滑动窗口扫描逻辑。
- **成稿与词频分工**：`nc-成稿`(nc-draft) 负责「读全部卡片 → 出正文初稿」（内容
  生成），`nc-词频`(nc-wordfreq) 负责「词频向量 + 感官均衡约束」（纯约束校验）。
  二者协作但不重叠：成稿可消费词频卡提供的约束向量，但词频工具本身不产出正文。
- **研判与编排分工**：`nc-研判`(nc-analyze) 偏「出主意」——对少量资产做单点创作
  推演，输出方案 A/B/C 供作者选择，**绝不直接改动卡片**；`nc-编排`(nc-compose)
  偏「批量执行」——对整条故事线做跨资产联动迭代/扩写/重构，先生成结构化
  compose_plan 交作者逐条审核，再前置跑 `nc-校阅` 扫冲突后顺序执行。单点评估走
  研判，批量整线迭代走编排。
- **更名与本体技能分工**：`nc-更名`(nc-rename) 只做**全局标识符替换**（书名 /
  全局代号），先出【替换预览清单】确认后才批量写入，不动 `res/` 原始素材与正文
  口语称呼；要改角色性格 / 暗线内容 / 桥段情节等**内容**时，路由到对应本体技能
  （`nc-角色` / `nc-暗线` / `nc-桥段` / `nc-动向`），一卡对应一修改入口保持内聚。
- **动向依附角色**：`nc-动向`(nc-tendency) 刻画角色性格/心智倾向的带触发事件连续
  滑动标尺，每次变动 MUST 绑定一个具体桥段事件（`trigger_plot` 引用 `pp-*`）作为
  推手，MUST NOT 替代角色基础卡（基线初始状态仍存于 `actor` 卡）。
- **审计类技能铁律**：`nc-校阅` / `nc-节奏` / `nc-守卫` MUST 只输出意见，
  绝不自动修改、删除任何文稿或卡片内容；所有发现以「建议」形式呈现，
  由作者自行决定是否采纳并手动修改。详见 `references/hard-rules.md`。
