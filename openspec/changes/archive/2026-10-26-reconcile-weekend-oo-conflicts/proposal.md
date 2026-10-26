# Proposal

## Why

本地 `main`（HEAD = `76ee081`）携带未提交的 `oo-rearchitecture` 工作树改动（OO 透镜重构：新增 `references/oo-model.md` / `references/event-inference.md` / `tools/nc_validate.py`，并对 9 个既有文档做 OO 语言改写），而 `origin/main` 领先一个周末提交 `104cce3`（胡勇推送），带来两个全新 OpenSpec change（`add-tendency-baseline-prototype`、`merge-usage-into-readme`）、一份 doubao 对话 inbox 文档，以及对**同一批共享文件**的独立编辑。两侧在 6 个文件上同时改动，直接 `git pull --rebase` / merge 会产生真实冲突且语义相互覆盖——必须先把「哪些行属于谁、合并后该保留什么」逐文件厘清，再执行受控合并，否则 OO 透镜与人格基线原型两套契约会在 `card-schema` / `skill-catalog` / `SKILL.md` / `README` / `AGENTS` / `data-layering` 里互相踩踏。

## What Changes

- **受控合并 origin/main 到本地**：先 `git stash`（或 commit）保护本地未提交的 `oo-rearchitecture` 工作树 → `git pull --rebase origin main`（把周末提交 `104cce3` 落到本地历史之上）→ 恢复本地 OO 改动 → 逐文件手工调和 6 个冲突文件，使**两套契约共存**而非互删。
- **六文件逐行调和（核心交付）**：对每个重叠文件，把「周末侧新增内容」（`baseline_prototype` 字段 / `tendency-prototypes.yaml` registry / nc-校阅 检查④ / README 卡表与硬规则 16 措辞扩展）与「本地侧新增内容」（OO 透镜注解块 / OO 归属列 / tools 只读铁律 / 可选运行时表述）**并集保留**，消除重复行与措辞漂移。
- **新文件零冲突落位**：确认周末带来的纯新增文件（`openspec/changes/add-tendency-baseline-prototype/*`、`openspec/changes/merge-usage-into-readme/*`、`inbox/doubao-对话-2026-10-24.md`、`templates/tendencies.md`、`references/hard-rules.md` 改动、`references/layout.md` 改动）随 rebase 无冲突落入本地工作树，不被本地未跟踪文件遮蔽。
- **跨契约一致性复核**：合并后跑全仓 grep 自检，确认 ① `baseline_prototype` 相关措辞在 card-schema / skill-catalog / SKILL / README / AGENTS / data-layering 六处一致；② OO 透镜引用（`oo-model.md` / `event-inference.md` / `tools/nc_validate.py`）在同样六处仍完整存在；③ 29 技能计数、auto_invokable 三处取值、frontmatter 三键铁律未被合并破坏。
- **归档决策留待用户**：本 change 只做「合并 + 调和 + 一致性验证」，**不**代为执行 `add-tendency-baseline-prototype` / `merge-usage-into-readme` 两个周末 change 的 apply/archive，也**不**提交或 push（遵守 AGENTS.md Never 清单）。

无 **BREAKING**：本变更不改任何卡片字段契约、技能行为或安装逻辑，仅做 git 历史对齐与文档级并集调和。

## Capabilities

### New Capabilities

- `repo-sync`: 本 skill 仓库自身在「本地未提交 OO 工作树 × origin 周末新提交」并存时的受控同步契约——stash/commit 保护本地改动、rebase 引入远端、逐文件并集调和 6 个重叠文件、新文件零冲突落位、合并后跨契约一致性 grep 自检；明确禁止 force-push / 自动 commit / 自动 archive 他人 change。

### Modified Capabilities

（无——`add-tendency-baseline-prototype` 与 `merge-usage-into-readme` 是远端已存在的独立 change，其 spec 级行为变化由各自 change 承载，不在本 change 范围内。）

## Impact

- **git 历史**：本地 `main` 从 `76ee081` 前进到包含 `104cce3` 的新 tip；本地未提交 OO 改动经 stash/commit 保护后重新应用。
- **6 个重叠文件**（`AGENTS.md` / `README.md` / `SKILL.md` / `references/card-schema.md` / `references/skill-catalog.md` / `references/data-layering.md`）：从「单侧视角」变为「OO 透镜 + 人格基线原型」双契约并集。
- **纯新增文件**：`openspec/changes/{add-tendency-baseline-prototype,merge-usage-into-readme}/`、`inbox/doubao-对话-2026-10-24.md`、`templates/tendencies.md`、`references/hard-rules.md`、`references/layout.md` 随 rebase 落入本地。
- **不受影响**：`install.sh`（两侧均未实质改骨架生成逻辑，周末侧仅文案）、`tools/nc_validate.py`（本地独有，远端无此文件）、`references/oo-model.md` / `references/event-inference.md`（本地独有）、使用方工程骨架、提案制与审计只读铁律。
- **风险面**：rebase 期间若本地未提交改动与远端改动落在同一行，git 会报 conflict——以 design 载明的「逐文件并集映射表」为准手工解决，禁止 `git checkout --theirs/--ours` 整文件取舍。
