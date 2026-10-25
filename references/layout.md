# 布局约定（layout.md）

使用方工程 v1.0 采用四层数据分层目录结构（md / json / yaml / html）。骨架由
`install.sh --project` 或 `nc-初始化` 双入口生成；skill 只**读**已存在的相对路径，
不创建、不移动、不重命名。缺失目录时提示用户补齐，由用户显式决定。

## 推荐布局（v1.0 完整目录树）

```
<consumer-project-root>/
  agents.md                # Agent 引导文件（Agent 行为契约；nc-初始化 生成，可编辑）
  quickstart.md            # 新手主线最简流程（6 步闭环 + 进阶扩展；隐藏 auto_invokable）
  skill-reference.md       # 29 技能全量备查总表（带 auto_invokable 列 + 六组分组）
  config/
    project.yaml           # 工程配置：lang / mode / pipeline_option
    skills.yaml            # 29 技能条目骨架（auto_invokable 默认值；唯一可见该属性的底层配置）
    safety-blacklist.yaml  # 合规禁区（与 registry/safety-blacklist.yaml 同源，工程级副本）
  registry/                # .yaml 静态配置白名单
    work-length-config.yaml   # 长短篇模式与技能启用矩阵
    work-setting.yaml         # pipeline_option 分支开关
    safety-blacklist.yaml     # 守卫用合规禁区
    types-registry.yaml       # 自定义卡片类型白名单
    tracks-registry.yaml      # 自定义动线 track 标签白名单
    tags-registry.yaml        # 语义标签白名单
    burst-tags-registry.yaml  # 爆点标注白名单
    tendency-prototypes.yaml  # 动向卡人格基线原型白名单（骨架 only，经 nc-注册 写入）
  index/                   # .json 机器索引 / 图森林真值
    card-graph.json          # 图森林（节点+边+tree_id）
    metric-index.json        # 量化数值索引
    lex-batch.json           # 词频向量批量统计
    query-cache              # nc-检索 查询缓存
  res/                     # 原始素材封存区
    inbox/                  # 待处理原始素材（本地/纯文本/URL 抓取落盘）
  cards/                   # .md 人类主编辑载体（业务源头）
    characters/            # type: actor，角色卡（id 前缀 ac-）
    plotpoints/            # type: plotpoint，桥段卡（pp-）
    items/                 # type: item，道具卡（it-）
    scenes/                # type: scene，场景卡（sc-）
    foreshadow/            # type: foreshadow，伏笔卡（fs-）
    timeline/              # type: timeline，动线卡（tl-）
    factions/              # type: faction，势力卡（fa-）
    snapshots/             # type: snapshot，快照卡（sn-）
    darklayer/             # type: darklayer，暗线卡（dk-，独立命名空间）
    modules/               # type: module，积木模块卡（md-）
    lexstats/              # type: lexstat，词频张力卡（lx-）
    corpus/                # type: corpus，语料卡（co-）
    metrics/               # type: metric，量化指标卡（mt-）
    pose-bank/             # type: pose，姿态卡（po-）
    tendencies/            # type: character_tendency，角色动向卡（tend-，性格/心智倾向滑动标尺）
    custom/                # 经 nc-注册 的自定义类型
      sensory_cue/         # type: sensory_cue，感官标记卡（su-）
      refwork/             # type: refwork，对标作品档案卡（rw-）
      <custom-type>/       # 其他自定义类型
  templates/               # 每类卡的独立模板（nc-初始化 从 skill 仓库拷贝）
  reflections/             # type: reflection，反思卡（rf-，独立于 cards/）
    chapter-050.md
    review-*.md            # nc-校阅 意见书
    rhythm-rt-*.json       # nc-节奏 评估报告
    safety-check/sg-*.md   # nc-守卫 告警报告
  manuscript/              # 正文章节
    chapter-001.md
    chapter-002.md
  graph/                   # .html 可视化看板（消费 index/card-graph.json 渲染）
    tl-bronze-key-graph.html
  export/                  # nc-导出 中间产物
  release/                 # nc-导出 成品（PDF/Word）
  history/                 # nc-定稿 工程快照归档
  drafts/
    practice/              # 练习稿（通胀过滤器未通过 / 用户标记）
  CHANGELOG.md             # 变更日志（nc-定稿 追加）
  latest.md                # 断点状态（nc-定稿 更新）
```

## 各目录职责速查

| 目录 | 文件类型 | 核心定位 | 能否改逻辑 |
|---|---|---|---|
| `quickstart.md` / `skill-reference.md` | `.md` | 新手主线引导 / 29 技能全量备查总表 | ✅ 作者可手动编辑 |
| `config/skills.yaml` | `.yaml` | 29 技能条目骨架（auto_invokable 默认值） | ⚠️ 底层配置，普通作者无需改动 |
| `cards/**` | `.md` | 人类主编辑载体，业务源头 | ✅ 直接改 |
| `reflections/` | `.md` / `.json` | 反思卡 + 审计意见书 | ✅ 直接改 |
| `manuscript/` | `.md` | 正文章节手稿 | ✅ 直接改 |
| `index/` | `.json` | 机器索引、图森林真值、数值索引 | ⚠️ 系统同步生成，优先经 nc- 指令改动 |
| `registry/` | `.yaml` | 静态配置白名单 | ✅ 人工少量维护（或经 nc-注册） |
| `graph/` | `.html` | 可视化看板，纯展示投影 | ❌ 由 json 重生成，不存业务逻辑 |
| `res/inbox/` | 原始格式 | 原始素材封存 | ✅ 原样封存，不可原地覆盖 |
| `export/` / `release/` | 多格式 | 导出中间产物 / 成品 | — |
| `history/` | 快照 | 定稿归档 | — |
| `drafts/practice/` | `.md` | 练习稿 | ✅ 自由文本 |

## install.sh 与 nc-初始化 双入口边界

两个入口都能生成使用方工程骨架，但职责不同：

| 入口 | 适用场景 | 生成内容 | 是否写 agents.md |
|---|---|---|---|
| `install.sh --project <path>` | 命令行批量初始化、CI 环境 | 空目录骨架 + `.gitkeep`，**不建任何卡片/图谱/反思卡文件** | ❌ 不生成 |
| `nc-初始化`（skill 指令） | 交互式初始化，作者首次使用 | 完整骨架 + `agents.md` + `config/project.yaml` + build 脚本 + registry 默认配置 | ✅ 生成（含 `--lang zh/en` 双语模板） |

**边界规则**：

- `install.sh --project` 是**唯一**的命令行骨架生成方式，仅建空目录 + `.gitkeep`，
  不建卡片/图谱/反思卡/练习稿文件，不写 agents.md。
- `nc-初始化` 是 skill 层的交互式初始化入口，支持 `--lang zh/en`（默认 zh）与
  `--mode short/mid/long` 长短篇预设，生成 agents.md 引导文件并填充 registry 默认值。
- 一个项目 SHOULD 只运行一次初始化（无论哪个入口）；重复运行会提示冲突而非覆盖。

## 命名规则

- **文件名**：`<id>.md`，与 frontmatter 的 `id` 保持一致。
- **id 前缀**（**必须**与 `type` 匹配）：

  | type | id 前缀 | 目录 |
  |---|---|---|
  | actor | `ac-` | `cards/characters/` |
  | plotpoint | `pp-` | `cards/plotpoints/` |
  | item | `it-` | `cards/items/` |
  | scene | `sc-` | `cards/scenes/` |
  | foreshadow | `fs-` | `cards/foreshadow/` |
  | timeline | `tl-` | `cards/timeline/` |
  | faction | `fa-` | `cards/factions/` |
  | snapshot | `sn-` | `cards/snapshots/` |
  | darklayer | `dk-` | `cards/darklayer/` |
  | module | `md-` | `cards/modules/` |
  | lexstat | `lx-` | `cards/lexstats/` |
  | corpus | `co-` | `cards/corpus/` |
  | metric | `mt-` | `cards/metrics/` |
  | pose | `po-` | `cards/pose-bank/` |
  | character_tendency | `tend-` | `cards/tendencies/` |
  | sensory_cue | `su-` | `cards/custom/sensory_cue/` |
  | refwork | `rw-` | `cards/custom/refwork/` |
  | reflection | `rf-` | `reflections/`（**不进入 `cards/`**） |

- **slug**：小写字母 + 连字符 + 数字，例：`ac-frog-lead` / `fs-orphan-letter` /
  `dk-mother-tongue` / `tl-bronze-key` / `rf-chapter-050`。避免 emoji、中文、空格。

## 动线卡命名空间（timeline）

- **位置**：`cards/timeline/`，id 前缀 `tl-`。
- 一条动线追踪**一个对象**（actor / item / faction / scene / other / 自定义），
  通过 `track` 字段显式声明类型。
- 一条动线的"关系交汇"在 `mentions` 段简要记录；
  **复杂交互**（多个对象、多条边）不放在 `mentions`，改由 `graph/`
  目录下的 HTML 图谱表达。
- 节点联动 MUST 走 module 积木（`bind_module` 字段），禁止零散写联动。

## 关系图谱（graph/）

- **位置**：使用方工程根的 `graph/`，与 `cards/` 平级。
- **文件命名**：`tl-<slug>-graph.html`，与所表达的核心动线卡的 slug 对齐；
  若跨多条动线则命名 `<主题>-graph.html`。
- **独立性**：图谱 HTML 文件**不属于**卡片，无 frontmatter，不被
  skill 视为卡片。卡片正文可通过 `见 graph/xxx.html` 引用，但不建立
  YAML 字段级双向绑定。
- **重生成**：`index/card-graph.json` 变更后，`nc-图谱` 重新渲染，旧 html 被覆盖。
- **模板**：见 `templates/relation-graph.html`（自包含 SVG，无需外部依赖）。

## 暗线命名空间（dark-layer）

- **必须**位于 `cards/darklayer/`（或等价独立目录，如 `cards/hidden/`、
  `cards/underlayer/`）。
- id 必须以 `dk-` 开头，**不允许**出现在 `cards/characters/` 等主书目录。
- 与主书人物卡的引用**只**通过 `references_to_main` 显式字段
  串接，例如：

  ```yaml
  references_to_main:
    - ac-jiang-li: 表面身份 / 别名
  ```

- 违反此约定的常见错误：把暗线人物直接写进 `cards/characters/` 但改一个
  隐藏前缀 —— 这在目录层面就破坏了命名空间隔离。

## 反思卡命名空间（reflection）

- **位置**：`reflections/`，**与 `cards/` 平级**（不进入 `cards/`）。
- **id 前缀**：`rf-`，命名约定 `rf-<chapter-id>`（例：`rf-chapter-050`）。
- **文件命名**：与关联章节同名（`reflections/chapter-050.md`），
  便于在目录中与 `manuscript/chapter-050.md` 一一对照。
- **正文结构**：必须包含五个二级标题：`stuck` / `shone` / `why` /
  `insights` / `action_items`。详见 `references/hard-rules.md` 规则 9。
- **反哺**：`action_items` 是唯一指向其他卡片的入口，格式必须明确到
  卡 id 或图谱文件；不写「优化一下人物刻画」这类模糊描述。

## 练习稿目录（drafts/practice/）

- **位置**：`drafts/practice/`，与 `cards/` 平级。
- **用途**：存放通胀过滤器判定为「不进正式排期」的素材，或用户主动
  标记为「练习稿」的题材构思。
- **不建 frontmatter 强制**：练习稿不是正式卡片，可以只用 Markdown
  自由文本；如果希望日后回炉，可加 `status: practice` / `created` /
  `updated` 三个字段以便检索，但 skill 不做强制。
- **回炉机制**：后续若出现新的独家洞察，可以按 `nc-过滤` 重新评估，
  判定通过后转入 `cards/`。

## 路径引用规范

- 所有路径引用必须使用**相对使用方工程根**的相对路径，例如
  `cards/characters/ac-frog-lead.md`、`graph/tl-bronze-key-graph.html`、
  `reflections/chapter-050.md`。
- **禁止**在卡片正文或 frontmatter 中使用绝对路径、`~/`、`$HOME`、
  Windows 盘符路径。
- 卡间引用使用 **id**（如 `ac-frog-lead`）而非路径，路径由目录约定推导。
- 图谱引用使用**相对路径**（`graph/xxx.html`），不使用 id。

## 安装与迁移

novel-cards skill 支持四种安装方式：

| 方式 | 路径 | 适用 |
|---|---|---|
| 全局 · OpenCode | `~/.config/opencode/skills/novel-cards/` | opencode 全项目通用 |
| 全局 · Claude Code | `~/.claude/skills/novel-cards/` | Claude Code 全项目通用 |
| 项目级 · OpenCode | `<project>/.opencode/skills/novel-cards/` | 单小说工程内联 |
| 项目级 · Claude Code | `<project>/.claude/skills/novel-cards/` | 单小说工程内联 |
| 软链（推荐开发期） | 见 `install.sh --link` | 本仓库直接改、双端同步生效 |

一键安装（复制模式）：

```bash
./install.sh                          # 装到全局 OpenCode + Claude Code
./install.sh --target opencode        # 只装 OpenCode 全局
./install.sh --target claude          # 只装 Claude Code 全局
./install.sh --link                   # 软链模式（开发期推荐）
```

初始化使用方工程骨架（**注意**：本 skill 不主动创建卡片文件；此命令只
建空目录，让用户明确选择启用哪些卡类型）：

```bash
./install.sh --project ~/path/to/novel-project
```

生成的目录骨架：

```
~/path/to/novel-project/
  agents.md                # Agent 引导兜底占位（nc-初始化 生成交互式完整版）
  quickstart.md            # 新手主线最简流程兜底占位
  skill-reference.md       # 29 技能全量备查总表兜底占位
  config/
    project.yaml           # lang / mode / pipeline_option 占位
    skills.yaml            # 29 技能条目骨架占位（auto_invokable 默认值）
    .gitkeep
  registry/.gitkeep
  index/.gitkeep
  templates/.gitkeep
  res/inbox/.gitkeep
  cards/
    characters/.gitkeep
    plotpoints/.gitkeep
    items/.gitkeep
    scenes/.gitkeep
    foreshadow/.gitkeep
    timeline/.gitkeep
    factions/.gitkeep
    snapshots/.gitkeep
    darklayer/.gitkeep
    modules/.gitkeep
    lexstats/.gitkeep
    corpus/.gitkeep
    metrics/.gitkeep
    pose-bank/.gitkeep
    tendencies/.gitkeep
    custom/sensory_cue/.gitkeep
    custom/refwork/.gitkeep
  reflections/.gitkeep
  manuscript/.gitkeep
  graph/.gitkeep
  export/.gitkeep
  release/.gitkeep
  history/.gitkeep
  drafts/practice/.gitkeep
  build.sh build.cmd       # 构建脚本骨架
  README.md CHANGELOG.md latest.md
```

**使用方工程配置不动**：本 skill 不修改使用方工程的 `AGENTS.md` /
`CLAUDE.md` / `.gitignore` / `package.json` 等任何项目配置（`agents.md`
引导文件除外，它由 `nc-初始化` 生成且允许作者手动编辑）。
