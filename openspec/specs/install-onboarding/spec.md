# install-onboarding

## Purpose

定义从「获取 novel-cards」到「建出第一张卡」的一键安装落地契约：获取来源、放置约定、安装方式（copy vs link 双端）、`--project` 骨架生成、`nc-初始化` 交互补全、首卡最小路径与装后自检，消除「只有 install.sh 一句、不知从哪下载 / 放哪 / 装哪 / 怎么落地」的断点。

## Requirements

### Requirement: 快速开始 MUST 给出明确的获取来源

文档 SHALL 提供至少两条可执行的获取途径并给出确切命令 / URL：① 从 git 仓库克隆；② 下载 release 归档包（tarball）。MUST 说明两种方式各自的适用场景（持续开发跟更 vs 一次性快照使用）。

#### Scenario: 克隆获取
- **WHEN** 读者按文档执行 git clone 命令
- **THEN** 得到包含 `install.sh` / `SKILL.md` / `references/` / `templates/` 的完整仓库目录，可直接进入下一步安装

#### Scenario: 归档包获取
- **WHEN** 读者按文档下载并解压 release tarball
- **THEN** 解压后目录结构与克隆结果等价（含 `install.sh`），可执行同一套安装命令；文档 MUST 注明归档包不含后续更新，需重新下载以升级

### Requirement: 放置约定 MUST 明确且无固定路径依赖

文档 SHALL 说明：`install.sh` 以脚本自身所在目录为源码根（`SRC`），因此仓库 / 解压目录可放在任意位置，无需安装到特定系统路径；`--link` 软链模式要求仓库目录长期保留（删除目录会断开软链），copy 模式则把文件复制到目标 skills 目录后不再依赖源目录。

#### Scenario: 任意目录运行
- **WHEN** 读者在克隆 / 解压后的任意目录内执行 `./install.sh`
- **THEN** 脚本正确定位自身所在目录为 `SRC` 并完成安装，不因工作目录不同而失败

#### Scenario: 软链模式的目录依赖
- **WHEN** 读者用 `--link` 安装后移动或删除了源仓库目录
- **THEN** 文档 MUST 已预先警示此行为会导致全局 skills 下的软链失效；copy 模式无此约束

### Requirement: 安装方式 MUST 区分 copy 与 link 并说明双端目标

文档 SHALL 清楚区分两种安装模式与两端目标：`--target opencode`（装到 `~/.config/opencode/skills/novel-cards/`）/ `--target claude`（装到 `~/.claude/skills/novel-cards/`）/ 缺省 both；`--link` 用软链（开发期改源即时生效）vs 缺省 copy（复制独立副本，稳定但需重跑升级）。

#### Scenario: 单端安装
- **WHEN** 读者只使用 OpenCode，执行 `./install.sh --target opencode`
- **THEN** 仅向 OpenCode 全局 skills 目录安装，不触碰 Claude Code 目录

#### Scenario: 开发期软链
- **WHEN** 读者在维护本 skill 源码，执行 `./install.sh --link`
- **THEN** 全局 skills 目录指向源仓库的软链，编辑源文件即时反映到两端，无需重复安装

### Requirement: 从骨架到第一张卡 MUST 有端到端最小路径

文档 SHALL 给出「安装 → 初始化使用方工程 → 建出第一张卡」的连续可走通路径：`./install.sh --project <path>` 生成使用方工程空骨架 → 在该工程内 `nc-初始化` 交互式补全配置 → 第一条创作指令（如 `nc-角色` 或 `nc-桥段`）经提案制产出第一张卡的完整闭环。

#### Scenario: 全新读者走通主线
- **WHEN** 一位从未用过本 skill 的读者严格按文档顺序执行：获取 → 安装 → `--project ~/my-novel` → 进入该目录 `nc-初始化` → `nc-角色 "新建主角 …"`
- **THEN** 每一步都有明确命令 / 提示语，最终在 `~/my-novel/cards/characters/` 得到第一张角色卡提案（用户确认后落盘），全程无「不知道下一步做什么」的断点

#### Scenario: 骨架缺失时提示而非自建
- **WHEN** 读者在未跑 `--project` 的目录直接调用 `nc-*` 技能
- **THEN** 技能 MUST 提示先初始化工程骨架（指向 `install.sh --project` 或 `nc-初始化`），MUST NOT 自行创建 `cards/` 等目录

### Requirement: 装后 MUST 提供 skill 生效自检

文档 SHALL 提供一条或多条「验证 skill 已正确安装并可被 agent 识别」的自检方法（如在 agent 的 skills 面板确认 `novel-cards` 可见且描述正确，或用触发词试探），让读者能确认安装成功而非盲目继续。

#### Scenario: 安装后确认生效
- **WHEN** 读者完成安装后执行文档给出的自检步骤
- **THEN** 能看到 `novel-cards` skill 已被当前 agent（OpenCode / Claude Code）加载，描述字段正确，可正常触发
