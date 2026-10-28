# Tasks

> 本 change 的任务范围 = 把 Doubao 对话中「书内谱系管理」能力落进 skill 仓库交付物
> （SKILL.md / references/ / templates/ / install.sh 骨架 / tools/nc_validate.py / examples/）。
> 远期 GUI 谱系树可视化、拖拽换归属为 TODO-only，不产生任务。所有新增向后兼容：
> 存量工程无 index.yaml 时视为未启用 book-lineage，全部既有 nc-* 行为不变。
> 技能计数由 29 → 33（新增 nc-谱系新增/修改/移除/查询），MUST 同步五处文档保持一致。

## 1. 命名规范与目录约定（naming-convention）

- [x] 1.1 新建 `references/lineage.md`：定义 uid 命名规范（IP 短码 ≥3 字符 + 固定 7 类 3 字符类型缩写 MAI/ABR/PRO/CAR/DRF/TST/REF + 卷号零填充 + `-CHxx` 章节后缀 + `Vxx` 版本 + 宣发时长 S10/S30/M01/M05 锁死四档）、浅目录约定（≤1 层子文件夹，禁止深层嵌套）、双轨制说明（物理浅目录 + 逻辑索引承担记忆层级）；验证：文档含完整缩写表 + 命名格式 + 目录深度铁律，措辞与 spec 一致
- [x] 1.2 `references/lineage.md`：补「与 multi-work-management 边界」节——book-lineage 管书内谱系、multi-work 管整本书隔离，两者正交叠加，多本工程每本书各自拥有独立 index.yaml；验证：边界表述清晰，不改变 works[]/--work 契约
- [x] 1.3 `references/hard-rules.md`：新增谱系硬规则（类型缩写固定 7 类不可自造 / IP 短码 ≥3 字符 / 目录嵌套 ≤1 层 / 时序只写 follow 不靠文件夹顺序 / uid 全局唯一遵循 `IP-3位码-编号` / 软删除优先硬删除需 --hard+二次确认）；验证：新规则编号连续、与既有规则风格一致，规则总数同步更新（见任务 6.1 计数 sweep）

## 2. index.yaml 逻辑谱系索引 schema（lineage-index-schema）

- [x] 2.1 `references/lineage.md`：定义 `index.yaml` 完整 schema——每条目字段 `uid`（全局唯一主键）/ `type` / `vol`|`ch`|`ver`|`tag`（按类型取其一）/ `title` / `file_path` / `status`（构思中/连载中/定稿/搁置）/ `archived`（软删除标记）/ `follow`（前置依赖 uid，表达时序）/ `children`（从属章节 uid 列表）/ 顶层 `related`（abr/promo/car 关联物料）；明确该文件由 nc-lineage-* 自动维护、人 SHOULD NOT 手改、损坏时 query 报错附提示；验证：schema 字段齐全、WHEN/THEN 行为与 spec 的 index.yaml Requirement 对齐
- [x] 2.2 新建 `templates/lineage-index.yaml` 骨架模板：仅字段结构 + 占位符（如 `{{IP_ID}}` / `{{IP_NAME}}` / 空 lineage 列表 / 空 related），零预置真实 IP 数据；验证：yaml 合法、无具体山河志等真实业务取值，符合 AGENTS.md「registry/config 模板只放骨架」禁区
- [x] 2.3 `install.sh --project` 骨架：在每本书子空间下生成 `index.yaml` 占位文件（从 templates/lineage-index.yaml 幂等拷入）+ 7 类物料子目录（MAI/ABR/PRO/CAR/DRF/TST/REF）各含 `.gitkeep`；验证：重复执行 install.sh --project 零变更，新生成目录结构与 spec 浅目录约定一致

## 3. 四个 nc-lineage-* 技能契约（lineage-skills）

- [x] 3.1 `references/lineage.md`：定义 `nc-谱系新增`(nc-lineage-add) 调用契约——支持卷/章节/配套物料三类新增，参数 `--ip/--type/--vol/--ch/--ver/--tag/--title`，自动校验（IP 存在/类型码合法/编号不重复）+ 登记 index.yaml + 生成空白文件 + 更新 last_modified + 写 CHANGELOG；`--exist-file <path>` 挂靠已有 md（不新建文件仅登记索引，文件名不合规范则警告并询问是否重命名）；`--restore <uid>` 恢复软删除；验证：契约含全部参数与自动行为，与 spec 的 add Requirement 场景一一对应
- [x] 3.2 `references/lineage.md`：定义 `nc-谱系修改`(nc-lineage-edit) 契约——`--id/--title/--follow/--move-to-vol/--status`，默认只改 index.yaml 逻辑关系不动文件名，`--rename-file` 才同步改名，每次写 CHANGELOG；验证：契约明确「逻辑改名与文件名解耦」，与 spec edit Requirement 对齐
- [x] 3.3 `references/lineage.md`：定义 `nc-谱系移除`(nc-lineage-del) 契约——默认软删除（archived:true，文件保留，query 默认过滤），`--hard` 硬删除需二次确认（删索引+删文件）；验证：契约含软/硬两模式与恢复路径，与 spec del Requirement 对齐
- [x] 3.4 `references/lineage.md`：定义 `nc-谱系查询`(nc-lineage-query) 契约——`--ip`（整 IP 谱系树）/ `--id`（单卷带章节+前后置）/ `--filter <TYPE>`（只看某类）/ `--show-archived`（含归档），输出文字谱系树（每条标 status/follow/related），读取前做校验（uid 唯一/follow 无环/file_path 存在性 L2 警告），损坏 fail-loud 报错；验证：契约含全部查询模式与输出样例，与 spec query Requirement 对齐
- [x] 3.5 `references/skill-catalog.md`：新增 4 行技能（nc-谱系新增/修改/移除/查询，英文别名 nc-lineage-add/edit/del/query，auto_invokable=false，OO 归属列给 StoryWorld 谱系方法映射），归入 C 剧情结构组；验证：技能总行数 29→33，六组分类仍覆盖全部技能，双语别名映射完整

## 4. 联动边界（integration-boundary）

- [x] 4.1 `references/lineage.md`：补「与既有能力联动」节——nc-lineage-query（作品时序谱系）与 nc-检索/nc-query（素材卡片检索）职责分离互不混用；nc-编排 MAY 读谱系按序批量生成下一章/梗概/宣发稿并自动挂靠谱系；nc-校阅 SHALL 支持 `--uid` 限定单卷/单章并读 follow 前置卷设定做跨卷一致性校验；验证：三处联动描述与 spec 的「正交联动」Requirement 场景一致
- [x] 4.2 `references/skill-catalog.md`：nc-检索/nc-编排/nc-校阅 三行描述增量补充谱系联动一句话（nc-检索 注明「素材检索，谱系走 nc-lineage-query」/ nc-编排 注明「可读谱系按序生成」/ nc-校阅 注明「支持 --uid 限定单卷读前置设定」）；验证：仅描述增量，三技能既有入参/产物/auto_invokable 取值不变
- [x] 4.3 SKILL.md body：触发场景补自然语言入口（「管理这本书的卷/章节/梗概/宣发谱系」「把这篇已有稿挂进谱系」「查一下山河志的谱系树」「归档这一章」），并在技能速查表 C 组加 4 个 nc-lineage-* 行；frontmatter 三键不动；验证：YAML frontmatter 解析仍只有 name/description/license 三键，触发词前缀 nc- 一致

## 5. 可选运行时校验（runtime-validation）

- [x] 5.1 `tools/nc_validate.py`：validate 子命令扩展——若某书 `index.yaml` 存在则做只读校验（uid 全局唯一 / uid 命名格式正则 `^[A-Z]{3,}-[A-Z]{3}-\d{3}(-CH\d{2})?$` / 物理目录深度 ≤1 / follow 链无环检测），纯 Python3 标准库（yaml 缺失时用内置简易解析或 json 回退，保持零第三方依赖）；无 index.yaml 的书跳过该校验；验证：对含合法 index.yaml 的样例输出 PASS，对重复 uid/环形 follow/超深目录输出对应 L1/L2 提示，对无 index.yaml 工程行为与现状一致
- [x] 5.2 `examples/` 新增假名示例片段：一个 `SHZ`（山河志假名 IP）的 index.yaml 样例 + nc-lineage-query 文字谱系树输出样例（卷一/卷二 + 章节 + 配套 ABR/PRO 物料 + follow 依赖），仅结构骨架与假名占位；验证：示例 uid 全部合规、谱系树结构与 spec query 输出样例一致，不含真实小说内容

## 6. 文档一致性与自检（consistency-sweep）

- [x] 6.1 全量技能计数 sweep：把 29→33 同步到 SKILL.md 速查表 / README 技能表 / `references/skill-catalog.md` / `USAGE.md` / `templates/skill-reference-zh.md` + `skill-reference-en.md` 六处，确保 AGENTS.md §7「技能计数一致性」自检通过；验证：脚本扫六处文件，nc-lineage-* 四技能均出现且总数标注为 33
- [x] 6.2 双语模板同步：`templates/quickstart-zh.md`/`quickstart-en.md` 补「谱系管理」一节（一句话定位 + 指向 references/lineage.md），`templates/skill-reference-zh.md`/`skill-reference-en.md` 补 4 技能行；验证：中英模板节结构一一对应、占位符集合一致
- [x] 6.3 跑 AGENTS.md §7 编辑自检清单全项（frontmatter 三键 / 提案制无直接写卡引导 / 五字段必备 / 相对路径无绝对路径 / 四层数据分层表述一致 / auto_invokable 三处一致 / 六组分类覆盖 / OO 透镜与事件推演对齐 / tools 只读铁律）；验证：逐项核对通过，新增 lineage 相关内容不破坏任何既有铁律
- [x] 6.4 `openspec validate add-book-lineage --strict` 通过；验证：exit 0，proposal/specs/design/tasks 四 artifact 状态均为 done

## Workflow follow-up

- 实现完成后由用户决定是否 commit/push（本会话惯例：用户显式说「提交/推送」才执行）。
- 满足项目 review 要求后归档 change（`openspec archive add-book-lineage`），归档时把 book-lineage delta spec 合入主 spec。
