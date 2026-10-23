# Design

## Context

本仓库是 opencode / Claude Code 双端兼容的 skill 定义仓库（无构建、无依赖、无运行时），交付物为 `SKILL.md` + `references/` + `templates/` + `install.sh`。当前形态：9 类卡（ch- 前缀 character）+ 反思卡 + 通胀过滤器 + HTML 图谱，12 个 `nc-` 触发词。使用方工程是外部小说仓库，skill 只走相对路径、提案制协作（AI 绝不直接写卡）。

约束：
- frontmatter 三键铁律（name/description/license）不可破坏，否则 Claude Code 兼容性失效
- 本仓库不生成任何卡片内容文件、不新增构建配置/依赖
- v1.0 定稿方案来自 `inbox/doubao-对话-2026-10-22.md`（用户已确认全量落地）；2026-10-23 追加需求来自 `inbox/doubao-对话-2026-10-23.md`（新增 nc-动向/nc-研判/nc-编排/nc-更名 + auto_invokable 内外调用标记 + 六组分类 + quickstart/skill-reference/agents 文档三分拆），在同一 change 内继续扩展

## Goals / Non-Goals

**Goals:**
- 把 v1.0 定稿（29 技能、16+ 卡类型、四层数据分层、长短篇分级、agents.md 引导、素材合规链路）完整落进 skill 文档与模板体系
- 在 references/ 中给出 `card-graph.json` 图森林 schema 与 registry yaml 的可执行约定，使 AI 能据此提案 json/yaml 产物
- 保持双端兼容与提案制不变；`install.sh --project` 骨架与新 `nc-初始化` 语义对齐
- 提供旧工程硬切换迁移指引
- 落地 2026-10-23 追加：四个新技能（动向/研判/编排/更名）、auto_invokable 内外调用标记、六组用户可见分类、quickstart/skill-reference/agents 文档三分拆，降低 29 技能的认知负荷

**Non-Goals:**
- 不实现任何运行时程序（词频统计器、json 校验器、html 渲染器均为「AI 按约定提案 + 用户落盘」，不引入脚本/依赖）
- 不做新旧双轨兼容逻辑（硬切换）
- 不改 LICENSE、不新增 package.json/opencode.json
- 不在本仓库内放任何真实小说示例内容（examples 仍只用假名占位）

## Decisions

### D1: 能力以「文档 + 模板 + 约定」承载，而非代码

**选择**：所有 v1.0 机制（图森林 schema、registry 白名单、pose 插槽填充优先级、节奏滑动窗口规则）都以 references/ 下的规范文档 + templates/ 骨架表达，由 AI 在执行 nc- 指令时读取并产出提案。

**理由**：本仓库定位是 skill 定义仓库，无运行时；引入 Python/Node 脚本会破坏「无构建无依赖」边界并带来双端分发复杂度。AI 提案 + 用户落盘的既有协作模式已覆盖全部需求。

**备选**：① 附带一个轻量 CLI 工具做 json 校验——被否，引入依赖与维护成本；② 把 schema 写成 JSON Schema 文件——部分采纳：`card-graph.json` 的结构约定用 Markdown 表格 + 最小 JSON 示例表达即可，正式 JSON Schema 文件留待后续 change（见 Open Questions）。

### D2: 目录命名沿用英文固定值，type 值与 id 前缀分离演进

**选择**：`cards/characters/` 目录名保留（避免大规模目录改名），但其中卡片 `type: actor`、id 前缀 `ac-`；`darklayer/` 保留；新增目录 `corpus/ metrics/ modules/ pose-bank/ lexstats/ custom/`。

**理由**：目录是文件系统事实，改名牵连使用方 .gitignore/索引习惯；type 与 id 前缀是 frontmatter 数据，批量替换成本低（sed 可完成）。目录名与 type 名不一致的张力在 card-schema.md 中显式说明。

**备选**：目录同步改名为 `actors/`——被否，迁移成本不成比例。

### D3: 双语别名映射表放在 references/skill-catalog.md，不进 frontmatter

**选择**：24 技能的中英文双向映射以 Markdown 表格 + JSON 代码块形式写入 `references/skill-catalog.md`；SKILL.md body 的 description 段只列中文主名 + 代表性英文别名。

**理由**：frontmatter 只能放三键；映射表是查阅型数据，放 body 会让 SKILL.md 膨胀。JSON 代码块内的 YAML/JSON 不会被解析为 frontmatter，安全。

### D4: agents.md 模板随 skill 仓库分发，init 时实例化到使用方工程

**选择**：`templates/agents-zh.md` 与 `templates/agents-en.md` 作为模板源存于本仓库；`nc-初始化` 按 `--lang` 选择模板，替换占位符（工程名、mode、启用技能清单）后输出到使用方工程根目录。`install.sh --project` 默认生成中文版（shell 无法感知 lang 交互时的兜底）。

**理由**：模板集中维护保证双入口（install.sh / nc-初始化）产物一致；使用方工程内的 agents.md 可被作者自由编辑（spec 已声明可编辑性）。

### D5: 通胀过滤器并入素材入库 gate，不再独立触发词

**选择**：原 `nc-过滤` 的三问逻辑保留为 `references/filter.md`，但触发时机改为 `nc-素材` 入库前的自动 gate（新语料/新桥段素材 MUST 过三问，Q3 否决项不变）；`nc-过滤` 前缀仍可手动单独调用以复检某条素材。

**理由**：定稿流程中过滤是入库前置环节而非独立工作流；保留手动入口满足复检需求。README/SKILL 中的触发词表需同步标注此变化。

### D6: 旧资产迁移 = 文档指引 + sed 命令清单，不做自动迁移脚本

**选择**：USAGE.md 新增「v0→v1 迁移」章节：前缀/type 批量替换 sed 命令、目录补齐命令（可直接复用 `install.sh --project` 对已有目录的幂等 mkdir -p）、触发词对照表。

**理由**：使用方工程形态各异，自动迁移脚本的边界情况（自定义卡、混合状态）难以穷尽；人工核对 + 命令辅助更可靠。

### D7: 角色性格建模 = 独立 character_tendency 卡（tend-），而非塞进 actor 卡字段

**选择**：2026-10-23 新增 `character_tendency`（id 前缀 `tend-`，目录 `cards/tendencies/`）作为独立卡类型，记录角色性格/心智倾向的**带触发事件的连续滑动标尺**（dimension / baseline / direction_rule / current_value / history[]）。它通过 `target_role` 引用 `ac-*` 依附角色，每次变动通过 `trigger_plot` 引用 `pp-*` 桥段作为推手。`actor` 卡只存基线初始状态，不再写一大段「固定性格」。

**理由**：性格是随剧情推进的动态弧光，不是静态属性——把它从 actor 卡拆出来才能表达「每一步滑动都绑定具体事件」的因果链，且可被 `nc-校阅` 独立校验逻辑冲突（引用桥段不存在 / 短期与长期趋势冲突 / 同维度矛盾规则）。塞进 actor 卡会让 frontmatter 膨胀且无法结构化校验。

**备选**：把动向做成 actor 卡的嵌套字段——被否，失去独立检索/校验/图谱节点能力，也无法支撑 nc-研判 的多方案刻度推演。

### D8: nc-研判 vs nc-编排 = 单点推演 vs 批量三段式，职责严格切分

**选择**：`nc-研判`(nc-analyze) 处理**少量资产、单点创作推演**，输出多方案 A/B/C 建议报告（只出不改），作者选定后调对应专项技能落地；`nc-编排`(nc-compose) 处理**大批量、跨资产联动**，走严格三段式「生成结构化计划 → 作者逐条审核增删改 → 前置 nc-校阅 扫冲突后顺序执行」。两者都是「先建议/计划、人掌握审批权、绝不静默改卡」，但规模与产物不同：研判产文本报告（可选存素材），编排产 compose_plan 计划文件（存为素材 tag:compose-plan）。

**理由**：把「出主意」（主观创作推演）和「批量调度」（客观任务清单执行）分开，避免一个万能 skill 既做分析又做批量改写导致边界模糊。编排的执行阶段复用底层技能（nc-桥段/nc-动向/nc-感官标记/nc-素材）而非自己实现改写逻辑，保持单一职责。

**备选**：合并为一个「智能修改」skill——被否，单点评估与批量迭代的心智模型差异大，合并会让作者困惑何时用哪个。

### D9: nc-更名 = 全局标识符替换单独抽离，内容修改仍走本体技能

**选择**：叙事实体（角色/道具/暗线/桥段）的**内容修改**交给各自本体技能（nc-角色/nc-暗线/nc-桥段……一卡对应一修改入口，保持内聚）；只有**跨全工程、需批量引用置换的命名变更**（项目书名、角色/势力/道具代号）单独抽 `nc-更名`(nc-rename)。安全机制：先输出替换预览清单（每处文件+原文片段）→ 作者确认 → 才批量写入卡片资产层；不动 res/ 原始素材、不改正文自然口语称呼；自动 history 快照 + CHANGELOG + latest.md。

**理由**：避免造一个臃肿、边界模糊的万能「修改」skill。改名是少数需要跨所有卡片/伏笔/快照/桥段/图谱统一替换引用的操作，单独抽离才能让「预览→确认→替换」的安全链路聚焦在标识符层面，不误伤正文叙事文本。

### D10: 技能认知负荷治理 = auto_invokable 属性标签 + 六组分类 + 文档三分拆

**选择**：不新增一堆看不见的内部命令，而是给每个技能加 `auto_invokable`（可被其他技能内部自动唤起，作者仍可手动调）/ `user_trigger_only`（仅作者主动触发）属性标签，写入 `config/skills.yaml`；面向用户按六组分类折叠展示（工程初始化&素材资产 / 叙事卡片建模 / 剧情结构 / 生成与可视化 / 审计校验 / 归档导出&复盘）；文档拆成 quickstart.md（新手主线，隐藏标记）/ skill-reference.md（全量备查带标记）/ agents.md（对话引导+流程向导）。`auto_invokable=true` 的为 nc-量化/nc-图谱/nc-节奏，其余默认 user_trigger_only。

**理由**：29 个技能平铺会让新手「上来就迷糊」。属性标签让流程引擎知道哪些可自动嵌套，前端只展示用户可调用的六组，作者无需背命令（自然语言路由兜底 + 向导模式）；想深挖再查 skill-reference.md。这比拆出一堆 🔒internal 独立指令更贴合需求——不凭空多出作者看不懂、不能用的命令。

**备选**：拆出独立 internal skill 指令——被否，会增加命令数量与记忆负担，且这些「子能力」本就不该脱离宿主技能独立存在。

## Risks / Trade-offs

- [SKILL.md body 膨胀] 29 技能 + 8 大能力全部塞进单个 SKILL.md 会使 body 超过 30KB，可能超出 agent 上下文经济区间 → 缓解：SKILL.md 只保留总览（六组技能速查表 + 硬规则 + 路由规则），细则全部下沉 references/，按需在指令执行时读取对应 reference 文件；全量备查走 skill-reference.md
- [AI 提案 json 的一致性漂移] card-graph.json 由 AI 逐次提案生成，多次增量更新可能出现节点重复/边丢失 → 缓解：规范中要求每次更新前先读现有 json 全文再合并；建议作者在重要节点用 `nc-检索` 全量重建索引
- [概念过载] 16+ 卡类型 + 29 技能对新手作者认知负担大 → 缓解：长短篇分级默认隐藏复杂技能（short 模式只见 11 个）；六组分类折叠 + quickstart/skill-reference/agents 文档三分拆 + auto_invokable 对用户透明 + agents.md 意图推荐与流程向导兜底
- [robots.txt 检查的执行边界] skill 层只能「指示 AI 先查 robots.txt」，无法保证 AI 实际执行了网络请求 → 缓解：文案明确「若无法获取 robots.txt，按禁止处理并提示手动复制」（fail-closed 原则）
- [硬切换导致旧工程短暂不可用] 升级期间旧触发词（nc-人物）失效 → 缓解：过渡期 skill 仍识别旧前缀并提示新名称（spec 已要求）；迁移章节置顶 USAGE.md
- [双入口漂移] install.sh 与 nc-初始化 各自维护骨架定义 → 缓解：install.sh 的目录列表与 consumer-project-layout spec 对齐，tasks 中设一致性检查步骤

## Migration Plan

1. 本 change 合入后，本仓库即 v1.0 skill 定义；已安装用户重新执行 `./install.sh`（或软链模式自动生效）
2. 旧使用方工程：按 USAGE.md 迁移章节执行 sed 替换 + 目录补齐，无需重装 skill
3. 回滚策略：git revert 本 change 对应的提交即可回到 v0 skill 定义；使用方工程已迁移的资产（ac- 前缀）若需回退，反向 sed 一次即可（frontmatter 数据层面无其他耦合）

## Open Questions

- `card-graph.json` 是否需要正式的 JSON Schema 文件（供未来可选校验工具消费）？当前以 Markdown 约定 + 最小示例承载，若后续有 CI 校验需求再单开 change
- `nc-导出` 的 Pandoc 依赖：Pandoc 是使用方本机工具还是 skill 应检测并提示安装？倾向后者（检测缺失时提示 `apt install pandoc`），实施时确认文案
- 多作品对标场景下 `tree_id` 的命名规范（作品 slug？）可在 tasks 实施阶段定稿
- `nc-编排` 的执行引擎在纯 skill（无运行时）约束下如何表达「顺序执行 + 遇冲突暂停」：倾向以 references/ 中的流程约定 + AI 逐步提案（每步调底层技能、作者确认落盘）承载，不引入脚本；compose_plan 计划文件作为 AI 与作者之间的结构化中介。实施时确认是否需要在 config/skills.yaml 之外单列 compose-plan schema
- `character_tendency` 的刻度数值语义（整数 vs 浮点、是否有上下界）留待 templates/tendencies.md 实施时定稿；当前 spec 只约束结构（baseline/current_value/history[].value 为数值），不锁死取值范围
