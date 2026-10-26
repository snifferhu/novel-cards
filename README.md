# novel-cards

双端兼容（**OpenCode** + **Claude Code**）的小说卡片体系维护 skill。为长篇 /
中篇 / 短篇虚构作品提供 **29 个 `nc-` 技能**（工程初始化&素材资产 / 叙事卡片建模 /
剧情结构 / 生成与可视化 / 审计校验 / 归档导出&复盘六组），覆盖 **16+ 类结构化卡片**，
支持 **HTML 图谱**表达复杂关系、**四层数据分层**（`.md` 业务源头 / `.json` 图森林真值 /
`.yaml` 配置白名单 / `.html` 展示投影）、**反思卡**沉淀单章复盘、**通胀过滤器**做
新素材入口 gate。以**提案制**方式与作者协作。统一触发前缀 `nc-`（均支持英文别名）。

> **面向对象透镜**：每张卡都是一个 `NcObject` 子类实例，每个 `nc-*` 技能都是对
> `StoryWorld` 容器或某个对象的一次方法调用；正文是参与对象按 timeline 顺序 `render()`
> 拼接的文本投影——文字只是视图，真相在对象实例里。完整类层次见 `references/oo-model.md`，
> 事件驱动连锁推演见 `references/event-inference.md`。可选只读运行时
> `tools/nc_validate.py`（Python3 标准库单文件）承载 validate/audit/simulate，缺失时降级
> 纸面校验。**OO 视角不改变任何字段契约、技能集合、六组分类与提案制铁律**。

## 这个仓库是什么

本仓库**不是**任何小说工程本身，而是一个 skill 定义仓库。交付物是：

- `SKILL.md` — skill 入口（触发词、29 技能六组速查表、硬规则摘要、路由规则、三场景流程概览、合规声明）
- `references/` — 细则（技能目录、卡片 schema、四层分层、合规链路、agents 引导、闭环工作流、硬规则、布局约定、过滤器）
- `templates/` — 16+ 类卡的骨架模板 + 关系图谱 HTML 模板 + 双语 agents/quickstart/skill-reference 模板
- `install.sh` — 一键安装到 OpenCode / Claude Code；`--project` 生成使用方工程 v1.0 完整目录骨架
- `AGENTS.md` — 本仓库自身的开发约定

**使用方工程**是外部的小说仓库。骨架由 `install.sh --project`（命令行批量）或
`nc-初始化`（交互式，含 agents.md 双语生成）双入口生成。本 skill 只走相对路径，
不修改使用方配置。

> 📖 日常使用、FAQ 与 **v0→v1 迁移指引**请看 **[USAGE.md](./USAGE.md)**。
> 本文档聚焦项目结构、安装方式与技术约定。

## 快速开始

### 一键安装

```bash
# 复制模式（默认）：装到全局 OpenCode + Claude Code
./install.sh

# 只装到一端
./install.sh --target opencode
./install.sh --target claude

# 软链模式（开发期推荐，本仓库改动即时生效）
./install.sh --link
```

### 初始化使用方工程骨架

```bash
./install.sh --project ~/path/to/your/novel
```

生成的 v1.0 空目录骨架（每目录含 `.gitkeep`，并写入 `config/project.yaml` /
`agents.md` 兜底 / `build.sh` / `build.cmd` / `README.md` / `CHANGELOG.md` /
`latest.md` 占位文件；幂等，重复执行不覆盖已有文件）：

```
~/path/to/your/novel/
  agents.md               # Agent 引导（兜底版；nc-初始化 生成交互式完整版）
  config/
    project.yaml          # lang / mode / pipeline_option
  registry/               # .yaml 静态配置白名单（7 个文件，nc-初始化 填充默认值）
  index/                  # .json 机器索引 / 图森林真值（card-graph.json 等）
  res/inbox/              # 原始素材封存区
  templates/              # 每类卡独立模板
  cards/
    characters/           # type: actor（id 前缀 ac-，目录名保留 characters）
    plotpoints/           # 桥段卡 pp-
    items/                # 道具卡 it-（黑盒三层）
    scenes/               # 场景卡 sc-
    foreshadow/           # 伏笔卡 fs-
    timeline/             # 动线卡 tl-（积木驱动）
    factions/             # 势力卡 fa-
    snapshots/            # 快照卡 sn-（时间锚点状态切片）
    darklayer/            # 暗线卡 dk-（独立命名空间）
    modules/              # 积木模块卡 md-（最小调度单元）
    lexstats/             # 词频张力卡 lx-
    corpus/               # 语料卡 co-
    metrics/              # 量化指标卡 mt-
    pose-bank/            # 姿态卡 po-
    custom/
      sensory_cue/        # 感官标记卡 su-
      refwork/            # 对标作品档案卡 rw-
  reflections/            # 反思卡 rf-（独立于 cards/）+ 审计意见书
  manuscript/             # 正文章节
  graph/                  # 关系图谱 HTML（消费 index/card-graph.json 渲染）
  tools/                  # 可选只读运行时（nc_validate.py：validate/audit/simulate，缺失降级纸面校验）
  export/                 # nc-导出 中间产物
  release/                # nc-导出 成品（PDF/Word）
  history/                # nc-定稿 工程快照归档
  drafts/practice/        # 练习稿（过滤器未通过 / 用户标记）
  build.sh build.cmd      # 构建脚本骨架
  README.md CHANGELOG.md latest.md
```

### 软链开发模式

```bash
./install.sh --link --target opencode
./install.sh --link --target claude
```

## 目录结构（本仓库）

```
novel-cards/
  AGENTS.md               # 本仓库开发约定（不要写卡片内容）
  SKILL.md                # skill 入口（frontmatter 仅 name/description/license）
  README.md               # 本文件（项目概览）
  USAGE.md                # 使用说明（三场景操作路径 + FAQ + v0→v1 迁移 + 回滚）
  LICENSE                 # AGPL-3.0（不可修改）
  install.sh              # 一键安装 / 项目初始化
  references/
    oo-model.md           # 面向对象透镜：NcObject 基类 + 8 子类 + StoryWorld 容器 + 29 技能→方法映射
    event-inference.md    # 事件驱动连锁推演：dispatch_event → enter/perceive/act/fire → ChangePlan → patch → render
    skill-catalog.md      # 29 技能六组分类、双语别名映射、auto_invokable 标记、入参/产物、旧 12→新 29 对照
    card-schema.md        # 全类型 frontmatter 字段定义与最小示例（含 character_tendency/tend-）
    data-layering.md      # 四层铁律、card-graph.json 图森林 schema、registry/index 清单
    compliance.md         # robots.txt 校验链路、四套中英文案、版权提醒、工具定位声明
    agents-guide.md       # agents.md 四块、意图匹配表、显式指令优先、文档三分拆、可编辑性
    loop.md               # 三场景流程编排、长短篇分级矩阵、研判/编排迭代分支、动向弧光链、分支开关
    hard-rules.md         # 26 条硬规则详解
    layout.md             # 使用方工程目录树、install.sh 与 nc-初始化 双入口边界
    filter.md             # 通胀过滤器三问（nc-素材 入库前自动 gate + 手动 nc-过滤 复检）
  tools/
    nc_validate.py        # 可选只读运行时（Python3 标准库单文件，validate/audit/simulate 三子命令）
  templates/
    characters.md         # 角色卡（type: actor，ac-）
    plotpoints.md         # 桥段卡
    items.md              # 道具卡（黑盒三层 + 五感公理）
    scenes.md             # 场景卡
    foreshadow.md         # 伏笔卡（payoff 硬约束 + 长线四方对齐）
    timeline.md           # 动线卡（bind_module / trigger_foreshadow）
    factions.md           # 势力卡
    snapshots.md          # 快照卡（时间锚点状态切片）
    darklayer.md          # 暗线卡（独立命名空间）
    reflections.md        # 反思卡（写作闭环五段）
    modules.md            # 积木模块卡（trigger_map）
    lexstats.md           # 词频张力卡
    corpus.md             # 语料卡
    metrics.md            # 量化指标卡
    pose-bank.md          # 姿态卡（插槽三级优先级）
    sensory-cues.md       # 感官标记卡
    tendencies.md         # 角色动向卡（type: character_tendency，tend-，滑动标尺）
    refworks.md           # 对标作品档案卡
    relation-graph.html   # 关系图谱 HTML 模板（自包含 SVG，积木联动总图）
    agents-zh.md          # agents.md 中文模板
    agents-en.md          # agents.md 英文模板
    quickstart-zh.md      # quickstart.md 中文模板（新手主线最简流程）
    quickstart-en.md      # quickstart.md 英文模板
    skill-reference-zh.md # skill-reference.md 中文模板（29 技能全量备查总表）
    skill-reference-en.md # skill-reference.md 英文模板
```

## 29 技能速览（六组）

按功能分六组。所有技能支持中文与英文双向别名调用，新手优先中文。面向作者呈现的是
**用户可主动调用**的六组分类；`auto_invokable` 内部标记对普通作者隐藏，仅在
`skill-reference.md` 备查总表与底层 `config/skills.yaml` 可见（仅 `nc-量化` /
`nc-图谱` / `nc-节奏` 为 true）。

### A. 工程初始化 & 素材资产组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-初始化` | `nc-init` | 新建工程骨架 + agents/quickstart/skill-reference 三文档 + config；`--lang zh/en`、长短篇预设 |
| `nc-素材` | `nc-material` | 原素材收纳入库（本地/纯文本/URL），入库前自动过通胀过滤器 gate |
| `nc-清洗` | `nc-clean` | 素材降噪预处理，生成独立干净副本，原始素材保留不动 |
| `nc-检索` | `nc-query` | 检索素材与全部卡片资产（含 `type:character_tendency`、按角色过滤），返回候选资产池 |
| `nc-注册` | `nc-reg` | 注册自定义卡片类型 / 动线 track 标签 / 动向人格基线原型（写入 registry 白名单） |
| `nc-更名` | `nc-rename` | 全局标识符替换（书名/代号），先预览后批量写入，不动 res/ 与口语称呼 |

### B. 叙事卡片建模组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-角色` | `nc-role` | 新建/更新叙事行动单元（人/蛤蟆/器灵/抽象意志，不限于人类） |
| `nc-姿态` | `nc-pose` | 角色招牌动作库：内核固定 + 环境插槽 + 多视角模板（长篇精细人设） |
| `nc-道具` | `nc-item` | 新建/更新道具卡，黑盒自动拆分物理/感知/抽象三层动线 |
| `nc-场景` | `nc-scene` | 新建/更新场景卡片，记录环境基础参数 |
| `nc-感官标记` | `nc-sensorycue` | 创建/编辑感官标记卡（声音/乐曲/气味/光影氛围触发器），供桥段引用 |
| `nc-动向` | `nc-tendency` | 创建/编辑 `character_tendency`（`tend-`）角色动向滑动标尺，每次变动绑定桥段推手；可选声明人格基线原型 `baseline_prototype`（须经 nc-注册） |

### C. 剧情结构组

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

### D. 生成与可视化组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-量化` | `nc-metric` | 挂载张力、爆点、信息载荷等量化指标（长篇/深度打磨）〔auto_invokable〕 |
| `nc-图谱` | `nc-graph` | 渲染叙事森林时序图、角色关系、动线链路图、积木联动总图〔auto_invokable〕 |
| `nc-成稿` | `nc-draft` | 读全部卡片出正文初稿，`--length short/mid/long` 控篇幅（走提案制） |
| `nc-词频` | `nc-wordfreq` | 词频向量 + 感官均衡强约束校验（纯约束，不出正文），为成稿提供输入 |

### E. 审计校验组

| 中文 | 英文 | 职责 |
|---|---|---|
| `nc-校阅` | `nc-review` | 叙事审计：设定/pose 约束/动线/伏笔/动机/OOC + 动向逻辑冲突（含原型边界漂移检查④；内置 nc-节奏） |
| `nc-节奏` | `nc-rhythm` | 章节桥段疏密、爆点密度、留白校验，战略爆点自动豁免〔auto_invokable〕 |
| `nc-守卫` | `nc-safetyguard` | 隐私 + 合规内容扫描，区分【渲染加害红线】/【揭露批判疑点】 |

### F. 归档导出 & 复盘组

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

## 16+ 卡类型速览

所有卡必备五字段：`id` / `type` / `status` / `created` / `updated`。

| # | 类型 | type | id 前缀 | 目录 | 关键专属字段 |
|---|---|---|---|---|---|
| 1 | 角色 | `actor` | `ac-` | `cards/characters/` | `classification`（非人类分类标签）/ `cross_ref` |
| 2 | 桥段 | `plotpoint` | `pp-` | `cards/plotpoints/` | `chapter` / `lexstat_bind` / `module_list` / `pose_refs` / `strategic_burst` |
| 3 | 道具 | `item` | `it-` | `cards/items/` | 黑盒三层（physical/perceptual/abstract）/ `advanced_mode` |
| 4 | 场景 | `scene` | `sc-` | `cards/scenes/` | `location` / `time_of_day` / 环境参数 |
| 5 | 伏笔 | `foreshadow` | `fs-` | `cards/foreshadow/` | `setup_chapter` + `payoff_chapter`（或 `status: unresolved`）/ 长线四方对齐 |
| 6 | 动线 | `timeline` | `tl-` | `cards/timeline/` | `track` / `target` / nodes（`node_id` / `bind_module` / `trigger_foreshadow`） |
| 7 | 势力 | `faction` | `fa-` | `cards/factions/` | `members` / `territory` / `conflicts` |
| 8 | 快照 | `snapshot` | `sn-` | `cards/snapshots/` | 时间锚点 / `used_pose` / 多方状态定格 |
| 9 | 暗线 | `darklayer` | `dk-` | `cards/darklayer/` | `layer`（1-7）/ `references_to_main` / `is_revealed` |
| 10 | 积木 | `module` | `md-` | `cards/modules/` | `trigger_map`（最小调度单元） |
| 11 | 词频 | `lexstat` | `lx-` | `cards/lexstats/` | 词频向量 / 感官均衡约束 |
| 12 | 语料 | `corpus` | `co-` | `cards/corpus/` | 来源 / 标签 / 入库 gate 判定 |
| 13 | 量化 | `metric` | `mt-` | `cards/metrics/` | 张力 / 爆点 / 信息载荷数值 |
| 14 | 姿态 | `pose` | `po-` | `cards/pose-bank/` | 内核 / 环境插槽 / 多视角模板（P1>P2>P3 优先级） |
| 15 | 感官标记 | `sensory_cue` | `su-` | `cards/custom/sensory_cue/` | 触发器类型（声音/乐曲/气味/光影） |
| 16 | 角色动向 | `character_tendency` | `tend-` | `cards/tendencies/` | `target_role` / `dimension` / `baseline` / `direction_rule` / `current_value` / `history[]`（每条绑定桥段推手）/ `baseline_prototype`（可选，人格基线原型，须经 nc-注册） |
| 17 | 对标作品 | `refwork` | `rw-` | `cards/custom/refwork/` | 独立 `tree_id` 隔离 / 拆解维度 |
| 18 | 反思 | `reflection` | `rf-` | `reflections/`（不入 `cards/`） | 五段结构（`stuck`/`shone`/`why`/`insights`/`action_items`） |

> **启用等级**（非硬约束，由 `registry/work-length-config.yaml` 的 mode 决定默认集）：
> - **long**：全技能开启，含 nc-伏笔/势力/暗线/量化/姿态/守卫/动向/研判/编排
> - **mid**：关闭 nc-势力/暗线/量化/姿态（按需手动开启）
> - **short**：仅 nc-初始化/素材/角色/道具/场景/桥段/词频/成稿，跳过审稿/定稿

## 四层数据分层

```
┌─────────────────────────────────────────────────────────────┐
│  .md   cards/**  reflections/  manuscript/                   │
│        人类主编辑载体 · 业务源头（直接改）                      │
├─────────────────────────────────────────────────────────────┤
│  .json index/card-graph.json  metric-index.json  lex-batch   │
│        机器索引 · 图森林真值（系统同步生成，优先经 nc- 指令改动） │
├─────────────────────────────────────────────────────────────┤
│  .yaml registry/*.yaml  config/project.yaml                  │
│        静态配置白名单（人工少量维护，或经 nc-注册）              │
├─────────────────────────────────────────────────────────────┤
│  .html graph/*.html                                             │
│        可视化看板 · 纯展示投影（由 json 重生成，不存业务逻辑）     │
└─────────────────────────────────────────────────────────────┘
```

铁律：`.html` MUST 由 `index/card-graph.json` 重生成，不存业务逻辑；`.md` 是唯一
业务源头；`.json` 是图森林真值（节点 id/type/tree_id + 边 source/target/relation）；
`.yaml` 是配置白名单。详见 `references/data-layering.md`。

## HTML 关系图谱

复杂关系（多对象、多类型、含暗示关系、积木联动）用 **HTML + SVG** 图谱表达，
存放于使用方工程的 `graph/` 目录，独立于 `cards/`。

- **模板**：`templates/relation-graph.html`（自包含，无外部依赖；积木联动总图三层结构）
- **数据源**：`index/card-graph.json` 图森林（本 HTML 是其纯展示投影）
- **命名**：`tl-<slug>-graph.html`（与核心动线卡 slug 对齐）
- **卡片引用**：动线卡正文写 `见 graph/xxx.html`
- **生成方式**：`nc-图谱 <对象>` 或自然语言「生成 xx 的关系图谱」
- **重生成**：`card-graph.json` 变更后，`nc-图谱` 重新渲染，旧 html 被覆盖

## 写作闭环（Loop）

系统的形状：素材 → AI → 卡片 → 文章 → **读者反馈 / 自我复盘 → 新认知 →
反哺素材库 → 再次写作**。反思卡是这条回路的锚点。

- **触发**：`nc-复盘 <章节>` 或自然语言「复盘这一章」
- **产物**：`reflections/<chapter-id>.md`，含五段结构：
  - `stuck` — 卡点
  - `shone` — 亮点
  - `why` — 归因
  - `insights` — 新认知
  - `action_items` — 反哺动作（唯一允许写回卡片的入口）
- **反哺**：每条 `action_items` 单独出反哺提案，用户逐条确认或跳过
- **详细**：`references/loop.md`

## 通胀过滤器（Filter）

新素材进入正式排期前的入口 gate，防止同质化素材污染素材库。现为 `nc-素材`
入库前**自动 gate**，同时保留手动 `nc-过滤` 复检入口。

- **三问**：
  1. Q1 公共领域性：这个题材是否是公共领域人人都能讨论的？
  2. Q2 三个月复刻性：如果我不做，三个月后会不会有别人用同样角度做出来？
  3. Q3 独家洞察：我的角度里有没有只有我知道、只有我能提供的特殊经验或洞察？
- **判定**：Q3 是否决项，无独家洞察一律进 `drafts/practice/`
- **详细**：`references/filter.md`

## 合规声明

Novel-Cards 仅提供轻量化单点内容摘录辅助。工具会主动遵从目标网站 robots.txt
协议；所有网页内容的使用合法性、著作权风险，由创作者本人承担。本工具不承担因
内容摘抄、引用带来的法律责任。单次单链接，无批量采集能力，不商用。

`nc-素材` 录入网页 URL 时 MUST 先校验目标站点 robots.txt：禁止路径直接拦截不请求
页面；不尝试绕过反爬/登录/动态渲染；任何不确定情况按「禁止」处理终止；抓取成功
必附版权提醒。详见 `references/compliance.md`。

## 硬规则速览（26 条，违反即视为失败）

1. **禁止直接写卡**：AI 绝不 `edit` / `write` 使用方工程的卡片、图谱、反思卡、练习稿文件。
2. **提案制**：AI 回写卡片以完整 Markdown 提案、图谱以完整 HTML 提案输出，用户确认后自行落盘。
3. **伏笔合法**：伏笔卡必须有 `payoff_chapter` **或** `status: unresolved`；二者皆缺视为非法。
4. **暗线隔离**：暗线卡必须位于 `cards/darklayer/`，id 前缀 `dk-`，与主书角色只通过 `references_to_main` 单向串接。
5. **五字段必备**：所有卡 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated`。
6. **相对路径**：所有读写引导用相对使用方工程根的相对路径，无绝对路径 / `~/` / `$HOME`。
7. **图谱与卡片分离**：关系图谱 HTML 存 `graph/`，不入 `cards/`；卡片正文可引用，图谱无 frontmatter。
8. **双端兼容**：`SKILL.md` frontmatter 只允许 `name` / `description` / `license` 三键，禁止 opencode 专属字段。
9. **闭环反哺**：反思卡正文必须含 `stuck` / `shone` / `why` / `insights` / `action_items` 五段；`action_items` 是唯一把新认知写回卡片的入口。
10. **过滤器 gate**：新素材经 `nc-素材` 入库前自动过三问；Q3（独家洞察）是否决项。
11. **四层数据分层铁律**：`.md` 业务源头 / `.json` 图森林真值 / `.yaml` 配置白名单 / `.html` 展示投影；html MUST 由 json 重生成。
12. **审计类技能只读**：`nc-校阅` / `nc-节奏` / `nc-守卫` 只出意见，绝不自动改稿。
13. **五感公理**：感知动线根 MUST 落在原生五感之一，玄幻衍生感知建模为子标签变体。
14. **道具黑盒三层**：item 卡支持物理/感知/抽象非感知层，默认黑盒模式自动拆解。
15. **pose 插槽三级优先级**：P1 桥段覆写 > P2 快照自动填充 > P3 默认兜底；冲突进意见书。
16. **注册前置**：自定义类型 / track 标签 / 动向人格基线原型取值 MUST 先经 `nc-注册` 写入 registry 再建卡。
17. **素材合规 fail-closed**：网页抓取先校验 robots.txt，禁止路径直接拦截，不绕过反爬。
18. **actor 与 item 区分**：拥有独立意志主动行动的道具 SHALL 建模为 actor（object-spirit）。
19. **跨动线同步走 module**：MUST 走积木 `trigger_map`，禁止零散写联动。
20. **长线四方对齐**：长线爆点 MUST 满足 fs- + tl- + md- + lx- 提前 ≥8 章预埋。
21. **研判/编排只出建议与计划**：`nc-研判` 只出方案 A/B/C 报告、`nc-编排` 先出 compose_plan 交作者审核，两者都绝不静默改卡。
22. **更名先预览后替换**：`nc-更名` 全局标识符替换必须先出【替换预览清单】经作者确认才批量写入，且不动 `res/` 原始素材与口语称呼。
23. **动向变动绑定桥段**：`character_tendency` 的 `history[]` 每条 MUST 绑定一个已存在的桥段卡（`trigger_plot` 引用真实 `pp-*`），禁止无推手凭空变性格。
24. **auto_invokable 仅三项**：只有 `nc-量化` / `nc-图谱` / `nc-节奏` 为 true，其余技能一律 `user_trigger_only`，不对普通作者暴露该属性。
25. **文档三分拆**：使用方工程引导文档拆为 `agents.md`（Agent 行为契约）/ `quickstart.md`（新手主线）/ `skill-reference.md`（29 技能全量备查），中英双语模板节结构一一对应。
26. **六组分类一致性**：SKILL.md 速查表 / README 技能表 / `references/skill-catalog.md` / `USAGE.md` 四处列出的 29 技能集合与六组分组完全相同。

完整规则见 `references/hard-rules.md`。

## 触发场景

### 统一前缀触发（推荐，29 个，均支持英文别名）

按六组分类：

- **A. 工程初始化 & 素材资产**：`nc-初始化` / `nc-素材` / `nc-清洗` / `nc-检索` / `nc-注册` / `nc-更名`
- **B. 叙事卡片建模**：`nc-角色` / `nc-姿态` / `nc-道具` / `nc-场景` / `nc-感官标记` / `nc-动向`
- **C. 剧情结构**：`nc-桥段` / `nc-伏笔` / `nc-快照` / `nc-势力` / `nc-暗线` / `nc-积木` / `nc-研判` / `nc-编排`
- **D. 生成与可视化**：`nc-量化` / `nc-图谱` / `nc-成稿` / `nc-词频`
- **E. 审计校验**：`nc-校阅` / `nc-节奏` / `nc-守卫`
- **F. 归档导出 & 复盘**：`nc-定稿` / `nc-导出` / `nc-复盘`

英文别名示例：`nc-role` / `nc-tendency` / `nc-analyze` / `nc-compose` / `nc-rename` /
`nc-plot` / `nc-item` / `nc-foreshadow` / `nc-timeline` / `nc-wordfreq` / `nc-draft` /
`nc-graph` / `nc-module` / `nc-snapshot` / `nc-faction` / `nc-thread` / `nc-refwork` /
`nc-metric` / `nc-pose` / `nc-sensorycue` / `nc-rhythm` / `nc-review` / `nc-safetyguard` /
`nc-export` / `nc-init` / `nc-material` / `nc-clean` / `nc-query` / `nc-reg`。
完整映射见 `references/skill-catalog.md`。

### 自然语言触发（无前缀，兜底）

- 「维护小说卡片体系」 / 「更新角色卡」 / 「添加一张伏笔卡」
- 「整理这一章出现的道具 / 场景」
- 「梳理动线」 / 「生成关系图谱」 / 「搭一个积木模块」
- 「埋个伏笔」 / 「回收伏笔」 / 「这条暗线要收」
- 「写章节状态快照」 / 「做一下时间线快照」
- 「这个角色本性克制，经历几件事后慢慢放荡」（性格动向 → `nc-动向`）
- 「这个角色再突破底线怎么安排合适」（单点推演 → `nc-研判`）
- 「这批素材用上，老情节换掉」（批量迭代 → `nc-编排`）
- 「改书名」 / 「把全局代号 X 重命名为 Y」（→ `nc-更名`）
- 「复盘这一章」 / 「这一章哪里卡住了」 / 「这一章写完要沉淀一下」
- 「过滤一下这个素材」 / 「这个题材值不值得做」 / 「这个角度别人能不能抄」
- 「校阅一下设定一致性」 / 「检查一下节奏」 / 「做个合规扫描」
- 「导出成 PDF」

## 工作流程（五步）

```
读上下文 → 提案卡片 / 图谱 / 反思卡 / 过滤器判定
         → 用户确认 → 用户落盘 → (反思卡) 反哺
```

1. **澄清意图**：命中触发场景（前缀式或自然语言），一句话回述目标动作；歧义先问清
2. **读取上下文**：AI 读取使用方工程的相关章节、卡片、图森林、正文片段（按需）
3. **生成提案**：AI 在对话中输出完整 Markdown 提案或 HTML 图谱代码，标注目标文件相对路径
4. **用户落盘**：用户审阅确认后将最终内容保存到目标路径；AI 不执行 `edit` / `write`
5. **反哺（仅反思卡）**：AI 逐条读 `action_items`，单独出反哺提案，用户逐条确认

## 使用方工程约束

本 skill 严格遵守以下边界：

- **只读已存在路径**：`cards/` 与 `manuscript/` 缺失时提示用户补齐，不自建
- **相对路径**：所有路径引导以使用方工程根为基准
- **不动使用方配置**：不修改 `AGENTS.md` / `CLAUDE.md` / `.gitignore` / `package.json` 等（`agents.md` 引导文件除外，它由 `nc-初始化` 生成且允许作者手动编辑）
- **不改本仓库配置**：不新增 `opencode.json` / `package.json` / 依赖锁

## 贡献本 skill

修改本仓库前请阅读 `AGENTS.md`，其中包含：

- 本仓库定位与禁区
- 双端兼容铁律（frontmatter 三键原则）
- SKILL.md / references / templates 编辑自检清单

## License

**AGPL-3.0**（见根目录 `LICENSE` 文件）。

`SKILL.md` frontmatter 的 `license` 字段与本许可证保持一致，均为 AGPL-3.0。
