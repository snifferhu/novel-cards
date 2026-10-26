# Tasks

## 1. OO 概念模型文档（references/oo-model.md）

- [x] 1.1 新建 `references/oo-model.md`：定义 `NcObject` 抽象基类公共属性（对齐五字段 + name/tags/private/remark 概念别名）与四方法契约（`render()` 抽象 / `validate()` / `snapshot()` / `patch()`），用 Markdown 表格 + 最小 YAML 示例表达；验证：文件存在，五字段名与 `card-schema.md` 通用五字段逐字一致，`render` 标注为抽象方法
- [x] 1.2 在 `oo-model.md` 写 8 子类映射表（Role→actor/ac-、Prop→item/it-、Scene→scene/sc-、SensoryCue→sensory_cue/su-、PlotBeat→plotpoint/pp-、StoryTrack→timeline/tl-、DarkLine→darklayer/dk-、Snapshot→snapshot/sn-）+ 每子类自有属性与方法签名（Role: act/perceive/get_pose；Prop: move_to/emit_sensory；Scene: enter/refresh_env；SensoryCue: broadcast；PlotBeat: fire；StoryTrack: step；DarkLine: check_converge；Snapshot: restore）；验证：8 行映射与 `card-schema.md` 类型前缀总表零差异，Role 动向经 `tend-` 引用、姿态经 `po-`/`pose_refs` 引用
- [x] 1.3 在 `oo-model.md` 写 `StoryWorld` 容器（objects/timeline/inbox/config/safety_guard 五属性 + constructor/query/import_raw/clean_object/plan_modify/audit/deliberate/export 八方法）；验证：容器属性对应 `index/card-graph.json`+`cards/**`/`res/inbox/`/config/nc-守卫，方法一一对应 nc-初始化/检索/素材/清洗/编排/校阅/研判/导出
- [x] 1.4 在 `oo-model.md` 写「29 技能 → OO 方法」完整映射表（含 nc-对标 分析模式条目），每技能唯一主归属方法；验证：29 行无遗漏、六组归属不变、auto_invokable 三项标记不变
- [x] 1.5 在 `oo-model.md` 写「草稿新命名 → 现有 schema」对齐表（uuid→id、create_at/update_at→created/updated、disposition_slide→character_tendency/tend-、pose_bank[]→pose/po- 经 pose_refs、MoodLine→lexstat+metric 概念别名、status 枚举对齐 draft/candidate/active/archived）；验证：每个草稿命名都有对齐目标，且明确「仅作概念别名，不作 frontmatter 字段落地」

## 2. 事件推演流程约定（references/event-inference.md）

- [x] 2.1 新建 `references/event-inference.md`：描述 `dispatch_event → enter→perceive→act→fire 连锁 → ChangePlan 汇总 → 作者审核 → patch 批量落地 → render 渲染` 全流程，明确「候选变更绝不直接写盘、对象不自动覆盖自身」；验证：文件存在，流程节点与 `loop.md` 研判/编排三段式（计划→审核→执行）语义对齐
- [x] 2.2 在 `event-inference.md` 写 ChangePlan 结构约定（逐项列明 Role 属性变更含动向刻度+推手桥段 / Prop 动线移动 / SensoryCue 激活 / PlotBeat 待引爆 / DarkLine 进度变化，每项标目标卡 id + 前后差异），并声明其 = `nc-编排` compose_plan 产物；验证：ChangePlan 字段集与 skill-catalog 中 nc-编排 的 compose_plan 五类任务（create_plot/edit_plot/archive_plot/update_tendency/bind_sensory_cue）可对应
- [x] 2.3 在 `event-inference.md` 写冲突处理三选一（保留旧实例 / 覆盖为新实例[先归档 history] / 合并取部分字段）+ 「决定权归作者」铁律；验证：与 `card-schema.md`「差异不直接覆盖先归档 history」约定一致
- [x] 2.4 在 `event-inference.md` 写「文字即视图」渲染阶段（按 timeline 顺序调各对象 render() 拼接 manuscript/，文稿是投影、对象模型是唯一可信源，改剧情=改状态再重渲）+ 长短篇 mode 门控（short 禁 DarkLine/长期 disposition_slide，long 全开），引用 `registry/work-length-config.yaml` 单一事实源；验证：门控表述与 `loop.md` 长短篇分级矩阵一致，不另建独立门控表

## 3. 轻量运行时工具（tools/）

- [x] 3.1 新建 `tools/nc_validate.py`（Python 3 标准库单文件，仅 import json/argparse/pathlib/re/os/sys，禁止 PyYAML 等第三方包）：实现 `validate <card>` 子命令——读卡片 frontmatter（正则/极简解析五字段 + 扁平关键专属字段），检查五字段齐全、type 与 id 前缀一致、伏笔 payoff_chapter/status:unresolved 二选一、动向 history[] 每条 trigger_plot 指向真实 pp-*；输出只读违规报告，绝不写盘；验证：对一张合法卡返回 0 违规，对缺字段/错前缀/悬空 trigger_plot 的卡报出具体项，脚本无任何文件写入
- [x] 3.2 在 `nc_validate.py` 实现 `audit` 子命令：跨对象 OOC 硬规则 + 暗线 references_to_main 单向引用合法性 + 长线四方对齐（fs-/tl-/md-/lx- ≥8 章预埋计数）+ `index/card-graph.json` 图森林结构校验（node 含 id/type/tree_id、edge 含 source/target/relation 且 relation 属合法枚举、边引用节点均存在）；输出只读意见书；验证：对含悬空边/未知 relation/缺失节点的 json 报出位置，对合法工程零误报，脚本不修改任何 json/md
- [x] 3.3 在 `nc_validate.py` 实现 `simulate <event>` 子命令（可选增强）：读当前对象状态，沿 enter→perceive→act→fire 链计算受影响对象候选新状态，输出标注「模拟结果，待作者审核，非确定预测」的 ChangePlan 草稿，绝不写盘；验证：给定 `ac-A enter sc-X` 输出受影响对象列表 + 前后差异草稿，文件零改动；若首期不交付则本任务改为「文档说明由 AI 纸面推演承载」
- [x] 3.4 确认 `nc_validate.py` 零第三方依赖且跨平台可运行：`python3 -c "import ast; ast.parse(open('tools/nc_validate.py').read())"` 通过 + grep 确认 import 仅标准库；验证：Ubuntu/Mac 有 python3 即可 `python3 tools/nc_validate.py audit` 跑通，无 pip/npm 安装步骤
- [x] 3.5 升级 `install.sh --project`：mkdir 列表增补 `tools/`，把 `tools/nc_validate.py` 拷入使用方工程根（幂等，重复执行零变更）；并在 README/USAGE 标注「tools/ 可选、缺失时 skill 降级纸面校验」；验证：`./install.sh --project /tmp/nc-test-$$` 后 `tools/nc_validate.py` 存在且可执行，二次执行幂等，临时目录清理

## 4. 现有文档 OO 化重构（措辞 + 交叉引用，字段契约不动）

- [x] 4.1 重构 `references/card-schema.md`：各类型节补一句「OO 视角：本卡 = `Xxx` 子类实例，`render()` 产出其文本投影」+ 交叉引用 `oo-model.md`；通用五字段表、各类型专属字段表、最小示例**逐字保留**；验证：grep 确认所有 type/前缀/字段名未变，仅新增 OO 注解行
- [x] 4.2 重构 `references/loop.md`：三场景流程图节点改标「对象方法调用」（如 nc-成稿→`StoryWorld.export()` render 阶段），补 OO 一句话类比；长短篇分级矩阵数值不变；验证：流程图节点与既有三场景一致，仅换 OO 标签
- [x] 4.3 重构 `references/skill-catalog.md`：每技能行补「OO 归属」列（`StoryWorld.xxx()` / `Role.act()` 等），六组分类、双语 JSON、auto_invokable 列、入参/产物表不变；验证：29 技能行 + refwork 注记齐全，OO 归属列与 oo-model.md 映射表零差异
- [x] 4.4 重构 `references/data-layering.md`：补「`.json` 图森林 = `StoryWorld.objects` 注册表的机器投影」「`.md` = 对象实例的人类编辑载体」OO 透镜表述；四层铁律与 card-graph.json schema 不变；验证：四层表与 relation 枚举逐字保留
- [x] 4.5 重构 `references/agents-guide.md`：意图匹配表补 OO 视角（「让角色 A 进房间」→ 事件派发→连锁→ChangePlan），文档三分拆/auto_invokable 透明化规则不变；验证：意图表覆盖原全部意图 + 事件驱动路由
- [x] 4.6 更新 `SKILL.md` body：description 触发词不变，速查表/路由/三场景流程概览补 OO 一句话类比与 `oo-model.md`/`event-inference.md` 引用；**frontmatter 仍仅 name/description/license 三键**；验证：YAML dump 确认三键，body 出现 OO 透镜且未破坏双端兼容
- [x] 4.7 更新 `README.md`：新增「面向对象心智模型」章节（NcObject/StoryWorld/文字即视图一句话 + 指向 oo-model.md），目录结构树补 `references/oo-model.md`/`event-inference.md`/`tools/`；29 技能/16+ 卡/四层分层表述不变；验证：README 出现 OO 章节，目录树含新文件
- [x] 4.8 更新 `AGENTS.md`：禁区清单新增「`tools/` 仅限零第三方依赖只读校验/审计/推演模拟器，不得引入第三方包、不得写使用方卡片/图谱/正文/索引、不得替代提案制」；自检清单补「OO 映射表与 card-schema 类型表零差异 / 技能→方法 29 行无遗漏 / frontmatter 三键不变」；验证：AGENTS.md 出现 tools/ 禁区条 + OO 自检项

## 5. 集成校验与一致性扫描

- [x] 5.1 OO 交叉一致性扫描：grep 校验 ① oo-model.md 8 子类映射表 vs card-schema.md 类型前缀总表零差异 ② 技能→方法映射 29 行无遗漏且六组归属不变 ③ auto_invokable=true 仍仅 nc-量化/nc-图谱/nc-节奏 ④ 草稿命名（uuid/disposition_slide/MoodLine/pose_bank）未作为 frontmatter 字段出现在任何模板/schema ⑤ 无 `ch-` 前缀残留（迁移语境除外）；验证：五项 grep 全部通过
- [x] 5.2 运行时端到端冒烟：对 `install.sh --project` 生成的临时工程跑 `python3 tools/nc_validate.py audit`，确认零依赖跑通、只读、对合法骨架零误报；缺失 python3 时 skill 提示降级；验证：临时工程 audit 退出码 0 或仅报预期项，无文件被修改，临时目录清理
- [x] 5.3 `openspec validate oo-rearchitecture` 通过；验证：exit 0（风格 warning 可接受）
- [x] 5.4 双端兼容回归：确认 SKILL.md frontmatter 三键未被 OO 重构破坏、`tools/` 随 `--project` 分发到使用方工程而非全局 skill 目录；验证：YAML dump 三键 + install.sh 分发路径检查

## Workflow follow-up

- （参考，不计入追踪进度）本 change 合入后，可考虑后续独立 change：① `graph/oo-classmap.html` OO 类图可视化（可选加分项）② `build.sh`/`build.cmd` 集成 `validate` target ③ simulate 子命令若首期未交付则补强 ④ 将 restructure-v1-pipeline 与本 change 一并 sync 到 `openspec/specs/` 主 spec
