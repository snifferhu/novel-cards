# Spec Delta

## Purpose

定义 novel-cards 体系的四层数据分层铁律（md / json / yaml / html）：各层的职责边界、可读可写规则、`card-graph.json` 图森林标准 schema（节点 + 边 + tree_id）、registry yaml 配置约定，以及 html 视图由 json 重生成的投影规则。

## ADDED Requirements

### Requirement: 四层数据分层职责

系统 MUST 遵守以下分层铁律：

| 文件类型 | 底层数据结构 | 主要位置 | 核心定位 | 能否改逻辑 |
|---|---|---|---|---|
| `.md` | 文档（内嵌 yaml frontmatter） | `cards/**`、`reflections`、`manuscript` | 人类主编辑载体：卡片、积木、指标、反思、正文、摘抄 | ✅ 直接改，业务源头 |
| `.json` | 扁平数组 / 图（Graph/森林 Forest，节点+边） | `index/`、`graph/export` | 机器索引、关系模型、数值索引：检索索引、卡片关系森林、metric 数值、词频向量 | ✅ 系统同步生成，优先经 nc- 指令改动 |
| `.yaml` | 配置树 | `registry/` | 注册表：类型、track、标签白名单，偏静态配置 | ✅ 人工少量维护 |
| `.html` | 渲染视图（消费 json 图数据） | `graph/` | 可视化看板、关系图谱、时序图，纯展示层 | ❌ 不存业务逻辑；json 一变，html 重生成 |

#### Scenario: 修改卡片后同步
- **WHEN** 作者直接编辑了某张 md 卡片
- **THEN** 下次执行相关 nc- 指令时，skill 检测 md 与 json 不一致并提案重新生成对应 `index/card-graph.json` 条目

#### Scenario: html 不存逻辑
- **WHEN** `index/card-graph.json` 更新后
- **THEN** `nc-图谱` 重新渲染 `graph/*.html`，旧 html 被覆盖，html 文件中不含任何独立于 json 的业务数据

### Requirement: card-graph.json 图森林 schema

`index/card-graph.json` SHALL 采用图森林结构：单一 JSON 文件内含多个互不连通的子图（tree），每个节点 MUST 含 `id`（卡 id）、`type`（卡类型）、`tree_id`（归属子图标记）；每条边 MUST 含 `source` / `target` / `relation`（关系类型，如 `bind_module` / `trigger` / `cross_ref` / `foreshadow_plant` / `references_to_main`）。单主线小说为单图（全部卡片连通）；多独立动线/势力链/对标作品相互隔离时为森林（多子图）。

#### Scenario: 多作品对标隔离
- **WHEN** 工程内同时存在原创主线与两部对标拆解作品
- **THEN** `card-graph.json` 含三个子图，分别以不同 `tree_id` 标记，跨子图无边连接

#### Scenario: 最小 demo
- **WHEN** 仅建了入场积木那套资产（ac-female-lead、tl-hairstyle、md-action-entry、fs-hairpin、lx-ch03）
- **THEN** `card-graph.json` 呈现单 tree，节点间通过 bind_module / trigger / foreshadow_plant 边连通

### Requirement: registry yaml 约定

`registry/` 目录 SHALL 包含以下配置文件：`work-length-config.yaml`（长短篇模式与技能启用矩阵）、`work-setting.yaml`（pipeline_option 分支开关：enable_review / enable_finalize / enable_safety_guard）、`safety-blacklist.yaml`（守卫用强制合规禁区 + 作者自定义隐私禁区）、以及类型/track/标签/burst-tag 白名单注册文件。registry 为偏静态配置，人工少量维护；新增自定义卡片类型或动线标签 MUST 先经 `nc-注册` 写入 registry 再建卡。

#### Scenario: 注册自定义 track
- **WHEN** 作者需要一条「温度场」自定义感知动线
- **THEN** 先执行 `nc-注册` 将 `temperature-field` 加入 track 白名单 registry，之后 timeline 卡才能使用该 track 值

### Requirement: index 目录产物清单

`index/` 目录 SHALL 包含：`card-graph.json`（图森林真值）、`metric-index.json`（量化数值索引）、`lex-batch.json`（词频向量批量统计）、检索索引与 query-cache。这些文件由 skill 指令驱动生成/更新，是后续批量统计分析（伏笔回收周期/爆点密度/五感信息释放节奏）与导出外部工具（思维导图/时序/数据库）的数据源。

#### Scenario: 批量统计
- **WHEN** 作者要求统计全书伏笔回收周期分布
- **THEN** skill 读取 `index/metric-index.json` + `index/card-graph.json` 中的 foreshadow 边计算，不重新解析全部 md 文件

### Requirement: 迁移与备份友好

整个使用方工程目录 MUST 可直接同步/备份/换机：md 可读、json 可解析、yaml 可校验，资产不锁死在任何私有二进制格式。

#### Scenario: 换机迁移
- **WHEN** 作者把整个工程目录复制到新机器
- **THEN** 所有资产可用，无需重新导入或转换格式
