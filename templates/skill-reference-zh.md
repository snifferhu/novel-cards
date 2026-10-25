# {{PROJECT_NAME}} · 技能备查总表（skill-reference）

> 本文件由 `nc-初始化`（--lang zh）生成，是**全量技能备查总表**。
> 工程模式：{{MODE}}（short / mid / long）。
> 作者可手动编辑本文件。新手主线流程见 `quickstart.md`；Agent 行为契约见 `agents.md`。
>
> **auto_invokable 列说明**：`true` = 该技能可被其他技能在流程内部自动唤起（作者仍可手动调用）；
> `false` = 仅作者主动触发，不会被系统后台自动拉起。本表是唯一对普通作者可见
> `auto_invokable` 属性的文档；底层配置见 `config/skills.yaml`。

## 六组技能全量总表（29 技能）

### A. 工程初始化 & 素材资产组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 1 | `nc-初始化` | `nc-init` | 新建创作工程骨架 + 三份引导文档 + config；`--lang zh/en`、长短篇预设 | false |
| 2 | `nc-素材` | `nc-material` | 原始素材收纳入库，入库前过通胀过滤器 gate | false |
| 3 | `nc-清洗` | `nc-clean` | 素材降噪预处理，生成独立干净副本，原始素材不动 | false |
| 4 | `nc-检索` | `nc-query` | 检索素材与全部卡片资产（含 `type:character_tendency`、按角色过滤） | false |
| 5 | `nc-注册` | `nc-reg` | 注册自定义卡片类型 / 动线 track 标签 / 动向人格基线原型（写入 registry 白名单） | false |
| 6 | `nc-更名` | `nc-rename` | 全局标识符替换（书名/代号），先预览后批量写入，不动 res/ 与口语称呼 | false |

### B. 叙事卡片建模组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 7 | `nc-角色` | `nc-role` | 新建/更新叙事行动单元（人/蛤蟆/器灵/抽象意志，不限于人类） | false |
| 8 | `nc-姿态` | `nc-pose` | 角色招牌动作库：内核固定 + 环境插槽 + 多视角模板 | false |
| 9 | `nc-道具` | `nc-item` | 新建/更新道具卡，黑盒自动拆分物理/感知/抽象三层动线 | false |
| 10 | `nc-场景` | `nc-scene` | 新建/更新场景卡片，记录环境基础参数 | false |
| 11 | `nc-感官标记` | `nc-sensorycue` | 创建/编辑感官标记卡（声音/乐曲/气味/光影氛围触发器），供桥段引用 | false |
| 12 | `nc-动向` | `nc-tendency` | 创建/编辑 `character_tendency`（`tend-`）角色动向滑动标尺，每次变动绑定桥段推手；可选声明人格基线原型 `baseline_prototype`（须经 nc-注册） | false |

### C. 剧情结构组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 13 | `nc-桥段` | `nc-plot` | 构思剧情单元、绑定角色/道具/pose、标记章节、标注战略爆点 | false |
| 14 | `nc-伏笔` | `nc-foreshadow` | 预埋长线伏笔、登记预期回收位置（长篇 ≥8 章四方对齐） | false |
| 15 | `nc-快照` | `nc-snapshot` | 时间锚点全局状态切片，定格多方角色/道具/势力状态 | false |
| 16 | `nc-势力` | `nc-faction` | 多方势力、立场、关系网络建模 | false |
| 17 | `nc-暗线` | `nc-thread` | 整条明面叙事的隐性逻辑链路（setting/plot/character/mixed） | false |
| 18 | `nc-积木` | `nc-module` | 积木编排：trigger_map 绑定动线/伏笔/pose，组装触发关系 | false |
| 19 | `nc-研判` | `nc-analyze` | 单点创作推演，出方案 A/B/C（只出建议报告，绝不改卡） | false |
| 20 | `nc-编排` | `nc-compose` | 批量剧情编排三段式（计划→审核→执行），前置 nc-校阅 扫冲突 | false |

### D. 生成与可视化组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 21 | `nc-量化` | `nc-metric` | 挂载张力/爆点/信息载荷量化指标，供深度打磨与批量统计 | true |
| 22 | `nc-图谱` | `nc-graph` | 渲染叙事森林时序图/角色关系/动线链路图/积木联动总图 | true |
| 23 | `nc-成稿` | `nc-draft` | 读全部卡片出正文初稿，`--length short/mid/long` 控篇幅（走提案制） | false |
| 24 | `nc-词频` | `nc-wordfreq` | 词频向量 + 感官均衡强约束校验（纯约束，不出正文），为成稿提供输入 | false |

### E. 审计校验组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 25 | `nc-校阅` | `nc-review` | 叙事审计：设定/pose/动线/伏笔/动机/OOC + 动向逻辑冲突（含原型边界漂移检查④；内置 nc-节奏） | false |
| 26 | `nc-节奏` | `nc-rhythm` | 章节桥段疏密/爆点密度/留白校验，战略爆点自动豁免 | true |
| 27 | `nc-守卫` | `nc-safetyguard` | 隐私 + 合规内容扫描，区分【渲染加害红线】/【揭露批判疑点】 | false |

### F. 归档导出 & 复盘组

| # | 中文 | 英文别名 | 简要职责 | auto_invokable |
|---|---|---|---|---|
| 28 | `nc-定稿` | `nc-finalize` | 生成工程快照归档、打锁定标记 | false |
| 29 | `nc-导出` | `nc-export` | Pandoc 跨平台导出 PDF / Word | false |
| 30 | `nc-复盘` | `nc-retrospect` | 沉淀经验、洞察，回流素材库，开启新一轮构思 | false |

> 注：`nc-对标`(nc-refwork) 是 v1.0 主体保留的**分析模式专用技能**（外部作品拆解学习，
> 独立 `tree_id` 隔离），服务于「拆解现成外部作品」流程，不计入面向用户的六组 29 技能分类，
> 在分析模式下按需手动触发。

## 每技能入参 / 产物备查

| 技能 | 典型入参 | 主要产物（相对使用方工程根） |
|---|---|---|
| `nc-初始化` | `--lang zh/en`、`--mode short/mid/long` | 工程骨架 + agents/quickstart/skill-reference 三文档 + config/project.yaml + config/skills.yaml + build 脚本 |
| `nc-素材` | 本地文件路径 / 纯文本 / 网页 URL | `res/inbox/` 封存 + `cards/corpus/co-*.md`（入库前过 gate） |
| `nc-清洗` | 目标素材 id | 独立干净副本（`res/` 派生），原始素材不动 |
| `nc-检索` | 关键词 + 类型/标签/来源/状态筛选 | 候选资产池（对话输出，不落盘） |
| `nc-注册` | 自定义类型名 / track 标签名 / 动向人格基线原型 key（含 boundary_hints） | `registry/` 白名单追加条目 |
| `nc-更名` | 旧标识符 → 新标识符 | 【替换预览清单】→ 确认后批量写入 + history 快照 + CHANGELOG + latest.md |
| `nc-角色` | 名字、分类标签、动机、首出场 | `cards/characters/ac-*.md`（type: actor） |
| `nc-姿态` | pose_tag、内核、插槽、多视角文案 | `cards/pose-bank/po-*.md` |
| `nc-道具` | 自然语言描述 | `cards/items/it-*.md`（黑盒三层自动拆解） |
| `nc-场景` | 地点、氛围、时段 | `cards/scenes/sc-*.md` |
| `nc-感官标记` | cue 类型、绑定对象 | `cards/custom/sensory_cue/su-*.md` |
| `nc-动向` | target_role(ac-)、dimension、baseline、direction_rule、history[]、baseline_prototype（可选，须经 nc-注册） | `cards/tendencies/tend-*.md`（type: character_tendency） |
| `nc-桥段` | 章节、涉及对象、是否战略爆点 | `cards/plotpoints/pp-*.md` |
| `nc-伏笔` | 埋点章节、计划回收章节 | `cards/foreshadow/fs-*.md` |
| `nc-快照` | 章节锚点、聚焦对象 | `cards/snapshots/sn-*.md` |
| `nc-势力` | 势力名、成员、领地、冲突 | `cards/factions/fa-*.md` |
| `nc-暗线` | 主题、层级、references_to_main | `cards/darklayer/dk-*.md` |
| `nc-积木` | 动作名、trigger_map 绑定的动线/伏笔/pose | `cards/modules/md-*.md` |
| `nc-研判` | 选定资产（可多个）+ 作者诉求 | 结构化分析报告 + 方案 A/B/C（不改任何卡片） |
| `nc-编排` | `--source` / `--reference` / `--prompt` / `--mode expand/rewrite/restructure` | compose_plan → 审核 → 前置 nc-校阅 → 顺序执行（记 CHANGELOG + latest.md）；计划存为素材 tag:compose-plan |
| `nc-量化` | 章节区间、指标维度 | `cards/metrics/mt-*.md` + `index/metric-index.json` 追加 |
| `nc-图谱` | 对象/主题 | `graph/*.html`（由 `index/card-graph.json` 重渲染） |
| `nc-成稿` | 章节/桥段 id + `--length short/mid/long` | `manuscript/chapter-*.md` 正文初稿（提案制） |
| `nc-词频` | 章节/桥段 id | `cards/lexstats/lx-*.md` 词频向量 + 感官均衡约束报告 |
| `nc-校阅` | 章节/范围 | `reflections/review-*.md` + `.json`（只出意见） |
| `nc-节奏` | 章节区间 | 节奏评估报告 + `reflections/rhythm-rt-*.json` |
| `nc-守卫` | （无，整体扫描） | `reflections/safety-check/sg-*.md` + `.json`（只告警） |
| `nc-定稿` | （无，整体操作） | `history/` 快照 + CHANGELOG 追加 + latest.md 更新 |
| `nc-导出` | 目标格式（pdf/docx） | `export/` 中间产物 + `release/` 成品 |
| `nc-复盘` | 章节 id | `reflections/rf-*.md`（五段结构） |
