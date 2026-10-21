# AGENTS.md — novel-cards

本仓库是 **opencode / Claude Code 双端兼容 skill**（`name: novel-cards`），**不是**小说工程本身。Agent 在此仓库内工作 = 编写和维护 skill 定义文件，**绝不**在此仓库写任何具体卡片内容。

## 1. 仓库定位

- **交付物**：`SKILL.md`（skill 入口）+ `references/`（细则/长文档）+ `templates/`（各卡类型骨架）+ `examples/`（示例片段）。
- **不含**：小说正文、任何具体人物/桥段/道具/伏笔卡、使用方工程目录结构。
- **使用方工程**：外部小说仓库，须已有 `cards/`（按类型分目录）与 `manuscript/` 目录；本 skill 读写时以使用方工程根为基准，走相对路径。
- **八类卡**：人物 / 桥段 / 道具 / 场景 / 伏笔 / 动线 / 势力 / 状态快照 / 七层暗线（dark-layer）。
- **HTML 关系图谱**：复杂关系网络用 HTML + SVG 表达，存放于使用方工程的 `graph/` 目录。

## 2. Skill 硬规则（skill 编写时必须落进 SKILL.md body）

1. **提案制**：AI 回写卡片一律以 Markdown 完整草案形式输出到对话，等用户确认后由用户落盘；skill 指令中**禁止**出现「直接 edit / write 卡片文件」的引导语。
2. **伏笔卡**：必须关联 `payoff_chapter` 或明确标 `status: unresolved`；二者皆缺视为非法。
3. **暗线卡（dark-layer）**：独立命名空间（`cards/darklayer/` 或等价约定），**不得**混入主书人物链；与主书人物卡的引用通过显式字段串接，不共享主链 id。
4. **动线卡（timeline）**：通过 `track` 字段声明追踪对象类型（`character` / `item` / `faction` / `place` / `other`），`target` 指向具体对象 id；复杂关系不在此展开，改由 `graph/` 下 HTML 图谱表达。
5. **图谱与卡片分离**：关系图谱 HTML 存放于使用方工程的 `graph/` 目录，**不进入** `cards/`；卡片正文可引用图谱文件，图谱本身无 frontmatter，不被视为卡片。
6. **必备字段**：所有卡 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated`。

## 3. 安装/迁移（一键脚本）

`install.sh` 是本仓库的**唯一推荐入口**，支持全局安装、软链开发模式、
以及使用方工程骨架初始化。

```bash
./install.sh                          # 复制模式：装到全局 OpenCode + Claude Code
./install.sh --target opencode        # 只装到 OpenCode 全局（~/.config/opencode/skills/）
./install.sh --target claude          # 只装到 Claude Code 全局（~/.claude/skills/）
./install.sh --link                   # 软链模式（开发期推荐，本仓库改动即时生效）
./install.sh --project ~/my-novel     # 初始化使用方工程骨架（只建空目录，不建卡片）
```

安装目标：

| 方式 | 路径 | 适用 |
|---|---|---|
| 全局 · OpenCode | `~/.config/opencode/skills/novel-cards/` | opencode 全项目通用 |
| 全局 · Claude Code | `~/.claude/skills/novel-cards/` | Claude Code 全项目通用 |
| 软链（开发期推荐） | 由 `--link` 处理 | 本仓库直接改、双端同步生效 |

**注意**：本仓库**不提供**项目级 `.opencode/skills/` 与 `.claude/skills/` 的
安装路径 —— 项目级 skill 属于使用方工程内联，用户可手工把本仓库复制到
目标项目，但 `install.sh` 不代为执行，以免与本 skill「不改使用方配置」
的边界冲突。

## 4. 双端兼容铁律（**违反即破坏 Claude Code 兼容性**）

- **frontmatter 只保留三个字段**：`name` / `description` / `license`。
- **禁止**写 opencode 专属字段到 frontmatter：`when_to_use` / `triggers` / `allowed-tools` / `model` / `metadata` / `tags` 等一律不写。Claude Code 会当作未知字段误读，最坏情况整份 skill 失效。
- 触发词、何时使用、工具白名单、模型偏好等一律写在 **SKILL.md body**，用自然语言段落描述，或放在 body 中的 YAML / Markdown 代码块示例里（代码块中的 YAML 不会被解析为 frontmatter，安全）。
- **验证方法**：改完 SKILL.md 后，用任一 YAML frontmatter 解析器 dump 头部，确认只有 `name` / `description` / `license` 三个键；再让 Claude Code `Skills` 面板确认 skill 可见且描述正确。

## 5. 使用方工程读写约定（skill 指令层）

- **相对路径**：所有对卡片的读/写引导，均以使用方工程根为基准，如 `cards/characters/<id>.md`、`manuscript/chapter-XX.md`。不要写绝对路径，不要写 `~/` 或 `$HOME`。
- **skill 不创建目录**：`cards/` 与 `manuscript/` 由使用方工程预先建好；skill 只读已存在路径，缺失时提示用户补齐而非自建。
- **不改使用方工程配置**：不要动使用方工程的 `AGENTS.md` / `CLAUDE.md` / `.gitignore`。

## 6. 在本仓库工作的禁区

- **不生成**任何 `.md` 卡片文件（`cards/`、`manuscript/`、`novels/`、`drafts/`、`graph/` 目录均不建）。
- **不生成**使用方工程的目录骨架或脚手架（`install.sh --project` 是**唯一**生成方式，仅建空目录 + `.gitkeep`，不建卡片/图谱文件）。
- **本 skill 不主动创建** `graph/` 目录；图谱 HTML 生成由 `nc-图谱` 触发，AI 只在提案中输出 HTML 代码，由用户落盘到已有 `graph/` 目录。
- **不新增** opencode.json / package.json / 依赖锁 / 构建配置 —— 本 skill 无构建、无依赖、无测试命令。
- **不写**真实小说内容示例；`examples/` 只放结构骨架与假名占位（如 `角色-甲`、`章节-001`）。
- **不修改** `LICENSE`（AGPL-3.0，全文保留）。

## 7. 编辑 SKILL.md / references / templates 时的自检

- [ ] frontmatter 仅 3 个键，YAML 解析无误。
- [ ] 未出现「AI 直接 edit / write 卡片」的指令措辞，全部走提案制。
- [ ] 伏笔卡模板含 `payoff_chapter` 或 `status: unresolved` 二选一。
- [ ] dark-layer 卡模板与主书人物链的 id / 命名空间分离。
- [ ] 动线卡模板含 `track` 与 `target` 字段，`track` 枚举值合法。
- [ ] 图谱 HTML 模板独立于卡片模板，位于 `templates/relation-graph.html`。
- [ ] 五字段（`id` / `type` / `status` / `created` / `updated`）在每个卡片模板中都出现（图谱 HTML 除外）。
- [ ] 所有路径示例都是使用方工程的相对路径，无绝对路径、无 `$HOME`。
- [ ] `description` 字段能被 Claude Code 与 OpenCode 同时正确解析（无 opencode 专属键混入）。
- [ ] 无 `relationship` 卡类型残留引用（已合并到 timeline）。
- [ ] 触发词前缀 `nc-` 在 SKILL.md description / README / USAGE 三处一致。
