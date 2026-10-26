# Tasks

## 1. 保护本地未提交改动（D1）

- [x] 1.1 `git status --short` 全量盘点本地未提交文件，区分「交付物」（AGENTS/README/SKILL/install.sh/references/*.md + 未跟踪 oo-model.md/event-inference.md/tools/ + openspec/changes/oo-rearchitecture/）与「运行时噪音」（.omo/*），记录清单
- [x] 1.2 `git stash push -u -m "oo-rearchitecture WIP"` 把工作树（含未跟踪文件）整体入栈；验证：`git status` 显示工作树干净（仅剩 .omo 若被忽略则无）
- [x] 1.3 校验 stash 完整性：`git stash show -p stash@{0} --stat` 确认 9 个已修改文件 + 3 组未跟踪新文件全部在栈内；若有遗漏（如被 gitignore 遮蔽）则中止并报告

## 2. 引入远端周末提交（D2）

- [x] 2.1 `git fetch origin` 确认 `origin/main` tip = `104cce3`，本地落后 1 提交
- [x] 2.2 `git pull --rebase origin main`（工作树已空，预期零冲突 fast-forward 到含 104cce3 的新 tip）；验证：`git log --oneline -3` 显示 104cce3 在 tip、76ee081 在其下
- [x] 2.3 确认远端纯新增文件落位：`ls openspec/changes/add-tendency-baseline-prototype/ openspec/changes/merge-usage-into-readme/ inbox/doubao-对话-2026-10-24.md templates/tendencies.md references/hard-rules.md references/layout.md` 全部存在

## 3. 恢复本地改动并调和六文件冲突（D3）

- [x] 3.1 `git stash pop` 触发 conflict；`git status` 列出全部 conflicted 文件，预期 ⊆ {AGENTS.md, README.md, SKILL.md, references/card-schema.md, references/skill-catalog.md, references/data-layering.md}（外加可能的 .omo 噪音）
- [x] 3.2 调和 `references/card-schema.md`：character_tendency 小节保留本地 OO 注解块 + 远端 baseline_prototype 字段行/说明段/扩展示例，删除冲突标记
- [x] 3.3 调和 `references/skill-catalog.md`：表头合并为 7 列（含 OO 归属列），nc-注册/nc-动向/nc-校阅 三行保留远端职责扩展 + 本地 OO 归属值
- [x] 3.4 调和 `SKILL.md`：frontmatter 三键不动，body 并集本地 OO 透镜段 + 远端速查表行/硬规则 14 扩展
- [x] 3.5 调和 `README.md`：技能表/卡表行级并集（本地 OO blurb + 远端 baseline_prototype 卡表行/硬规则 16）
- [x] 3.6 调和 `AGENTS.md`：尾部 checklist 四条并集（本地 3 条 + 远端 1 条），禁区节仅本地侧 tools/ 条目
- [x] 3.7 调和 `references/data-layering.md`：本地四层 OO 投影注解块 + 远端 .yaml tendency-prototypes.yaml 行/注册前置扩句并存
- [x] 3.8 `.omo/` 运行时噪音若冲突则 `git checkout -- .omo/` 丢弃本地改动（非交付物）；每个已解决文件 `git add`
- [x] 3.9 全仓 `grep -rn '<<<<<<<\|=======\|>>>>>>>' AGENTS.md README.md SKILL.md references/ install.sh` 确认零残留冲突标记

## 4. 跨契约一致性验证（D4）

- [x] 4.1 结构层：`git status` 工作树仅剩预期交付物文件；`git log --oneline -3` 历史正确；本地独有 oo-model.md/event-inference.md/tools/nc_validate.py 仍存在
- [x] 4.2 契约层①：`grep -l baseline_prototype AGENTS.md README.md SKILL.md references/card-schema.md references/skill-catalog.md references/data-layering.md` 六文件全命中
- [x] 4.3 契约层②：`grep -l 'oo-model.md' AGENTS.md README.md SKILL.md references/card-schema.md references/skill-catalog.md references/data-layering.md` 六文件全命中（本地 OO 引用未误删）
- [x] 4.4 契约层③：YAML dump `SKILL.md` frontmatter 确认仅 name/description/license 三键；grep 确认 29 技能计数在 SKILL/README/skill-catalog 不变；auto_invokable=true 仍仅 nc-量化/nc-图谱/nc-节奏
- [x] 4.5 工具层：`python3 tools/nc_validate.py --help` 可运行（stdlib 单文件未被破坏）；`openspec list --json` 显示 4 个 change（oo-rearchitecture + restructure-v1-pipeline + 远端两个新的）
- [x] 4.6 `openspec validate reconcile-weekend-oo-conflicts` 通过

## 5. 收尾（不越界）

- [x] 5.1 向用户报告：合并完成、六文件双契约并集达成、验证全绿；明确工作树处于「已调和、未 commit」状态
- [x] 5.2 提示用户后续决策点（本 change 不代为执行）：是否 commit 调和结果 / 是否 push（force-with-lease 与否）/ 远端两 change 是否 apply 或 archive / 是否初始化 STATE.md
