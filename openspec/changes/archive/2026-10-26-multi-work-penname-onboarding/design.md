# Design

## Context

本仓库是 novel-cards skill 定义仓库（无构建 / 无依赖 / 无运行时，除可选只读 `tools/nc_validate.py`）。当前工程模型是「一个使用方工程 = 一本作品」：`config/project.yaml` 仅承载单本 `lang / mode / pipeline_option`，全仓无作者 / 笔名 / 多书概念。三个痛点见 proposal.md Why。本设计只改 skill 的**文档 / 模板 / config 骨架 / registry 骨架 / install.sh 文案与可选透传**层，不引入新运行时、不改卡片字段契约、不破提案制与双端兼容铁律。

## Goals / Non-Goals

**Goals**
- 同项目可组织多本作品（`works/` 工作区 + `works[]` 清单 + `--work` 作用域），数据隔离、跨书检索、总览可用。
- 多笔名署名经 `registry/pen-names.yaml` 白名单管理，作品默认笔名 + 章节覆写，`nc-导出`/`nc-成稿` 落署名。
- 「快速开始」补齐获取 → 放置 → 安装 → 落地首卡 → 装后自检的完整闭环。
- 全部向后兼容：存量单本工程零行为变化。

**Non-Goals**
- 不做跨工程的「作品集 / 出版管理台」（那是另一个量级，超出本 skill 边界）。
- 不做笔名的版权 / 法律校验（属合规域，已有 `references/compliance.md` 覆盖内容摘录合规，署名本身不涉及）。
- 不引入数据库或新运行时；`works[]` 与 `pen-names.yaml` 都是纯 `.yaml` 配置，沿用四层分层的 `.yaml` 白名单层。
- 不改 `refwork.author` 语义（外部对标作品作者，与本变更的「本工程署名主体」正交）。

## Decisions

### D1 — 多书用「工程内 `works/` 子空间」而非「多工程目录」

**选择**：一个使用方工程根下新增 `works/` 顶层目录，每本书 = `works/<work-id>/` 独立子空间（含该书自己的 `cards/ manuscript/ index/ graph/ registry/` + 单书 config 片段）；工程根的 `config/project.yaml` 持有 `works[]` 清单做索引。

**理由**：用户痛点①明确是「同项目共创 / 同时管理多本」——要的是**同一项目内的统一调度**（跨书检索、总览、共享 registry 词表如自定义类型 / 动向原型），而非一堆互不相通的目录。工程级共享物（`registry/` 的类型 / track / 原型 / 笔名白名单、`tools/`、`build.sh`）放工程根，书级私有物（cards/manuscript/index/graph）下沉到 `works/<id>/`。

**备选**：
- 多工程目录（现状延伸）：无法跨书检索 / 总览，共享词表要重复维护，正是痛点①。
- 单工程扁平多书（所有书共用一个 `cards/`，靠 `tree_id` 区分）：图森林已支持多 `tree_id`，但 `cards/` 文件层面会混在一起，目录导航与「删一本书」都困难；`works/` 子空间在文件系统层面就隔离，更直观。

**OO 对齐**：`works/` 天然表述为 `StoryWorld` 容器下挂多个「作品子容器」（每个子容器自身也是一组 `NcObject` + 局部 `index` 图森林），是 `references/oo-model.md` 类层次的延伸，不新增基类 / 子类，不破坏 OO 透镜一致性自检。

### D2 — `works[]` 缺省 = 隐式单本，保证零破坏

**选择**：`config/project.yaml` 的 `works[]` 为**可选**字段。缺失时，整个工程视为唯一隐式 work（work-id = 工程根，`tree_id_root` = 既有默认值）。`nc-*` 技能的 `--work` 参数同样可选，缺省解析到「当前默认书」。

**当前默认书确定规则（消除多书歧义）**：
1. 显式 `--work <id>` → 用之。
2. 否则读 `config/project.yaml` 的 `active_work` 指针（`nc-初始化 --new-work` 或首次 `--work` 操作时更新）。
3. 否则若 `works[]` 恰好一条 → 即之。
4. 否则（多书且无 `active_work`）→ **不静默猜测**，提示作者用 `--work` 指定，并列出候选。

**理由**：规则 4 的「宁提示不猜错」是多书场景的安全底线——技能误操作到错误的书比报错代价高得多。单本工程（绝大多数存量）永远命中规则 3，行为与今天完全一致。

### D3 — 笔名走 registry 白名单，复用「注册前置」硬规则

**选择**：`registry/pen-names.yaml` 存笔名条目（`key / display_name / note`），骨架 only、零预置，经 `nc-注册` 写入；`works[].default_pen_name` 与章节覆写都引用其 key。未注册取值拦截。

**理由**：与 `tendency-prototypes.yaml`（周末刚加的动向原型白名单）、自定义类型 / track 标签白名单完全同构——都是「skill 不内置锁死枚举、取值经 nc-注册 进 registry」的既有机制，作者心智一致，审计层（`nc-校阅`）也能机器校验「引用的笔名是否已注册」。

**备选**：把笔名直接写死在 `config/project.yaml`（不走 registry）。否决：失去注册前置的统一性与机器校验能力，且与既有 registry 白名单模式割裂。

### D4 — 一键安装补「四步闭环 + 自检」，只改文档与 install.sh 文案

**选择**：README「快速开始」节重写为四步（获取 / 放置 / 安装 / 落地首卡）+ 装后自检小节；`templates/quickstart-zh.md` / `quickstart-en.md` 同步；`install.sh` 头部注释与结尾提示语补齐「从哪下载、放哪、装哪、下一步跑什么」。`install.sh` 逻辑改动仅限：结尾 echo 增加指向 quickstart 的下一步指引、可选透传 `--work`（给 `--project` 生成的骨架 `config/project.yaml` 预填首个 work 条目）。

**理由**：痛点③纯粹是**文档断点**，不是脚本缺陷——`install.sh` 已能自定位 `SRC`、已支持 copy/link/双端/`--project`。所以本决策几乎全是文档工作，脚本改动极小，风险最低。

**获取来源 URL**：git clone 用仓库真实地址（`github.com:snifferhu/novel-cards.git`，与 git remote 一致）；tarball 用 GitHub release 下载链接（若仓库尚未打 release tag，则文档注明「以最新 tag 的 Source code (tar.gz) 为准」，不虚构具体版本号）。

### D5 — `nc-初始化` 加「新书分支」，与「新工程分支」并存

**选择**：`nc-初始化` 检测当前目录：若是已初始化的工程根（有 `config/project.yaml`）→ 进入「追加一本书」分支（生成 `works/<id>/` 子空间 + 追加 `works[]` 条目）；若是空目录 → 走既有「新工程」分支（生成完整工程骨架，含首个隐式 / 显式 work）。

**理由**：同一个入口命令按上下文分流，作者无需记两套命令；「在这个项目里再开一本」自然映射到 `nc-初始化`。

## Risks / Trade-offs

- [`works/` 子空间让既有「工程根即 cards/ 父目录」的路径假设失效] → 所有 `nc-*` 技能的路径解析改为「工程根 + （可选）works/<id>/」前缀拼接；单本工程下该前缀为空串，路径与今天逐字相同。design 要求实现时集中处理路径基址，不散落硬编码。
- [多书 + 缺 `active_work` 时技能频繁提示打断心流] → 规则 2 让「最近操作的书」成为默认，连续创作同一本书时无需反复 `--work`；只有真正切换书且无指针时才提示。
- [`pen-names.yaml` 与 `tendency-prototypes.yaml` 等 registry 文件增多，骨架膨胀] → 都是骨架 only（空结构 + 占位注释），由 `nc-初始化` 填充，`install.sh --project` 只建目录与 .gitkeep，体量可控。
- [文档四步闭环写得过细导致 README 臃肿] → 详细步骤放 `templates/quickstart-*.md`（使用方工程内），README 只留精简主线 + 锚点链接，避免双写漂移（呼应已归档的 merge-usage-into-readme 单源化精神）。
- [tarball 获取方式依赖仓库是否打 release] → 文档对 tarball 路径做条件表述（有 tag 给确切链接，无则指向 GitHub 页面的 Source code 按钮），不写死可能不存在的版本号，规避 AI 幻觉坐标。

## Migration Plan

1. **config 骨架**：`config/project.yaml` 模板增 `works[]`（可选）+ `active_work`（可选）占位；`registry/pen-names.yaml` 空骨架加入 `nc-初始化` 产物与 `references/layout.md` registry 清单。
2. **install.sh**：`--project` 生成的骨架含 `works/` 目录（.gitkeep）+ `pen-names.yaml` 占位；结尾提示语补四步下一步指引。
3. **技能文档**：`references/skill-catalog.md` 相关行补 `--work` / 署名入参；`nc-初始化` 描述补新书分支；`nc-检索` 补 `--all-works`；`nc-导出`/`nc-成稿` 补署名落点。
4. **文档闭环**：README 快速开始四步 + 自检；`templates/quickstart-*.md` 双语同步。
5. **验证**：纸面演练「克隆 → 安装 → --project → nc-初始化 → 第二本 nc-初始化 --new-work → nc-角色 --work book-b → nc-导出 落署名」全链路；grep 自检 frontmatter 三键 / 29 技能计数 / auto_invokable 三处不变；存量单本工程 `works[]` 缺失路径的行为回归。

**回滚**：全部改动集中在文档 / 模板 / config 骨架 / install.sh 文案，`git revert` 对应提交即可；`works[]` 与 `pen-names.yaml` 均为可选 / 新增，旧工程不受影响，无需数据迁移。

## Open Questions

- `works[]` 是否需要上限或推荐规模（如「单工程建议 ≤ 5 本，再多拆工程」）？默认不设硬上限，仅在文档给软性建议——是否需要在 spec 里写成 MUST NOT 超过 N？（倾向否，保持灵活。）
- 章节级笔名覆写的载体：写在章节 frontmatter 的新字段 `pen_name`，还是 `manuscript/` 章节文件的既有元信息？倾向新增可选 frontmatter 字段 `pen_name`（与五必备字段并列的可选项），待 apply 时确认是否与 card-schema 的章节约定冲突。
- 是否要在 `nc-图谱` 总览里加「多书作品关系总图」？本 change 暂不含（属可视化增强，可后续单独提）。
