# Proposal

## Why

作者同时推进多卷 / 多线并进的长篇时，正传分卷、精简缩略版（3k–5k）、配套宣发物料
（10s/30s/1min/5min 介绍）属于**同一作品谱系**却散落在不同位置：纯数字编号无语义、
目录一多检索成本高、层级嵌套又难记路径。需要一套「语义化命名 + 浅目录 + 机器维护的
逻辑谱系索引」让作者只记 IP 编号，谱系归属 / 卷册从属 / 时序依赖 / 关联物料全部交给
工具托管，并能对新建与已有文稿做增删改查。

## What Changes

- **新增能力 `book-lineage`（书内谱系管理）**：在一本作品内部，把正传分卷、章节、
  精简梗概、宣发稿、卡片资产、草稿、测试样例、外部参考等物料按**固定 3 字符类型缩写**
  （MAI/ABR/PRO/CAR/DRF/TST/REF）+ **IP 短码（≥3 字符）**组织成统一 uid 命名
  （`IP-TYPE-卷号[-CH章节]`），物理目录**最多一层子文件夹**（拒绝深层嵌套）。
- **机器维护的逻辑谱系索引 `index.yaml`**：每本书一份，记录谱系关系、卷册从属、
  章节归属、时序依赖（`follow`）、关联物料（abr/promo/car）、状态与软删除标记；
  由 skill 自动维护，人尽量不手改，避免写错。
- **新增 4 个 `nc-lineage-*` 技能**（中英文双别名，对齐既有 29 技能体系）：
  - `nc-谱系新增` / `nc-lineage-add`：新增卷 / 章节 / 配套物料；支持 `--exist-file`
    把已有 md 快速挂靠进谱系（不新建文件，仅登记索引）
  - `nc-谱系修改` / `nc-lineage-edit`：改标题 / 调时序 / 变更归属 / 改状态；逻辑改名
    默认不动文件名，`--rename-file` 才同步改名
  - `nc-谱系移除` / `nc-lineage-del`：默认软删除（`archived: true`，可恢复），
    `--hard` 硬删除需二次确认
  - `nc-谱系查询` / `nc-lineage-query`：查谱系树 / 前后置依赖 / 关联物料，输出文字
    谱系树（远期 GUI 渲染可视化连线图）
- **边界铁律**：类型缩写固定 7 类不可自造、IP 短码 ≥3 字符、目录嵌套深度 ≤1 层、
  时序只写在 `follow` 字段不靠文件夹顺序、uid 全局唯一遵循 `IP-3位码-编号` 格式。
- **与既有能力联动**：`nc-检索`(nc-query) 命中素材卡片，`nc-lineage-query` 命中作品
  时序谱系，二者职责分离；`nc-编排` 可读谱系按序批量生成下一章 / 梗概 / 宣发稿；
  `nc-校阅` 支持传入 uid 限定只校验单卷 / 单章并读取前置卷设定做一致性校验。
- **与 `multi-work-management` 边界**：后者管「整本书」隔离（works/<id>/ 子空间 +
  works[] 清单 + --work 作用域）；本能力管「一本书内部」的卷 / 章节 / 物料谱系，
  两者正交叠加——多本工程里每本书各自拥有自己的 book-lineage 索引。
- **远期 GUI 映射**（TODO-only，不在本次范围）：谱系树面板 = nc-lineage-query 可视化，
  右键增删改查映射 4 个 skill，拖拽换归属调序底层调 nc-lineage-edit。

## Capabilities

### New Capabilities
- `book-lineage`: 书内谱系管理——语义化命名规范（IP 短码 + 3 字符类型缩写 + 卷/章节
  编号）、浅目录约定（≤1 层嵌套）、机器维护的 `index.yaml` 逻辑谱系索引 schema、
  4 个 `nc-lineage-*` 增删改查技能契约、与 nc-query/nc-编排/nc-校阅/multi-work 的
  联动边界。

### Modified Capabilities
<!-- 无 spec 级行为变更：multi-work-management 的 works[]/--work 契约不变，本能力在其
     之上叠加书内谱系；nc-query/nc-编排/nc-校阅 的技能描述增量属实现细节，不改其
     spec 级 Requirement。故留空。 -->

## Impact

- **SKILL.md**：技能速查表新增 4 个 `nc-lineage-*`（归入 C 剧情结构组或单列谱系管理组，
  见 design）；触发场景补「管理这本书的卷 / 章节 / 梗概 / 宣发谱系」「把这篇已有稿挂进
  谱系」等自然语言入口；frontmatter 三键不变。
- **references/**：新增 `lineage.md`（命名规则 + 目录约定 + index.yaml schema + 4 技能
  调用契约 + 边界铁律 + 与 multi-work/nc-query 联动）；`skill-catalog.md` 增 4 技能行；
  `hard-rules.md` 增谱系命名 / 目录深度 / uid 唯一性 / 软删除优先等硬规则。
- **templates/**：新增 `lineage-index.yaml` 骨架模板（字段结构 + 占位，零预置真实 IP）；
  双语 quickstart/skill-reference 模板补谱系管理节。
- **install.sh**：`--project` 骨架在每本书子空间下生成 `index.yaml` 占位 + 7 类物料
  子目录（MAI/ABR/PRO/CAR/DRF/TST/REF）`.gitkeep`，幂等。
- **tools/nc_validate.py**：可选扩展——若 `index.yaml` 存在则做 uid 唯一性 / 命名格式 /
  目录深度 / follow 链无环的只读校验（纯标准库 yaml/json），缺失降级纸面校验；保持
  零依赖只读、不替代提案制。
- **examples/**：新增假名示例工程片段（如 `SHZ` 山河志假名 IP 的 index.yaml + 谱系树
  输出样例），仅结构骨架与假名占位，不写真实内容。
- **向后兼容**：存量单本 / 多本工程无 `index.yaml` 时视为未启用谱系管理，全部既有
  `nc-*` 行为不变；MUST NOT 因缺 index.yaml 报错或强制迁移。
