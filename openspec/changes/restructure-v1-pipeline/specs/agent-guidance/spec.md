# Spec Delta

## Purpose

定义使用方工程根目录 `agents.md` 引导机制：Agent 身份约束、底层铁律、意图识别→技能推荐规则（只推荐不执行）、双语模板契约，以及显式 `nc-xxx` 指令与自由输入两种交互模式的分流规则。让新手作者零散丢想法时 Agent 能接住、看懂、温柔提醒可用工具，而非直接瞎写正文。2026-10-23 追加：quickstart / skill-reference / agents 文档三分拆、流程向导模式、auto_invokable 对用户透明、六组分类折叠展示，降低 29 技能的认知负荷。

## ADDED Requirements

### Requirement: agents.md 自动生成

`nc-初始化` MUST 在使用方工程根目录生成三份引导文档（与 README.md / CHANGELOG.md / latest.md 同级）：

- `agents.md`——对话引导层，内容分四块：① Agent 身份；② 底层铁律；③ 意图识别 & 技能推荐规则；④ 六组分类折叠的技能速查（只列用户可调用的，不暴露 auto_invokable 底层联动）。
- `quickstart.md`——新手主线向导，只放高频主线路径（nc-init → nc-material → nc-role/nc-item/nc-scene → nc-plot → nc-review → nc-export）+ 进阶扩展分组，隐藏属性标记，不罗列全部 29 个技能。
- `skill-reference.md`——全量备查手册，完整总表带 `auto_invokable` 标记 + 每技能入参/产物，供深挖、调脚本、GUI 开发时查阅。

三份文件均支持 `--lang zh/en` 双语模板，跟随工程 lang 参数。`agents.md` 内置路由逻辑：初次进入优先展示 quickstart 主线向导（禁止一次性抛全部 skill 列表）；自然语言提问做意图路由（不强制输入指令）；作者主动询问完整清单才跳转 skill-reference；调用链路内部自动调度 `auto_invokable=true` 的能力对用户透明；输入 skill 名优先匹配中英别名双向兼容；网页素材导入自动携带合规提示；每次执行变更后自动更新 latest.md。

#### Scenario: 初始化产出三份引导文档
- **WHEN** 执行 `nc-初始化 --lang zh`
- **THEN** 工程根目录出现中文 `agents.md`（身份/铁律/意图匹配/六组速查）、`quickstart.md`（主线最简流程 + 进阶扩展）、`skill-reference.md`（29 技能全量总表带 auto_invokable 标记）

### Requirement: Agent 身份约束

`agents.md` MUST 声明：Agent 是本工程的创作辅助助手；不能自动修改、新增任何 cards 卡片，不能自动写入素材库；所有结构化变更必须由作者显式调用 nc-* 技能完成；核心职责是理解作者零散输入、识别创作意图、提醒可用技能、解释技能用法。

#### Scenario: 作者只发想法
- **WHEN** 作者发送一段剧情片段但未输入任何 nc- 指令
- **THEN** Agent 不直接生成卡片或正文，而是识别意图后询问「是否需要调用 nc-xxx」

### Requirement: 意图识别与技能推荐

当作者未输入 `nc-xxx` 指令、只发送自由文本时，Agent SHALL 按意图匹配表识别并推荐对应技能，话术模板为「识别到你【xxx意图】，你可以选择调用技能：`nc-xxx`，作用：简短说明。是否需要执行？」。匹配表至少覆盖：粘贴网页链接/论文/LLM对话/摘抄→`nc-素材`；AI 多版本草稿含冗余话术→`nc-清洗`；查找角色/道具/桥段/感官标记/素材→`nc-检索`；构思事件/冲突/剧情片段→`nc-桥段`；设计角色专属 BGM/气味标识/出场音效/标志性光影→`nc-感官标记`；描述角色心智/性格沿某方向逐步变化且每次转变都有剧情事件推动→`nc-动向`（维护角色倾向滑动标尺）；想对现有剧情/人物弧光做推演拿修改方案评估不同走向好坏→`nc-研判`（多方案推演分析，确认后动手改）；已积累素材想基于素材新增剧情/改动整条故事线/批量调整桥段与角色变化→`nc-编排`（自动生成编排计划，审核后统一落地）；想改整个故事名字/批量更换角色势力代号→`nc-更名`（全局标识符替换，预览确认后执行）；改角色人设/暗线内容/桥段剧情（非改名）→对应本体技能（`nc-角色`/`nc-暗线`/`nc-桥段`），告知每个卡片自身 skill 自带编辑更新能力；检查伏笔冲突/设定矛盾→`nc-校阅`；检查章节节奏/疏密/爆点排布→`nc-节奏`；锁定版本打快照→`nc-定稿`；导出 Word/PDF→`nc-导出`；复盘沉淀经验→`nc-复盘`。

MUST NOT 在作者只发想法时直接替作者执行技能或直接生成卡片，只能询问确认。

#### Scenario: 王熙凤笑声
- **WHEN** 作者输入「王熙凤，人还没进院子，笑声先传过来，所有人安静下来」
- **THEN** Agent 回复「识别到你在构思角色专属的标志性听觉氛围信号，你可以选择调用技能：`nc-感官标记`……是否需要执行？」

#### Scenario: AI 草稿清理
- **WHEN** 作者输入「我刚才让 Grok 写了三段不同结局，里面一堆开场白废话」
- **THEN** Agent 推荐 `nc-清洗`，说明可去除多余话术、拆分独立方案，并询问是否执行

### Requirement: 显式指令优先

当作者明确写出 `nc-xxx` 指令时，系统 MUST 优先执行该指令，不再触发意图猜测和技能推荐；意图识别只在无指令的自由碎输入时生效。

#### Scenario: 显式指令跳过推荐
- **WHEN** 作者输入 `nc-校阅 第5章`
- **THEN** 直接执行校阅流程，不输出「识别到意图……是否执行」的推荐话术

### Requirement: agents.md 可编辑性

`agents.md` / `quickstart.md` / `skill-reference.md` 三份引导文档均为引导提示而非强制锁死：作者 MUST 能够手动编辑，自行增删意图匹配规则、自定义话术、调整分组折叠；skill 的意图识别与推荐行为 SHALL 以工程内实际存在的文档内容为准，而非 skill 内置默认值。

#### Scenario: 作者自定义意图规则
- **WHEN** 作者在 `agents.md` 意图匹配表中新增一条「提到『钱庄』→推荐 nc-势力」
- **THEN** 后续作者提到钱庄相关零散想法时，Agent 按自定义规则推荐 nc-势力

### Requirement: 文档三分拆与 auto_invokable 透明化

系统 SHALL 把技能清单按认知负荷拆成三份文档隔离新手主线与底层备查：`quickstart.md`（新手只看高频主线 + 六组进阶扩展，隐藏 auto_invokable 标记）/ `skill-reference.md`（全量 29 技能总表带 auto_invokable 标记，供深挖查阅）/ `agents.md`（对话引导层，内置路由 + 流程向导模式）。前端交互面板 MUST 分组折叠展示，默认只展开【主线最简流程】；`auto_invokable` 属性仅在 `config/skills.yaml` 与 `skill-reference.md` 可见，对普通作者隐藏。流程向导模式 SHALL 让作者可不记忆任何 skill 名称，跟着向导点选（新建项目→导入素材→建立角色道具场景→写桥段→校验→导出），后台自动调度对应技能。

#### Scenario: 新手只看主线
- **WHEN** 新手作者首次打开工程
- **THEN** Agent 优先展示 quickstart.md 主线最简流程（6 步），不一次性抛出全部 29 个技能；其余分组折叠收起

#### Scenario: 向导模式免记命令
- **WHEN** 作者说「我想开始写个新故事」但不记得任何 skill 名
- **THEN** Agent 进入流程向导，逐步引导「先初始化项目」→「导入素材」→……，后台自动调用对应技能，作者无需输入 skill 名

#### Scenario: 内部联动对用户透明
- **WHEN** 作者执行 `nc-校阅`，其内部自动唤起 `auto_invokable=true` 的 `nc-节奏`
- **THEN** 交互提示不单独弹出「正在调用 nc-节奏」，对用户透明；完整联动细节仅在 skill-reference.md 备查
