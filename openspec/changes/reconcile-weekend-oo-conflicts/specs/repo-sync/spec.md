# Spec Delta

## Purpose

定义本 skill 仓库在「本地未提交 OO 工作树 × origin 周末新提交」并存时的受控同步契约：如何保护本地改动、引入远端历史、调和重叠文件并验证跨契约一致性，同时绝不破坏双端兼容铁律与提案制边界。

## ADDED Requirements

### Requirement: 本地未提交改动 MUST 在引入远端前被完整保护

同步开始前，本地工作树上所有未提交的 `oo-rearchitecture` 改动（已修改的跟踪文件 + 未跟踪的新文件）MUST 处于可完整恢复的状态；保护机制 MUST 保证 rebase 失败或冲突时本地 OO 透镜内容零丢失。

#### Scenario: 有未提交改动的干净保护
- **WHEN** 本地 `main` 工作树存在未提交的已修改文件（如 `SKILL.md` / `README.md` / `references/*.md`）或未跟踪新文件（如 `references/oo-model.md` / `tools/nc_validate.py`）
- **THEN** 执行同步前 MUST 先通过 `git stash -u`（含未跟踪文件）或一次显式 WIP commit 将其全部纳入保护；保护后 `git status` MUST 显示工作树干净，方可执行 `git pull --rebase origin main`

#### Scenario: 保护失败时回滚
- **WHEN** stash 或 WIP commit 未能覆盖全部本地改动（如被 `.gitignore` 遮蔽的文件）
- **THEN** MUST 中止同步流程，向用户报告哪些文件未被保护，由用户决定如何处理；MUST NOT 在保护不完整的情况下继续 rebase

### Requirement: 远端周末提交 MUST 以 rebase 方式落入本地历史

`origin/main` 上领先本地的周末提交（当前为 `104cce3`，含两个新 OpenSpec change 与共享文件编辑）MUST 通过 rebase 引入本地 `main`，使本地历史成为远端历史的线性后继，而非产生 merge commit。

#### Scenario: 无冲突 rebase
- **WHEN** 本地受保护的工作树为空且远端仅领先 N 个提交
- **THEN** `git pull --rebase origin main` MUST 成功将本地 tip 前进到包含远端全部提交的新 tip，`git log --oneline` 中周末提交出现在本地原 tip 之后

#### Scenario: rebase 冲突
- **WHEN** rebase 过程中 git 报告冲突（本地已保护的改动经 rebase 重放时与远端改动落在同一区域）
- **THEN** MUST 按 design 载明的逐文件并集映射表手工解决每个冲突 hunk，保留两侧语义；MUST NOT 使用 `git checkout --ours` / `--theirs` 整文件取舍；解决后 `git rebase --continue` 直至完成

### Requirement: 六个重叠文件 MUST 达成双契约并集

以下六个文件同时被本地 OO 透镜重构与远端人格基线原型变更所修改，合并后 MUST 同时完整保留两侧新增内容，消除重复行与措辞漂移：`AGENTS.md`、`README.md`、`SKILL.md`、`references/card-schema.md`、`references/skill-catalog.md`、`references/data-layering.md`。

#### Scenario: card-schema 双契约共存
- **WHEN** 合并 `references/card-schema.md`
- **THEN** 文件 MUST 同时包含：本地侧的 OO 透镜注解块（NcObject 子类视角引用 `oo-model.md`）与远端侧的 `baseline_prototype` 可选字段行 + 人格基线原型说明段 + 扩展示例；两侧内容互不覆盖，`character_tendency` 小节内 OO 注解与 baseline_prototype 字段表行相邻共存

#### Scenario: skill-catalog 列扩展与 OO 归属列共存
- **WHEN** 合并 `references/skill-catalog.md`
- **THEN** 六组技能表 MUST 同时具备本地侧新增的「OO 归属」列与远端侧对 `nc-注册` / `nc-动向` / `nc-校阅` 三行职责描述中 `baseline_prototype` / 检查④ 的措辞扩展；表头列数 = 原 6 列 + OO 归属 1 列 = 7 列，三行扩展文案落在对应行的「简要职责」列内

#### Scenario: SKILL.md frontmatter 三键铁律不被破坏
- **WHEN** 合并 `SKILL.md`
- **THEN** frontmatter MUST 仍仅含 `name` / `description` / `license` 三键（YAML dump 确认），body 内同时保留本地 OO 透镜段落与远端对 nc-注册 / nc-动向 / nc-校阅 速查表行及硬规则 14 的 `baseline_prototype` 措辞扩展；29 技能计数不变

#### Scenario: AGENTS.md 自检清单双追加
- **WHEN** 合并 `AGENTS.md`
- **THEN** 文件尾部自检清单 MUST 同时包含本地侧追加的 OO 透镜一致性 / 事件推演对齐 / tools 只读铁律三条 checklist 项，与远端侧追加的 `baseline_prototype` registry-backed 枚举一条 checklist 项；四条互不重复

### Requirement: 远端纯新增文件 MUST 随 rebase 无冲突落位

远端周末提交带来的纯新增文件 MUST 在 rebase 后完整出现在本地工作树，不被本地同名未跟踪文件遮蔽或覆盖。

#### Scenario: 新增 OpenSpec change 目录落位
- **WHEN** rebase 完成
- **THEN** `openspec/changes/add-tendency-baseline-prototype/` 与 `openspec/changes/merge-usage-into-readme/` 两个目录 MUST 完整存在于本地，各含 `.openspec.yaml` / `proposal.md` / `design.md` / `tasks.md` / `specs/` 子树；`inbox/doubao-对话-2026-10-24.md`、`templates/tendencies.md` MUST 存在

#### Scenario: 本地独有文件不被远端遮蔽
- **WHEN** rebase 完成
- **THEN** 本地独有的 `references/oo-model.md` / `references/event-inference.md` / `tools/nc_validate.py` MUST 仍存在于工作树（远端无这些文件，rebase 不会删除它们）

### Requirement: 合并后 MUST 通过跨契约一致性 grep 自检

rebase 与手工调和完成后，MUST 运行一组全仓 grep 验证两套契约在六个重叠文件中一致落地，且既有铁律未被破坏。

#### Scenario: baseline_prototype 六处一致
- **WHEN** 运行 `grep -rl 'baseline_prototype' AGENTS.md README.md SKILL.md references/card-schema.md references/skill-catalog.md references/data-layering.md`
- **THEN** 六个文件 MUST 全部命中（每个文件至少一处提及该字段或其关联措辞），证明远端契约在六处均落地

#### Scenario: OO 透镜引用六处仍在
- **WHEN** 运行 `grep -l 'oo-model.md' AGENTS.md README.md SKILL.md references/card-schema.md references/skill-catalog.md references/data-layering.md`
- **THEN** 本地 OO 透镜交叉引用 MUST 在六处仍完整存在（合并未误删本地侧注解）

#### Scenario: 铁律未被破坏
- **WHEN** 合并后校验
- **THEN** ① `SKILL.md` frontmatter 仍仅三键；② 29 技能计数在 SKILL / README / skill-catalog 三处不变；③ auto_invokable=true 仍仅 `nc-量化` / `nc-图谱` / `nc-节奏` 三个；④ `tools/nc_validate.py` 仍为零第三方依赖单文件

### Requirement: 同步流程 MUST NOT 触发禁止操作

整个同步过程 MUST 遵守 AGENTS.md 安全底线，不越权执行任何禁止操作。

#### Scenario: 不 force-push / 不自动 push
- **WHEN** 同步完成
- **THEN** MUST NOT 执行 `git push --force` 或任何形式的 `git push`（push 由用户显式发起）；本地 rebase 后的新 tip 停留在本地，等待用户审查后自行推送

#### Scenario: 不代为 apply/archive 他人 change
- **WHEN** 同步完成
- **THEN** MUST NOT 对 `add-tendency-baseline-prototype` / `merge-usage-into-readme` 执行 `/opsx-apply` 或 `/opsx-archive`；这两个 change 的后续处置由用户独立决策
