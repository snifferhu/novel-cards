# Proposal

## Why

`character_tendency` 滑动标尺目前无法声明角色的**人格病理类稳定基线**（如自恋型人格的两种创作原型：浮夸型 / 脆弱型）。作者刻画这类角色时，只能把「共情维度几乎不可自发上调、表演性温柔不算改善」这类滑动边界约束反复写进自由文本 `notes`，`nc-校阅` 也无法机器校验边界冲突——边界对审计层不可见。背景来自 `inbox/doubao-对话-2026-10-24.md`（注意：该对话对现行 schema 的描述有误，本提案以 `references/card-schema.md` 的真实字段契约为准，只吸收「人格基线原型 + 滑动边界约束」这一意图）。

## What Changes

- `character_tendency` frontmatter 新增**可选**枚举字段 `baseline_prototype`：声明该动向卡依附角色的人格病理类稳定基线原型（推荐词表如 `npd-grandiose`（浮夸型）/ `npd-vulnerable`（脆弱型）），取值 MUST 经 `nc-注册` 写入使用方工程 `registry/tendency-prototypes.yaml` 白名单（沿用硬规则 16「注册前置」的既有机制，skill 不内置锁死枚举）。维度与滑动逻辑仍由现行 `dimension` / `baseline` / `direction_rule` / `history[]` 表达，本字段只作边界约束的声明锚点。
- 每个原型在 registry 条目中携带 `boundary_hints`（维度关键词 → 受限滑动方向 + 提醒文案），供 `nc-校阅` 做**建议级**边界漂移检查（新增动向逻辑冲突检查项 ④）：带原型声明的 tend- 卡其匹配维度朝受限方向漂移超阈值时输出提醒，作者可刻意写反常弧光豁免（与现有检查 ②「提示风险而非禁止」同一分级）。
- `nc-动向`(nc-tendency) 入参新增可选 `baseline_prototype`，建卡/编辑时校验取值已注册，未注册则按「注册前置」拦截提示先走 `nc-注册`。
- `nc-初始化` 默认值新增 `registry/tendency-prototypes.yaml` 空骨架（只含字段结构与占位，不预置具体原型取值；`npd-*` 等词表以文档示例形式出现在 references/templates），`references/layout.md` 的 registry 文件清单同步收录（install.sh --project 只建 registry/ 目录与 .gitkeep，registry yaml 骨架本就由 nc-初始化 填充，install.sh 无需改动）。
- 同步更新：`references/card-schema.md`（字段定义 + 示例）、`templates/tendencies.md`（模板字段）、`references/skill-catalog.md`（nc-动向 入参 / nc-校阅 职责描述）、`references/audit-skills` 对应文档段、`README.md` / `USAGE.md` 卡表与硬规则速览措辞、双语 skill-reference 模板相应行。
- **无 BREAKING**：字段可选，存量 tend- 卡不带该字段时全部现行行为不变；registry 文件为新增，旧工程可后补。

## Capabilities

### New Capabilities

（无——本变更不引入全新能力域，只在既有能力的 requirement 上扩展。）

### Modified Capabilities

- `card-schema`：`character_tendency` requirement 增补可选 `baseline_prototype` 字段契约（registry-backed 枚举、依附角色共享原型、与滑动字段的分工），及「原型声明 + 边界漂移提醒」场景。
- `audit-skills`：`nc-校阅` 动向逻辑冲突检查从 ①②③ 扩为 ①②③④，新增原型边界漂移建议级检查（registry boundary_hints 匹配维度关键词、受限方向漂移提醒、可豁免）。
- `skill-catalog`：`nc-动向` requirement 入参契约增补可选 `baseline_prototype`（含注册前置校验）。
- `consumer-project-layout`：`registry/` 文件清单增补 `tendency-prototypes.yaml`（原型白名单 + boundary_hints 骨架），`install.sh --project` / `nc-初始化` 骨架生成同步。

## Impact

- **文档/模板层（主要）**：`references/card-schema.md`、`references/skill-catalog.md`、`references/audit-skills` 相关段、`templates/tendencies.md`、`README.md`、`USAGE.md`、`templates/skill-reference-zh.md` / `skill-reference-en.md`。
- **骨架生成**：`nc-初始化` 默认值与说明文档（registry yaml 骨架由 nc-初始化 填充；install.sh --project 不涉及）。
- **行为层**：`nc-动向` 增加一个可选入参 + 注册校验；`nc-校阅` 增加一个建议级检查项——两者均不改现有检查语义，无存量数据迁移。
- **不受影响**：`.json` 图森林真值结构（原型为 frontmatter 字段，不新增节点/边类型）、`.html` 图谱、其他 15+ 卡类型、提案制与审计只读铁律。
