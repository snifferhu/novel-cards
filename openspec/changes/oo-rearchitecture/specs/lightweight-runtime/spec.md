# Spec Delta: lightweight-runtime

## Purpose

定义一个**可选、零第三方依赖**的轻量运行时工具的边界契约：为 OO 模型提供 `NcObject.validate()` / `StoryWorld.audit()` 的可执行校验、`card-graph.json` 图森林结构校验，以及事件推演的纸面模拟。该工具只读 + 出报告，绝不替代提案制、绝不自动写盘；缺失时 skill 优雅降级为纯纸面约定且功能不降级。本能力是本仓库首次引入运行时，属边界变更，须以标准库/纯 shell 实现并锁死在 AGENTS.md 禁区。

## ADDED Requirements

### Requirement: 零第三方依赖与双端兼容

轻量运行时 MUST 仅使用目标平台自带的能力实现，MUST NOT 引入任何需要安装/下载的第三方包或构建步骤，以保持本仓库「无构建、无依赖」边界与 OpenCode + Claude Code 双端分发不被破坏。

#### Scenario: 依赖约束

- **WHEN** 实现运行时工具
- **THEN** MUST 仅用 Python 3 标准库（倾向单文件）或纯 POSIX shell 之一实现，MUST NOT `pip install` / `npm install` 任何第三方包
- **AND** MUST NOT 新增 `package.json` / `requirements.txt` / 锁文件 / 构建配置到本仓库
- **AND** 工具 MUST 在使用方工程根目录可直接运行（相对路径），不依赖绝对路径或 `$HOME`

#### Scenario: 缺失时优雅降级

- **WHEN** 使用方环境无法运行该工具（如无 Python 3 / 未随工程分发）
- **THEN** skill MUST 退回纯纸面约定（AI 按 references/ 规则人工执行 validate/audit/推演），功能 MUST NOT 因此不可用
- **AND** skill MUST 在检测到工具缺失时提示作者（如「未检测到 nc_validate，本次以纸面校验」），MUST NOT 静默失败或阻断流程

### Requirement: 只读校验与审计，绝不写盘

运行时工具 MUST 是只读的：读取卡片 frontmatter 与 `index/card-graph.json`，输出结构化校验/审计报告；MUST NOT 修改、创建或删除使用方工程的任何卡片/图谱/正文/索引文件。落地仍由提案制（AI 出草案、用户落盘）完成。

#### Scenario: validate 单对象自检

- **WHEN** 对某张卡调用 `validate`
- **THEN** 工具 MUST 检查：通用五字段齐全、type 与 id 前缀一致、各类型专属必填字段存在、伏笔 `payoff_chapter`/`status:unresolved` 二选一、动向 `history[]` 每条 `trigger_plot` 指向真实存在的 `pp-*` 桥段
- **AND** 输出 MUST 为只读报告（违规项列表 + 建议），MUST NOT 自动改写该卡

#### Scenario: audit 全局批量审计

- **WHEN** 调用 `StoryWorld.audit()` 等价的全局审计
- **THEN** 工具 MUST 跨对象检查：OOC（角色行为是否越出动向刻度/姿态约束）、暗线 `references_to_main` 单向引用合法性、长线四方对齐（fs-/tl-/md-/lx- 提前 ≥8 章预埋齐全）、图森林边引用的节点 id 均存在于注册表
- **AND** 输出 MUST 为只读意见书（对应 `nc-校阅` 产物形态），MUST NOT 自动改稿

#### Scenario: 图森林结构校验

- **WHEN** 校验 `index/card-graph.json`
- **THEN** 工具 MUST 验证：每个 node 含 `id`/`type`/`tree_id`、每条 edge 含 `source`/`target`/`relation` 且 relation 属于合法枚举、edge 引用的 source/target 均为已声明 node、同 tree 内连通性合理
- **AND** 发现悬空边/未知 relation/缺失节点时 MUST 报出具体位置，MUST NOT 尝试自动修复 json

### Requirement: 事件推演纸面模拟

运行时工具 MAY 提供事件推演的纸面模拟：读取当前对象状态，按 OO 方法契约计算一次事件的连锁影响，输出「哪些对象将如何变更」的预测报告。模拟 MUST 是只读的，产出供作者/AI 参考的 ChangePlan 草稿，MUST NOT 直接应用变更。

#### Scenario: 推演模拟输出

- **WHEN** 给定一个事件（如「ac-A enter sc-RoomX」）与当前世界状态
- **THEN** 工具 MUST 沿 `enter→perceive→act→fire` 链计算受影响对象及其候选新状态，输出一份 ChangePlan 草稿（逐项列明目标卡 + 前后差异）
- **AND** 该草稿 MUST 标注「模拟结果，待作者审核」，MUST NOT 写入任何文件
- **AND** 若工具不支持模拟（仅实现 validate/audit），skill MUST 由 AI 按 `references/event-inference.md` 约定人工完成同等推演，功能不降级

### Requirement: 工具定位与禁区登记

运行时工具 MUST 被明确定位为「辅助校验器」而非「叙事引擎」，并在本仓库开发约定中登记其边界，防止后续演变为可写盘、带依赖的重型运行时。

#### Scenario: AGENTS.md 禁区登记

- **WHEN** 本 change 落地
- **THEN** `AGENTS.md` 禁区清单 MUST 新增一条：`tools/` 仅限零第三方依赖的只读校验/审计/推演模拟器，MUST NOT 引入第三方包、MUST NOT 写使用方卡片/图谱/正文/索引、MUST NOT 替代提案制
- **AND** 工具入口 MUST 在 README / USAGE 中说明「可选、缺失可降级」，避免作者误以为必须安装才能使用 skill
