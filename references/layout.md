# 布局约定（layout.md）

使用方工程必须预先存在 `cards/` 与 `manuscript/` 两个目录。novel-cards
skill 只**读**已存在的相对路径，不创建、不移动、不重命名。缺失目录时
提示用户补齐，由用户显式决定。

## 推荐布局

```
<consumer-project-root>/
  cards/
    characters/          # type: character，人物卡
    plotpoints/          # type: plotpoint，桥段卡
    items/               # type: item，道具卡
    scenes/              # type: scene，场景卡
    foreshadow/          # type: foreshadow，伏笔卡
    timeline/            # type: timeline，动线卡
    factions/            # type: faction，势力卡
    snapshots/           # type: snapshot，状态快照卡
    darklayer/           # type: darklayer，暗线卡（独立命名空间）
  manuscript/
    chapter-001.md
    chapter-002.md
    ...
  graph/                 # 关系图谱 HTML（独立于 cards/）
    tl-bronze-key-graph.html
    ...
```

## 命名规则

- **文件名**：`<id>.md`，与 frontmatter 的 `id` 保持一致。
- **id 前缀**（**必须**与 `type` 匹配）：

  | type | id 前缀 | 目录 |
  |---|---|---|
  | character | `ch-` | `cards/characters/` |
  | plotpoint | `pp-` | `cards/plotpoints/` |
  | item | `it-` | `cards/items/` |
  | scene | `sc-` | `cards/scenes/` |
  | foreshadow | `fs-` | `cards/foreshadow/` |
  | timeline | `tl-` | `cards/timeline/` |
  | faction | `fa-` | `cards/factions/` |
  | snapshot | `sn-` | `cards/snapshots/` |
  | darklayer | `dk-` | `cards/darklayer/` |

- **slug**：小写字母 + 连字符 + 数字，例：`ch-jiang-li` /
  `fs-orphan-letter` / `dk-mother-tongue` / `tl-bronze-key`。
  避免 emoji、中文、空格。

## 动线卡命名空间（timeline）

- **位置**：`cards/timeline/`，id 前缀 `tl-`。
- 一条动线追踪**一个对象**（人物 / 道具 / 势力 / 场景 / 其他），
  通过 `track` 字段显式声明类型。
- 一条动线的"关系交汇"在 `mentions` 段简要记录；
  **复杂交互**（多个对象、多条边）不放在 `mentions`，改由 `graph/`
  目录下的 HTML 图谱表达。

## 关系图谱（graph/）

- **位置**：使用方工程根的 `graph/`，与 `cards/` 平级。
- **文件命名**：`tl-<slug>-graph.html`，与所表达的核心动线卡的 slug 对齐；
  若跨多条动线则命名 `<主题>-graph.html`。
- **独立性**：图谱 HTML 文件**不属于**卡片，无 frontmatter，不被
  skill 视为卡片。卡片正文可通过 `见 graph/xxx.html` 引用，但不建立
  YAML 字段级双向绑定。
- **模板**：见 `templates/relation-graph.html`（自包含 SVG，无需外部依赖）。

## 暗线命名空间（dark-layer）

- **必须**位于 `cards/darklayer/`（或等价独立目录，如 `cards/hidden/`、
  `cards/underlayer/`）。
- id 必须以 `dk-` 开头，**不允许**出现在 `cards/characters/` 等主书目录。
- 与主书人物 / 关系卡的引用**只**通过 `references_to_main` 显式字段
  串接，例如：

  ```yaml
  references_to_main:
    - ch-jiang-li: 表面身份 / 别名
  ```

- 违反此约定的常见错误：把暗线人物直接写进 `cards/characters/` 但改一个
  隐藏前缀 —— 这在目录层面就破坏了命名空间隔离。

## 路径引用规范

- 所有路径引用必须使用**相对使用方工程根**的相对路径，例如
  `cards/characters/ch-jiang-li.md`、`graph/tl-bronze-key-graph.html`。
- **禁止**在卡片正文或 frontmatter 中使用绝对路径、`~/`、`$HOME`、
  Windows 盘符路径。
- 卡间引用使用 **id**（如 `ch-jiang-li`）而非路径，路径由目录约定推导。
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
  manuscript/.gitkeep
  graph/.gitkeep
```

**使用方工程配置不动**：本 skill 不修改使用方工程的 `AGENTS.md` /
`CLAUDE.md` / `.gitignore` / `package.json` 等任何项目配置。
