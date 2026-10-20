# novel-cards

双端兼容（**OpenCode** + **Claude Code**）的小说卡片体系维护 skill。为长篇
小说写作提供**人物 / 桥段 / 道具 / 场景 / 伏笔 / 关系 / 势力 / 快照 / 暗线**
九类结构化卡片模板，并以**提案制**方式与作者协作。

## 这个仓库是什么

本仓库**不是**任何小说工程本身，而是一个 skill 定义仓库。交付物是：

- `SKILL.md` — skill 入口（触发词、场景、工作流程、硬规则）
- `references/` — 细则（布局约定、硬规则详解、卡片 schema）
- `templates/` — 九类卡的骨架模板
- `install.sh` — 一键安装到 OpenCode / Claude Code
- `AGENTS.md` — 本仓库自身的开发约定

**使用方工程**是外部的小说仓库，须已存在 `cards/` 与 `manuscript/` 目录。
本 skill 只走相对路径，不创建使用方目录、不修改使用方配置。

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
    relationships/        # 关系动态卡（type: relationship，id 前缀 rel-）
    factions/             # 势力卡（type: faction，id 前缀 fa-）
    snapshots/            # 状态快照卡（type: snapshot，id 前缀 sn-）
    darklayer/            # 暗线卡（type: darklayer，id 前缀 dk-）
  manuscript/             # 正文章节
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
  README.md               # 本文件
  LICENSE                 # AGPL-3.0（不可修改）
  install.sh              # 一键安装 / 项目初始化
  references/
    layout.md             # 布局约定与安装方式
    hard-rules.md         # 六条硬规则详解
    card-schema.md        # 九类卡完整字段定义
  templates/
    characters.md         # 人物卡模板
    plotpoints.md         # 桥段卡模板
    items.md              # 道具卡模板
    scenes.md             # 场景卡模板
    foreshadow.md         # 伏笔卡模板（含硬规则约束）
    relationships.md      # 关系动态卡模板
    factions.md           # 势力卡模板
    snapshots.md          # 状态快照卡模板
    darklayer.md          # 暗线卡模板（独立命名空间）
```

## 九类卡速览

| # | 类型 | type | id 前缀 | 模板 | 关键专属字段 |
|---|---|---|---|---|---|
| 1 | 人物 | `character` | `ch-` | `templates/characters.md` | `name` / `role` / `first_appearance` |
| 2 | 桥段 | `plotpoint` | `pp-` | `templates/plotpoints.md` | `chapter` / `summary` / `participants` |
| 3 | 道具 | `item` | `it-` | `templates/items.md` | `name` / `owner` / `origin` |
| 4 | 场景 | `scene` | `sc-` | `templates/scenes.md` | `name` / `location` |
| 5 | 伏笔 | `foreshadow` | `fs-` | `templates/foreshadow.md` | `planted_at` + `payoff_chapter`（或 `status: unresolved`） |
| 6 | 关系 | `relationship` | `rel-` | `templates/relationships.md` | `from` / `to` / `arcs` / `current_state` |
| 7 | 势力 | `faction` | `fa-` | `templates/factions.md` | `name` / `leader` / `members` |
| 8 | 快照 | `snapshot` | `sn-` | `templates/snapshots.md` | `chapter` / `focus` / `summary` |
| 9 | 暗线 | `darklayer` | `dk-` | `templates/darklayer.md` | `truth` / `references_to_main` |

所有卡必备五字段：`id` / `type` / `status` / `created` / `updated`。

## 硬规则速览

1. **禁止直接落盘**：AI 绝不 `edit` / `write` 使用方工程的卡片文件。
2. **提案制**：AI 回写卡片一律以完整 Markdown 提案输出到对话，用户确认后自行落盘。
3. **伏笔合法**：伏笔卡必须有 `payoff_chapter` **或** `status: unresolved`；二者皆缺视为非法。
4. **暗线隔离**：暗线卡必须位于 `cards/darklayer/`，id 前缀 `dk-`，与主书人物只通过 `references_to_main` 单向串接。
5. **五字段必备**：所有卡 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated`。
6. **双端兼容**：`SKILL.md` frontmatter 只允许 `name` / `description` / `license` 三键，禁止 opencode 专属字段（`when_to_use` / `triggers` / `allowed-tools` / `model` 等）。

完整规则见 `references/hard-rules.md`。

## 触发场景

skill 会在以下情形被激活（description 触发词，双端通用）：

- 「维护小说卡片体系」 / 「更新人物卡」 / 「添加一张伏笔卡」
- 「整理这一章出现的道具 / 场景」
- 「梳理势力关系」 / 「画一下人物关系图」
- 「埋个伏笔」 / 「回收伏笔」 / 「这条暗线要收」
- 「写章节状态快照」 / 「做一下时间线快照」

## 工作流程（四步）

```
读上下文 → 提案卡片 → 用户确认 → 用户落盘
```

1. **读上下文**：AI 读取使用方工程的相关章节和已有卡片
2. **提案卡片**：AI 在对话中输出完整 Markdown 提案（含目标路径）
3. **用户确认**：用户回复确认、修改、或拒绝
4. **用户落盘**：用户自行复制提案到编辑器并保存到目标路径

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

