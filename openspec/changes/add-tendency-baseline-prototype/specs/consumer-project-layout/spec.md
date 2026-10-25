# Spec Delta

## Purpose

为使用方工程 `registry/` 白名单体系增补 `tendency-prototypes.yaml` 人格基线原型注册文件的骨架契约。本 delta 只追加增量关切，不改写既有 `工程目录结构` requirement 的现有 registry 文件清单语义。

## ADDED Requirements

### Requirement: registry/tendency-prototypes.yaml 原型白名单骨架

使用方工程 `registry/` SHALL 支持 `tendency-prototypes.yaml` 作为人格基线原型的静态白名单文件（经 `nc-注册` 写入或人工少量维护，同其他 registry yaml 的定位）：

- 文件骨架 SHALL 含顶层 `prototypes:` 清单；每个原型条目 SHALL 支持 `label`（显示名）、`description`（一句话创作语义）、`boundary_hints[]`（每条含 `dimension_keywords[]` / `constrained_direction`（`higher` / `lower` / `both`）/ `max_drift`（相对 baseline 的允许漂移绝对值）/ `note`（提醒文案））。
- `nc-初始化` SHALL 在 registry 默认配置中产出该文件的**结构占位骨架**（键名 + 注释 + `<...>` 占位符），MUST NOT 预置任何具体原型条目（如 `npd-*`）——具体词表由各使用方工程经 `nc-注册` 自行登记；`references/layout.md` 的 registry 文件清单 SHALL 收录该文件。（`install.sh --project` 只建 `registry/` 目录与 `.gitkeep`，registry yaml 骨架本就由 `nc-初始化` 填充，install.sh 无需改动。）
- 工程缺少该文件时：`nc-动向` 不带 `baseline_prototype` 入参照常工作；带了则按注册前置拦截；`nc-校阅` 检查 ④ 静默跳过。文件为增量可选，旧工程零迁移。

#### Scenario: 骨架生成只含占位

- **WHEN** 作者经 `nc-初始化` 生成 registry 默认配置
- **THEN** `registry/tendency-prototypes.yaml` 生成且仅含 `prototypes:` 结构占位与字段注释，不含任何具体原型 key

#### Scenario: 经 nc-注册 写入条目

- **WHEN** 作者经 `nc-注册` 登记一个新原型（含 label / description / boundary_hints）
- **THEN** 条目写入 `registry/tendency-prototypes.yaml` 的 `prototypes` 清单下，随后 `nc-动向` 可接受该 key 作为 `baseline_prototype` 取值
