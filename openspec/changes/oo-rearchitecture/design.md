# Design

## Context

本仓库是 opencode / Claude Code 双端兼容的 skill 定义仓库（无构建、无依赖、无运行时），交付物为 `SKILL.md` + `references/` + `templates/` + `install.sh`。v1.0 已定稿：29 个 `nc-` 技能（六组分类）、16+ 类卡、四层数据分层（md/json/yaml/html）、长短篇分级、提案制协作（AI 绝不直接写卡）。v1.0 design D1 明确**拒绝引入运行时**，所有机制以「文档 + 模板 + 约定」承载。

本 change 把 v1.0 体系用**面向对象**思想重新解构：叙事资产 = 对象（`NcObject` 基类 + 8 子类）、技能 = 对象方法、流程 = 对象间消息传递、校验 = 类的断言/钩子、写作产出 = 对象状态流转后渲染序列化。动机与范围见 proposal.md。

关键约束（继承自 v1.0，本 change 不破坏）：
- frontmatter 三键铁律（name/description/license）不可破坏
- 提案制不变：AI 出草案、用户落盘；审计/研判/编排只出建议绝不静默改卡
- 29 技能集合、六组分类、`auto_invokable` 三项标记、四层数据分层均不变
- **唯一边界变更**：首次引入一个可选、零第三方依赖的轻量运行时工具（用户明确要求）

## Goals / Non-Goals

**Goals:**
- 新增 `references/oo-model.md`：`NcObject` 基类契约 + 8 子类属性/方法签名 + `StoryWorld` 容器 + 技能→方法完整映射表 + 草稿新命名→现有 schema 对齐规则
- 新增 `references/event-inference.md`：事件派发→连锁调用→ChangePlan→审核→patch→render 的 OO 化流程约定，作为 `nc-研判`/`nc-编排` 既有三段式的 OO 表述
- 新增 `tools/` 下零依赖只读运行时（validate/audit/图森林校验/推演纸面模拟），缺失可降级
- 把 `card-schema.md` / `loop.md` / `agents-guide.md` / `skill-catalog.md` / `data-layering.md` / `SKILL.md` body / `README.md` 的措辞以「对象/方法/消息/状态流转/渲染」语言重构，字段契约与技能集合不变
- 在 `AGENTS.md` 登记 `tools/` 禁区（零依赖、只读、不替代提案制）

**Non-Goals:**
- 不把 OO 模型实现为真实可执行的事件循环引擎（运行时只做只读校验/审计/纸面模拟，不做真实状态机驱动）
- 不新增任何卡类型、不改任何 frontmatter 字段名、不动 id 前缀/目录结构
- 不引入第三方依赖、不加构建配置、不改 LICENSE
- 不在本仓库放真实小说内容（OO 示例仍用假名占位，如 `ac-frog-lead`）
- 不改变 29 技能的行为语义（仅换 OO 视角表述）

## Decisions

### D1: OO 模型以「概念文档」承载，运行时只做只读校验/模拟（部分逆转 v1.0 D1）

**选择**：`NcObject`/子类/`StoryWorld` 的类层次与方法契约全部以 `references/oo-model.md` 的规范文档表达（Markdown 表格 + 最小 YAML/JSON 示例），由 AI 在执行 nc- 指令时读取并据此提案。**同时**新增一个可选轻量运行时 `tools/nc_validate.py`（Python 3 标准库单文件，倾向），提供 `validate`/`audit`/图森林结构校验/事件推演纸面模拟——但严格限定为**只读 + 出报告**。

**理由**：用户明确要求「引入轻量运行时」。纯文档无法给作者一个可一键执行的客观校验器（OOC/动向冲突/四方对齐靠人眼易漏）；一个零依赖只读脚本能在不破坏「无构建无依赖」精神的前提下补上这块。把它限定为只读 + 可降级，既满足用户对「可执行校验」的诉求，又不让运行时变成会写盘、带依赖、可能 OOC 的重型引擎——叙事真相仍收敛在卡片（对象实例）里，落地仍走提案制。

**备选**：① 完全无运行时（纯文档，v1.0 原状）——被否，用户明确要运行时；② 完整事件循环引擎（真实状态机驱动 render）——被否，突破边界过远，且「文字即视图」的渲染质量最终仍取决于作者/AI 的 render 判断，引擎化收益低、风险高；③ Node 实现——被否，Python 标准库对 YAML/JSON 解析更顺手且 Ubuntu 自带。

### D2: 草稿新命名一律对齐到现有 schema，草稿命名仅作概念别名

**选择**：`uuid`→`id`、`create_at/update_at`→`created/updated`、`disposition_slide:Track`→`character_tendency`(`tend-`)卡、`pose_bank[]`→独立 `pose`(`po-`)卡经 `pose_refs`、`MoodLine`→`lexstat`(`lx-`)+`metric`(`mt-`)概念别名。对齐表写入 `oo-model.md`，草稿命名 MUST NOT 作为 frontmatter 字段落地。

**理由**：v1.0 的 `id`(含前缀)/`tend-`/独立 `pose` 卡已定稿并被 29 技能、四层分层、图谱引用。若采纳草稿的 `uuid`/嵌套 `pose_bank`/`MoodLine` 会造成双轨漂移、破坏已落地的 `character_tendency` 独立卡设计（v1.0 D7）与 pose 插槽三级优先级。OO 重构的价值在「心智模型统一」，不在「重命名字段」——对齐成本最低且不丢任何 OO 表达力。

**备选**：按草稿全面改名（uuid/disposition_slide/MoodLine）——被否，迁移成本不成比例且与 v1.0 已归档决策冲突。

### D3: 事件推演 = 既有三段式（计划→审核→执行）的 OO 化表述，不新建独立流程

**选择**：`dispatch_event → enter/perceive/act/fire → ChangePlan 汇总 → 作者审核 → patch → render` 不是一条新流水线，而是 `nc-研判`（单点推演，出方案 A/B/C）与 `nc-编排`（批量三段式，compose_plan→审核→前置 nc-校阅→顺序执行）的 OO 词汇重述。`ChangePlan` 就是 compose_plan；`patch` 就是「作者确认后逐条调底层技能 + CHANGELOG + history 快照」；`render` 就是 `nc-成稿` 读对象状态出正文。

**理由**：v1.0 D8 已把「出主意」（研判）与「批量调度」（编排）严格切分，且都遵守「先建议/计划、人掌握审批权、绝不静默改卡」。OO 的「事件驱动」恰好是这套机制的自然语言外壳——对象响应事件产生候选变更（= 推演），汇总成计划（= ChangePlan/compose_plan），人审批后落地（= patch）。复用而非新建，避免再造一条与研判/编排平行的流程导致边界模糊。

**备选**：建独立的 `nc-推演` 事件引擎技能——被否，与研判/编排职责重叠，徒增第 30 个技能的认知负荷。

### D4: 运行时工具 = Python 3 标准库单文件，只读，缺失可降级

**选择**：`tools/nc_validate.py`（或等价 `nc_audit.py`），仅 import 标准库（`json`/`argparse`/`pathlib`/`re`；YAML frontmatter 用内置极简解析或正则提取五字段，避免 PyYAML 依赖）。子命令：`validate <card>`（单对象自检）、`audit`（全局跨对象 + 图森林结构）、`simulate <event>`（推演纸面模拟，可选）。`install.sh --project` 把 `tools/` 拷入使用方工程；检测不到 Python3 时 skill 提示并退回纸面约定。

**理由**：单文件 + 标准库 = 零安装、跨平台（Ubuntu/Mac/Windows 只要有 python3）、不污染依赖。YAML 不引 PyYAML 是因为卡片 frontmatter 结构简单，正则/手工解析五字段 + 关键专属字段足够做校验；真要深解析 json 层用标准库 `json`。可降级保证「没装 python 也能用 skill」。

**备选**：① shell 实现——被否，跨对象关系校验（图森林边、四方对齐）用 shell 极难维护；② 引 PyYAML——被否，违反零第三方依赖。

### D5: 文档 OO 化 = 措辞重构 + 交叉引用，不动字段契约

**选择**：`card-schema.md` 各类型节补一句「OO 视角：本卡 = `Xxx` 子类实例，`render()` 产出其文本投影」；`loop.md` 三场景流程图节点改标「对象方法调用」；`skill-catalog.md` 每技能行补「OO 归属：`StoryWorld.xxx()` / `Role.act()`」列；`data-layering.md` 补「`.json` 图森林 = `StoryWorld.objects` 注册表的机器投影」；`SKILL.md` body 流程概览补 OO 一句话类比。字段表、技能集合、六组、硬规则编号**逐字保留**。

**理由**：用户选「重构现有文档为 OO 表述」。但 v1.0 文档的字段契约是被 29 技能与模板消费的硬接口，只能换「叙述框架」不能动「接口本身」。做法是加 OO 透镜（每处补一句对象/方法映射 + 交叉引用 `oo-model.md`），而非重写整段——控制改动面、降低回归风险。

**备选**：整篇重写为纯 OO 教科书体——被否，丢失 v1.0 已打磨的可操作细节，且字段表必须原样保留才能继续驱动模板。

### D6: 篇幅门控复用既有 work-length-config，OO 不另起一套

**选择**：`StoryWorld.config.mode` 直接映射到既有 `registry/work-length-config.yaml` 的 short/mid/long 技能启用矩阵；OO 文档中「短篇禁用 DarkLine/长期 disposition_slide」只是对该矩阵的 OO 复述，不新增独立门控表。

**理由**：v1.0 已有长短篇分级矩阵（loop.md）+ skills.yaml 启用集。OO 再建一套门控必然与既有矩阵漂移。单一事实源 = work-length-config.yaml，OO 文档只引用不复述数值。

## Risks / Trade-offs

- [边界变更：首次引入运行时] v1.0 D1 明确无运行时，本 change 逆转之 → 缓解：严格限定为零依赖 + 只读 + 可降级；AGENTS.md 禁区显式登记 `tools/` 边界；README/USAGE 标注「可选、缺失可降级」，作者不会误以为必须安装
- [运行时与 AI 校验结论不一致] 脚本校验是静态规则子集，AI 纸面校验覆盖更广（语义级 OOC）→ 缓解：定位脚本为「客观硬规则兜底」（五字段/前缀/伏笔二选一/动向 trigger_plot 存在性/图森林结构/四方对齐计数），语义级判断仍归 AI；两者结论冲突时以 AI 意见书为准并提示差异
- [YAML 极简解析的健壮性] 不用 PyYAML，复杂 frontmatter（嵌套 blackbox/history 数组）正则解析可能漏判 → 缓解：校验聚焦「五字段 + 扁平关键专属字段 + json 层」，嵌套结构的存在性检查用宽松匹配；解析失败时报「无法解析，请人工核对」而非误报通过/失败
- [文档 OO 化改动面大] 触及 6+ 个 references + SKILL.md + README，措辞重构易引入笔误或与字段表矛盾 → 缓解：tasks 设「OO 交叉一致性扫描」步骤（grep 校验：每个子类映射表与 card-schema 类型表零差异、技能→方法映射 29 行无遗漏、frontmatter 三键不变）；字段表逐字保留只加注解
- [推演模拟的「伪精确」误导] 纸面模拟输出的 ChangePlan 可能被作者当作确定性结果 → 缓解：模拟输出强制标注「模拟结果，待作者审核，非确定预测」；spec 已要求该标注
- [双端分发 tools/] install.sh 需把 `tools/` 一并分发到 OpenCode/Claude Code 全局或使用方工程 → 缓解：`tools/` 随 `--project` 骨架分发到使用方工程根（而非全局 skill 目录），因为它操作的是使用方工程的卡片；全局 skill 目录只放 SKILL.md/references/templates

## Migration Plan

1. 本 change 合入后，本仓库即「v1.0 + OO 透镜 + 可选运行时」；已安装用户重新 `./install.sh`（或软链模式自动生效）
2. 使用方工程：`./install.sh --project` 幂等补齐 `tools/` 目录；旧工程无 `tools/` 时 skill 自动降级纸面校验，无需强制升级
3. 回滚策略：git revert 本 change 提交即回到纯 v1.0（无 OO 文档、无 tools/）；因 OO 仅为文档透镜 + 可选只读工具，未触碰任何卡片字段/技能行为，回滚无数据迁移负担
4. 渐进采用：作者可只读 `oo-model.md` 建立心智模型而完全不装运行时；想跑客观校验再 `python3 tools/nc_validate.py audit`

## Open Questions

- 运行时入口命名与形态：单文件 `nc_validate.py`（含 validate/audit/simulate 子命令）vs 拆 `nc_validate.py` + `nc_simulate.py` 两文件？倾向前者（单文件更易分发），实施时定稿
- `simulate` 子命令是否首期就实现，还是先交付 validate/audit、simulate 留作后续 change？倾向首期交付 validate + audit（价值最高、最客观），simulate 因「伪精确」风险可降为 AI 纸面推演为主、脚本辅助——实施时确认
- 使用方工程 `tools/` 是否需要 `build.sh`/`build.cmd` 集成一个 `validate` target？倾向加（一行 `python3 tools/nc_validate.py audit`），方便作者一键体检
- OO 类图是否需要一张 HTML/SVG 可视化（类似 relation-graph.html 的 `graph/oo-classmap.html`）？倾向可选加分项，不阻塞核心交付
