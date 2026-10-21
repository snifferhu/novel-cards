# novel-cards

双端兼容（**OpenCode** + **Claude Code**）的小说卡片体系维护 skill。为长篇
小说写作提供**人物 / 桥段 / 道具 / 场景 / 伏笔 / 动线 / 势力 / 快照 / 暗线**
九类结构化卡片，并支持 **HTML 图谱**表达复杂关系、**反思卡**沉淀单章
复盘、**通胀过滤器**做新素材入口 gate。以**提案制**方式与作者协作。
统一触发前缀 `nc-`。

## 这个仓库是什么

本仓库**不是**任何小说工程本身，而是一个 skill 定义仓库。交付物是：

- `SKILL.md` — skill 入口（触发词、场景、工作流程、硬规则）
- `references/` — 细则（布局约定、硬规则详解、卡片 schema、闭环工作流、过滤器）
- `templates/` — 九类卡的骨架模板 + 关系图谱 HTML 模板
- `install.sh` — 一键安装到 OpenCode / Claude Code
- `AGENTS.md` — 本仓库自身的开发约定

**使用方工程**是外部的小说仓库，须已存在 `cards/` 与 `manuscript/` 目录。
本 skill 只走相对路径，不创建使用方目录、不修改使用方配置。

> 📖 日常使用与常见问题请看 **[USAGE.md](./USAGE.md)**。
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

生成的空目录（不带 `.gitkeep` 也不会被 git 忽略）：

```
~/path/to/your/novel/
  cards/
    characters/           # 人物卡（type: character，id 前缀 ch-）
    plotpoints/           # 桥段卡（type: plotpoint，id 前缀 pp-）
    items/                # 道具卡（type: item，id 前缀 it-）
    scenes/               # 场景卡（type: scene，id 前缀 sc-）
    foreshadow/           # 伏笔卡（type: foreshadow，id 前缀 fs-）
    timeline/             # 动线卡（type: timeline，id 前缀 tl-）
    factions/             # 势力卡（type: faction，id 前缀 fa-）
    snapshots/            # 状态快照卡（type: snapshot，id 前缀 sn-）
    darklayer/            # 暗线卡（type: darklayer，id 前缀 dk-）
  reflections/            # 反思卡（type: reflection，id 前缀 rf-）
  manuscript/             # 正文章节
  graph/                  # 关系图谱 HTML（复杂关系可视化）
  drafts/
    practice/             # 练习稿（过滤器未通过 / 用户标记为练习）
```

### 软链开发模式

```bash
./install.sh --link --target opencode
./install.sh --link --target claude
```

## 目录结构

```
novel-cards/
  AGENTS.md               # 本仓库开发约定（不要写卡片内容）
  SKILL.md                # skill 入口（frontmatter 仅 name/description/license）
  README.md               # 本文件（项目概览）
  USAGE.md                # 使用说明（日常使用 + FAQ + 回滚）
  LICENSE                 # AGPL-3.0（不可修改）
  install.sh              # 一键安装 / 项目初始化
  references/
    layout.md             # 布局约定与安装方式
    hard-rules.md         # 硬规则详解（含反思卡、过滤器）
    card-schema.md        # 九类卡完整字段定义
    loop.md               # 写作闭环工作流
    filter.md             # 通胀过滤器规则
  templates/
    characters.md         # 人物卡模板
    plotpoints.md         # 桥段卡模板
    items.md              # 道具卡模板
    scenes.md             # 场景卡模板
    foreshadow.md         # 伏笔卡模板（含硬规则约束）
    timeline.md           # 动线卡模板（含 track 分类）
    factions.md           # 势力卡模板
    snapshots.md          # 状态快照卡模板
    darklayer.md          # 暗线卡模板（独立命名空间）
    reflections.md        # 反思卡模板（写作闭环）
    relation-graph.html   # 关系图谱 HTML 模板（SVG 骨架）
```

## 九类卡速览

| # | 类型 | type | id 前缀 | 模板 | 关键专属字段 |
|---|---|---|---|---|---|
| 1 | 人物 | `character` | `ch-` | `templates/characters.md` | `name` / `role` / `first_appearance` |
| 2 | 桥段 | `plotpoint` | `pp-` | `templates/plotpoints.md` | `chapter` / `summary` / `participants` |
| 3 | 道具 | `item` | `it-` | `templates/items.md` | `name` / `owner` / `origin` |
| 4 | 场景 | `scene` | `sc-` | `templates/scenes.md` | `name` / `location` |
| 5 | 伏笔 | `foreshadow` | `fs-` | `templates/foreshadow.md` | `planted_at` + `payoff_chapter`（或 `status: unresolved`） |
| 6 | 动线 | `timeline` | `tl-` | `templates/timeline.md` | `title` / `track` / `target` / `first_seen` |
| 7 | 势力 | `faction` | `fa-` | `templates/factions.md` | `name` / `leader` / `members` |
| 8 | 快照 | `snapshot` | `sn-` | `templates/snapshots.md` | `chapter` / `focus` / `summary` |
| 9 | 暗线 | `darklayer` | `dk-` | `templates/darklayer.md` | `truth` / `references_to_main` |
| 10 | 反思 | `reflection` | `rf-` | `templates/reflections.md` | `chapter` / 五段结构（`stuck` / `shone` / `why` / `insights` / `action_items`） |

所有卡必备五字段：`id` / `type` / `status` / `created` / `updated`。

> **推荐等级**（非硬约束，仅建议）：
> - **核心**：character / plotpoint / foreshadow —— 长篇骨架
> - **常用**：scene / item / timeline / faction —— 中篇以上
> - **按需**：snapshot / darklayer / reflection —— 特定叙事需要时才建
>
> 九类卡全部可选，按需启用。反思卡建议随写作节奏使用，不必强求每章一张。

## HTML 关系图谱

复杂关系（多对象、多类型、含暗示关系）用 **HTML + SVG** 图谱表达，
存放于使用方工程的 `graph/` 目录，独立于 `cards/`。

- **模板**：`templates/relation-graph.html`（自包含，无外部依赖）
- **命名**：`tl-<slug>-graph.html`（与核心动线卡 slug 对齐）
- **卡片引用**：动线卡正文写 `见 graph/xxx.html`，或 `graph:` 字段显式指向
- **生成方式**：`nc-图谱 <对象>` 或自然语言「生成 xx 的关系图谱」

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

新素材进入正式排期前的入口 gate，防止同质化素材污染素材库。

- **触发**：`nc-过滤 <素材摘要>` 或自然语言「过滤一下这个素材」
- **三问**：
  1. Q1 公共领域性：这个题材是否是公共领域人人都能讨论的？
  2. Q2 三个月复刻性：如果我不做，三个月后会不会有别人用同样角度做出来？
  3. Q3 独家洞察：我的角度里有没有只有我知道、只有我能提供的特殊经验或洞察？
- **判定**：Q3 是否决项，无独家洞察一律进 `drafts/practice/`
- **详细**：`references/filter.md`

## 硬规则速览

1. **禁止直接落盘**：AI 绝不 `edit` / `write` 使用方工程的卡片、图谱、反思卡、练习稿文件。
2. **提案制**：AI 回写卡片以完整 Markdown 提案、图谱以完整 HTML 提案输出，用户确认后自行落盘。
3. **伏笔合法**：伏笔卡必须有 `payoff_chapter` **或** `status: unresolved`；二者皆缺视为非法。
4. **暗线隔离**：暗线卡必须位于 `cards/darklayer/`，id 前缀 `dk-`，与主书人物只通过 `references_to_main` 单向串接。
5. **五字段必备**：所有卡 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated`。
6. **动线分类**：动线卡必须通过 `track` 字段声明追踪对象类型（`character` / `item` / `faction` / `place` / `other`）。
7. **图谱与卡片分离**：关系图谱 HTML 存 `graph/`，不入 `cards/`；卡片正文可引用，图谱无 frontmatter。
8. **双端兼容**：`SKILL.md` frontmatter 只允许 `name` / `description` / `license` 三键，禁止 opencode 专属字段。
9. **闭环反哺**：反思卡正文必须含 `stuck` / `shone` / `why` / `insights` / `action_items` 五段；`action_items` 是唯一把新认知写回卡片的入口。
10. **过滤器 gate**：所有新素材在写入 `cards/` 前必须过 `nc-过滤` 三问；Q3（独家洞察）是否决项。

完整规则见 `references/hard-rules.md`。

## 触发场景

### 统一前缀触发（推荐）

| 前缀 | 动作 |
|---|---|
| `nc-人物` | 新增 / 更新人物卡 |
| `nc-桥段` | 新增桥段卡 |
| `nc-道具` | 新增道具卡 |
| `nc-场景` | 新增场景卡 |
| `nc-伏笔` | 新增伏笔卡 |
| `nc-动线` | 新增动线卡 |
| `nc-势力` | 新增势力卡 |
| `nc-快照` | 新增状态快照卡 |
| `nc-暗线` | 新增暗线卡 |
| `nc-图谱` | 生成 / 更新 HTML 关系图谱 |
| `nc-复盘` | 生成 / 更新反思卡（单章复盘） |
| `nc-过滤` | 对新素材执行通胀过滤器三问 |

### 自然语言触发（无前缀，兜底）

- 「维护小说卡片体系」 / 「更新人物卡」 / 「添加一张伏笔卡」
- 「整理这一章出现的道具 / 场景」
- 「梳理动线」 / 「生成关系图谱」
- 「埋个伏笔」 / 「回收伏笔」 / 「这条暗线要收」
- 「写章节状态快照」 / 「做一下时间线快照」
- 「复盘这一章」 / 「这一章哪里卡住了」 / 「这一章写完要沉淀一下」
- 「过滤一下这个素材」 / 「这个题材值不值得做」 / 「这个角度别人能不能抄」

## 工作流程（五步）

```
读上下文 → 提案卡片 / 图谱 / 反思卡 / 过滤器判定
         → 用户确认 → 用户落盘 → (反思卡) 反哺
```

1. **读上下文**：AI 读取使用方工程的相关章节和已有卡片
2. **提案卡片 / 图谱 / 反思卡 / 过滤器**：AI 在对话中输出完整 Markdown 提案或 HTML 图谱代码
3. **用户确认**：用户回复确认、修改、或拒绝
4. **用户落盘**：用户自行复制提案到编辑器并保存到目标路径
5. **反哺（仅反思卡）**：AI 逐条读 `action_items`，单独出反哺提案，用户逐条确认

## 使用方工程约束

本 skill 严格遵守以下边界：

- **只读已存在路径**：`cards/` 与 `manuscript/` 缺失时提示用户补齐，不自建
- **相对路径**：所有路径引导以使用方工程根为基准
- **不动使用方配置**：不修改 `AGENTS.md` / `CLAUDE.md` / `.gitignore` / `package.json` 等
- **不改本仓库配置**：不新增 `opencode.json` / `package.json` / 依赖锁

## 贡献本 skill

修改本仓库前请阅读 `AGENTS.md`，其中包含：

- 本仓库定位与禁区
- 双端兼容铁律（frontmatter 三键原则）
- SKILL.md / references / templates 编辑自检清单

## License

**AGPL-3.0**（见根目录 `LICENSE` 文件）。

`SKILL.md` frontmatter 的 `license` 字段与本许可证保持一致，均为 AGPL-3.0。
