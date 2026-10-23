# Proposal

## Why

当前 novel-cards skill 只覆盖「九类卡 + 反思闭环 + 通胀过滤器」的静态卡片维护，无法承载作者实际创作流水线：**语料收集 → 词频/张力控制 → 桥段构思 → 多维度动线（发型/气味/光源/服饰）提前十几章预埋 → 积木式联动触发爆点 → 复盘回流**。2026-10-22 与 Doubao 的规划对话已产出 v1.0 定稿方案（`inbox/doubao-对话-2026-10-22.md`），本次变更把该定稿全量落进 skill：扩容技能清单、改造卡片 schema、引入四层数据分层（md/json/yaml/html）、长短篇分级配置，以及面向新手作者的 `agents.md` 意图引导机制。

2026-10-23 追加需求（`inbox/doubao-对话-2026-10-23.md`）在同一 change 内继续扩展：新增四个技能——`nc-动向`(nc-tendency) 角色性格滑动标尺卡、`nc-研判`(nc-analyze) 创作推演多方案分析工具、`nc-编排`(nc-compose) 批量剧情编排「计划→审核→执行」三段式工具、`nc-更名`(nc-rename) 全局标识符批量替换；并引入**技能内外调用标记**（`auto_invokable` / `user_trigger_only`）+ **六组用户可见分类**降低认知负荷，配套**文档三分拆**（quickstart / skill-reference / agents）隔离新手主线与底层备查。

## What Changes

- **BREAKING** 技能清单从 12 个 `nc-` 触发词重命名为 24 个双语别名技能（如 `nc-人物`→`nc-角色`/`nc-role`、`nc-暗线`→`nc-暗线`/`nc-thread`），新增 `nc-素材`/`nc-清洗`/`nc-检索`/`nc-注册`/`nc-对标`/`nc-积木`/`nc-量化`/`nc-词频`/`nc-定稿`/`nc-姿态`/`nc-节奏`/`nc-校阅`/`nc-守卫`/`nc-导出`/`nc-初始化`/`nc-感官标记` 等。
- **BREAKING** 卡片类型体系从 9 类扩到 15+ 类：`character`(ch-) 改名为 `actor`(ac-) 并扩展非人类行动单元分类；新增 `corpus`(co-)、`lexstat`(lx-)、`module`(md-)、`metric`(mt-)、`pose`(po-)、`sensory_cue`、`refwork` 等类型及对应模板。
- **BREAKING** 使用方工程目录结构重构：新增 `registry/`（yaml 配置树）、`index/`（json 机器真值：card-graph.json 图森林、metric-index.json、lex-batch.json）、`export/`、`res/inbox/`、`history/`、`release/`、`config/`；`cards/` 下新增 `corpus/`、`metrics/`、`modules/`、`pose-bank/`、`lexstats/`、`custom/` 子目录。
- 引入**四层数据分层铁律**：`.md`（人读设计底稿）/ `.json`（机器逻辑真值，图森林）/ `.yaml`（registry 配置树）/ `.html`（视图投影，由 json 重生成）。在 references 中定义 `card-graph.json` 标准 schema（节点+边+tree_id 森林结构）与 registry yaml 约定。
- 新增**长短篇分级**（short/mid/long）：`registry/work-length-config.yaml` 按字数规模过滤默认启用的技能集；新增 `registry/work-setting.yaml` 控制审稿/定稿/守卫分支开关。
- 新增 **`agents.md` 引导机制**：`nc-初始化` 在使用方工程根目录自动生成 `agents.md`（Agent 身份、底层铁律、意图识别→技能推荐规则、可用技能速查表），支持 `--lang zh/en` 双语模板；作者零散输入时 Agent 只推荐不执行。
- 新增**素材合规链路**：`nc-素材` 支持本地文件/纯文本/网页 URL 录入；URL 先校验目标站点 `robots.txt`，禁止路径直接拦截终止，抓取成功必附版权提醒，不绕过反爬/登录/动态渲染限制；配套两套中英文提示文案与顶层合规声明。
- 新增**黑盒三层道具建模**（物理层/感知层/抽象非感知层）与**五感公理**（玄幻灵觉归为五感变体子标签，不新增独立感知大类）；感知动线根只能落在五感之一。
- 新增**姿态库（pose）**：固定内核 + 环境变量插槽 + 多视角文案 + 使用约束；插槽填充三级优先级（桥段覆写 > 快照自动填充 > 默认兜底）。
- 新增**积木模块（module）**：最小调度单元，`trigger_map` 自由绑定任意数量、任意 track 类型的 timeline 节点 + pose + 自定义卡片，替代原「四感锁死」的联动方式；timeline 节点通过 `bind_module` 由积木驱动。
- 新增**审计类技能**（`nc-校阅`/`nc-节奏`/`nc-守卫`）：只输出意见书（md + json 双产物），绝不自动修改文稿；守卫区分「渲染加害红线」与「揭露批判豁免」。
- `install.sh --project` 骨架生成同步更新为新目录结构；提供旧资产迁移说明（`ch-`→`ac-` 前缀、`darklayer` 保留、目录映射表）。
- SKILL.md / README.md / USAGE.md / references/ / templates/ 全套文档与模板同步重写，保持 frontmatter 三键（name/description/license）双端兼容铁律不变。

### 2026-10-23 追加（同一 change 内继续扩展）

- **新增技能 `nc-动向`(nc-tendency)**：角色性格/心智倾向的**滑动标尺**卡（`character_tendency`，id 前缀 `tend-`），含维度、基线刻度、长期趋势方向规则、当前值、触发事件历史数组（每条绑定 `trigger_plot` 桥段 id + 描述）。区别于静态写死在角色卡上的固定性格；`nc-校阅` 可校验动向逻辑冲突（引用桥段不存在 / 短期变化与长期趋势严重冲突 / 同维度多条矛盾规则）。
- **新增技能 `nc-研判`(nc-analyze)**：创作层面推演工具——读取选定的桥段/角色/动向/感官标记资产，输出多套修改方案 A/B/C（附利弊与连锁影响），**只出建议报告绝不自动改卡**；作者确认方案后再调用对应专项技能落地。与 `nc-校阅` 互补：校阅偏「找茬」（规则校验查冲突），研判偏「出主意」（主观创作推演）。研判本身是操作技能，不生成独立卡片（报告可选存素材）。
- **新增技能 `nc-编排`(nc-compose)`**：批量剧情编排三段式工具——根据素材/原有剧情资产/作者情节目标，先生成结构化【编排执行计划】（4 类任务：create_plot / edit_plot / archive_plot / update_tendency / bind_sensory_cue，每条含预览/预期影响/风险提示），交作者逐条审核增删改，审核定稿后**前置自动跑 nc-校阅 扫冲突**，无红色冲突才顺序执行（每步调用底层技能并记 CHANGELOG），遇冲突暂停退回计划页。`--mode expand/rewrite/restructure`。计划文件存为素材（`tag:compose-plan`）便于回溯。
- **新增技能 `nc-更名`(nc-rename)`**：全局标识符批量替换——改项目主标题（书名）或全局代号（角色/势力/道具代号）。先输出【替换预览清单】（每处文件+原文片段），作者确认后批量写入卡片资产层引用；**不动 res/ 原始素材**、不改正文自然口语称呼（只处理卡片注册标识符）；自动 history 快照 + CHANGELOG + latest.md。归属工程维护类，非创作主线强制节点。
- **技能内外调用标记**：每个技能增加 `auto_invokable`（可被其他技能内部自动唤起，作者仍可手动调）/ `user_trigger_only`（仅作者主动触发）属性标签，写入 `config/skills.yaml`；`auto_invokable=true` 的为 `nc-量化`/`nc-图谱`/`nc-节奏`，其余默认 `user_trigger_only`。前端引导面板只展示用户可调用的六组，不暴露底层联动细节。
- **六组用户可见分类**（替代原四组，降低记忆负担）：A 工程初始化&素材资产 / B 叙事卡片建模 / C 剧情结构 / D 生成与可视化 / E 审计校验 / F 归档导出&复盘。
- **文档三分拆**：`quickstart.md`（新手主线，只放高频 6 组主线路径，隐藏属性标记）/ `skill-reference.md`（全量备查总表，带 auto_invokable 标记）/ `agents.md`（对话引导层，内置路由 + 流程向导模式）。使用方工程骨架新增 `config/skills.yaml` + `quickstart.md` + `skill-reference.md`。

## Capabilities

### New Capabilities

- `skill-catalog`: 29 个 nc- 技能的完整清单（含 2026-10-23 新增的 nc-动向/nc-研判/nc-编排/nc-更名）、双语别名映射、职责边界、六组用户可见分类 + auto_invokable/user_trigger_only 内外调用标记，以及每个技能的入参与产物约定
- `card-schema`: 全部卡片类型的 frontmatter schema（含 actor 非人类分类、黑盒三层 item、pose 插槽、module trigger_map、lexstat 张力标尺、corpus 语料、metric 量化、sensory_cue、refwork，以及 2026-10-23 新增的 character_tendency 角色动向滑动标尺卡），通用五字段与各自专属字段
- `data-layering`: md/json/yaml/html 四层数据分层的职责边界、`card-graph.json` 图森林 schema（节点/边/tree_id）、registry yaml 约定、html 由 json 重生成的投影规则
- `consumer-project-layout`: 使用方工程目录结构规范（cards/ 各子目录、registry/、index/、graph/、res/、history/、release/、export/、config/、drafts/，以及 2026-10-23 新增的 config/skills.yaml + quickstart.md + skill-reference.md）、`nc-初始化` 生成的骨架与 `agents.md` / `quickstart.md` / `skill-reference.md` 内容契约
- `agent-guidance`: `agents.md` 引导机制——Agent 身份约束、底层铁律、意图识别→技能推荐规则（只推荐不执行）、双语模板、`nc-xxx` 显式指令优先于意图猜测；2026-10-23 追加：quickstart/skill-reference/agents 文档三分拆、流程向导模式、auto_invokable 对用户透明、六组分类折叠展示
- `material-compliance`: `nc-素材` 录入链路的 robots.txt 合规校验、版权提醒、反爬/登录/动态页失败处理、中英文提示文案、单点自用定位声明
- `pipeline-flows`: 三大场景流程（原创写作 / 外部作品对标拆解 / 纯素材整理）的技能编排顺序、长短篇分级过滤规则、写稿→审稿→修稿→定稿分支开关；2026-10-23 追加：nc-研判（单点推演）与 nc-编排（批量「计划→审核→执行」三段式）在流程中的位置，以及角色动向标尺随桥段推进的长期弧光链路
- `audit-skills`: `nc-校阅`/`nc-节奏`/`nc-守卫` 三个审计技能的审计维度、告警分级、豁免规则、只出意见不改稿的输出契约；2026-10-23 追加：nc-校阅 新增 character_tendency 动向逻辑冲突检查项

### Modified Capabilities

（无——本项目 `openspec/specs/` 目前为空，所有能力均为首次以 spec 形式固化）

## Impact

- **本仓库**：`SKILL.md`（重写 body，frontmatter 三键不变）、`references/`（card-schema.md 重写、hard-rules.md 追加新硬规则、loop.md 重写为三场景流程、layout.md 更新目录约定、filter.md 保留、新增 data-layering.md / registry.md / agents-guide.md / compliance.md；2026-10-23 追加 skill-catalog.md 扩到 29 技能六组分类 + auto_invokable 标记、card-schema.md 增 character_tendency、agents-guide.md 增文档三分拆与向导模式）、`templates/`（15+ 套模板重写/新增，2026-10-23 追加 tendency.md 角色动向卡模板 + quickstart/skill-reference 双语模板）、`install.sh`（`--project` 骨架升级 + `nc-初始化` 语义，新增 config/skills.yaml + quickstart.md + skill-reference.md 占位）、`README.md` / `USAGE.md` 同步重写。
- **使用方工程**：目录结构 BREAKING 变化，旧工程需按迁移指引调整（前缀改名、目录补齐）；已有卡片资产本身格式向后兼容部分（五字段不变），但 `character`→`actor` 类型名变更需要批量替换。
- **无构建/依赖变化**：本仓库仍无 package.json / 构建配置 / 测试命令；json 索引与 registry 由 skill 指令驱动 AI 提案生成，用户落盘，不引入运行时脚本依赖。
- **双端兼容**：OpenCode + Claude Code 兼容性铁律不变（frontmatter 仅 name/description/license）。
