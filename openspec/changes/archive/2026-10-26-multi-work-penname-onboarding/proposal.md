# Proposal

## Why

当前 novel-cards 的工程模型是「一个使用方工程 = 一本作品」：`config/project.yaml` 只承载单本的 `lang / mode / pipeline_option`，全仓没有任何「作者 / 笔名 / 多本作品」的概念（唯一沾边的是 `refwork` 卡的 `author` 字段，但它指外部对标作品的作者，不是本工程的署名主体）。这带来三个真实痛点：① 作者同时创作 / 管理多本作品时，只能开多个互不相通的工程目录，无法在同一项目内统一调度、跨书检索与总览；② 作者有多个笔名（不同平台 / 题材用不同署名）时，无处登记、无法按笔名为某本书或某些章节指定署名，导出成品也带不出正确署名；③ 「快速开始一键安装」只有 `./install.sh` 这一句，没讲清**从哪下载、下载后放哪、装到哪、怎么落地到第一张卡**，新读者照 README 走不通。

## What Changes

- **多本作品管理（同项目）**：引入「工作区（workspace）」概念——一个使用方工程可容纳多本作品，每本书是一个独立子空间（独立 `cards/` / `manuscript/` / `index/` / `graph/` / `registry/` 命名空间 + 独立 `tree_id` 族），由新增的 `works/` 顶层目录组织；`config/project.yaml` 升级为「工程级配置 + `works[]` 作品清单」（每本含 `id / title / mode / lang / default_pen_name / tree_id_root`）。`nc-初始化` 增加「新建一本书」分支（在既有工程内追加一个 work，而非另起工程）；全部 `nc-*` 技能支持 `--work <work-id>` 作用域参数（缺省 = 当前默认书），使同一套技能在多本书间复用而不串数据。
- **署名 / 多笔名管理**：新增 `registry/pen-names.yaml` 笔名白名单（经 `nc-注册` 写入，沿用硬规则「注册前置」机制，skill 不内置锁死词表）；每本作品在 `works[]` 条目里声明 `default_pen_name`，单章 / 单卡可覆写；`nc-导出` 出成品时按作品默认笔名（或章节覆写）落署名，`nc-成稿` 提案头部标注署名。笔名是 registry-backed 枚举，未注册取值拦截提示先走 `nc-注册`。
- **一键安装落地闭环**：把「快速开始」从一句 `./install.sh` 扩成完整落地路径——**获取**（git clone / 下载 release tarball 两条来源，给出确切 URL 与命令）、**放置**（克隆到任意目录即可运行，`install.sh` 以脚本所在目录为 `SRC`，无需固定路径）、**安装**（`--target opencode/claude/both` 装到全局 skills 目录 vs `--link` 软链开发模式，二者差异与适用场景）、**落地**（`--project <path>` 生成使用方工程骨架 → `nc-初始化` 交互式补全 → 第一条 `nc-角色`/`nc-桥段` 指令建出第一张卡的端到端最小路径）。README「快速开始」节与 `templates/quickstart-*.md` 同步补齐这四步，并加「装完怎么验证 skill 生效」的自检命令。
- **无 BREAKING**：存量单本工程 `config/project.yaml` 无 `works[]` 字段时，行为完全不变（视为隐式单本，`work-id` 缺省即该唯一书）；`pen-names.yaml` 为新增 registry 文件，旧工程可后补；`install.sh` 仅增文案与可选 `--work` 透传，不改既有 `--target/--link/--project` 语义。

## Capabilities

### New Capabilities

- `multi-work-management`: 同项目多本作品的组织与调度契约——`works/` 工作区结构、`config/project.yaml` 的 `works[]` 清单、`nc-初始化` 新书分支、`nc-*` 技能的 `--work` 作用域参数、跨书检索与总览；以及署名 / 多笔名管理（`registry/pen-names.yaml` 白名单、作品默认笔名、章节覆写、`nc-导出` 落署名）。
- `install-onboarding`: 从获取到第一张卡的一键安装落地契约——获取来源（clone / tarball）、放置约定（脚本自定位 `SRC`）、安装方式（copy vs link 双端）、`--project` 骨架生成、`nc-初始化` 交互补全、首卡最小路径、装后自检。

### Modified Capabilities

（无——`repo-sync` 等既有能力不涉及；`card-schema` 的 `refwork.author` 语义保持「外部对标作品作者」不变，本变更的署名主体是「本工程署名 / 笔名」，二者正交。）

## Impact

- **使用方工程骨架**：`install.sh --project` 新增 `works/` 顶层目录 + `config/project.yaml` 的 `works[]` 占位 + `registry/pen-names.yaml` 空骨架；`nc-初始化` 产物同步。
- **config 层**：`config/project.yaml` 从「单本工程配置」升级为「工程配置 + works[] 清单」（向后兼容：无 `works[]` = 隐式单本）。
- **registry 层**：新增 `registry/pen-names.yaml`（笔名白名单，骨架 only，经 `nc-注册` 填充）。
- **技能层**：`nc-初始化`（新书分支）、`nc-检索`（跨书）、`nc-导出`（落署名）、`nc-成稿`（署名标注）职责扩展；全部 `nc-*` 技能接受可选 `--work` 作用域参数（缺省 = 默认书，零破坏）。
- **文档层**：README「快速开始」节重写为四步落地闭环 + 装后自检；`templates/quickstart-zh.md` / `quickstart-en.md` 同步；`references/layout.md` 收录 `works/` 与 `pen-names.yaml`；`references/skill-catalog.md` 相关技能行补 `--work` / 署名入参。
- **不受影响**：卡片字段契约（五必备字段不变）、提案制铁律、审计只读铁律、`tools/nc_validate.py` 只读运行时、OO 透镜（`works/` 可表述为 `StoryWorld` 下挂多个作品子容器，属 OO 模型的天然延伸，不改变类层次）、双端兼容 frontmatter 三键。
- **风险面**：`works[]` 引入后 `nc-*` 技能的作用域解析（缺省书如何确定、`--work` 缺失时是否报错）需在 design 明确，避免多书工程下技能误操作到错误的书。
