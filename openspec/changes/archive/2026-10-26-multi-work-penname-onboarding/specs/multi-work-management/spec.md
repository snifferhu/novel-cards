# Spec Delta

## Purpose

定义同一使用方工程内多本作品的组织、调度与署名契约：`works/` 工作区结构、`config/project.yaml` 的 `works[]` 作品清单、`nc-初始化` 新书分支、`nc-*` 技能的 `--work` 作用域参数、跨书检索，以及基于 `registry/pen-names.yaml` 的多笔名署名管理。

## ADDED Requirements

### Requirement: 一个使用方工程 MUST 能容纳多本独立作品

使用方工程 SHALL 以「工作区（workspace）」为顶层单位组织多本作品：每本书是 `works/<work-id>/` 下的独立子空间，拥有各自独立的 `cards/` / `manuscript/` / `index/` / `graph/` / `registry/` 命名空间与独立 `tree_id` 族，彼此数据隔离、互不串卡。

#### Scenario: 同工程新建第二本书
- **WHEN** 作者在一个已含作品 A 的工程内执行 `nc-初始化 --new-work`（或自然语言「在这个项目里再开一本」）
- **THEN** 系统在 `works/<新work-id>/` 下生成该书的完整骨架（cards/manuscript/index/graph/registry + 该书自己的 `config` 片段），并把新条目追加进 `config/project.yaml` 的 `works[]`；作品 A 的既有卡片 / 图森林 / 配置零改动

#### Scenario: 单本工程向后兼容
- **WHEN** 存量工程的 `config/project.yaml` 不含 `works[]` 字段
- **THEN** 系统 MUST 将其视为隐式单本工作区（唯一 work-id = 工程根），全部 `nc-*` 技能行为与引入本能力前完全一致；MUST NOT 因缺 `works[]` 报错或强制迁移

### Requirement: config/project.yaml MUST 承载作品清单 works[]

`config/project.yaml` SHALL 在保留既有工程级字段（`lang` / `mode` / `pipeline_option`）的基础上，新增可选 `works[]` 数组；每个元素含 `id`（work-id，全局唯一）、`title`（书名）、`mode`（short/mid/long，可覆写工程默认）、`lang`、`default_pen_name`（指向 `registry/pen-names.yaml` 的笔名 key，可选）、`tree_id_root`（该书图森林子树根标记）。

#### Scenario: works[] 条目字段齐全
- **WHEN** `nc-初始化 --new-work` 完成
- **THEN** 追加的 `works[]` 条目 MUST 至少含 `id` / `title` / `mode` / `tree_id_root`；`default_pen_name` 若声明 MUST 指向已在 `registry/pen-names.yaml` 注册的笔名 key，未注册则拦截提示先走 `nc-注册`

#### Scenario: 工程级默认值兜底
- **WHEN** 某 `works[]` 条目未显式声明 `mode` / `lang`
- **THEN** 回落到 `config/project.yaml` 顶层的 `mode` / `lang` 工程默认值；MUST NOT 因单书缺省而中断

### Requirement: nc-* 技能 MUST 支持 --work 作用域参数

全部 `nc-*` 创作 / 审计 / 导出技能 SHALL 接受可选 `--work <work-id>` 参数，把操作限定在指定作品子空间内；缺省时作用于「当前默认书」。当前默认书的确定规则 MUST 明确且可预测。

#### Scenario: 显式指定作用域
- **WHEN** 作者执行 `nc-角色 --work book-b "新建角色 …"`
- **THEN** 技能 MUST 只在 `works/book-b/` 子空间内读写，绝不触碰其他作品的卡片 / 图森林

#### Scenario: 缺省作用域的确定性
- **WHEN** 多本工程中作者执行不带 `--work` 的技能
- **THEN** 系统 MUST 按明确规则选定默认书（如 `config/project.yaml` 的 `active_work` 指针，或最近一次 `--work` 指定的书），并在输出中标注「正在操作的书 = <work-id>」；MUST NOT 在多书歧义时静默猜测到错误的书——若无法确定唯一默认书，MUST 提示作者用 `--work` 显式指定

#### Scenario: 单本工程缺省即唯一书
- **WHEN** 工程仅有一本书（含隐式单本）
- **THEN** 缺省 `--work` 无歧义，直接作用于该书，无需标注也不需作者干预

### Requirement: 跨书检索与总览 MUST 可用

`nc-检索` SHALL 支持跨全部作品的资产检索（返回结果带 `work-id` 归属标签），并支持「列出本工程所有作品及其状态」的总览查询。

#### Scenario: 跨书检索
- **WHEN** 作者执行 `nc-检索 --all-works "关键词"`
- **THEN** 返回命中候选 MUST 每条标注所属 `work-id` 与书名，便于作者判断命中落在哪本书

#### Scenario: 作品总览
- **WHEN** 作者请求「看看这个项目有哪些书」
- **THEN** 系统 MUST 列出 `works[]` 全部条目（work-id / title / mode / 默认笔名 / 卡片数量概览），不展开任何单书正文

### Requirement: 多笔名署名 MUST 经 registry 白名单管理

作者 MAY 拥有多个笔名；笔名 SHALL 作为 registry-backed 枚举存于使用方工程 `registry/pen-names.yaml`（骨架 only，经 `nc-注册` 写入具体条目，skill 不内置锁死词表）。每本作品声明 `default_pen_name`，单章 / 单卡可覆写；`nc-导出` 出成品时按生效笔名落署名，`nc-成稿` 提案头部标注署名。

#### Scenario: 注册笔名后为作品指定默认署名
- **WHEN** 作者先 `nc-注册` 登记笔名 `夜行客`（key `pen-yexingke`），再为作品 B 设 `default_pen_name: pen-yexingke`
- **THEN** 作品 B 的 `nc-导出` 成品署名 MUST 为「夜行客」；`nc-成稿` 提案头部 MUST 标注该署名

#### Scenario: 章节级覆写默认笔名
- **WHEN** 作品 B 默认笔名为 `夜行客`，但某一章作者指定用另一已注册笔名 `pen-mingyue`
- **THEN** 该章导出 / 成稿署名 MUST 为 `明月`，其余章节仍用默认 `夜行客`

#### Scenario: 未注册笔名被拦截
- **WHEN** 作者尝试把 `default_pen_name` 设为未在 `registry/pen-names.yaml` 注册的 key
- **THEN** 系统 MUST 拦截并提示先走 `nc-注册`（沿用硬规则「注册前置」），MUST NOT 静默接受未注册取值

#### Scenario: 无笔名声明的存量作品
- **WHEN** 作品未声明 `default_pen_name` 且 `registry/pen-names.yaml` 缺失或为空
- **THEN** 导出 / 成稿署名留空或回落到工程级作者名（若有），MUST NOT 报错；存量单本工程行为不变
