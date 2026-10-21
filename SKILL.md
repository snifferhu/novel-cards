---
name: novel-cards
description: >-
  维护小说卡片体系，走提案制与用户共创。为长篇 / 中篇虚构作品整理与
  追踪八类结构化卡片：人物、桥段、道具、场景、伏笔、动线、势力、
  状态快照、七层暗线（dark-layer），并支持用 HTML 图谱表达复杂关系。
  统一触发前缀 `nc-`：当用户说 `nc-人物` / `nc-桥段` / `nc-道具` /
  `nc-场景` / `nc-伏笔` / `nc-动线` / `nc-势力` / `nc-快照` / `nc-暗线`
  / `nc-图谱` 时触发。无前缀的自然语言触发词：「维护小说卡片体系」
  「走提案制」「新增/更新人物卡」「整理伏笔卡」「梳理动线」「状态快照」
  「暗线卡」「生成关系图谱」等。所有回写一律输出 Markdown 完整草案，
  用户确认后由用户落盘；AI 不直接写卡。
license: AGPL-3.0
---

# novel-cards

面向长篇 / 中篇虚构作品的**卡片式创作辅助 skill**。用 Markdown + YAML
frontmatter 结构化维护八类创作卡，通过提案制协作保持卡与正文同步。
复杂关系用独立 HTML 图谱表达，避免 Markdown 表格无法承载的交互密度。

本 skill 是双端兼容的（OpenCode + Claude Code），frontmatter 只保留
`name` / `description` / `license` 三个键，其余规则全部写在 body。

---

## 1. 用途

- **卡片化管理**：把人物、桥段、道具、场景、伏笔、动线、势力、
  状态快照、暗线拆成独立卡片，每卡一文件，便于检索、diff、追踪状态。
- **叙事同步**：正文写完后回补卡片，正文改之前先查卡片，防止设定漂移。
- **多时间线并行**：主书人物链与暗线（dark-layer）分命名空间，主线与
  暗线的引用通过显式字段串接，不共享 id，避免"暗线身份泄漏"。
- **跨章节一致性**：状态快照（snapshot）记录关键节点的时间线状态，
  避免后续章节出现时间/位置/关系前后矛盾。
- **动线追踪**：单一对象（人物 / 道具 / 势力 / 场景）跨章节跨场景
  的完整轨迹用动线卡（timeline）表达，比分散在桥段卡中更容易跟进。
- **复杂关系可视化**：当多个对象之间的关系密度超过 Markdown 表格可表达
  范围时，生成 HTML + SVG 关系图谱到 `graph/` 目录。

**不做的事**：不写正文、不替代大纲、不生成情节。skill 只维护卡片与图谱本身。

---

## 2. 卡片目录约定（使用方工程）

skill 读写均以**使用方工程根**为基准，走相对路径。使用方工程须预先
存在 `cards/` 与 `manuscript/` 两个目录。skill **不创建**这两个目录，
缺失时提示用户补齐。

推荐目录布局：

```
<consumer-project>/
  cards/
    characters/          # 人物卡
    plotpoints/          # 桥段卡
    items/               # 道具卡
    scenes/              # 场景卡
    foreshadow/          # 伏笔卡
    timeline/            # 动线卡（跨场景跨时间的对象追踪）
    factions/            # 势力卡
    snapshots/           # 状态快照卡
    darklayer/           # 暗线卡（独立命名空间）
  manuscript/
    chapter-001.md
    chapter-002.md
    ...
  graph/                 # 关系图谱（HTML，独立于 cards/）
    tl-bronze-key-graph.html
    ...
```

- 所有路径示例为**相对使用方工程根**的相对路径，不出现绝对路径、
  `~/`、`$HOME`。
- 暗线卡必须位于 `cards/darklayer/` 或等价的独立命名空间，**不得**混入
  `cards/characters/` 等主书人物链目录。
- 关系图谱 HTML 位于 `graph/`，是**独立于** `cards/` 的产物，可自由
  打开查看，不被 skill 写入 `cards/` 内的卡片引用。
- 详细布局见 `references/layout.md`。

---

## 3. 八类卡与必备字段

所有卡片 frontmatter **至少**包含以下五个字段：

| 字段 | 含义 | 约束 |
|---|---|---|
| `id` | 卡片的唯一标识 | 全局唯一；命名规则见 `references/hard-rules.md` |
| `type` | 卡片类型 | 枚举：`character` / `plotpoint` / `item` / `scene` / `foreshadow` / `timeline` / `faction` / `snapshot` / `darklayer` |
| `status` | 生命周期状态 | 常见值：`draft` / `active` / `resolved` / `unresolved` / `archived` |
| `created` | 创建日期 | ISO 8601 日期，形如 `2025-01-15` |
| `updated` | 更新日期 | ISO 8601 日期，每次内容变更后同步 |

各类型专属字段见对应模板与 `references/hard-rules.md`：

- **人物卡**（`characters/`）：`name`、`role`、`faction`、`first_appearance`。
- **桥段卡**（`plotpoints/`）：`chapter`、`summary`、`participants`。
- **道具卡**（`items/`）：`name`、`owner`、`origin`、`last_seen`。
- **场景卡**（`scenes/`）：`name`、`location`、`first_appearance`。
- **伏笔卡**（`foreshadow/`）：**必须**有 `payoff_chapter` 或标 `status: unresolved`。
- **动线卡**（`timeline/`）：`title`、`track`（`character` / `item` / `faction` / `place` / `other`）、`target`、`first_seen`；关系细节在正文 `mentions` 段简要记录，复杂交互指向 `graph/` 目录下的 HTML 图谱。
- **势力卡**（`factions/`）：`name`、`leader`、`members`、`goals`。
- **状态快照卡**（`snapshots/`）：`chapter`、`focus`、`summary`。
- **暗线卡**（`darklayer/`）：独立 id 命名空间，通过 `references_to_main`
  字段显式串接主书人物 / 关系卡。

八类卡模板位于 `templates/`，见 `references/card-schema.md`。
关系图谱 HTML 模板位于 `templates/relation-graph.html`。

---

## 4. 触发场景

### 4.1 统一前缀触发（推荐）

以 `nc-` 为统一前缀，后接卡片类型或操作：

| 提示语 | 动作 |
|---|---|
| `nc-人物 <名字>` | 新增 / 更新人物卡 |
| `nc-桥段 <章节/描述>` | 新增桥段卡 |
| `nc-道具 <名字>` | 新增道具卡 |
| `nc-场景 <名字>` | 新增场景卡 |
| `nc-伏笔 <描述>` | 新增伏笔卡 |
| `nc-动线 <对象/主题>` | 新增动线卡 |
| `nc-势力 <名字>` | 新增势力卡 |
| `nc-快照 <章节>` | 新增状态快照卡 |
| `nc-暗线 <主题>` | 新增暗线卡 |
| `nc-图谱 <对象>` | 生成或更新关系图谱 HTML |

### 4.2 自然语言触发（无前缀，兜底）

1. **新增卡**：用户说「加一个人物卡」「新建一个伏笔卡」「登记一个新势力」等。
2. **更新卡**：用户说「更新主角的档案」「这一章新增的道具要挂上卡」等。
3. **查询卡**：用户说「主角和反派之间的关系在哪」「有没有未回收的伏笔」等。
4. **状态整理**：用户说「做一次状态快照」「把伏笔卡按 payoff 排一下」等。
5. **暗线维护**：用户说「新增一条暗线」「暗线人物和主书 X 有关」等。
6. **图谱生成**：用户说「画一下势力关系图」「这些人物之间的交互关系
   需要图谱表达」等。

任一触发场景都遵循下方硬规则与工作流程。

---

## 5. 硬规则（**违反即视为失败**）

1. **禁止直接写卡**：AI 不直接调用 `edit` / `write` 工具对 `cards/**/*.md`
   或 `manuscript/**/*.md` 或 `graph/**/*.html` 落盘。**所有回写一律走提案制**。
2. **必须出提案、等用户确认**：AI 输出完整 Markdown 草案（含 frontmatter
   与正文）或 HTML 图谱代码，标注目标文件相对路径，等用户口头确认
   （如「OK」「就这样」「按这个写」）后**由用户落盘**。用户修改后仍按
   用户版本为准。
3. **伏笔卡必须关联 payoff**：`cards/foreshadow/*.md` 必须满足
   `payoff_chapter` 有值 **或** `status: unresolved`；两者皆缺视为非法，
   必须请用户澄清后补上。
4. **dark-layer 隔离**：暗线卡必须位于 `cards/darklayer/`（或等价独立
   命名空间），id 与主书人物链不共享前缀 / 命名空间；与主书人物 / 关系
   卡的引用**只**通过 `references_to_main` 显式字段串接，不隐式合并。
5. **五字段不可缺**：`id` / `type` / `status` / `created` / `updated`
   在每个模板、每张卡中都必须出现，缺一项即视为非法卡。
6. **相对路径**：所有对使用方工程的读写引导都使用相对使用方工程根的
   相对路径；不出现绝对路径、`~/`、`$HOME`。
7. **图谱与卡片分离**：关系图谱 HTML 存放于 `graph/`，不放入 `cards/`。
   卡片正文可指向图谱文件（如 `见 graph/tl-xxx-graph.html`），但图谱
   HTML 文件本身不需要 frontmatter，不被 skill 视为卡片。

---

## 6. 工作流程（四步）

### Step 1 · 澄清意图

- 用户请求命中触发场景之一（前缀式或自然语言）。
- AI 用**一句话**回述要操作的卡片类型与目标动作（新增 / 更新 / 查询 /
  整理 / 暗线维护 / 图谱生成）。
- 存在歧义时（如「整理一下」不指明范围），先问清楚再进入 Step 2。

### Step 2 · 读取上下文

- 定位使用方工程根（若不确定，问用户确认）。
- 读取相关卡片：
  - 新增人物 → 查该人物在 `cards/characters/` 是否已有卡；查关联
    `timeline/`、`factions/`、`darklayer/`。
  - 更新卡 → 直接读目标卡；查相关引用卡。
  - 伏笔相关 → 读 `cards/foreshadow/` 下全部卡，检查 `payoff_chapter`
    与 `status` 分布。
  - 动线相关 → 读 `cards/timeline/` 下已有卡；若同一对象已有多条动线，
    提示合并或分层。
  - 状态快照 → 读 `cards/snapshots/` 下**最近一份**快照作为基线。
  - 图谱生成 → 读取相关 `timeline/` 卡的 `mentions` 段；扫描所有相关
    `character` / `faction` / `item` / `scene` 卡的引用关系。
- 相关正文片段（`manuscript/chapter-*.md`）**按需**读取，不主动加载全文。

### Step 3 · 生成提案

- 依据 `templates/<type>.md` 生成 Markdown 完整草案。
- 依据 `templates/relation-graph.html` 生成 HTML 图谱代码（替换占位符）。
- 提案格式（**必须严格遵守**）：

  ```
  📋 卡片提案 · <动作> · <type>

  目标文件：<cards/xxx/<id>.md>   ← 相对使用方工程根

  ---
  id: ...
  type: ...
  status: ...
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  ...（其他必备 + 类型专属字段）
  ---

  # <卡片标题>

  <卡片正文：概述、要点、相关引用>

  ---
  说明：<为什么这么写 / 与哪些卡关联 / 有意的取舍>
  ```

  图谱提案：

  ```
  📋 图谱提案 · <对象> · relation-graph

  目标文件：<graph/tl-<slug>-graph.html>   ← 相对使用方工程根

  ```html
  <!DOCTYPE html>
  ...（完整 HTML 代码）
  </html>
  ```

  ---
  说明：<图表达的核心关系 / 未画入的元素及原因 / 建议关联的 timeline 卡>
  ```

- 一次只提案一张卡或一张图谱（跨多张的任务分多次提案，等前一张落盘后
  再出下一张）。

### Step 4 · 落盘（**由用户执行**）

- 用户审阅提案，可修改任意字段 / 正文 / SVG 坐标。
- 用户确认后将最终内容保存到提案中标注的目标文件路径。
- AI 不执行 `edit` / `write`；仅在用户报告落盘完成后：
  - 读取用户落盘结果，核对是否满足硬规则（五字段、伏笔 payoff、暗线隔离）。
  - 若发现违规（如漏了 `updated`），提示用户修正，并给出修正建议片段。
  - 更新相关引用卡的 `updated` 字段（同样走提案，用户落盘）。

---

## 7. 参考文件

- `references/layout.md` — 使用方工程的目录布局约定与命名规则。
- `references/hard-rules.md` — 硬规则详解、id 命名空间、暗线隔离规范、
  伏笔 payoff 的判定与常见陷阱。
- `references/card-schema.md` — 八类卡字段定义、类型专属字段清单、
  `status` 枚举与生命周期。

八类卡模板（**结构骨架**，不含真实内容示例）：

- `templates/characters.md`
- `templates/plotpoints.md`
- `templates/items.md`
- `templates/scenes.md`
- `templates/foreshadow.md`
- `templates/timeline.md`
- `templates/factions.md`
- `templates/snapshots.md`
- `templates/darklayer.md`

关系图谱模板：`templates/relation-graph.html`

安装 / 初始化：`install.sh` 支持将本 skill 复制或软链到 OpenCode 与
Claude Code 的 skill 目录，四选一（全局 × 双端 + 开发期软链），见
`references/layout.md` 的"安装与迁移"章节。
