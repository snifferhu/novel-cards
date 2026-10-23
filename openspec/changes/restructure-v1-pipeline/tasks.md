# Tasks

## 1. references/ 规范文档（能力契约层）

- [x] 1.1 新建 `references/skill-catalog.md`：24 技能四类分组清单、双语别名映射表（Markdown 表格 + JSON 代码块）、每技能职责/入参/产物约定、旧 12 触发词→新 24 技能对照表；验证：文件含全部 24 个中文+英文别名且双向可查
- [x] 1.2 重写 `references/card-schema.md`：通用五字段 + actor（非人类分类标签）/ item（黑盒三层 + 五感公理）/ pose（插槽三级优先级）/ module（trigger_map）/ timeline（bind_module）/ lexstat / corpus / metric / sensory_cue / refwork / snapshot / foreshadow / scene / faction / darklayer 全类型 frontmatter 字段定义与最小示例；验证：每个类型的必备专属字段与 specs/card-schema 的 requirement 一一对应，无遗漏
- [x] 1.3 新建 `references/data-layering.md`：md/json/yaml/html 四层铁律表、`card-graph.json` 图森林 schema（节点 id/type/tree_id，边 source/target/relation，relation 枚举）、registry yaml 文件清单与结构约定、index/ 产物清单、html 重生成规则；验证：含一个最小 demo JSON 示例（入场积木那套资产），可被任意 JSON 解析器解析
- [x] 1.4 新建 `references/compliance.md`：robots.txt 校验链路（fail-closed 原则）、四套中英文提示文案原文、版权提醒、工具定位声明全文；验证：四套文案中英各一份齐全，链路图与 specs/material-compliance 一致
- [x] 1.5 新建 `references/agents-guide.md`：agents.md 四块内容说明、意图匹配表、显式指令优先规则、可编辑性声明、双语模板引用；验证：意图匹配表覆盖 specs/agent-guidance 列出的全部 10 类意图
- [x] 1.6 重写 `references/loop.md`：三场景流程（原创/对标/纯素材）编排图、长短篇分级过滤矩阵、写稿→审稿→修稿→定稿分支开关说明；验证：三场景的技能顺序与 specs/pipeline-flows 逐节点一致
- [x] 1.7 重写 `references/hard-rules.md`：保留原 10 条中仍有效的（提案制/伏笔合法/暗线隔离/五字段/双端兼容/闭环反哺），追加 v1.0 新硬规则（跨动线联动必须走 module、长线四方对齐 ≥8 章、词频强约束留白、多视角视图只写在 module、审计技能只出意见不改稿、素材合规 fail-closed）；验证：每条规则可在 specs 中找到对应 requirement
- [x] 1.8 更新 `references/layout.md`：使用方工程新目录树、install.sh 与 nc-初始化 双入口边界、registry/index/res/history/release/export/config 各目录职责；验证：目录树与 specs/consumer-project-layout 完全一致
- [x] 1.9 保留并微调 `references/filter.md`：标注三问现为 nc-素材 入库前自动 gate，同时保留手动 `nc-过滤` 复检入口；验证：Q3 否决项表述不变

## 2. templates/ 模板体系

- [x] 2.1 新增 `templates/corpus.md`（co-）、`templates/lexstats.md`（lx-）、`templates/modules.md`（md-）、`templates/metrics.md`（mt-）、`templates/pose-bank.md`（po-）、`templates/sensory-cues.md`、`templates/refworks.md` 七套新模板；验证：每套模板 frontmatter 含五字段 + 该类型全部专属字段，与 card-schema.md 字段名逐字一致
- [x] 2.2 改造 `templates/characters.md` → actor 语义：type 改 `actor`、id 前缀示例改 `ac-`、增加分类标签字段（protagonist/supporting/extra/creature/object-spirit/force/phantom）与 cross_ref 字段；文件名保持 characters.md（目录名未变）；验证：模板示例卡的 type/id 为 actor/ac-
- [x] 2.3 改造 `templates/items.md`：增加黑盒三层分区（物理/感知/抽象）注释结构与高级模式开关说明、五感子标签示例（灵识=触觉回声定位型等）；验证：三层字段齐全，感知 track 根均为五感之一
- [x] 2.4 改造 `templates/timeline.md`：nodes 结构升级为含 node_id / bind_module / trigger_foreshadow / 爆点标注；track 枚举补充「已注册自定义类型」说明；验证：示例节点含 bind_module 字段
- [x] 2.5 改造 `templates/plotpoints.md`：增加 lexstat_bind / module_list / pose 引用 / strategic-burst 标注字段；验证：示例卡含全部新增字段
- [x] 2.6 改造 `templates/snapshots.md`：明确「时间锚点状态切片」定义（非姿势库），增加 used_pose 引用字段与多方状态定格示例；验证：模板正文含与 timeline 的区别说明
- [x] 2.7 新增 `templates/agents-zh.md` 与 `templates/agents-en.md`：四块结构（身份/铁律/意图匹配/技能速览）完整双语模板，含占位符（{{PROJECT_NAME}}/{{MODE}}/{{ENABLED_SKILLS}}）；验证：两模板节结构一一对应，占位符集合一致
- [x] 2.8 更新 `templates/relation-graph.html`：支持积木联动总图渲染（中心 md 模块节点 → 多 tl 分支 → fs/dk/lx 外圈），保留自包含无外部依赖约束；验证：HTML 在浏览器打开可显示三类层级节点，无外部资源请求
- [x] 2.9 检查其余模板（scenes/foreshadow/factions/darklayer/reflections）字段与新 schema 的一致性，必要时补 cross_ref / tree 归属注释；验证：全部 15+ 模板通过五字段自检

## 3. SKILL.md 重写（skill 入口）

- [x] 3.1 重写 SKILL.md body：frontmatter 仅 name/description/license 三键（description 更新为覆盖 24 技能 + 双语触发 + 新自然语言触发词）；body 含技能速查总表（24 行）、硬规则摘要、路由规则（nc-xxx → 读哪个 reference）、三场景流程概览、合规声明小节；验证：用 YAML 解析器 dump frontmatter 确认仅三键；body 不超 ~10KB（细则均在 references/）
- [x] 3.2 SKILL.md 触发词表同步：12 旧前缀 → 24 新前缀（含英文别名列），标注 nc-人物→nc-角色 更名与 nc-过滤 并入 gate 的变化；验证：表中 24 个中文前缀与 skill-catalog.md 映射表零差异

## 4. install.sh 升级

- [x] 4.1 升级 `--project` 骨架：mkdir 列表扩展为新目录全集（cards/ 下 15 个子目录含 corpus/metrics/modules/pose-bank/lexstats/custom、registry/、index/、res/inbox/、history/、release/、export/、config/、graph/、manuscript/、reflections/、drafts/practice/），写入默认 `config/project.yaml`（lang: zh, mode: short 占位）与中文版 agents.md 兜底、build.sh/build.cmd 骨架、README/CHANGELOG/latest.md 占位；验证：对临时目录执行后 `find` 输出与 consumer-project-layout spec 目录树逐目录一致
- [x] 4.2 幂等性检查：对已存在部分目录的工程重复执行 `--project` 不报错不覆盖已有文件（mkdir -p + 仅当文件不存在时写入）；验证：连续执行两次，第二次零变更（git status 干净或 diff 为空）
- [x] 4.3 一致性核对：install.sh 目录列表 vs references/layout.md 目录树 vs specs/consumer-project-layout 三处逐一比对（已补 templates/ 与 config/safety-blacklist.yaml 对齐 spec）；验证：三者目录集合完全相同

## 5. README.md / USAGE.md 重写

- [x] 5.1 重写 README.md：项目定位（v1.0 创作辅助体系）、目录结构（本仓库）、24 技能速览表、15+ 卡类型速览表、四层数据分层示意、安装方式不变、合规声明小节；验证：技能表/卡型表与 skill-catalog.md、card-schema.md 零差异
- [x] 5.2 重写 USAGE.md：日常使用（三场景操作路径）、FAQ、**v0→v1 迁移章节置顶**（sed 替换命令：type character→actor、id ch-→ac-；目录补齐；触发词对照表）、回滚说明；验证：按迁移章节命令在一个模拟旧工程上执行后可被新 skill 正常读取
- [x] 5.3 AGENTS.md（本仓库开发约定）更新：九类卡→15+ 类表述、禁区清单补充（不生成 json/yaml 真实数据文件、registry 模板只放骨架）、自检清单扩充（24 技能一致性、双语模板对应、四层分层表述一致）；验证：自检清单每项可在本仓库找到对应检查对象

## 6. 集成验证

- [x] 6.1 frontmatter 三键验证：YAML 解析 SKILL.md 头部仅 name/description/license；Claude Code 侧描述可读（人工确认面板可见）
- [x] 6.2 全量交叉一致性扫描：grep 检查全仓库无 `ch-` 前缀残留（迁移说明中的旧值引用除外）、无 `nc-人物` 作为现行触发词的表述（对照表/迁移语境除外）、12 旧触发词在正文中只出现于对照表
- [x] 6.3 端到端演练（纸面）：以「女主进门名场面」为例，按 specs 走一遍 nc-素材→nc-桥段→nc-积木→nc-词频→nc-图谱 的指令路由，确认每步指向的 reference/模板文件都存在且字段对得上
- [x] 6.4 `openspec validate --change restructure-v1-pipeline` 通过；运行 `./install.sh --project /tmp/nc-test-$$` 冒烟通过后清理临时目录

## 7. 2026-10-23 追加需求落地（四新技能 + auto_invokable 标记 + 六组分类 + 文档三分拆）

来源：`inbox/doubao-对话-2026-10-23.md`。本组在 v1.0 主体（第 1–6 组）基础上继续扩展，全部走提案制，不引入运行时脚本。

### 7A. references/ 同步

- [x] 7.1 更新 `references/skill-catalog.md`：技能数 25→29；新增 `nc-动向`(nc-tendency)/`nc-研判`(nc-analyze)/`nc-编排`(nc-compose)/`nc-更名`(nc-rename) 四行到对应分组；把「四类分组」改写为「六组用户可见分类」（A 工程初始化&素材资产 / B 叙事卡片建模 / C 剧情结构 / D 生成与可视化 / E 审计校验 / F 归档导出&复盘），并保留原四组流水线视角的映射说明；双语别名映射 JSON 增补四条双向映射；每技能入参/产物表增补四行（含 nc-编排 的 `--source/--reference/--prompt/--mode` 与 compose_plan 产物、nc-更名 的预览清单产物）；新增 `auto_invokable` 列（true: nc-量化/nc-图谱/nc-节奏，其余 false）；验证：29 个中文+英文别名双向可查，六组分类覆盖全部 29 技能无遗漏
- [x] 7.2 更新 `references/card-schema.md`：新增 `character_tendency`（tend-）类型 frontmatter 字段定义（target_role/dimension/baseline/direction_rule/current_value/history[]/notes）与最小示例卡；目录标注 `cards/tendencies/`；验证：字段名与 specs/card-schema 的 character_tendency requirement 逐字一致
- [x] 7.3 更新 `references/agents-guide.md`：意图匹配表增补四行（角色性格逐步变化→nc-动向；推演拿方案→nc-研判；批量迭代故事线→nc-编排；改书名/全局代号→nc-更名；内容修改→本体技能）；新增「文档三分拆」小节（quickstart/skill-reference/agents 各自定位）与「流程向导模式」「auto_invokable 对用户透明」规则；验证：意图表覆盖 specs/agent-guidance 全部意图含新增四项
- [x] 7.4 更新 `references/loop.md`：三场景流程图中 weave 进 nc-研判（单点推演分支）与 nc-编排（批量三段式分支）；长短篇分级矩阵增补两行（short/mid 默认不主动推荐研判/编排，long 全开）；新增「角色动向弧光随桥段推进」链路说明；验证：流程图节点与 specs/pipeline-flows 一致
- [x] 7.5 更新 `references/hard-rules.md`：追加硬规则——「研判/编排只出建议与计划，绝不静默改卡」（并入审计类只读铁律的延伸）、「更名先预览后替换且不动 res/ 原始素材与正文口语称呼」、「动向每次变动必须绑定已存在桥段」；验证：每条可在 specs 找到对应 requirement
- [x] 7.6 更新 `references/layout.md`：使用方工程目录树增补 `cards/tendencies/`、`config/skills.yaml`、`quickstart.md`、`skill-reference.md`；验证：目录树与 specs/consumer-project-layout 完全一致

### 7B. templates/ 新增

- [x] 7.7 新增 `templates/tendencies.md`（tend-）：frontmatter 含五字段 + target_role/dimension/baseline/direction_rule/current_value/history[]/notes，附「克制↔放荡」最小示例卡；验证：通过五字段自检，history[] 结构含 value/trigger_plot/description
- [x] 7.8 新增 `templates/quickstart-zh.md` 与 `templates/quickstart-en.md`：新手主线最简流程（6 步）+ 进阶扩展分组，隐藏 auto_invokable 标记，占位符 {{PROJECT_NAME}}/{{MODE}}；验证：中英两模板节结构一一对应
- [x] 7.9 新增 `templates/skill-reference-zh.md` 与 `templates/skill-reference-en.md`：29 技能全量总表（带 auto_invokable 列 + 六组分组）+ 每技能入参/产物备查；验证：总表 29 行与 skill-catalog.md 零差异
- [x] 7.10 更新 `templates/agents-zh.md` / `templates/agents-en.md`：第四块「技能速查」从平铺改为六组折叠结构；意图匹配表增补四项；新增流程向导模式说明；验证：占位符集合与 quickstart/skill-reference 模板一致

### 7C. SKILL.md / README / USAGE / AGENTS 同步

- [x] 7.11 更新 `SKILL.md` body：description 触发词增补 nc-动向/nc-研判/nc-编排/nc-更名 及自然语言触发短语；技能速查总表 25→29 行并按六组重排；路由规则增补四行（nc-动向→card-schema+tendencies 模板、nc-研判/nc-编排→pipeline-flows、nc-更名→hard-rules 更名规则）；frontmatter 仍仅 name/description/license 三键；验证：YAML dump 确认三键，body 速查表 29 行
- [x] 7.12 更新 `README.md`：技能速览 25→29（六组）、卡类型表增补 character_tendency(tend-) 行、目录结构增补 cards/tendencies/ + config/skills.yaml + quickstart.md + skill-reference.md、硬规则速览增补 3 条；验证：与 skill-catalog.md / card-schema.md 零差异
- [x] 7.13 更新 `USAGE.md`：FAQ 增补「性格怎么记」「想批量改剧情怎么办」「改书名用什么」三条；v0→v1 迁移章节不变；验证：FAQ 答案指向正确技能
- [x] 7.14 更新 `AGENTS.md`（本仓库开发约定）：九类卡→16+ 类表述、禁区清单补充（不生成 skills.yaml 真实数据/quickstart/skill-reference 真实内容，模板只放骨架）、自检清单扩充（29 技能一致性、六组分类覆盖、auto_invokable 标记三处一致、三分拆文档对应）；验证：自检清单每项可在本仓库找到检查对象

### 7D. install.sh 升级

- [x] 7.15 升级 `install.sh --project` 骨架：mkdir 列表增补 `cards/tendencies/`；写入 `config/skills.yaml` 占位（29 技能条目骨架，auto_invokable 默认值）、`quickstart.md` / `skill-reference.md` 中文版兜底占位；幂等性保持（重复执行零变更）；验证：对临时目录执行后 find 输出与 consumer-project-layout spec 目录树逐目录一致
- [x] 7.16 一致性核对：install.sh 目录列表 vs references/layout.md 目录树 vs specs/consumer-project-layout 三处逐一比对（含 tendencies/、skills.yaml、quickstart.md、skill-reference.md）；验证：三者目录集合完全相同

### 7E. 集成验证

- [x] 7.17 全量交叉一致性扫描：grep 检查全仓库 29 技能计数一致（skill-catalog/SKILL/README/AGENTS/skill-reference 五处均为 29）、六组分类名称三处一致（skill-catalog/agents-guide/skill-reference）、auto_invokable=true 仅 nc-量化/nc-图谱/nc-节奏 三处一致、无 `ch-` 前缀残留（迁移语境除外）
- [x] 7.18 端到端演练（纸面）：以「主角克制→放荡弧光 + 批量扩写」为例，走一遍 nc-动向(建 tend- 卡)→nc-桥段(新增事件)→nc-研判(推演下一步刻度)→作者选方案→nc-动向/nc-桥段(落地)→nc-编排(批量迭代计划)→审核→nc-校阅(扫冲突)→执行 的路由，确认每步指向的 reference/模板文件都存在且字段对得上
- [x] 7.19 `openspec validate --change restructure-v1-pipeline` 通过；运行 `./install.sh --project /tmp/nc-test-$$` 冒烟（确认 tendencies/、skills.yaml、quickstart.md、skill-reference.md 均生成）通过后清理临时目录

## Workflow follow-up

- 合入后提醒用户重新执行 `./install.sh`（或软链模式自动生效）刷新全局安装
- 后续可选 change：card-graph.json 正式 JSON Schema 文件、Pandoc 导出依赖检测文案定稿、tree_id 命名规范、compose-plan 独立 schema 文件、character_tendency 刻度数值语义定稿
