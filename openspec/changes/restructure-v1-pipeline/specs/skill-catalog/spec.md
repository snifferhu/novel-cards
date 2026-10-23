# Spec Delta

## Purpose

定义 novel-cards skill 的完整技能清单：29 个 `nc-` 技能的职责边界、双语别名映射、六组用户可见分类（工程初始化&素材资产 / 叙事卡片建模 / 剧情结构 / 生成与可视化 / 审计校验 / 归档导出&复盘）+ auto_invokable / user_trigger_only 内外调用标记，以及每个技能的触发方式与产物约定。

## ADDED Requirements

### Requirement: 技能清单完整性

系统 SHALL 提供以下 29 个技能，面向用户按六组分类呈现（降低记忆负担），每个技能另带 `auto_invokable` / `user_trigger_only` 内外调用标记：

**A. 工程初始化 & 素材资产组**：`nc-初始化`(nc-init)、`nc-素材`(nc-material)、`nc-清洗`(nc-clean)、`nc-检索`(nc-query)、`nc-注册`(nc-reg)、`nc-更名`(nc-rename)

**B. 叙事卡片建模组**：`nc-角色`(nc-role)、`nc-姿态`(nc-pose)、`nc-道具`(nc-item)、`nc-场景`(nc-scene)、`nc-感官标记`(nc-sensorycue)、`nc-动向`(nc-tendency)

**C. 剧情结构组**：`nc-桥段`(nc-plot)、`nc-伏笔`(nc-foreshadow)、`nc-快照`(nc-snapshot)、`nc-势力`(nc-faction)、`nc-暗线`(nc-thread)、`nc-积木`(nc-module)、`nc-研判`(nc-analyze)、`nc-编排`(nc-compose)

**D. 生成与可视化组**：`nc-量化`(nc-metric)、`nc-图谱`(nc-graph)、`nc-成稿`(nc-draft)、`nc-词频`(nc-wordfreq)

**E. 审计校验组**：`nc-校阅`(nc-review)、`nc-节奏`(nc-rhythm)、`nc-守卫`(nc-safetyguard)

**F. 归档导出 & 复盘组**：`nc-定稿`(nc-finalize)、`nc-导出`(nc-export)、`nc-复盘`(nc-retrospect)

> 注：原「主流程 / 素材辅助 / 校验审计 / 导出归档」四组为内部流水线视角；六组为用户可见分类。两者是同一 29 技能的不同切面，文档中须同时给出映射，避免双轨漂移。

#### Scenario: 用户以中文前缀触发技能
- **WHEN** 用户在对话中输入 `nc-角色` 或自然语言「新建一个角色卡」
- **THEN** skill 识别为 `nc-role` 技能并执行对应工作流

#### Scenario: 用户以英文别名触发技能
- **WHEN** 用户输入 `nc-role` 或 `nc-module`
- **THEN** skill 通过双语别名映射表解析为对应中文技能并执行

### Requirement: 双语别名映射

系统 SHALL 维护一份完整的双向别名映射（JSON 格式，存放于 references 文档中），保证每个中文调用名与英文调用名可互相解析；交互提示优先展示中文名，英文名括号附带；用户输入任一别名时内部自动映射，返回提示仍以中文为主。

#### Scenario: 英文输入返回中文提示
- **WHEN** 用户输入 `nc-wordfreq`
- **THEN** skill 执行词频约束工作流，且后续流程推荐提示显示为「nc-词频(nc-wordfreq)」

### Requirement: 技能命名与旧版对照

系统 SHALL 在文档中提供旧版 12 触发词到新版 29 技能的对照表：`nc-人物`→`nc-角色`(nc-role)、`nc-暗线` 保留中文名但英文名为 `nc-thread`（旧 `nc-暗线` 无英文别名）、新增技能无旧版对应。`nc-过滤`（通胀过滤器）SHALL 保留为独立能力，其三问逻辑并入 `nc-素材` 入库前的 gate 环节。

#### Scenario: 旧用户迁移
- **WHEN** 旧使用方工程的用户习惯说 `nc-人物`
- **THEN** skill 文档中的迁移说明告知该前缀已更名为 `nc-角色`，且 skill 在过渡期仍应能识别 `nc-人物` 并提示新名称

### Requirement: 技能职责不重叠

每个技能 SHALL 有唯一的核心职责描述；跨技能的能力复用（如 `nc-校阅` 内置调用 `nc-节奏` 的输出）SHALL 通过显式引用表达，而非复制逻辑。审计类技能（`nc-校阅`/`nc-节奏`/`nc-守卫`）MUST 只输出意见，绝不自动修改、删除文稿。`nc-成稿`(nc-draft) 与 `nc-词频`(nc-wordfreq) 职责分离：成稿负责「读全部卡片 → 出正文初稿」（内容生成），词频负责「词频向量 + 感官均衡约束」（纯约束校验，不出正文）。

#### Scenario: 校阅引用节奏
- **WHEN** 执行 `nc-校阅` 且需要节奏维度审计
- **THEN** 校阅流程读取 `nc-节奏` 的输出报告作为其中一个审计模块，不重新实现滑动窗口扫描逻辑

#### Scenario: 成稿消费词频约束
- **WHEN** 执行 `nc-成稿` 生成某章正文初稿
- **THEN** 成稿流程读取该章绑定的 `lx-*` 词频卡作为约束输入，但词频工具本身不产出任何正文文本

### Requirement: 自动成稿技能（nc-成稿 / nc-draft）

系统 SHALL 提供 `nc-成稿`(nc-draft) 技能：读取已备好的设定 / 桥段 / 大纲 / 暗线 / 角色 / 道具 / 场景等卡片，按 `--length short/mid/long` 控制篇幅档位，自动生成正文初稿。该技能 MUST 走提案制——以完整 Markdown 提案输出到对话并标注目标路径 `manuscript/chapter-*.md`，由作者校阅调整后自行落盘，MUST NOT 直接写入 `manuscript/`。篇幅档位语义：`short`（精简骨架，约 1/3 篇幅）/ `mid`（标准，默认）/ `long`（详尽展开，含环境 / 心理 / 感官铺陈）。

#### Scenario: 长篇模式成稿
- **WHEN** 用户输入 `nc-成稿 chapter-012 --length long`
- **THEN** skill 读取 chapter-012 关联的全部卡片，生成详尽展开的正文初稿提案（含环境 / 心理 / 感官铺陈），输出到对话供作者校阅

#### Scenario: 短篇模式成稿
- **WHEN** 用户输入 `nc-成稿 chapter-003 --length short`
- **THEN** skill 生成精简骨架版正文初稿提案（约 1/3 篇幅），省略大量铺陈

### Requirement: 设定卡检索容错与差异归档

所有「更新已有卡」类技能（含 `nc-检索` 触发的填充流程）SHALL 对作者口述 / 输入的设定对象做模糊匹配，命中多个可能对应同一设定的记录时 MUST 返回全部候选（含各自 id 与关键差异点）请作者确认，MUST NOT 自行拍板选定唯一候选后直接改写。当要更新的卡与现有内容存在实质差异（非纯笔误修正）时，MUST NOT 原地覆盖：先把旧版本快照复制到 `history/<card-id>/<updated-date>.md`（只读快照），再出新版提案。纯笔误 / 格式修正可直接出更新提案并注明「仅修正 X」。

#### Scenario: 多候选返回
- **WHEN** 作者说「更新青铜钥匙的设定」，而工程中存在 `it-bronze-key` 与 `it-bronze-key-v2` 两张近似卡
- **THEN** skill 列出两张候选及差异，请作者确认是哪一张，不自行选定

#### Scenario: 差异先归档
- **WHEN** 作者确认更新 `it-bronze-key`，且新内容与现有内容有实质差异
- **THEN** skill 先把旧版本复制到 `history/it-bronze-key/<date>.md`，再出新版提案

### Requirement: 呈现收敛原则

系统 SHALL 在文档中声明：技能数量虽达 29 个，但日常使用不必一次全部触发；AI 应按当前流水线阶段只推荐「下一步最相关的 1–3 个技能」，不一次性倾倒全部技能清单。作者可在 `agents.md` 声明「本项目常用技能集」做进一步收敛。

#### Scenario: 分阶段推荐
- **WHEN** 用户刚完成建卡阶段进入写稿
- **THEN** skill 只推荐 `nc-成稿` / `nc-词频` 等写稿相关技能，不罗列其余 26 个技能

### Requirement: 技能内外调用标记（auto_invokable / user_trigger_only）

每个技能 SHALL 携带两个互斥属性标签，写入使用方工程 `config/skills.yaml` 并在 `skill-reference.md` 备查总表中标注：

- `auto_invokable: true`：可被其他技能在流程内部自动唤起，作者仍可手动调用。本清单中为 `nc-量化`(nc-metric)、`nc-图谱`(nc-graph)、`nc-节奏`(nc-rhythm)。
- `user_trigger_only: true`：仅作者主动触发，不会被系统后台自动拉起。其余 26 个技能默认此值。

前端引导面板与交互提示 MUST 只展示用户可调用的六组分类，`auto_invokable` 属性仅在底层配置（`config/skills.yaml`）与备查文档（`skill-reference.md`）可见，对普通作者隐藏，避免凭空多出一堆看不懂、不能用的内部命令。

#### Scenario: 校阅自动唤起节奏
- **WHEN** 执行 `nc-校阅` 需要节奏维度审计
- **THEN** 因 `nc-节奏` 的 `auto_invokable: true`，校阅流程引擎可自动嵌套调用它，对用户透明，无需作者手动输入 `nc-节奏`

#### Scenario: 初始化不可被自动唤起
- **WHEN** 任一技能执行过程中
- **THEN** 因 `nc-初始化` 的 `user_trigger_only: true`，没有任何技能会自动去初始化新项目，只有作者手动触发

### Requirement: nc-动向 角色倾向滑动标尺（nc-tendency）

系统 SHALL 提供 `nc-动向`(nc-tendency) 技能：创建/编辑 `character_tendency`（id 前缀 `tend-`）角色动向卡，刻画角色性格/心智倾向的**带触发事件的连续滑动标尺**——有基准刻度、长期趋势方向、当前刻度，每一次变动绑定一个具体桥段事件作为推手，而非凭空变性格。该卡依附角色（`target_role` 引用 `ac-` id），引用桥段（`trigger_plot` 引用 `pp-` id）作为变动原因。`nc-检索` 支持 `type:character_tendency` 与按角色过滤。`nc-校阅` 可校验动向逻辑冲突。它 MUST NOT 替代角色基础卡（基线初始状态仍存于 `actor` 卡）。

#### Scenario: 克制→放荡滑动标尺
- **WHEN** 作者说「这个角色本性克制，经历几件事后慢慢变得放荡，每次转变都有对应事件刺激他」
- **THEN** skill 提案 `tend-*` 卡：`dimension: 克制↔放荡`、`baseline: 0`、`direction_rule: 长期向放荡偏移`、`history[]` 每条含 `{value, trigger_plot: pp-*, description}`，绑定 `target_role: ac-*`

#### Scenario: 检索某角色全部动向
- **WHEN** 作者输入 `nc-检索 type:character_tendency role:ac-002`
- **THEN** skill 返回该角色全部性格标尺与变动历史

### Requirement: nc-研判 创作推演多方案分析（nc-analyze）

系统 SHALL 提供 `nc-研判`(nc-analyze) 技能：读取选定的剧情/角色/动向/感官标记资产（可多个）+ 作者诉求，做**创作层面推演**，输出结构化分析报告 + 可选修改方案 A/B/C（附每方案利弊与对其他资产的连锁影响）。铁律：MUST 只输出建议报告，绝不直接改动任何 cards/素材；报告末尾固定询问是否选定方案，作者确认后再调用对应专项技能（`nc-动向`/`nc-桥段`/`nc-感官标记` 等）落地变更。研判是操作技能，MUST NOT 生成独立驻留卡片（报告可选经 `nc-素材` 存入素材库）。与 `nc-校阅` 互补：校阅偏「找茬」（规则校验查冲突），研判偏「出主意」（主观创作推演）。

#### Scenario: 角色突破底线推演
- **WHEN** 作者说「这个角色现在刻度 +2，我想让他再突破底线，帮我看看怎么安排比较合适」
- **THEN** skill 读取 `tend-*` 动向标尺 + 关联 `pp-*` 桥段，输出方案 A（小幅偏移+3）/B（大幅跳跃+5）/C（短期回弹+1），各附优缺点与风险，末尾询问「请选择 A/B/C/自行修改/放弃」，确认后调用 `nc-动向`+`nc-桥段` 落地

#### Scenario: 研判不改卡
- **WHEN** `nc-研判` 产出多方案报告
- **THEN** 报告中所有方案仅为文本建议，未写入任何卡片；作者选定后才由对应技能执行

### Requirement: nc-编排 批量剧情编排三段式（nc-compose）

系统 SHALL 提供 `nc-编排`(nc-compose) 技能：根据指定素材（`--source`）、原有剧情资产（`--reference`）、作者情节目标（`--prompt`）与模式（`--mode expand/rewrite/restructure`），自动生成一套结构化【编排执行计划】——4 类任务（`create_plot` 新增桥段 / `edit_plot` 修改已有桥段 / `archive_plot` 归档旧桥段 / `update_tendency` 更新角色动向标尺 / `bind_sensory_cue` 绑定感官标记），每条任务自带任务 ID、类型、目标资产 ID、变更说明、预期影响、风险提示。核心铁律：MUST 先交付计划给作者逐条审核（同意/编辑/移除/新增自定义任务/整体约束），作者确认【计划定稿开始执行】后，内核才顺序执行，每一步调用对应底层技能（`nc-桥段`/`nc-动向`/`nc-感官标记`/`nc-素材`）并记录 CHANGELOG、更新 latest.md。执行前 MUST 自动跑一次 `nc-校阅` 扫描整套计划叠加后的冲突：无严重冲突则顺序执行，遇红色冲突则暂停退回计划页让作者调整，绝不强行执行。计划文件 MUST 保存为素材（`tag:compose-plan`）便于回溯。全程禁止静默修改。

#### Scenario: 基于素材批量扩写
- **WHEN** 作者说「我这批素材用上，写他接受馈赠，性格再进一步偏移，原来那段老情节换掉」
- **THEN** skill 生成 compose_plan（含 create_plot 新桥段 + update_tendency tend-001:+1 + archive_plot 旧桥段 + bind_sensory_cue），交作者逐条审核；审核定稿后前置跑 nc-校阅，无红冲突则顺序执行，每步记 CHANGELOG

#### Scenario: 执行遇冲突暂停
- **WHEN** 编排计划执行到某任务时 nc-校阅 检出红色冲突
- **THEN** skill 暂停执行，定位冲突任务退回计划页让作者调整，不强行继续

#### Scenario: 研判与编排分工
- **WHEN** 作者想对少量资产做单点推演 vs 大批量跨资产联动
- **THEN** 单点评估走 `nc-研判`，批量整条故事线迭代/扩写/重构走 `nc-编排`

### Requirement: nc-更名 全局标识符批量替换（nc-rename）

系统 SHALL 提供 `nc-更名`(nc-rename) 技能：专门处理**全局标识符替换**——修改项目主标题（故事书名，同步更新根 README/project.yaml/CHANGELOG/latest.md 及导出模板页眉标题），或全局代号重命名（角色代号/势力代号/核心道具代号，跨所有卡片/伏笔/快照/桥段/图谱引用统一替换）。安全机制：MUST 先输出【替换预览清单】（列出每一处要修改的文件 + 原文片段），作者确认批准后才批量写入；自动在 history 生成本次变更快照、CHANGELOG 追加记录、更新 latest.md。边界：MUST NOT 修改 `res/` 原始素材文件夹内内容（原始素材保留原样，只改卡片资产层）；MUST NOT 改动正文描写文本里的自然口语称呼（如文中「阿三」），只处理卡片注册的标识符。归属工程维护类，非创作主线强制节点，`user_trigger_only`。

#### Scenario: 修改故事书名
- **WHEN** 作者说「把书名从《旧名》改成《新名》」
- **THEN** skill 输出替换预览清单（README/project.yaml/CHANGELOG/latest.md/导出模板各处），作者确认后批量写入，history 快照 + CHANGELOG 追加

#### Scenario: 全局代号重命名不动素材
- **WHEN** 作者要把角色代号 `旧代号` 全局改为 `新代号`
- **THEN** skill 扫描 cards/ 下全部卡片/积木/伏笔/快照/暗线/桥段的注册标识符引用，预览后替换；`res/` 原始素材与正文自然口语称呼均不动

#### Scenario: 内容修改走本体技能
- **WHEN** 作者想改角色性格/暗线内容/桥段情节（非改名）
- **THEN** 路由到对应本体技能（`nc-角色`/`nc-暗线`/`nc-桥段`），不走 `nc-更名`；一卡对应一修改入口保持内聚
