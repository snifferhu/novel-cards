# Proposal

## Why

当前 v1.0 体系是**过程式流水线**心智：作者按顺序调用 `nc-素材 → nc-清洗 → nc-桥段 → …`，每个技能是游离的独立函数，叙事资产（角色/道具/场景/桥段…）只是被这些函数读写的被动数据。这导致三类痛点：① 改一处剧情要人肉追踪它牵动的角色动向、伏笔、感官 cue，极易 OOC / 前后矛盾；② 「文字」被当成真相本身，改剧情 = 改字符串，下次渲染无法自动保持人设/道具/感官一致；③ 29 个技能平铺在作者脑中是一团「函数列表」，缺乏统一的「世界容器 + 对象自带行为」心智模型。

用**面向对象（OO）**思想重构可根治：把全部叙事资产建模为**对象**（`NcObject` 基类 + 子类），把技能建模为**对象的方法**，把流程建模为**对象间发消息、调用方法**，把校验/约束建模为**类的属性/断言/钩子**；写作产出不再是逐字拼接字符串，而是**对象实例演化、状态流转之后渲染序列化出的文本**。文字退化为「视图」，真相收敛到对象实例里——改剧情本质是修改对象状态，而非修改文本。

## What Changes

- **新增 OO 概念模型文档**（`references/oo-model.md`）：定义根抽象类 `NcObject`（统一 `id`/`name`/`tags`/`status`/`created`/`updated` 公共属性 + `render()`/`validate()`/`snapshot()`/`patch()` 公共方法）、8 个核心业务子类（`Role`/`Prop`/`Scene`/`SensoryCue`/`PlotBeat`/`StoryTrack`/`DarkLine`/`Snapshot`）及全局容器 `StoryWorld`（对象注册表 + timeline + inbox + config + safety_guard）。
- **技能 → 方法映射**：29 个 `nc-` 技能重新表述为 `StoryWorld` 或对应子类的成员方法（如 `nc-编排`→`StoryWorld.plan_modify()`、`nc-研判`→`StoryWorld.deliberate()`、`nc-校阅`→`NcObject.validate()`+`StoryWorld.audit()`、`nc-成稿`→`StoryWorld.export()` 的 render 阶段）。技能集合与六组分类**不变**，仅换 OO 视角表述。
- **命名对齐**：草稿中的新命名显式映射回现有 schema，不破坏已定稿字段——`uuid`→`id`（含类型前缀）、`disposition_slide:Track`→`character_tendency`(`tend-`)卡、`pose_bank[]`→独立 `pose`(`po-`)卡经 `pose_refs` 引用、`MoodLine`→无 v1.0 对应（映射到 `lexstat` 张力曲线 + `metric` 量化，标注为概念别名）。
- **事件驱动推演流程**：新增「世界对象演化 → 渲染」流程约定（`dispatch_event → enter/perceive/act/fire → ChangePlan 汇总 → 作者审核 → patch → render`），作为 `nc-研判`/`nc-编排` 既有三段式（计划→审核→执行）的 OO 化表述。
- **引入轻量运行时**：**BREAKING（边界变更）**——突破本仓库既有「无构建、无依赖、无运行时」铁律（v1.0 design D1 明确拒绝运行时）。新增一个**可选、零第三方依赖**的轻量运行时工具（倾向 Python 3 标准库单文件，或纯 shell），提供：`card-graph.json` 结构校验、`NcObject.validate()` 跨对象一致性检查（OOC/动向逻辑冲突/伏笔四方对齐）、`StoryWorld.audit()` 批量审计、以及事件推演的**纸面模拟**（读取卡片状态 → 输出连锁影响报告，不自动写盘）。该工具**只读 + 出报告**，绝不替代提案制（AI 仍出草案、用户落盘）；缺失时 skill 退回纯纸面约定，功能不降级。
- **现有文档 OO 化重构**：将 `references/card-schema.md` / `loop.md` / `agents-guide.md` / `skill-catalog.md` 及 `SKILL.md` body 的措辞以「对象 / 方法 / 消息 / 状态流转 / 渲染」语言重新表述；字段契约、技能集合、六组分类、硬规则编号**保持不变**，仅换表述框架并补 OO 交叉引用。
- **篇幅自适应**：`StoryWorld.config.mode`（short/mid/long）控制哪些子类方法启用（短篇禁用 `DarkLine`/长期 `disposition_slide` 轨道，长篇全开），与既有 `registry/work-length-config.yaml` 分级矩阵对齐。

## Capabilities

### New Capabilities

- `oo-model`: 面向对象概念模型——`NcObject` 抽象基类（公共属性 + `render`/`validate`/`snapshot`/`patch` 方法契约）、8 个业务子类的属性与方法签名、`StoryWorld` 容器（注册表/timeline/inbox/config/safety_guard）、技能→方法映射表、草稿新命名→现有 schema 的对齐规则。
- `event-driven-inference`: 事件驱动剧情推演流程——`dispatch_event` 派发、`enter`/`perceive`/`act`/`fire` 连锁调用、`ChangePlan` 汇总（绝不直接写对象）、作者审核、`patch` 批量落地、`render` 渲染序列化为正文；冲突处理（保留旧实例/覆盖/合并三选一，决定权归作者）；长短篇模式对方法集的门控。
- `lightweight-runtime`: 可选轻量运行时工具的边界契约——零第三方依赖、只读 + 出报告、提供 `validate`/`audit`/图森林结构校验/事件推演纸面模拟；缺失时 skill 优雅降级为纯纸面约定；绝不替代提案制、绝不自动写盘。

### Modified Capabilities

<!-- 无：本项目尚无已归档的主 spec（openspec/specs/ 为空，restructure-v1-pipeline 未 sync）。
     v1.0 的 card-schema / pipeline-flows / skill-catalog 等能力在本 change 中以「新增 OO 视角
     能力 + 文档措辞重构」承载，不改动其既有 requirement 语义（字段/技能/分组/硬规则均不变）。 -->

（空）

## Impact

- **新增文件**：`references/oo-model.md`（OO 概念模型 + 类图骨架 + 方法映射表）、`references/event-inference.md`（事件推演流程约定）、`tools/`（轻量运行时，倾向单文件 `tools/nc_validate.py` 或等价，零依赖）、`templates/` 可能新增 OO 视角示例片段（假名占位）。
- **改写文件**：`references/card-schema.md` / `loop.md` / `agents-guide.md` / `skill-catalog.md` / `data-layering.md`（补 OO 交叉引用与「对象=节点、方法=技能」表述）、`SKILL.md` body（速查表/路由/流程概览补 OO 视角，frontmatter 三键不动）、`README.md`（补 OO 心智模型章节）、`install.sh`（`--project` 骨架视需要纳入 `tools/` 分发说明）。
- **边界变更**：首次引入运行时工具，需在 `AGENTS.md` 禁区清单中显式登记「`tools/` 仅限零依赖只读校验器，不得引入第三方包 / 不得写使用方卡片」。
- **不受影响**：29 技能集合、六组分类、`auto_invokable` 三项标记、四层数据分层（md/json/yaml/html）、frontmatter 三键铁律、提案制协作模式、双端兼容（OpenCode + Claude Code）。
- **风险**：运行时工具若引入第三方依赖即破坏双端分发与「无构建」边界——必须以标准库/纯 shell 实现并在 AGENTS.md 锁死；若工具在某环境不可用，skill MUST 退回纸面约定且功能不降级。
