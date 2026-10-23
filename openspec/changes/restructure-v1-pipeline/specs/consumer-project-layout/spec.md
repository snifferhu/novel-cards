# Spec Delta

## Purpose

定义使用方小说工程的目录结构规范：`nc-初始化`（nc-init）生成的完整骨架、各目录职责、`agents.md` 引导文件的生成位置与内容契约，以及 `install.sh --project` 与本 skill `nc-初始化` 的边界划分。

## ADDED Requirements

### Requirement: 工程目录结构

使用方工程根目录 SHALL 具备以下结构：

```
项目根目录/
├── README.md
├── CHANGELOG.md
├── latest.md              # 断点状态
├── agents.md              # Agent 对话引导层（nc-初始化 自动生成；身份/铁律/意图匹配/六组速查）
├── quickstart.md          # 新手主线向导（高频主线路径 + 进阶扩展，隐藏 auto_invokable 标记）
├── skill-reference.md     # 全量技能备查手册（29 技能总表带 auto_invokable 标记 + 入参/产物）
├── res/                   # 素材收件箱（网页/LLM对话/论文/摘抄原样封存）
│   └── inbox/
├── history/               # 定稿快照归档
├── release/               # 导出成品（PDF/Word）
├── cards/
│   ├── corpus/            # 语料卡 co-
│   ├── metrics/           # 量化指标卡 mt-
│   ├── modules/           # 积木模块 md-
│   ├── characters/        # 角色卡 ac-（目录名保留 characters，type 为 actor）
│   ├── tendencies/        # 角色动向滑动标尺卡 tend-（character_tendency）
│   ├── plotpoints/        # 桥段卡 pp-
│   ├── items/             # 道具卡 it-
│   ├── scenes/            # 场景卡 sc-
│   ├── foreshadow/        # 伏笔卡 fs-
│   ├── timeline/          # 动线卡 tl-
│   ├── factions/          # 势力卡 fa-
│   ├── snapshots/         # 快照卡 sn-
│   ├── darklayer/         # 暗线卡 dk-
│   ├── pose-bank/         # 姿态卡 po-
│   ├── lexstats/          # 词频张力卡 lx-
│   └── custom/            # 自定义类型卡片（按类型子目录）
├── registry/              # 注册表 yaml（类型/track/burst-tag/work-length-config/work-setting/safety-blacklist）
├── templates/             # 每个类型独立模板
├── reflections/           # 复盘 rf- / 校阅 review- / 节奏 rhythm- / 守卫 safety-check
├── manuscript/            # 正文手稿
├── graph/                 # 可视化 html 图谱
├── export/                # 导出 pdf / docx 中间产物
├── index/                 # card-graph.json / metric-index.json / lex-batch.json / 检索索引
├── config/
│   ├── project.yaml       # 工程级配置（lang、mode 等）
│   ├── skills.yaml        # 技能元数据（skill_id/name_cn/alias_en/auto_invokable/group/description，供 GUI/脚本引擎读取）
│   └── safety-blacklist.yaml
├── build.cmd              # Windows 构建脚本
└── build.sh               # Unix 构建脚本
```

#### Scenario: 初始化生成骨架
- **WHEN** 作者执行 `nc-初始化`（或 `./install.sh --project <path>`）
- **THEN** 上述全部目录被创建（空目录含 `.gitkeep`），`agents.md` / `quickstart.md` / `skill-reference.md` / `README.md` / `CHANGELOG.md` / `latest.md` / `config/project.yaml` / `config/skills.yaml` / `build.sh` / `build.cmd` 被生成

### Requirement: nc-初始化 能力

`nc-初始化`（nc-init）SHALL 支持：一键生成固定英文目录骨架、build 脚本、三份引导文档（`agents.md` / `quickstart.md` / `skill-reference.md`）与 `config/skills.yaml` 技能元数据；`--lang zh/en` 参数（默认 zh），README/模板/交互文案跟随参数切换；初始化时可指定长短篇预设（short/mid/long），写入 `registry/work-length-config.yaml`。一个项目只运行一次。`config/skills.yaml` SHALL 为每个技能登记 `skill_id` / `name_cn` / `alias_en` / `auto_invokable` / `group` / `description` 字段，供 GUI 与脚本引擎读取做分组折叠与内部联动调度。

#### Scenario: 英文工程初始化
- **WHEN** 执行 `nc-初始化 --lang en --mode long`
- **THEN** 生成的 `agents.md` / `quickstart.md` / `skill-reference.md` / README / 模板均为英文版，`work-length-config.yaml` 设为 long 模式全技能启用，`config/skills.yaml` 含全部 29 技能条目

#### Scenario: skills.yaml 驱动分组折叠
- **WHEN** GUI 读取 `config/skills.yaml` 渲染技能面板
- **THEN** 按 `group` 字段折叠成六组，`auto_invokable` 字段仅在调试视图展示，普通作者视图隐藏

### Requirement: 素材池与资产隔离

`res/` 素材池（网页、LLM 对话、论文、摘抄）仅作为参考源；无作者确认，MUST NOT 写入或覆盖 `cards/` 正式资产。素材分类依靠标签，不靠文件夹层级。原始素材原样封存、不可原地覆盖；`nc-清洗` 生成独立干净副本，原始素材保留不动。

#### Scenario: 素材误写防护
- **WHEN** AI 在提案中引用了 res/ 中的某段素材
- **THEN** 该素材进入 cards/ 前 MUST 经过作者显式确认（及通胀过滤器 gate），AI 绝不自动落盘

### Requirement: install.sh 与 nc-初始化 的边界

`install.sh --project` 负责本仓库侧的工程骨架初始化（纯目录 + 基础文件生成，含 `config/skills.yaml` 占位与三份引导文档兜底，shell 脚本可独立完成）；`nc-初始化` 作为 skill 指令承载更完整的语义（lang 切换、长短篇预设、agents.md / quickstart.md / skill-reference.md 双语模板选择、skills.yaml 全量填充）。两者产出的骨架 MUST 保持一致，避免双入口漂移。

#### Scenario: 双入口一致
- **WHEN** 分别用 `./install.sh --project ~/novel-a` 和在新工程中跑 `nc-初始化`
- **THEN** 两个工程的目录结构（含 cards/tendencies/、config/skills.yaml、quickstart.md、skill-reference.md）与基础文件集合一致

### Requirement: 旧工程迁移说明

文档 SHALL 提供从旧版目录结构（9 类卡 + ch- 前缀 + 12 触发词）到新版结构的迁移指引，至少包含：`character`(ch-)→`actor`(ac-) 的前缀与 type 批量替换规则、新增目录补齐清单、旧 12 触发词到新 25 技能的映射表。迁移为硬切换，不做双轨兼容逻辑。

#### Scenario: 旧工程升级
- **WHEN** 旧使用方工程（已有 cards/characters/ch-*.md 资产）升级到 v1.0
- **THEN** 按迁移指引：批量替换 frontmatter 中 `type: character`→`type: actor`、`id: ch-`→`id: ac-`，补齐 registry/ index/ res/ 等新目录，之后新技能正常工作
