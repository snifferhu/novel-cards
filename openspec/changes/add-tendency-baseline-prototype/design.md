# Design

## Context

`character_tendency`（`tend-`）是 v1.0 的角色性格滑动标尺卡：`dimension` 自定义维度、`baseline` 基线、`direction_rule` 长期趋势、`history[]` 每次变动绑定 `pp-*` 桥段推手。现行体系里没有任何字段能声明「这个角色带人格病理类稳定基线，某类维度的滑动有硬边界」——这类信息只能散落在 `notes` 自由文本里，`nc-校阅` 无法机器感知。`inbox/doubao-对话-2026-10-24.md` 提出了 NPD（自恋型人格）两类创作原型（浮夸型 / 脆弱型）与「共情维度不可自发拉高」式边界约束的需求意图；该对话对本仓库 schema 的描述系幻觉（`baseline_prototype` / 六轴等字段均不存在），本设计只吸收其意图，以 `references/card-schema.md` 真实字段契约为准。

约束（来自 AGENTS.md / 硬规则）：

- **注册前置**（硬规则 16）：自定义枚举类取值必须先经 `nc-注册` 写入使用方工程 `registry/` 白名单。
- **禁区**：本仓库 registry/config 模板只放骨架与占位，不写具体业务取值；`npd-*` 词表只能以文档示例形式出现。
- **审计只读**（硬规则 12）：`nc-校阅` 新检查只能出建议，不能阻断。
- **无 BREAKING**：字段可选，存量 tend- 卡零迁移。
- **spec 基线**：`openspec/specs/` 主 spec 目录当前为空（前一 change `restructure-v1-pipeline` 已完成未归档），本变更的 delta 全部使用 ADDED Requirements 增量表达，不依赖 MODIFIED 基线，与前一 change 的归档先后顺序无关。

## Goals / Non-Goals

**Goals:**

- 给 `character_tendency` 一个可选的、registry-backed 的人格基线原型声明字段 `baseline_prototype`，让「滑动边界」对 `nc-校阅` 可见。
- `nc-校阅` 新增建议级原型边界漂移检查（动向逻辑冲突检查项 ④），与现有检查 ② 同分级：提示风险而非禁止。
- `nc-动向` 接受该可选入参并执行注册前置校验。
- 使用方工程 `nc-初始化` 默认值提供 `registry/tendency-prototypes.yaml` 空骨架，`references/layout.md` registry 清单同步收录。

**Non-Goals:**

- 不把 NPD 等具体原型词表内置进 skill（词表归使用方工程 registry 所有，文档只给示例）。
- 不改 `dimension` / `baseline` / `direction_rule` / `history[]` 任何现有语义，不引入六轴等新维度体系。
- 不改 `.json` 图森林结构、`.html` 图谱、其他 15+ 卡类型。
- 不做原型的「临床诊断化」输出——本字段是创作参考锚点，`nc-守卫` 不涉及。
- 不强制同一角色全部维度共享原型声明（见决策 3）。

## Decisions

### D1: 字段落在 tend- 卡上（而非 actor 卡），可选、string、registry-backed 枚举

`baseline_prototype` 作为 `character_tendency` frontmatter 可选字段，取值 MUST 是使用方工程 `registry/tendency-prototypes.yaml` 中已注册的原型 key（未注册 → `nc-动向` 按硬规则 16 拦截，提示先走 `nc-注册`）。

**候选方案对比**：

- **actor 卡承载原型**（被拒）：原型确实是角色基线状态，放 actor 一处声明、多张 tend- 卡继承，无重复。但：① `nc-校阅` 处理每张 tend- 卡时必须强制 join actor 卡再查 registry，链路变长；② 会把该角色**全部**维度卷入原型检查，即使作者只想给一条受限维度打标；③ 改动面溢出到 actor requirement 与 `nc-角色` 入参，超出本次授权范围（用户明确授权「给 character_tendency 加字段」）。
- **tend- 卡承载**（采纳）：声明与被约束的标尺同卡，`nc-校阅` 单卡自包含处理；同一角色的不同维度卡可共享同一原型 key（registry 引用共享，重复声明成本≈一个短字符串），也可按需只给受限维度打标，甚至罕见场景下不同维度声明不同原型（如共情轴按 npd、冲动轴另建原型）。漂移风险（同角色多卡写了不同原型）由检查 ③ 与文档说明覆盖。

### D2: registry 条目结构与词表边界

`registry/tendency-prototypes.yaml` 每个原型条目：

```yaml
prototypes:
  npd-grandiose:            # key = baseline_prototype 取值
    label: 浮夸型自恋基线    # 显示名
    description: <一句话创作语义>
    boundary_hints:
      - dimension_keywords: [共情, empathy]   # 子串匹配 tend- 卡的 dimension 字段
        constrained_direction: higher         # higher=向轴高端漂移受限 / lower / both
        max_drift: 2                          # 相对 baseline 允许漂移绝对值，超过才提醒
        note: <提醒文案：共情不可自发拉高，表演性温柔不计入上调>
```

- `dimension_keywords` 子串匹配 `dimension`（如「共情↔冷漠」命中 `共情`）；命中多条 hints 时逐条检查。
- 本仓库 `references/layout.md` registry 清单与 `nc-初始化` 默认值只写上述**结构占位**（键名 + 注释 + `<...>` 占位符），不预置 `npd-*` 具体条目（install.sh --project 只建 registry/ 目录，registry yaml 骨架本就由 nc-初始化 填充）；具体词表以文档示例块出现在 `references/card-schema.md` / `templates/tendencies.md`（与现有 `tend-lead-restraint` 等示例同一处理方式）。

### D3: `nc-校阅` 检查 ④ = 建议级边界漂移提醒

在现有动向逻辑冲突检查 ①（引用桥段不存在）②（短期变化与长期趋势严重冲突）③（同维度多条矛盾规则）之后新增：

- **触发条件**：tend- 卡声明了 `baseline_prototype` 且该原型注册了 `boundary_hints`，且某 hint 的 `dimension_keywords` 命中该卡 `dimension`。
- **判定**：`|current_value - baseline|` 沿 `constrained_direction` 受限方向的漂移量 > `max_drift` → 输出提醒（含原型 `note` 文案与当前漂移量）。
- **分级**：与检查 ② 同级——**提示风险而非禁止**，作者可刻意写「受限维度缓慢松动」的反常弧光，提醒文案引导作者确认每次漂移的桥段推手是否支撑跨档变化。
- **未命中 / 未声明**：不检查、不报错；registry 文件缺失时该检查整体静默跳过（不阻断其他检查）。

### D4: `nc-动向` 入参扩展与注册前置

`nc-动向`(nc-tendency) 建卡/编辑入参新增可选 `baseline_prototype`：

- 提供但未注册 → 拦截，返回「先经 `nc-注册` 写入 registry/tendency-prototypes.yaml」提示（同 track 标签注册前置行为）。
- 不提供 → 与现行行为完全一致。
- `nc-检索` 过滤维度不扩展（如需按原型检索，作者可用关键词检索命中 registry label，不在本次范围）。

### D5: spec 表达策略 = 全 ADDED Requirements

四个能力域的 delta 全部用 `## ADDED Requirements` 追加新 requirement（跨引用既有 requirement 名），不使用 MODIFIED：字段可选、检查新增、入参新增、registry 文件新增，均为**增量关切**而非改写既有行为；且主 spec 目录为空时 ADDED 与前一 change 的归档顺序解耦。

## Risks / Trade-offs

- **关键词子串匹配过宽误报**（如 dimension「信任↔依赖」误命中无关 hint）→ 缓解：hints 与 `max_drift` 由作者在自己工程的 registry 里维护，检查为建议级，误报零阻断成本；文档引导 keywords 写具体（「共情」优于「情」）。
- **原型标签被误当临床诊断** → 缓解：字段说明与模板注释固定措辞「创作参考原型，非临床诊断」；不新增 `nc-守卫` 扫描维度。
- **同角色多张 tend- 卡原型声明不一致** → 缓解：同维度矛盾仍由检查 ③ 覆盖；跨维度不同原型属 D1 明示允许的建模自由，模板 notes 引导作者在角色 actor 卡正文备注整体人格基线。
- **registry 骨架与文档示例的边界被误读为「skill 内置词表」** → 缓解：安装骨架只含占位键，文档示例块统一标注「示例，需经 nc-注册 后方可使用」。
- **max_drift 默认值主观** → 实施时定稿为 2（容 ±2 格小步回弹不打扰），registry 条目可逐原型覆盖；如实践反馈噪音大再调。

## Migration Plan

无迁移。旧工程不建 `tendency-prototypes.yaml` 时：`nc-动向` 不传 `baseline_prototype` 走老路；`nc-校阅` 检查 ④ 静默跳过。回滚 = 删除字段声明与相关文档段，registry 文件可留存无害。

## Open Questions

（无阻塞项；`max_drift` 默认值 2 与 `constrained_direction` 枚举名在实施 review 时可微调，不影响契约结构。）
