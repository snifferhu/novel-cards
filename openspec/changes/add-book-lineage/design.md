# Design

## Context

novel-cards 是双端兼容（OpenCode + Claude Code）的小说卡片 skill 仓库，交付物为
SKILL.md / references/ / templates/ / install.sh 骨架 / tools/nc_validate.py。既有
`multi-work-management` spec 已解决「整本书」隔离（works/<id>/ 子空间 + works[] 清单 +
--work 作用域 + 多笔名署名）。本设计在其之上叠加「一本书内部」的卷/章节/物料谱系管理，
两者正交。约束：AGENTS.md 禁区——不写真实业务数据、registry/config 模板只放骨架占位、
frontmatter 三键、tools 零依赖只读、提案制铁律不变；所有新增向后兼容，存量工程缺
index.yaml 时行为不变。

## Goals / Non-Goals

**Goals:**
- 一套语义化命名规范（IP 短码 ≥3 字符 + 固定 7 类 3 字符类型缩写 + 卷/章节/版本编号），
  让单看文件名即可识别归属，平铺或浅目录都可用。
- 机器维护的 `index.yaml` 逻辑谱系真值：uid 主键、从属、follow 时序、related 关联、
  status/archived 状态，人尽量不手改。
- 4 个 `nc-lineage-*` 技能承载增删改查，支持新建与已有文稿 `--exist-file` 挂靠。
- 与 nc-query（素材检索）/ nc-编排 / nc-校阅 / multi-work 明确联动边界。
- 浅目录（≤1 层嵌套）+ 索引表承担「记忆层级」职责的双轨制。

**Non-Goals:**
- GUI 谱系树可视化面板、拖拽换归属（远期 TODO-only，本次仅留文字谱系树输出 + 映射说明）。
- 跨 IP 的复杂关系图谱渲染（由既有 nc-图谱 / graph/ HTML 承接，本能力只管书内谱系）。
- 自动内容生成（梗概/宣发稿正文由 nc-成稿/nc-编排 产出，本能力只管其谱系登记与命名落位）。
- 改变 multi-work 的 works[]/--work 契约。

## Decisions

### D1. 能力定位为「书内谱系」而非新顶层工作区
- **选择**：book-lineage 作用于单本书内部（每本书一份 index.yaml），多本工程里每本书各自
  拥有独立索引，复用 multi-work 的 works/<id>/ 子空间。
- **理由**：Doubao 对话的痛点是「一本书里卷一/卷二/缩略版/宣发稿捆在一起但不混为一谈」，
  是书内组织问题；整本书隔离已由 multi-work 解决。避免再造一个与 works/ 竞争的顶层结构。
- **备选**：① 在工程根再开 projects/ 顶层（被否——与 works/ 双轨冲突，作者要记两套根）；
  ② 把谱系塞进 card-graph.json（被否——graph 是对象关系图森林，谱系是文档物料时序，
  语义不同，混入会污染四层数据分层的 .json 真值定位）。

### D2. 物理浅目录 + 逻辑索引双轨，时序只写在 follow
- **选择**：文件落盘最多一层子文件夹（MAI/ABR/PRO/CAR/DRF/TST/REF），章节用文件名后缀
  `-CHxx`；卷册从属、时序先后、关联物料全部托管在 index.yaml 的 children/follow/related。
- **理由**：深层嵌套逼作者记路径（忘了在哪层查找成本飙升）；纯扁平则丢了从属结构。
  浅目录保证「单看文件名可知归属、平铺不丢信息」，索引表承担「谁是谁的前传/配套」。
- **备选**：① 按卷建子目录 MAI/VOL001/（被否——两层嵌套，正是用户抱怨的记忆负担）；
  ② 用文件夹顺序表达剧情先后（被否——重排文件即乱序，且与索引真值双源漂移）。

### D3. 类型缩写固定 7 类、IP 短码 ≥3 字符，均不可自造
- **选择**：TYPE ∈ {MAI, ABR, PRO, CAR, DRF, TST, REF} 硬编码白名单；IP 短码 ≥3 字符。
  校验在 nc-lineage-add/edit 入口强制，非法即拦截。
- **理由**：2 字符缩写易撞（SZ vs SZX）、自造类型会让命名体系越写越乱——这是用户明确
  点名的失控风险。固定词表 + 长度下限把「看着都有标号也乱」从源头堵死。
- **备选**：允许经 nc-注册 扩展自定义类型缩写（被否——类型是物料分类不是创作实体，
  开放扩展会破坏「一眼看懂」的核心价值；CAR 已覆盖全部卡片资产，无需细分子类型缩写）。

### D4. index.yaml 为逻辑真值，skill 自动维护，损坏即报错
- **选择**：每本书一份 index.yaml；nc-lineage-* 读写它；nc-lineage-query 读取前做校验
  （uid 唯一、follow 无环、file_path 存在性可选警告），手改损坏 MUST 报错附提示，不静默。
- **理由**：人手动改 yaml 极易写错（重复 uid / 环形 follow），静默吞错会让谱系树悄悄错乱。
  fail-loud 符合本 skill 既有的 fail-closed 合规风格。
- **备选**：① 索引存 JSON（被否——yaml 对人更友好，且本 skill 配置层本就是 .yaml 白名单，
  谱系索引归 .yaml 层比 .json 层更贴切，不污染 card-graph.json 的图森林真值定位）；
  ② 损坏时降级空谱系（被否——会误导作者以为没有物料）。

### D5. 软删除优先，硬删除需 --hard + 二次确认
- **选择**：nc-lineage-del 默认 archived:true（文件保留、查询默认过滤、可 --restore 恢复）；
  硬删除必须显式 --hard 并二次确认。
- **理由**：长篇创作误删一卷代价极高；软删除零成本兜底，符合「防误删」直觉。
- **备选**：默认硬删除（被否——高危，违背创作工具的安全底线）。

### D6. 4 技能归入「C 剧情结构组」并在速查表单列谱系小节
- **选择**：nc-lineage-add/edit/del/query 四个技能加入 skill-catalog，归入 C 剧情结构组
  （谱系是剧情组织的延伸），同时在 SKILL.md 触发场景补自然语言入口。技能总数 29→33。
- **理由**：谱系管理本质是「剧情物料的时序组织」，与桥段/伏笔/快照同属剧情结构域；
  单列谱系小节降低发现成本。
- **备选**：① 单开第七组「谱系管理组」（被否——六组是既定用户心智模型，加组冲击大，
  且 AGENTS.md 自检要求六组一致性）；② 并入 nc-初始化（被否——初始化是一次性脚手架，
  谱系是持续 CRUD，生命周期不同）。
- **注意**：技能计数变更（29→33）MUST 同步更新 SKILL.md 速查表 / README 技能表 /
  skill-catalog.md / USAGE.md / skill-reference 模板五处，保持 AGENTS.md §7 计数一致性自检通过。

### D7. tools/nc_validate.py 可选只读校验，缺失降级
- **选择**：validate 子命令若检测到某书 index.yaml 则做只读校验（uid 唯一 / 命名格式正则 /
  目录深度 ≤1 / follow 无环），纯标准库（yaml 解析用内置或 json 回退）；无 index.yaml 跳过。
- **理由**：给作者一个不依赖 skill 运行的快速体检入口，延续「可选运行时 + 缺失降级纸面
  校验」的既有模式；保持零依赖只读、不替代提案制。
- **备选**：不做运行时校验（被否——index.yaml 手改损坏是高频风险，有只读校验能早暴露）。

## Risks / Trade-offs

- [技能计数 29→33 引发五处文档不一致] → tasks 中设专门任务做全量计数 sweep，对齐
  AGENTS.md §7 自检清单，验证脚本扫五处文件。
- [index.yaml 与磁盘文件漂移（文件被手动移动/删除后索引仍指向旧 path）] →
  nc-lineage-query 对 file_path 做存在性检查，缺失发 L2 警告（不阻断），提示作者
  用 nc-lineage-edit 修正路径或重新 --exist-file 挂靠。
- [follow 链过深导致谱系树难读] → nc-lineage-query 支持 --filter 与 --show-archived，
  作者可按类型/单卷聚焦；远期 GUI 折叠展开。
- [多本工程下「当前默认书」歧义影响 lineage 操作] → 复用 multi-work 的 active_work/--work
  解析规则，lineage 技能同样接受 --work 限定作用域，缺省歧义时提示显式指定。
- [固定 7 类缩写未来不够用] → 设计上 CAR 已聚合全部卡片资产；若确需新物料大类，走
  正式 spec 变更扩展白名单，不在运行期自造，守住「不可自造」铁律。

## Migration Plan

- **部署**：纯 skill 文档/模板/骨架增量，install.sh --project 幂等生成新书 index.yaml 占位
  + 7 类子目录 .gitkeep；存量工程不强制迁移。
- **向后兼容**：无 index.yaml 的存量单本/多本工程视为未启用 book-lineage，全部既有 nc-*
  行为不变；MUST NOT 因缺 index.yaml 报错。
- **回滚**：移除 4 个 nc-lineage-* 技能定义 + lineage.md + 模板 + install.sh 骨架行即可回到
  引入前状态；已生成的 index.yaml 文件无害残留（不被任何技能消费），可保留或删除。
- **数据无损**：本能力只新增索引与空白文件，绝不改写既有卡片/正文/图森林。

## Open Questions

- 宣发时长是否严格锁死 S10/S30/M01/M05 四档，还是允许作者经 nc-注册 追加自定义时长档
  （如 S15/M03）？当前按 Doubao 对话「统一口径、不搞自定义时长」取**锁死四档**；若作者
  后续需要更多档位，应走 spec 变更而非运行期自造——此点不影响本次实现，留待实际使用反馈。
