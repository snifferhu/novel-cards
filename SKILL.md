---
name: novel-cards
description: >-
  维护小说卡片体系，走提案制与用户共创。为长篇 / 中篇 / 短篇虚构作品提供
  29 个 nc- 技能（工程初始化&素材资产 / 叙事卡片建模 / 剧情结构 / 生成与可视化 /
  审计校验 / 归档导出&复盘六组），覆盖 actor（角色）、桥段、道具（黑盒三层）、
  场景、伏笔、动线（积木驱动）、势力、快照（时间锚点状态切片）、暗线、积木模块、
  词频张力、语料、量化指标、姿态库、感官标记、角色动向（性格/心智倾向滑动标尺）、
  对标作品档案等 16+ 类结构化卡片，并支持 HTML 图谱表达复杂关系、四层数据分层
  （md/json/yaml/html）。统一触发前缀 `nc-`：当用户说 `nc-初始化` / `nc-素材` /
  `nc-清洗` / `nc-检索` / `nc-注册` / `nc-更名` / `nc-角色` / `nc-姿态` /
  `nc-道具` / `nc-场景` / `nc-感官标记` / `nc-动向` / `nc-桥段` / `nc-伏笔` /
  `nc-快照` / `nc-势力` / `nc-暗线` / `nc-积木` / `nc-研判` / `nc-编排` /
  `nc-量化` / `nc-图谱` / `nc-成稿` / `nc-词频` / `nc-校阅` / `nc-节奏` /
  `nc-守卫` / `nc-定稿` / `nc-导出` / `nc-复盘` 时触发（均支持英文别名，如
  nc-role / nc-tendency / nc-analyze / nc-compose / nc-rename / nc-wordfreq）。
  无前缀的自然语言触发词：「维护小说卡片体系」「走提案制」「新增/更新角色卡」
  「整理伏笔卡」「梳理动线」「状态快照」「暗线卡」「生成关系图谱」「复盘这一章」
  「过滤一下这个素材」「这个角色再突破底线怎么安排」（单点推演→nc-研判）
  「这批素材用上，老情节换掉」（批量迭代→nc-编排）「改书名/全局代号重命名」
  （→nc-更名）等。所有回写一律输出 Markdown 完整草案，用户确认后由用户落盘；
  AI 不直接写卡。
license: AGPL-3.0
---

# novel-cards v1.0

面向长 / 中 / 短篇虚构作品的**卡片式创作辅助 skill**。用 Markdown + YAML
frontmatter 结构化维护 15+ 类创作卡，通过提案制协作保持卡与正文同步。
复杂关系用独立 HTML 图谱表达；四层数据分层（`.md` 业务源头 / `.json` 图森林
真值 / `.yaml` 配置白名单 / `.html` 展示投影）让资产可迁移、可批量分析。
系统自带**闭环**（文章→反思→反哺→再写）与**入口 gate**（通胀过滤器并入
`nc-素材` 入库前自动判定），让素材库随写作自进化。

本 skill 是双端兼容的（OpenCode + Claude Code），frontmatter 只保留
`name` / `description` / `license` 三个键，其余规则全部写在 body。

> **面向对象透镜**：每张卡都是一个 `NcObject` 子类实例（通用五字段 = 基类公共属性，
> 各类型专属字段 = 子类属性），每个 `nc-*` 技能都是对 `StoryWorld` 容器或某个对象的一次
> 方法调用；正文是参与对象按 timeline 顺序 `render()` 拼接的文本投影——文字只是视图，
> 真相在对象实例里。完整类层次、方法契约与「技能 → 方法」映射见 `references/oo-model.md`；
> 事件驱动的连锁推演（enter→perceive→act→fire → ChangePlan）见
> `references/event-inference.md`。**OO 视角不改变任何字段契约、技能集合、六组分类与提案制
> 铁律**，仅换叙述框架。可选只读运行时 `tools/nc_validate.py`（Python3 标准库单文件）承载
> validate/audit/simulate 三子命令，缺失时降级纸面校验，绝不写盘、绝不替代提案制。

---

## 1. 用途

- **卡片化管理**：把角色（actor）、桥段、道具、场景、伏笔、动线、势力、
  快照、暗线、积木、词频、语料、量化、姿态、感官标记、对标作品拆成独立卡片，
  每卡一文件，便于检索、diff、追踪状态。
- **叙事同步**：正文写完后回补卡片，正文改之前先查卡片，防止设定漂移。
- **多时间线并行**：主书角色链与暗线（darklayer）分命名空间，主线与暗线的引用
  通过显式字段串接，不共享 id，避免"暗线身份泄漏"。
- **跨章节一致性**：快照（snapshot）记录关键时间锚点的多方状态切片，避免后续
  章节出现时间/位置/关系前后矛盾。
- **动线追踪 + 积木调度**：单一对象跨章节轨迹用动线卡（timeline）表达，节点联动
  MUST 走积木模块（module）的 `trigger_map`，禁止零散写联动。
- **复杂关系可视化**：当关系密度超过 Markdown 表格可表达范围时，由
  `index/card-graph.json` 图森林渲染 HTML + SVG 关系图谱到 `graph/`。
- **写作闭环**：单章完稿后用反思卡（reflection）沉淀卡点/亮点/新认知，并把结论
  以 `action_items` 反哺回卡片与图谱。
- **入口过滤**：新素材经 `nc-素材` 入库前自动过通胀过滤器三问，区分「正式排期」
  与「练习稿」，防止同质化素材污染素材库。

**不做的事**：不写正文、不替代大纲、不生成情节。skill 只维护卡片、图谱、反思卡
本身；过滤器只输出提案，不替用户做最终决策；审计类技能（nc-校阅/nc-节奏/nc-守卫）
只出意见，绝不自动改稿。

---

## 2. 使用方工程目录约定

skill 读写均以**使用方工程根**为基准，走相对路径。骨架由 `install.sh --project`
或 `nc-初始化` 双入口生成（边界见 `references/layout.md`）；skill 只读已存在路径，
缺失时提示用户补齐，不自建。

```
<consumer-project>/
  agents.md            # Agent 引导（nc-初始化 生成，可编辑）
  config/project.yaml  # lang / mode / pipeline_option
  registry/            # .yaml 静态配置白名单（7 个文件）
  index/               # .json 机器索引 / 图森林真值
    card-graph.json    # 图森林（节点+边+tree_id）
  res/inbox/           # 原始素材封存区
  cards/               # .md 人类主编辑载体（业务源头）
    characters/        # type: actor（ac-）
    plotpoints/        # type: plotpoint（pp-）
    items/             # type: item（it-）
    scenes/            # type: scene（sc-）
    foreshadow/        # type: foreshadow（fs-）
    timeline/          # type: timeline（tl-）
    factions/          # type: faction（fa-）
    snapshots/         # type: snapshot（sn-）
    darklayer/         # type: darklayer（dk-，独立命名空间）
    modules/           # type: module（md-）
    lexstats/          # type: lexstat（lx-）
    corpus/            # type: corpus（co-）
    metrics/           # type: metric（mt-）
    pose-bank/         # type: pose（po-）
    custom/            # 经 nc-注册 的自定义类型
      sensory_cue/     # type: sensory_cue（su-）
      refwork/         # type: refwork（rw-）
  reflections/         # type: reflection（rf-，独立于 cards/）
  manuscript/          # 正文章节
  graph/               # .html 可视化看板（消费 card-graph.json 渲染）
  tools/               # 可选只读运行时（nc_validate.py：validate/audit/simulate，缺失降级纸面校验）
  export/ release/     # nc-导出 中间产物 / 成品
  history/             # nc-定稿 工程快照归档
  drafts/practice/     # 练习稿（过滤器未通过 / 用户标记）
  CHANGELOG.md latest.md
```

详细布局与各目录职责见 `references/layout.md`。

---

## 3. 29 技能速查总表（六组）

按功能分六组。所有技能支持中文与英文双向别名调用，新手优先中文；输入任一别名
内部自动映射，返回提示仍以中文为主、英文名括号附带。面向作者呈现的是**用户可主动
调用**的六组分类；`auto_invokable` 内部标记对普通作者隐藏，仅在
`skill-reference.md` 备查总表与底层 `config/skills.yaml` 可见（仅 `nc-量化` /
`nc-图谱` / `nc-节奏` 为 true）。

### 3.A 工程初始化 & 素材资产组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-初始化` | `nc-init` | 新建工程骨架 + agents/quickstart/skill-reference 三文档 + config；`--lang zh/en`、长短篇预设 |
| `nc-素材` | `nc-material` | 原素材收纳入库（本地/纯文本/URL），入库前自动过通胀过滤器 gate |
| `nc-清洗` | `nc-clean` | 素材降噪预处理，生成独立干净副本，原始素材保留不动 |
| `nc-检索` | `nc-query` | 检索素材与全部卡片资产（含 `type:character_tendency`、按角色过滤），返回候选资产池 |
| `nc-注册` | `nc-reg` | 注册自定义卡片类型 / 动线 track 标签 / 动向人格基线原型（写入 registry 白名单） |
| `nc-更名` | `nc-rename` | 全局标识符替换（书名/代号），先预览后批量写入，不动 res/ 与口语称呼 |

### 3.B 叙事卡片建模组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-角色` | `nc-role` | 新建/更新叙事行动单元（人/蛤蟆/器灵/抽象意志，不限于人类） |
| `nc-姿态` | `nc-pose` | 角色招牌动作库：内核固定 + 环境插槽 + 多视角模板（长篇精细人设） |
| `nc-道具` | `nc-item` | 新建/更新道具卡，黑盒自动拆分物理/感知/抽象三层动线 |
| `nc-场景` | `nc-scene` | 新建/更新场景卡片，记录环境基础参数 |
| `nc-感官标记` | `nc-sensorycue` | 创建/编辑感官标记卡（声音/乐曲/气味/光影氛围触发器），供桥段引用 |
| `nc-动向` | `nc-tendency` | 创建/编辑 `character_tendency`（`tend-`）角色动向滑动标尺，每次变动绑定桥段推手；可选声明人格基线原型 `baseline_prototype`（须经 nc-注册） |

### 3.C 剧情结构组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-桥段` | `nc-plot` | 构思剧情单元、绑定角色/道具/pose、标记章节、标注战略爆点 |
| `nc-伏笔` | `nc-foreshadow` | 预埋长线伏笔、登记预期回收位置（长篇 ≥8 章四方对齐） |
| `nc-快照` | `nc-snapshot` | 时间锚点全局状态切片，定格多方角色/道具/势力状态 |
| `nc-势力` | `nc-faction` | 多方势力、立场、关系网络建模（长篇默认开启） |
| `nc-暗线` | `nc-thread` | 整条明面叙事的隐性逻辑链路（setting/plot/character/mixed） |
| `nc-积木` | `nc-module` | 积木编排：trigger_map 绑定动线/伏笔/pose，组装触发关系 |
| `nc-研判` | `nc-analyze` | 单点创作推演，出方案 A/B/C（只出建议报告，绝不改卡） |
| `nc-编排` | `nc-compose` | 批量剧情编排三段式（计划→审核→执行），前置 nc-校阅 扫冲突 |

### 3.D 生成与可视化组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-量化` | `nc-metric` | 挂载张力、爆点、信息载荷等量化指标（长篇/深度打磨）〔auto_invokable〕 |
| `nc-图谱` | `nc-graph` | 渲染叙事森林时序图、角色关系、动线链路图、积木联动总图〔auto_invokable〕 |
| `nc-成稿` | `nc-draft` | 读全部卡片出正文初稿，`--length short/mid/long` 控篇幅（走提案制） |
| `nc-词频` | `nc-wordfreq` | 词频向量 + 感官均衡强约束校验（纯约束，不出正文），为成稿提供输入 |

### 3.E 审计校验组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-校阅` | `nc-review` | 叙事审计：设定/pose 约束/动线/伏笔/动机/OOC + 动向逻辑冲突（含原型边界漂移检查④；内置 nc-节奏） |
| `nc-节奏` | `nc-rhythm` | 章节桥段疏密、爆点密度、留白校验，战略爆点自动豁免〔auto_invokable〕 |
| `nc-守卫` | `nc-safetyguard` | 隐私 + 合规内容扫描，区分【渲染加害红线】/【揭露批判疑点】 |

### 3.F 归档导出 & 复盘组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-定稿` | `nc-finalize` | 生成工程快照归档、打上锁定标记（可选分支） |
| `nc-导出` | `nc-export` | Pandoc 底层，跨平台导出 PDF / Word |
| `nc-复盘` | `nc-retrospect` | 沉淀经验、洞察，回流素材库，开启新一轮构思 |

> **分析模式专用**：`nc-对标`(nc-refwork) 是 v1.0 主体保留的外部作品拆解学习技能
> （独立 `tree_id` 隔离），服务于「拆解现成外部作品」流程，不计入面向用户的六组
> 29 技能分类，在分析模式下按需手动触发。

完整双语别名映射 JSON、每技能入参/产物、旧 12→新 29 对照表见
`references/skill-catalog.md`。

---

## 4. 硬规则摘要（违反即视为失败）

1. **禁止直接写卡**：AI 不直接 `edit` / `write` 使用方工程的卡片、图谱、反思卡、
   练习稿文件。**所有回写一律走提案制**，用户确认后由用户落盘。
2. **伏笔卡必须关联 payoff**：`payoff_chapter` 有值 **或** `status: unresolved`；
   两者皆缺视为非法。
3. **dark-layer 隔离**：暗线卡位于 `cards/darklayer/`，id 前缀 `dk-`，与主书角色链
   不共享命名空间；引用**只**通过 `references_to_main` 显式串接。
4. **五字段不可缺**：`id` / `type` / `status` / `created` / `updated` 每张卡必备。
5. **相对路径**：所有读写引导用相对使用方工程根的相对路径，无绝对路径 / `~/` / `$HOME`。
6. **图谱与卡片分离**：HTML 图谱存 `graph/`，不入 `cards/`，无 frontmatter，不被视为卡片。
7. **闭环反哺**：反思卡 `action_items` 是唯一把新认知写回卡片的入口，逐条提案。
8. **通胀过滤器 gate**：新素材经 `nc-素材` 入库前自动过三问，Q3（独家洞察）是否决项；
   保留手动 `nc-过滤` 复检。
9. **四层数据分层铁律**：`.md` 业务源头 / `.json` 图森林真值 / `.yaml` 配置白名单 /
   `.html` 展示投影；html MUST 由 `index/card-graph.json` 重生成，不存业务逻辑。
10. **审计类技能只读**：`nc-校阅` / `nc-节奏` / `nc-守卫` 只出意见，绝不自动改稿。
11. **五感公理**：感知动线根 MUST 落在原生五感之一，玄幻衍生感知建模为子标签变体。
12. **道具黑盒三层**：item 卡支持物理/感知/抽象非感知层，默认黑盒模式自动拆解。
13. **pose 插槽三级优先级**：P1 桥段覆写 > P2 快照自动填充 > P3 默认兜底；冲突进意见书。
14. **注册前置**：自定义类型 / track 标签 / 动向人格基线原型取值 MUST 先经 `nc-注册` 写入 registry 再建卡。
15. **素材合规 fail-closed**：网页抓取先校验 robots.txt，禁止路径直接拦截，不绕过反爬。
16. **actor 与 item 区分**：拥有独立意志主动行动的道具 SHALL 建模为 actor（object-spirit）。
17. **跨动线同步走 module**：MUST 走积木 `trigger_map`，禁止零散写联动。
18. **长线四方对齐**：长线爆点 MUST 满足 fs- + tl- + md- + lx- 提前 ≥8 章预埋。

完整规则见 `references/hard-rules.md`。

---

## 5. 路由规则（nc-xxx → 读哪个 reference）

| 技能 | 主要读取 | 模板 |
|---|---|---|
| `nc-初始化` | `references/layout.md`、`references/agents-guide.md` | `templates/agents-zh.md` / `agents-en.md` / `quickstart-zh.md` / `skill-reference-zh.md` |
| `nc-素材` | `references/compliance.md`、`references/filter.md` | `templates/corpus.md` |
| `nc-清洗` / `nc-检索` / `nc-注册` | `references/data-layering.md`（registry/index 约定） | — |
| `nc-更名` | `references/hard-rules.md`（规则 25 先预览后替换）、`references/data-layering.md`（graph 重渲染） | — |
| `nc-角色` | `references/card-schema.md`（actor 分类标签） | `templates/characters.md` |
| `nc-姿态` | `references/card-schema.md`（pose 插槽优先级） | `templates/pose-bank.md` |
| `nc-道具` | `references/card-schema.md`（黑盒三层 + 五感公理） | `templates/items.md` |
| `nc-场景` | `references/card-schema.md` | `templates/scenes.md` |
| `nc-感官标记` | `references/card-schema.md` | `templates/sensory-cues.md` |
| `nc-动向` | `references/card-schema.md`（character_tendency 滑动标尺） | `templates/tendencies.md` |
| `nc-桥段` | `references/card-schema.md`（lexstat_bind/module_list/pose_refs） | `templates/plotpoints.md` |
| `nc-伏笔` | `references/card-schema.md`（四方对齐） | `templates/foreshadow.md` |
| `nc-快照` | `references/card-schema.md`（时间锚点定义） | `templates/snapshots.md` |
| `nc-势力` | `references/card-schema.md` | `templates/factions.md` |
| `nc-暗线` | `references/hard-rules.md`（规则 4 暗线边界） | `templates/darklayer.md` |
| `nc-积木` | `references/card-schema.md`（trigger_map） | `templates/modules.md` |
| `nc-研判` | `references/loop.md`（单点推演分支）、`references/hard-rules.md`（规则 24 只出建议） | — |
| `nc-编排` | `references/loop.md`（批量迭代分支）、`references/hard-rules.md`（规则 24 计划→审核→执行） | — |
| `nc-量化` | `references/data-layering.md`（metric-index.json） | `templates/metrics.md` |
| `nc-图谱` | `references/data-layering.md`（card-graph.json schema） | `templates/relation-graph.html` |
| `nc-成稿` | `references/loop.md`（写稿分支 + --length 档位） | — |
| `nc-词频` | `references/card-schema.md`（lexstat 强约束） | `templates/lexstats.md` |
| `nc-校阅` | `references/hard-rules.md`（规则 12 只读铁律 + 动向逻辑冲突） | — |
| `nc-节奏` | `references/hard-rules.md`（规则 12 只读铁律） | — |
| `nc-守卫` | `references/hard-rules.md`（规则 17 合规 fail-closed） | — |
| `nc-定稿` | `references/loop.md`（分支开关） | — |
| `nc-复盘` | `references/loop.md`、`references/hard-rules.md`（规则 9） | `templates/reflections.md` |
| `nc-对标` | `references/data-layering.md`（tree_id 隔离，分析模式专用） | `templates/refworks.md` |
| `nc-导出` | `references/layout.md`（export/release 目录） | — |

---

## 6. 三场景流程概览

由 `registry/work-length-config.yaml` 的 mode 决定默认启用集，详见
`references/loop.md` 的长短篇分级矩阵。

- **场景 A · 长篇深度打磨（long）**：全技能开启，含 nc-伏笔/势力/暗线/量化/姿态/守卫/动向/研判/编排。
  `nc-初始化(long) → nc-素材 → [nc-清洗] → nc-检索 → 建卡 → nc-词频(写稿) →
  nc-成稿 → nc-校阅+nc-节奏(审稿) → 修稿 → nc-定稿 → nc-导出 → nc-复盘(反哺) → 回到构思`
- **场景 B · 中篇标准流程（mid）**：关闭 nc-势力/暗线/量化/姿态（按需手动开启）。
- **场景 C · 短篇极简流程（short）**：仅 nc-初始化/素材/角色/道具/场景/桥段/词频/成稿，
  跳过审稿/定稿，nc-复盘可选。

创作迭代分支（三场景均可按需手动触发）：单点推演走 `nc-研判`（出方案 A/B/C，不改卡）；
批量整线迭代走 `nc-编排`（计划→审核→执行，前置 nc-校阅 扫冲突）。两者都绝不静默改卡。

写稿→审稿→修稿→定稿分支由 `registry/work-setting.yaml` 的 `pipeline_option`
（`enable_review` / `enable_finalize` / `enable_safety_guard`）控制。

---

## 7. 合规声明

Novel-Cards 仅提供轻量化单点内容摘录辅助。工具会主动遵从目标网站 robots.txt
协议；所有网页内容的使用合法性、著作权风险，由创作者本人承担。本工具不承担因
内容摘抄、引用带来的法律责任。单次单链接，无批量采集能力，不商用。

`nc-素材` 录入网页 URL 时 MUST 先校验目标站点 robots.txt：禁止路径直接拦截不请求
页面；不尝试绕过反爬/登录/动态渲染；任何不确定情况按「禁止」处理终止；抓取成功
必附版权提醒。详见 `references/compliance.md`。

---

## 8. 工作流程（五步）

1. **澄清意图**：命中触发场景（前缀式或自然语言），一句话回述目标动作；歧义先问清。
2. **读取上下文**：定位使用方工程根，读取相关卡片 / 图森林 / 正文片段（按需）。
3. **生成提案**：依据 `templates/<type>.md` 出完整 Markdown 草案（含 frontmatter +
   正文）或 HTML 图谱代码，标注目标文件相对路径；一次只提案一张卡或一张图谱。
4. **落盘（由用户执行）**：用户审阅确认后将最终内容保存到目标路径；AI 不执行
   `edit` / `write`，仅在用户报告落盘后核对硬规则合规性。
5. **反哺（仅限反思卡）**：逐条读 `action_items`，每条单独出反哺提案，用户逐条
   确认或跳过；全部处理完毕后反思卡 `status` 可由 `draft` 改为 `closed`。

---

## 9. 参考文件

- `references/oo-model.md` — 面向对象透镜：NcObject 基类（五字段 + render/validate/snapshot/patch 四方法）、8 子类属性/方法契约、StoryWorld 容器（5 属性 / 8 方法）、29 技能 → 方法全量映射、草稿命名 → 既有 schema 对齐表。
- `references/event-inference.md` — 事件驱动连锁推演：dispatch_event → enter→perceive→act→fire 链 → ChangePlan → 作者审核 → patch → render；冲突三选一；「文字即视图」render 阶段；short/mid/long 模式门控。
- `references/skill-catalog.md` — 29 技能六组分类、双语别名映射、auto_invokable 标记、入参/产物、旧 12→新 29 对照。
- `references/card-schema.md` — 全类型 frontmatter 字段定义与最小示例（含 character_tendency/tend-）。
- `references/data-layering.md` — 四层铁律、card-graph.json 图森林 schema、registry/index 清单。
- `references/compliance.md` — robots.txt 校验链路、四套中英文案、版权提醒、工具定位声明。
- `references/agents-guide.md` — agents.md 四块、意图匹配表、显式指令优先、文档三分拆、可编辑性。
- `references/loop.md` — 三场景流程编排、长短篇分级矩阵、研判/编排迭代分支、动向弧光链、写稿/审稿/修稿/定稿分支开关。
- `references/hard-rules.md` — 26 条硬规则详解（含 24 研判/编排只出建议 / 25 更名先预览后替换 / 26 动向变动绑定桥段）。
- `references/layout.md` — 使用方工程目录树、install.sh 与 nc-初始化 双入口边界。
- `references/filter.md` — 通胀过滤器三问（现为 nc-素材 入库前自动 gate + 手动 nc-过滤 复检）。

模板（结构骨架，不含真实内容示例）：`templates/` 下 characters / plotpoints / items /
scenes / foreshadow / timeline / factions / snapshots / darklayer / reflections / modules /
lexstats / corpus / metrics / pose-bank / sensory-cues / tendencies / refworks /
relation-graph.html / agents-zh.md / agents-en.md / quickstart-zh.md / quickstart-en.md /
skill-reference-zh.md / skill-reference-en.md。

安装 / 初始化：`install.sh` 支持将本 skill 复制或软链到 OpenCode 与 Claude Code 的
skill 目录；`install.sh --project <path>` 生成使用方工程空目录骨架，`nc-初始化`
交互式生成完整骨架 + agents.md。见 `references/layout.md` 的"安装与迁移"章节。
