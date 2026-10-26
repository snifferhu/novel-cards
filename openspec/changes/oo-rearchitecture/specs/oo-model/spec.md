# Spec Delta: oo-model

## Purpose

定义 novel-cards 的面向对象（OO）概念模型：所有叙事资产统一为 `NcObject` 抽象基类的实例，技能是对象的方法，流程是对象间消息传递；并提供草稿新命名到现有 v1.0 schema 的对齐规则，使「文字只是视图、真相在对象实例里」成为可校验的系统心智。

## ADDED Requirements

### Requirement: NcObject 抽象基类契约

系统 SHALL 把全部叙事卡片资产建模为统一抽象基类 `NcObject` 的实例，所有子类共享一组公共属性与公共方法契约。公共属性 MUST 对齐现有 frontmatter 通用五字段并扩展检索/权限维度；公共方法 MUST 覆盖渲染、自检、快照、增量修改四类行为。该基类是**概念契约**（由文档承载），不要求存在同名运行时类。

#### Scenario: 公共属性对齐现有五字段

- **WHEN** 任一卡片类型被建模为 `NcObject` 实例
- **THEN** 其公共属性 MUST 包含 `id`（含类型前缀，全局唯一）、`type`、`status`、`created`、`updated` 五项，且取值语义与 `references/card-schema.md` 通用五字段逐字一致
- **AND** 可选扩展属性 `name` / `tags` / `private` / `remark` 仅在不破坏现有 schema 的前提下作为概念别名出现，MUST NOT 强制要求每张卡新增这些 frontmatter 字段

#### Scenario: 公共方法四件套

- **WHEN** 描述任一子类的行为能力
- **THEN** MUST 能映射到四个公共方法之一：`render()`（把对象序列化为文本，各子类实现不同）、`validate()`（自检内部冲突，对应 `nc-校阅` 内置能力）、`snapshot()`（生成当前状态快照存入 history）、`patch()`（增量修改并记录变更日志）
- **AND** `render()` MUST 标注为抽象方法（基类不实现，子类各自实现）

### Requirement: 核心业务子类与现有卡类型一一对应

系统 SHALL 定义 8 个核心业务子类，每个子类 MUST 对应一个已存在的 v1.0 卡类型（或明确的卡类型组合），不得凭空引入无对应落地的新卡类型。子类自有属性与方法签名 MUST 能在现有 `card-schema.md` 字段中找到承载。

#### Scenario: 八子类映射表

- **WHEN** 列出 OO 子类清单
- **THEN** MUST 满足如下映射：`Role`→`actor`(`ac-`)、`Prop`→`item`(`it-`)、`Scene`→`scene`(`sc-`)、`SensoryCue`→`sensory_cue`(`su-`)、`PlotBeat`→`plotpoint`(`pp-`)、`StoryTrack`→`timeline`(`tl-`)、`DarkLine`→`darklayer`(`dk-`)、`Snapshot`→`snapshot`(`sn-`)
- **AND** `Role` 的性格滑动标尺 MUST 通过引用独立 `character_tendency`(`tend-`)卡表达（`disposition_slide` 为其概念别名），MUST NOT 把动向塞进 `actor` 卡字段
- **AND** `Role` 的姿态库 MUST 通过引用独立 `pose`(`po-`)卡表达（`pose_bank[]` 为其概念别名），经 `pose_refs` 串接

#### Scenario: 子类方法签名

- **WHEN** 描述子类行为
- **THEN** `Role` MUST 暴露 `act(trigger_event)`（沿动向标尺滑动 + 切换姿态）、`perceive(scene)`（捕获场景内感官信号）、`get_pose(state_id)`（调取姿态保证跨场景一致）
- **AND** `Prop` MUST 暴露 `move_to(scene, position)`（动线变更触发关联伏笔检查）、`emit_sensory()`（释放感官 cue）
- **AND** `Scene` MUST 暴露 `enter(role)`（角色进入触发环境感官/光源变化）、`refresh_env()`（刷新环境变量插槽）
- **AND** `SensoryCue` MUST 暴露 `broadcast()`（向外扩散，范围内 Role 自动 perceive）
- **AND** `PlotBeat` MUST 暴露 `fire()`（前置条件满足时引爆并派发事件给场内对象）
- **AND** `StoryTrack` MUST 暴露 `step(timeline)`（沿时间轴推进输出状态变更）
- **AND** `DarkLine` MUST 暴露 `check_converge()`（扫描全场判断伏笔是否集齐、暗线可否回收）
- **AND** `Snapshot` MUST 暴露 `restore()`（回滚整套对象到该快照状态）

### Requirement: StoryWorld 全局容器

系统 SHALL 定义全局容器 `StoryWorld` 作为整个叙事世界的运行沙盒，挂载全部对象实例并持有世界级状态。容器的属性与方法 MUST 与现有工程结构（注册表/timeline/inbox/config/safety_guard）及既有技能职责对齐。

#### Scenario: 容器属性

- **WHEN** 实例化 `StoryWorld`
- **THEN** MUST 持有：`objects`（全部资产注册表，对应 `index/card-graph.json` 图森林 + `cards/**`）、`timeline`（全局章节时序）、`inbox`（待入库原始素材，对应 `res/inbox/`）、`config`（项目配置：lang / 安全黑名单 / 篇幅模式 short-mid-long）、`safety_guard`（安全校验实例，对应 `nc-守卫`）

#### Scenario: 容器方法映射既有技能

- **WHEN** 调用容器方法
- **THEN** `query(filter)` MUST 对应 `nc-检索`、`import_raw(source, content)` MUST 对应 `nc-素材`、`clean_object(obj)` MUST 对应 `nc-清洗`、`plan_modify(change_request)` MUST 对应 `nc-编排`、`audit()` MUST 对应 `nc-校阅` 的全局批量审计、`deliberate()` MUST 对应 `nc-研判`、`export()` MUST 对应 `nc-导出`/`nc-成稿` 的 render 阶段
- **AND** `constructor()` MUST 对应 `nc-初始化`（实例化世界、生成目录骨架与配置）

### Requirement: 技能即方法的映射完整性

系统 SHALL 提供一张「29 技能 → OO 方法」完整映射表，使每个 `nc-` 技能都能表述为 `StoryWorld` 或某个子类的成员方法。技能集合、六组分类、`auto_invokable` 标记 MUST 保持不变，本要求仅换 OO 视角表述。

#### Scenario: 全量映射无遗漏

- **WHEN** 对照 29 技能清单与 OO 方法映射表
- **THEN** 每个技能 MUST 有且仅有一个主归属方法（允许一个技能映射到「子类方法 + 容器方法」组合，如 `nc-校阅`→`NcObject.validate()`+`StoryWorld.audit()`）
- **AND** 映射表 MUST 保留 `nc-对标`(nc-refwork) 作为分析模式专用条目（不计入六组 29 技能，但出现在映射表保证解析完整）
- **AND** MUST NOT 因 OO 重构而增删任何技能或改变其六组归属

### Requirement: 草稿新命名到现有 schema 的对齐规则

系统 SHALL 显式给出草稿中非 v1.0 命名的对齐规则，避免双轨漂移。对齐 MUST 以现有 schema 为准，草稿命名仅作概念别名。

#### Scenario: 命名对齐表

- **WHEN** 文档中出现草稿新命名
- **THEN** MUST 按如下规则对齐：`uuid`→`id`（含类型前缀）、`create_at`/`update_at`→`created`/`updated`、`disposition_slide:Track`→`character_tendency`(`tend-`)卡、`pose_bank[]`→独立 `pose`(`po-`)卡经 `pose_refs` 引用、`MoodLine`→无 v1.0 直接对应，映射到 `lexstat`(`lx-`)张力曲线 + `metric`(`mt-`)量化指标并标注为概念别名
- **AND** `status` 枚举【草稿/备选/生效/归档/废弃】MUST 对齐到现有生命周期（`draft`/`candidate`/`active`/`archived` + 各类型特殊态），MUST NOT 引入与现有 `status` 冲突的新枚举值
- **AND** 任何草稿命名 MUST NOT 作为 frontmatter 字段名落地，仅可在 OO 概念文档中以「别名」形式出现
