# 书内谱系管理（lineage.md）

novel-cards v1.0 提供**书内谱系管理**能力：在一本作品内部，把正传分卷、章节、精简缩略版
（3k–5k）、配套宣发物料（10s/30s/1min/5min 介绍）、卡片资产、草稿备选、校阅测试样例、
外部参考等物料，按**语义化命名 + 浅目录 + 机器维护的逻辑谱系索引**组织起来。作者只需记住
IP 编号，谱系归属 / 卷册从属 / 时序依赖 / 关联物料全部交给工具托管，并能对新建与已有文稿
做增删改查。

> **定位边界**：本能力管「**一本书内部**」的卷 / 章节 / 物料谱系；「**整本书**」之间的隔离
> （works/<id>/ 子空间 + works[] 清单 + --work 作用域 + 多笔名署名）由
> `multi-work-management` 能力承接。两者**正交叠加**——多本工程里每本书各自拥有自己独立的
> book-lineage 索引，互不干扰。详见 §6。

## 1. uid 命名规范

每本书的谱系物料以全局唯一主键 `uid` 标识，格式：

```
IP-TYPE-卷号[-CH章节]        # 正传正文（MAI）
IP-TYPE-V版本                # 精简缩略（ABR）
IP-TYPE-时长档               # 宣发文案（PRO）
IP-TYPE-类别码               # 资产卡片（CAR）/ 草稿（DRF）/ 测试（TST）/ 参考（REF）
```

### 1.1 IP 短码

- MUST ≥3 字符（一个独立 IP 永久固定，如 `SHZ`=山河志、`HXX`=河下序、`YES`=夜祀）。
- MUST NOT 使用 2 字符缩写（易撞、歧义，如 `SZ` 与 `SZX`）。
- 字母大写，可含数字；一经登记不可变更（改名走 `nc-更名`，不在谱系层重定义 IP 短码）。

### 1.2 类型缩写（固定 7 类，MUST NOT 自造）

| 缩写 | 全称 | 含义 | 典型编号形态 |
|---|---|---|---|
| `MAI` | MainText | 正传正文（分卷、分章主体文稿） | `SHZ-MAI-001`（卷一）/ `SHZ-MAI-001-CH05`（卷一第五章） |
| `ABR` | Abridged | 精简缩略版（3k–5k 字梗概） | `SHZ-ABR-V01`（第一版） |
| `PRO` | Promo | 宣发文案包（各类时长介绍） | `SHZ-PRO-S10` / `S30` / `M01` / `M05` |
| `CAR` | Cards | NAVI 资产卡片库（角色、桥段、道具、动线等） | `SHZ-CAR-ROL`（角色卡合集）/ `SHZ-CAR-PLT`（桥段卡合集） |
| `DRF` | Draft | 临时草稿、备选分支、废弃线 | `SHZ-DRF-001` |
| `TST` | TestCase | 校阅测试样例 | `SHZ-TST-001` |
| `REF` | Reference | 外部参考素材、史料、论文、对话记录 | `SHZ-REF-001` |

**铁律**：类型缩写限定死为上表 7 类，**禁止自造新缩写**。所有物料必须归入这 7 类之一；
`CAR` 已聚合全部卡片资产，无需为角色 / 桥段 / 道具等再细分类型缩写。若未来确需新增物料
大类，走正式 spec 变更扩展白名单，绝不在运行期自造。

### 1.3 编号规则

- **分卷**：零填充顺序编号 `001` / `002` / `003`……（不用 `1` / `2`）。
- **章节**：`-CHxx` 后缀，如 `SHZ-MAI-001-CH05`（卷一第五章）；一卷内部章节靠文件名后缀区分。
- **版本**：`Vxx`，如 `SHZ-ABR-V01`；版本迭代只用 V1/V2/V3，不随便加别的后缀。
- **宣发时长**：固定四档 `S10` / `S30` / `M01` / `M05`（10 秒 / 30 秒 / 1 分钟 / 5 分钟），
  **统一口径，不搞 S15 / M03 这种自定义时长**。
- **uid 正则**：`^[A-Z]{3,}-[A-Z]{3}-\d{3}(-CH\d{2})?$`（MAI 卷/章节形态）；ABR/PRO/CAR/DRF/TST/REF
  的后缀形态（`Vxx` / `Sxx`/`Mxx` / 类别码）由对应类型约定，校验时按类型分别匹配。

**好处**：同 IP 自动凑一块排序；看到缩写就知道是什么物料，不用点开文件；单看文件名即可识别
归属——哪怕临时把文件复制到桌面平铺，依然可读、可检索、不丢失归属信息。

## 2. 物理目录约定（浅层级 ≤1 层）

每本书根目录下**最多一层**物料子文件夹，MUST NOT 出现二级及以上嵌套（禁止 `MAI/vol1/chapter01`
这类多层目录）：

```
SHZ/                     # IP 根目录（仅此一层 IP 隔离）
├─ index.yaml            # 本书逻辑谱系索引（真值，skill 自动维护）
├─ MAI/                  # 正传正文（仅一层，不再往下套）
│  ├─ SHZ-MAI-001.md     # 卷一
│  ├─ SHZ-MAI-002.md     # 卷二
│  └─ SHZ-MAI-001-CH05.md # 卷一第五章（章节用文件名后缀，不建子目录）
├─ ABR/
│  └─ SHZ-ABR-V01.md
├─ PRO/
│  ├─ SHZ-PRO-S10.md
│  ├─ SHZ-PRO-S30.md
│  ├─ SHZ-PRO-M01.md
│  └─ SHZ-PRO-M05.md
├─ CAR/
├─ DRF/
├─ TST/
└─ REF/
```

**为什么浅目录**：层级越深，作者要记忆的路径越长（`SHZ/MAI/VOL1/CH5.md`），一旦忘了在哪一层，
查找成本飙升。浅目录 + 文件名自带完整谱系信息，两套模式都能跑——文件管理器按名称排序天然排成
卷 1→卷 2→卷 3；直接平铺到外面也不丢归属。

**双轨制核心**：物理存储是浅目录（不折磨记忆），逻辑谱系是一张虚拟树（`index.yaml` 知道谁是谁的
前传、谁是配套缩略稿）。作者只记 IP 编号，**谱系、前后顺序、关联物料交给索引表，不用人脑记层级**。

## 3. index.yaml 逻辑谱系索引（schema）

每本书一份 `index.yaml`，是**逻辑谱系真值**：记录谱系关系、卷册从属、章节归属、时序依赖、
关联物料、状态与软删除标记。该文件 SHALL 由 `nc-lineage-*` 技能自动读写，人 SHOULD NOT 手改；
手改损坏时 `nc-lineage-query` MUST 报错并附校验提示，MUST NOT 静默吞错。

### 3.1 字段契约

顶层结构：

```yaml
ip_id: SHZ              # IP 短码（≥3 字符，与目录名一致）
ip_name: 山河志          # IP 中文全名
status: writing         # 整书状态：构思中 / 连载中 / 定稿 / 搁置
last_modified: "2026-10-28"   # 最近一次谱系操作时间戳（skill 自动更新）
lineage:                # 谱系条目列表（卷 / 章节 / 物料）
  - <entry>
related:                # 跨类型关联物料（挂在整书层面）
  abr:   ["SHZ-ABR-V01"]
  promo: ["SHZ-PRO-S10", "SHZ-PRO-S30", "SHZ-PRO-M01", "SHZ-PRO-M05"]
  car:   ["SHZ-CAR-ROL", "SHZ-CAR-PLT"]
```

每个 `lineage` 条目（`<entry>`）字段：

| 字段 | 必填 | 说明 |
|---|---|---|
| `uid` | ✅ | 全局唯一主键，遵循 §1 命名规范；所有 nc-lineage 操作靠 uid 定位，不依赖路径 |
| `type` | ✅ | 取自 7 类固定缩写（MAI/ABR/PRO/CAR/DRF/TST/REF） |
| `vol` | MAI 卷 | 卷号（零填充字符串，如 `"001"`） |
| `ch` | MAI 章节 | 章节号（如 `"05"`），仅章节条目有 |
| `ver` | ABR | 版本号（如 `V01`） |
| `tag` | PRO/CAR/DRF/TST/REF | 时长档（S10/S30/M01/M05）或类别码（ROL/PLT…）或序号 |
| `title` | ✅ | 人类可读标题（如「卷一 风起荒原」/「第五章 雨夜渡口相逢」） |
| `file_path` | 落盘后 | 相对本书根的磁盘路径（如 `./MAI/SHZ-MAI-001-CH05.md`）；`--exist-file` 挂靠时指向已有文件 |
| `status` | ✅ | 构思中 / 连载中 / 定稿 / 搁置 |
| `archived` | ✅ | 软删除标记（false 默认 / true 归档） |
| `follow` | 可选 | 前置依赖 uid（表达时序，如卷二 `follow: SHZ-MAI-001` 接在卷一之后）；无前置为 `null` |
| `children` | 卷级 | 从属章节 uid 列表（如卷一的 `[SHZ-MAI-001-CH01, ...]`） |

### 3.2 示例（SHZ 假名 IP）

```yaml
ip_id: SHZ
ip_name: 山河志
status: writing
last_modified: "2026-10-28"
lineage:
  - uid: SHZ-MAI-001
    type: MAI
    vol: "001"
    title: "卷一 风起荒原"
    follow: null
    status: finished
    archived: false
    children: [SHZ-MAI-001-CH01, SHZ-MAI-001-CH02, SHZ-MAI-001-CH05]
  - uid: SHZ-MAI-001-CH05
    type: MAI
    vol: "001"
    ch: "05"
    title: "第五章 雨夜渡口相逢"
    file_path: "./MAI/SHZ-MAI-001-CH05.md"
    status: writing
    archived: false
  - uid: SHZ-MAI-002
    type: MAI
    vol: "002"
    title: "卷二 江海归舟"
    follow: SHZ-MAI-001        # 时序依赖：接在卷一之后
    status: waiting
    archived: false
    children: []
  - uid: SHZ-ABR-V01
    type: ABR
    ver: V01
    title: "山河志精简梗概 3k-5k"
    file_path: "./ABR/SHZ-ABR-V01.md"
    status: writing
    archived: false
related:
  abr:   ["SHZ-ABR-V01"]
  promo: ["SHZ-PRO-S10", "SHZ-PRO-S30", "SHZ-PRO-M01", "SHZ-PRO-M05"]
  car:   ["SHZ-CAR-ROL", "SHZ-CAR-PLT"]
```

### 3.3 校验规则（nc-lineage-query 读取前执行，fail-loud）

- **uid 全局唯一**：重复 uid → 报错指出冲突项。
- **follow 无环**：沿 follow 链遍历检测环形依赖 → 报错指出环上 uid。
- **命名格式**：uid 须匹配 §1.3 正则（按类型分别匹配）→ 非法格式报错。
- **file_path 存在性**：可选 L2 警告（文件被手动移动 / 删除后索引仍指旧 path 时提示，不阻断），
  建议用 `nc-lineage-edit` 修正路径或重新 `--exist-file` 挂靠。

## 4. 四个 nc-lineage-* 技能调用契约

四个技能均为 `user_trigger_only`（auto_invokable=false），中英文双别名，归入 C 剧情结构组。
全部接受可选 `--work <work-id>` 限定作用域（复用 multi-work 的 active_work/--work 解析链）。

### 4.1 nc-谱系新增 / nc-lineage-add

支持三类新增：**卷**、**章节**、**配套物料**（梗概 / 宣发 / 卡片 / 草稿 / 测试 / 参考）。

```
# 新增卷
nc-lineage-add --ip SHZ --type MAI --vol 001 --title "卷一 风起荒原"
# 新增章节（自动绑定从属卷）
nc-lineage-add --ip SHZ --type MAI --vol 001 --ch 05 --title "第五章 渡口相逢"
# 新增配套物料
nc-lineage-add --ip SHZ --type ABR --ver V01 --title "山河志精简梗概3k-5k"
nc-lineage-add --ip SHZ --type PRO --tag S10 --title "10s宣发口播"
# 挂靠已有 md（不新建文件，仅登记索引）
nc-lineage-add --ip SHZ --type MAI --vol 001 --ch 06 --title "第六章 山道伏击" \
  --exist-file ./MAI/SHZ-MAI-001-CH06.md
# 恢复软删除条目
nc-lineage-add --restore SHZ-MAI-001-CH07
```

**自动行为**：
1. 校验参数：IP 存在、3 字符类型码合法（∈ 7 类）、卷号 / 章节号 / 版本不重复（重复 uid 拦截）。
2. 在 `SHZ/index.yaml` 写入这条谱系记录，自动绑定从属（CH05 归属 VOL001 的 children）。
3. 在对应目录生成空白文件：`SHZ/MAI/SHZ-MAI-001-CH05.md`（`--exist-file` 时跳过新建）。
4. 自动更新 `index.yaml` 的 `last_modified`。
5. 写入 CHANGELOG.md，记录：新增【SHZ-MAI-001-CH05】。

**已有文稿挂靠**（`--exist-file`）：不新建文件，仅在索引登记从属 / 时序 / 标题，瞬间纳入谱系
管理，后续查询 / 溯源 / 联动校阅都生效。**兜底**：若文件名不遵守规范，skill 提示警告，询问是否
自动重命名对齐规范。

### 4.2 nc-谱系修改 / nc-lineage-edit

用来改标题、调换顺序（时序）、变更归属、标记状态。

```
# 修改章节标题
nc-lineage-edit --ip SHZ --id SHZ-MAI-001-CH05 --title "第五章 雨夜渡口相逢"
# 调整时序：卷2的前置依赖改成卷1
nc-lineage-edit --ip SHZ --id SHZ-MAI-002 --follow SHZ-MAI-001
# 把某章节从卷1挪到卷2（变更归属）
nc-lineage-edit --ip SHZ --id SHZ-MAI-001-CH09 --move-to-vol 002
# 修改状态：连载中 / 定稿 / 搁置
nc-lineage-edit --ip SHZ --id SHZ-MAI-001 --status finished
# 同步重命名文件（默认不改文件名，显式才改）
nc-lineage-edit --ip SHZ --id SHZ-MAI-001-CH05 --rename-file
```

**自动行为**：
- **只改 index.yaml 的逻辑关系，默认不改动文件名**——逻辑从属和文件名解耦，方便临时调整谱系
  试错，不想改文件名时就不动。仅当显式加 `--rename-file` 才同步重命名磁盘文件。
- 写 CHANGELOG 变更记录。

### 4.3 nc-谱系移除 / nc-lineage-del

分两种模式，**默认软删除**（推荐，防止误删）。

```
# 软删除：索引标记 archived，文件保留，不再出现在正常谱系树，可恢复
nc-lineage-del --ip SHZ --id SHZ-MAI-001-CH07
# 硬删除：索引删掉 + 本地文件直接删除（高危，需二次确认）
nc-lineage-del --ip SHZ --id SHZ-MAI-001-CH07 --hard
```

**自动行为**：
- 软删除只是加字段 `archived: true`，文件保留；检索谱系时默认过滤归档条目。
- 查询归档可加 `--show-archived`（见 nc-lineage-query）。
- 恢复软删除条目走 `nc-lineage-add --restore <uid>`。
- 硬删除 MUST 先二次确认，确认后删除索引条目与本地文件；未确认则中止。

### 4.4 nc-谱系查询 / nc-lineage-query（最常用）

```
# 查整个 IP 完整谱系树（卷+章节+配套梗概宣发）
nc-lineage-query --ip SHZ
# 查单卷，带出它所有章节、前置后置
nc-lineage-query --ip SHZ --id SHZ-MAI-001
# 只看正传时序链，过滤宣发、卡片
nc-lineage-query --ip SHZ --filter MAI
# 包含归档条目
nc-lineage-query --ip SHZ --show-archived
```

**输出**（文字谱系树，远期 GUI 渲染成可视化连线图）：

```
【SHZ 山河志】
├─ MAI-001 卷一 风起荒原 [finished]
│  ├─ CH01 荒原来客
│  ├─ CH02 破庙夜谈
│  └─ CH05 雨夜渡口相逢 [writing]
└─ MAI-002 卷二 江海归舟 [waiting]
   ↳ 前置依赖：MAI-001
配套物料：
• ABR-V01 精简梗概
• PRO-S10 / PRO-S30 / PRO-M01 / PRO-M05
```

**读取前校验**：执行 §3.3 校验规则（uid 唯一 / follow 无环 / 命名格式 / file_path 存在性 L2
警告）；损坏 fail-loud 报错，不静默返回错误谱系树。

## 5. 与既有能力联动

- **nc-检索 (nc-query)**：命中**素材 / 卡片**资产（关键词 / 标签 / 类型筛选）；
  **nc-lineage-query**：命中**作品时序谱系**（卷 / 章节 / 物料的从属与前后置）。二者职责分离，
  互不混用——找「哪张角色卡写了复仇动机」走 nc-检索，查「卷二接在谁后面、配套哪些宣发稿」走
  nc-lineage-query。
- **nc-编排 (nc-compose)**：MAY 读取谱系，按 follow 时序批量生成下一章 / 梗概 / 宣发稿，
  产物自动挂靠谱系（登记进 index.yaml）。
- **nc-校阅 (nc-review)**：SHALL 支持传入 `--uid` 限定只校验单卷 / 单章，并自动读取其
  `follow` 指向的前置卷设定做跨卷一致性校验；不把宣发 / 梗概混入正文校验。
- **multi-work-management**：正交叠加。多本工程里每本书各自拥有独立 book-lineage 索引；
  lineage 技能同样接受 `--work` 限定作用域，缺省歧义时复用 multi-work 的「不静默猜测」规则。

## 6. 与 multi-work-management 的边界

| 维度 | multi-work-management | book-lineage（本能力） |
|---|---|---|
| 管理粒度 | **整本书**（works/<id>/ 子空间） | **一本书内部**（卷 / 章节 / 物料） |
| 核心数据结构 | `config/project.yaml` 的 `works[]` 清单 | 每本书一份 `index.yaml` 谱系索引 |
| 作用域机制 | `--work <work-id>` + `active_work` 指针 | 复用同一套 `--work` 解析链 |
| 解决的问题 | 多本书并行不串卡、多笔名署名 | 单本书内卷册 / 物料谱系不散乱、可溯源 |

两者正交：多本工程 = N 个 works/<id>/ 子空间，每个子空间内部各有一套 book-lineage 索引。
本能力**不改变** works[] / --work 的任何契约。

## 7. 边界铁律（防体系崩坏）

1. **类型缩写固定 7 类**（MAI/ABR/PRO/CAR/DRF/TST/REF），MUST NOT 自造新缩写；IP 短码 MUST ≥3 字符。
2. **目录嵌套深度上限**：IP 根目录下面最多一层子文件夹，MUST NOT 出现二级以上文件夹。
3. **时序 / 谱系 / 前后依赖只写在 index.yaml 的 `follow` / `children` 字段**，MUST NOT 靠文件夹
   嵌套或文件夹顺序表达剧情先后。
4. **uid 严格遵循 `IP-3位码-编号` 格式**，全局唯一；所有 nc-lineage 操作靠 uid 定位，不依赖路径。
5. **人优先用 nc-lineage-* 指令，SHOULD NOT 直接手改 index.yaml**；若手动改坏，后续 query 会
   fail-loud 报错（附校验提示），不静默吞错。
6. **改名分离**：逻辑改名（title）随时改；文件名改名需显式 `--rename-file`，避免批量连锁错乱。
7. **软删除优先**：nc-lineage-del 默认 `archived: true`（文件保留、可恢复）；硬删除 MUST 需
   `--hard` 并二次确认。
8. **向后兼容**：存量工程无 `index.yaml` 时视为未启用 book-lineage，全部既有 `nc-*` 技能行为
   与引入本能力前完全一致；MUST NOT 因缺 index.yaml 报错或强制迁移。

## 8. 远期 GUI 映射（TODO-only，不在当前范围）

- **谱系树面板** = nc-lineage-query 的可视化输出（文字树渲染成连线图）。
- **右键菜单**：新增卷 / 新增章节 / 挂靠已有文件 / 编辑 / 归档 → 直接映射上面 4 个 skill。
- **拖拽**：拖拽章节节点换归属、调换顺序 → 底层自动调用 nc-lineage-edit。
