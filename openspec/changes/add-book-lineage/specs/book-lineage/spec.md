# Spec Delta

## Purpose

在一本作品内部，把正传分卷、章节、精简梗概、宣发稿、卡片资产等物料按语义化命名与
机器维护的逻辑谱系索引组织起来，让作者只记 IP 编号即可检索 / 溯源 / 增删改查整套
谱系，物理目录保持浅层级不靠文件夹嵌套表达时序与从属。

## ADDED Requirements

### Requirement: 书内物料 MUST 遵循统一 uid 命名规范

每本书的谱系物料 SHALL 以全局唯一主键 `uid` 标识，格式为 `IP-TYPE-卷号[-CH章节]`：
IP 短码 MUST ≥3 字符（一个独立 IP 永久固定）；TYPE MUST 取自固定 7 类缩写
（MAI 正传正文 / ABR 精简缩略 / PRO 宣发文案 / CAR 资产卡片 / DRF 草稿备选 /
TST 校阅测试 / REF 外部参考），MUST NOT 自造类型缩写；卷号用零填充顺序编号
（001/002…），章节用 `-CHxx` 后缀，版本用 `Vxx`，宣发时长固定 S10/S30/M01/M05。

#### Scenario: 合法 uid 通过校验
- **WHEN** 作者登记 `SHZ-MAI-001-CH05`（山河志·卷一·第五章）
- **THEN** 系统接受该 uid：IP 短码 SHZ 为 3 字符、TYPE MAI 属固定 7 类、卷号 001 零填充、章节 CH05 合规

#### Scenario: 非法类型缩写被拦截
- **WHEN** 作者尝试登记 `SHZ-XYZ-001`（XYZ 不在 7 类固定缩写内）
- **THEN** 系统 MUST 拒绝并提示「类型缩写必须取自 MAI/ABR/PRO/CAR/DRF/TST/REF，不可自造」

#### Scenario: 两字符 IP 短码被拦截
- **WHEN** 作者尝试用 2 字符 IP 短码（如 `SZ-MAI-001`）
- **THEN** 系统 MUST 拒绝并提示「IP 短码须 ≥3 字符，避免冲突歧义」

### Requirement: 物理目录 MUST 保持浅层级（≤1 层子文件夹）

每本书根目录下 SHALL 最多一层物料子文件夹（MAI/ABR/PRO/CAR/DRF/TST/REF），
MUST NOT 出现二级及以上嵌套（禁止 `MAI/vol1/chapter01` 这类多层目录）；一卷内部的
章节 SHALL 用文件名后缀区分（`SHZ-MAI-001-CH05.md`），时序顺序靠文件名自带数字排序。

#### Scenario: 深层嵌套被拦截
- **WHEN** 作者试图把文件放到 `SHZ/MAI/VOL001/SHZ-MAI-001-CH05.md`（两层嵌套）
- **THEN** 系统 MUST 提示目录深度超限，要求改为单层 `SHZ/MAI/SHZ-MAI-001-CH05.md`

#### Scenario: 单看文件名可识别归属
- **WHEN** 一个文件被临时复制到任意位置平铺
- **THEN** 仅凭文件名 `SHZ-MAI-001-CH05.md` 仍可识别其 IP、类型、卷号、章节，不丢失归属信息

### Requirement: index.yaml MUST 作为逻辑谱系真值由 skill 自动维护

每本书 SHALL 有一份 `index.yaml` 记录谱系关系：每个条目含 `uid`（全局唯一主键）、
`type`、`vol`/`ch`/`ver`/`tag`（按类型取其一）、`title`、`file_path`、`status`
（构思中/连载中/定稿/搁置）、`archived`（软删除标记）、`follow`（前置依赖 uid，
表达时序）、`children`（从属章节 uid 列表）、以及 `related`（abr/promo/car 关联物料）。
该文件 SHALL 由 `nc-lineage-*` 技能自动读写，人 SHOULD NOT 手改；手改损坏时
`nc-lineage-query` MUST 报错并附校验提示，MUST NOT 静默吞错。

#### Scenario: 时序依赖只写在 follow 字段
- **WHEN** 卷二接在卷一之后
- **THEN** `index.yaml` 中卷二条目的 `follow` 指向卷一 uid，剧情先后不靠文件夹顺序或文件名隐含

#### Scenario: 手改 yaml 损坏后查询报错
- **WHEN** 作者手动编辑 `index.yaml` 导致结构非法（如重复 uid / follow 成环）
- **THEN** `nc-lineage-query` MUST 报错并指出具体校验失败项（重复 uid / 环形依赖），不静默返回错误谱系树

### Requirement: nc-lineage-add MUST 支持新建与已有文稿挂靠

`nc-谱系新增`(nc-lineage-add) SHALL 支持三类新增：卷、章节、配套物料（梗概/宣发/卡片）；
登记时 MUST 校验 IP 存在、类型码合法、卷号/章节号不重复，并在 `index.yaml` 写入谱系
记录（章节自动绑定从属卷）、生成空白文件、更新全局 `last_modified`、写 CHANGELOG。
SHALL 支持 `--exist-file <path>` 把已有 md 快速挂靠进谱系——不新建文件，仅在索引登记
从属/时序/标题；若文件名不合规范 MUST 提示警告并询问是否自动重命名对齐。

#### Scenario: 新建章节自动生成文件并登记
- **WHEN** 执行 `nc-lineage-add --ip SHZ --type MAI --vol 001 --ch 06 --title "第六章 山道伏击"`
- **THEN** 系统生成 `SHZ/MAI/SHZ-MAI-001-CH06.md` 空白文件，在 index.yaml 登记该章节归属卷 001，写 CHANGELOG

#### Scenario: 已有文稿挂靠不新建文件
- **WHEN** 执行 `nc-lineage-add --ip SHZ --type MAI --vol 001 --ch 06 --title "..." --exist-file ./MAI/SHZ-MAI-001-CH06.md`
- **THEN** 系统不新建文件，仅在 index.yaml 登记该已有文件的从属/时序/标题，后续查询/溯源/联动校阅生效

#### Scenario: 重复编号被拦截
- **WHEN** 对已存在的 `SHZ-MAI-001-CH05` 再次执行 add
- **THEN** 系统 MUST 拒绝并提示该 uid 已存在，建议改用 edit 或换编号

### Requirement: nc-lineage-edit MUST 支持逻辑修改且默认不改文件名

`nc-谱系修改`(nc-lineage-edit) SHALL 支持改标题、调时序（`follow`）、变更归属
（`move-to-vol`）、改状态；默认只改 `index.yaml` 的逻辑关系，MUST NOT 改动文件名，
仅当显式加 `--rename-file` 才同步重命名文件；每次修改 MUST 写 CHANGELOG。

#### Scenario: 逻辑改名不动文件名
- **WHEN** 执行 `nc-lineage-edit --ip SHZ --id SHZ-MAI-001-CH05 --title "第五章 雨夜渡口相逢"`
- **THEN** 仅 index.yaml 中该条目 title 更新，磁盘文件名 `SHZ-MAI-001-CH05.md` 保持不变

#### Scenario: 变更章节归属卷
- **WHEN** 执行 `nc-lineage-edit --ip SHZ --id SHZ-MAI-001-CH09 --move-to-vol 002`
- **THEN** 该章节从卷 001 的 children 移除、加入卷 002 的 children，follow/从属关系相应更新

### Requirement: nc-lineage-del MUST 默认软删除并可恢复

`nc-谱系移除`(nc-lineage-del) SHALL 默认软删除——仅置 `archived: true`，文件保留，
归档条目不再出现在正常谱系树（`nc-lineage-query` 默认过滤），可通过
`nc-lineage-add --restore <uid>` 恢复；硬删除 MUST 需 `--hard` 参数并二次确认，
同时删除索引条目与本地文件。

#### Scenario: 软删除后查询默认隐藏
- **WHEN** 执行 `nc-lineage-del --ip SHZ --id SHZ-MAI-001-CH07`（无 --hard）
- **THEN** 该条目 `archived: true`，文件保留；`nc-lineage-query --ip SHZ` 默认不显示它

#### Scenario: 恢复软删除条目
- **WHEN** 执行 `nc-lineage-add --restore SHZ-MAI-001-CH07`
- **THEN** 该条目 `archived` 复位为 false，重新出现在正常谱系树

#### Scenario: 硬删除需二次确认
- **WHEN** 执行 `nc-lineage-del --ip SHZ --id SHZ-MAI-001-CH07 --hard`
- **THEN** 系统 MUST 先二次确认，确认后删除索引条目与本地文件；未确认则中止

### Requirement: nc-lineage-query MUST 输出文字谱系树

`nc-谱系查询`(nc-lineage-query) SHALL 支持：查整 IP 完整谱系树（卷+章节+配套梗概/宣发）、
查单卷带出全部章节与前后置依赖、`--filter <TYPE>` 只看某类物料、`--show-archived`
包含归档条目；输出为文字谱系树（远期 GUI 渲染可视化连线图），每条标注 status 与
follow 依赖及 related 配套物料。

#### Scenario: 查整 IP 谱系树
- **WHEN** 执行 `nc-lineage-query --ip SHZ`
- **THEN** 输出文字谱系树：各卷及其章节、follow 前置依赖、配套 abr/promo 物料，归档条目默认隐藏

#### Scenario: 按类型过滤
- **WHEN** 执行 `nc-lineage-query --ip SHZ --filter MAI`
- **THEN** 仅输出正传时序链（卷→章节），过滤掉宣发/卡片/梗概

### Requirement: 谱系管理 MUST 与既有能力正交联动

`nc-lineage-query`（作品时序谱系）与 `nc-检索`(nc-query，素材/卡片检索) SHALL 职责分离、
互不混用；`nc-编排` MAY 读取谱系按序批量生成下一章/梗概/宣发稿并自动挂靠谱系；
`nc-校阅` SHALL 支持传入 uid 限定只校验单卷/单章，并读取其前置卷设定做一致性校验。
本能力与 `multi-work-management` 正交叠加：多本工程里每本书各自拥有独立的 book-lineage
索引，works[]/--work 作用域契约不变。

#### Scenario: 谱系查询与素材检索分离
- **WHEN** 作者执行 `nc-lineage-query --ip SHZ-MAI-002`
- **THEN** 返回卷 2 正文、前置依赖卷 1、关联角色卡、配套梗概/宣发（走谱系索引），而非 nc-query 的关键词素材命中

#### Scenario: 校阅限定单卷并读前置设定
- **WHEN** 执行 `nc-校阅 --uid SHZ-MAI-002`
- **THEN** 只校验卷 2 正文，自动读取 follow 指向的卷 1 设定做跨卷一致性校验，不把宣发/梗概混入校验

#### Scenario: 存量工程未启用谱系时行为不变
- **WHEN** 使用方工程无任何 `index.yaml`
- **THEN** 视为未启用 book-lineage，全部既有 `nc-*` 技能行为与引入本能力前完全一致；MUST NOT 因缺 index.yaml 报错或强制迁移
