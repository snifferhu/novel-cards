# AGENTS.md — novel-cards

本仓库是 **opencode / Claude Code 双端兼容 skill**（`name: novel-cards`），**不是**小说工程本身。Agent 在此仓库内工作 = 编写和维护 skill 定义文件，**绝不**在此仓库写任何具体卡片内容。

## 1. 仓库定位

- **交付物**：`SKILL.md`（skill 入口）+ `references/`（细则/长文档）+ `templates/`（各卡类型骨架）+ `examples/`（示例片段）。
- **不含**：小说正文、任何具体人物/桥段/道具/伏笔卡、使用方工程目录结构。
- **使用方工程**：外部小说仓库，须已有 `cards/`（按类型分目录）与 `manuscript/` 目录；本 skill 读写时以使用方工程根为基准，走相对路径。
- **16+ 类卡**（v1.0，含新增建模类型）：角色(actor) / 桥段(plotpoint) / 道具(item) / 场景(scene) / 伏笔(foreshadow) / 动线(timeline) / 势力(faction) / 快照(snapshot) / 暗线(darklayer) / 积木(module) / 词频(lexstat) / 语料(corpus) / 量化(metric) / 姿态(pose) / 感官标记(sensory_cue) / 角色动向(character_tendency) / 对标作品(refwork)，外加不入 `cards/` 的**反思卡（reflection）**。完整字段契约见 `references/card-schema.md`。
- **面向对象透镜**：每张卡都是一个 `NcObject` 子类实例（五字段 = 基类公共属性），每个 `nc-*` 技能都是对 `StoryWorld` 容器或某个对象的一次方法调用；正文是参与对象按 timeline 顺序 `render()` 拼接的文本投影。完整类层次 / 方法契约 / 技能→方法映射见 `references/oo-model.md`，事件驱动连锁推演见 `references/event-inference.md`。**OO 视角不改变任何字段契约与提案制铁律**。
- **可选只读运行时**：`tools/nc_validate.py`（Python3 标准库单文件，validate/audit/simulate 三子命令）承载机器校验，**只读、绝不写盘、绝不替代提案制**；缺失时 skill 降级纸面校验。本仓库内该文件是交付物本体，使用方工程经 `install.sh --project` 拷入。
- **四层数据分层**：`.md` 业务源头 / `.json` 图森林真值（`index/card-graph.json`）/ `.yaml` 配置白名单（`registry/`、`config/`）/ `.html` 展示投影（`graph/`）。详见 `references/data-layering.md`。
- **HTML 关系图谱**：复杂关系网络用 HTML + SVG 表达，存放于使用方工程的 `graph/` 目录，是 `index/card-graph.json` 图森林的纯展示投影。
- **反思卡目录**：写作闭环的锚点，存放于使用方工程的 `reflections/` 目录，独立于 `cards/`。
- **练习稿目录**：通胀过滤器判定未通过的素材，存放于使用方工程的 `drafts/practice/` 目录。

## 2. Skill 硬规则（skill 编写时必须落进 SKILL.md body）

1. **提案制**：AI 回写卡片一律以 Markdown 完整草案形式输出到对话，等用户确认后由用户落盘；skill 指令中**禁止**出现「直接 edit / write 卡片文件」的引导语。
2. **伏笔卡**：必须关联 `payoff_chapter` 或明确标 `status: unresolved`；二者皆缺视为非法。
3. **暗线卡（dark-layer）**：独立命名空间（`cards/darklayer/` 或等价约定），**不得**混入主书人物链；与主书人物卡的引用通过显式字段串接，不共享主链 id。
4. **动线卡（timeline）**：通过 `track` 字段声明追踪对象类型（`character` / `item` / `faction` / `place` / `other`），`target` 指向具体对象 id；复杂关系不在此展开，改由 `graph/` 下 HTML 图谱表达。
5. **图谱与卡片分离**：关系图谱 HTML 存放于使用方工程的 `graph/` 目录，**不进入** `cards/`；卡片正文可引用图谱文件，图谱本身无 frontmatter，不被视为卡片。
6. **反思卡结构**：反思卡存放于 `reflections/` 目录（**不进入 `cards/`**），id 前缀 `rf-`；正文必须含 `stuck` / `shone` / `why` / `insights` / `action_items` 五个二级标题；`action_items` 是唯一把新认知写回卡片的入口，必须明确到卡 id 或图谱文件。
7. **通胀过滤器 gate**：所有新素材（首次入库的题材 / 口述灵感 / 反思卡反哺回来的素材）在写入 `cards/` 前必须过 `nc-过滤` 三问；`Q3`（独家洞察）是否决项，无独家洞察一律进 `drafts/practice/`。
8. **必备字段**：所有卡 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated`。

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

`--project` 生成的使用方工程骨架包含：`cards/`（16+ 类子目录，含 characters / plotpoints / items / scenes / foreshadow / timeline / factions / snapshots / darklayer / modules / lexstats / corpus / metrics / pose-bank / tendencies / custom）+ `registry/` + `index/` + `res/inbox/` + `templates/` + `tools/` + `config/project.yaml` + `config/skills.yaml` + `reflections/` + `manuscript/` + `graph/` + `export/` + `release/` + `history/` + `drafts/practice/`，每个目录都有 `.gitkeep`，并写入 `agents.md` 兜底 / `quickstart.md` 兜底 / `skill-reference.md` 兜底 / `build.sh` / `build.cmd` / `README.md` / `CHANGELOG.md` / `latest.md` 占位文件；`tools/nc_validate.py` 由本仓库幂等拷入（重复执行零变更）。

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

- **相对路径**：所有对卡片/反思卡/图谱的读/写引导，均以使用方工程根为基准，如 `cards/characters/<id>.md`、`reflections/<chapter-id>.md`、`graph/<slug>-graph.html`、`drafts/practice/<slug>.md`。不要写绝对路径，不要写 `~/` 或 `$HOME`。
- **skill 不创建目录**：`cards/` / `manuscript/` / `reflections/` / `graph/` / `drafts/` 由使用方工程预先建好（可通过 `install.sh --project` 一键生成）；skill 只读已存在路径，缺失时提示用户补齐而非自建。
- **不改使用方工程配置**：不要动使用方工程的 `AGENTS.md` / `CLAUDE.md` / `.gitignore`。

## 6. 在本仓库工作的禁区

- **不生成**任何 `.md` 卡片文件（`cards/`、`manuscript/`、`reflections/`、`drafts/`、`graph/`、`novels/` 目录均不建）。
- **不生成**使用方工程的目录骨架或脚手架（`install.sh --project` 是**唯一**生成方式，仅建空目录 + `.gitkeep`，不建卡片/图谱/反思卡/练习稿文件）。
- **本 skill 不主动创建** `graph/`、`reflections/`、`drafts/` 目录；对应文件生成由 `nc-图谱` / `nc-复盘` / `nc-过滤` 触发，AI 只在提案中输出内容，由用户落盘到已有目录。
- **不生成 json/yaml 真实数据文件**：`index/card-graph.json`、`registry/*.yaml`、`config/skills.yaml` 等机器真值/白名单在本仓库内只以**骨架/模板/示例**形式存在，绝不写入真实业务数据；真实数据由使用方工程运行时经 `nc-*` 技能生成。
- **registry / config 模板只放骨架**：`references/` 与 `templates/` 中对 registry yaml、skills.yaml 的描述只给字段结构与占位，不给具体取值。
- **quickstart / skill-reference 模板只放骨架**：`templates/quickstart-zh.md` / `quickstart-en.md` / `skill-reference-zh.md` / `skill-reference-en.md` 只含 `{{PROJECT_NAME}}` / `{{MODE}}` / `{{ENABLED_SKILLS}}` 占位符与结构节，绝不写入具体项目名、具体模式取值或真实技能启用集；真实内容由使用方工程运行时经 `nc-初始化` 填充。
- **不新增** opencode.json / package.json / 依赖锁 / 构建配置 —— 本 skill 无构建、无依赖、无测试命令。
- **不写**真实小说内容示例；`examples/` 只放结构骨架与假名占位（如 `角色-甲`、`章节-001`）。
- **不修改** `LICENSE`（AGPL-3.0，全文保留）。
- **tools/nc_validate.py 只读铁律**：该运行时 MUST 零第三方依赖（仅 Python3 标准库）、MUST 只读不写盘、MUST NOT 替代提案制或自动回写卡片；在本仓库内它是交付物本体，但绝不在本仓库内用它对真实工程做写操作。
- **OO 文档与 schema 对齐**：`references/oo-model.md` / `references/event-inference.md` 中的类层次、方法契约、技能→方法映射 MUST 与 `references/card-schema.md` 的 type/前缀表、`references/skill-catalog.md` 的 29 技能集合保持一致；草稿命名（uuid/create_at/disposition_slide/pose_bank/MoodLine）只作概念别名说明，MUST NOT 作为 frontmatter 字段落地。

## 7. 编辑 SKILL.md / references / templates 时的自检

- [ ] frontmatter 仅 3 个键，YAML 解析无误。
- [ ] 未出现「AI 直接 edit / write 卡片/反思卡/图谱/练习稿」的指令措辞，全部走提案制。
- [ ] 伏笔卡模板含 `payoff_chapter` 或 `status: unresolved` 二选一。
- [ ] dark-layer 卡模板与主书人物链的 id / 命名空间分离。
- [ ] 动线卡模板含 `track` 与 `target` 字段，`track` 枚举值合法。
- [ ] 反思卡模板含五个二级标题（`stuck` / `shone` / `why` / `insights` / `action_items`），id 前缀 `rf-`，目录为 `reflections/`。
- [ ] 通胀过滤器三问（Q1 公共领域性 / Q2 三个月复刻性 / Q3 独家洞察）在 `references/filter.md` 与 SKILL.md body 中一致，Q3 明确为**否决项**。
- [ ] 图谱 HTML 模板独立于卡片模板，位于 `templates/relation-graph.html`。
- [ ] 五字段（`id` / `type` / `status` / `created` / `updated`）在每个卡片模板中都出现（图谱 HTML 除外）。
- [ ] 所有路径示例都是使用方工程的相对路径，无绝对路径、无 `$HOME`。
- [ ] `description` 字段能被 Claude Code 与 OpenCode 同时正确解析（无 opencode 专属键混入）。
- [ ] 无 `relationship` 卡类型残留引用（已合并到 timeline）。
- [ ] 技能计数一致性：SKILL.md 速查表 / README 技能表 / `references/skill-catalog.md` / `USAGE.md` / `templates/skill-reference-zh.md` 五处列出的 29 技能集合完全相同（v1.0 主体 24 技能；2026-10-23 追加 `nc-动向` / `nc-研判` / `nc-编排` / `nc-更名` 后为 29 技能）。
- [ ] 六组分类覆盖：A 工程初始化&素材资产 / B 叙事卡片建模 / C 剧情结构 / D 生成与可视化 / E 审计校验 / F 归档导出&复盘 六组分组名称在 skill-catalog / agents-guide / skill-reference 三处一致，且 29 技能全部归入某一组（`nc-对标` 单列为分析模式专用，不计入六组）。
- [ ] auto_invokable 标记三处一致：仅 `nc-量化` / `nc-图谱` / `nc-节奏` 为 true，在 `config/skills.yaml` 骨架 / `references/skill-catalog.md` / `templates/skill-reference-*.md` 三处取值完全相同；其余技能一律 user_trigger_only。
- [ ] 三分拆文档对应：使用方工程引导文档拆为 `agents.md`（Agent 行为契约）/ `quickstart.md`（新手主线）/ `skill-reference.md`（29 技能全量备查），中英双语模板节结构一一对应、占位符集合一致。
- [ ] 双语模板对应：`templates/agents-zh.md` 与 `templates/agents-en.md`、`quickstart-zh.md` 与 `quickstart-en.md`、`skill-reference-zh.md` 与 `skill-reference-en.md` 各自节结构一一对应，占位符集合一致。
- [ ] 四层数据分层表述一致：`.md` / `.json` / `.yaml` / `.html` 的分工在 SKILL.md / README / `references/data-layering.md` 三处措辞一致。
- [ ] 触发词前缀 `nc-` 在 SKILL.md description / README / USAGE 三处一致（v1.0 主体 24 前缀；2026-10-23 追加 `nc-动向` / `nc-研判` / `nc-编排` / `nc-更名` 后为 29 前缀）。
- [ ] `baseline_prototype` 为 registry-backed 可选枚举：`npd-*` 等词表只在 references/templates 以「需经 nc-注册」标注的示例出现；`nc-初始化` 骨架（`registry/tendency-prototypes.yaml`）零预置具体条目；`nc-校阅` 检查④为建议级（提示而非禁止）；未声明该字段的存量 tend- 卡行为不变。
- [ ] OO 透镜一致性：`references/oo-model.md` 的 NcObject 基类五字段 / 8 子类 / StoryWorld 容器 / 29 技能→方法映射，与 `references/card-schema.md` type/前缀表、`references/skill-catalog.md` 六组 29 技能集合完全对齐；草稿命名（uuid/create_at/disposition_slide/pose_bank/MoodLine）仅作概念别名，未作为 frontmatter 字段落地。
- [ ] 事件推演文档对齐：`references/event-inference.md` 的 ChangePlan 五类任务（create_plot/edit_plot/archive_plot/update_tendency/bind_sensory_cue）与 `references/skill-catalog.md` 中 `nc-编排` 产物描述一致；enter→perceive→act→fire 链引用的对象类型均在 card-schema 中存在。
- [ ] tools/ 只读铁律：`tools/nc_validate.py` 零第三方依赖（仅 Python3 标准库）、只读不写盘、不替代提案制；SKILL.md / README / AGENTS.md 三处对「可选运行时 + 缺失降级纸面校验」的表述一致。
