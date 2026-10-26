# Design

## Context

本地 `main` tip = `76ee081`，工作树携带未提交的 `oo-rearchitecture` 改动（9 个已修改跟踪文件 + 3 组未跟踪新文件：`references/oo-model.md`、`references/event-inference.md`、`tools/nc_validate.py`）。`origin/main` tip = `104cce3`（周末提交），领先本地 1 个提交，带来两个新 OpenSpec change、一份 inbox 对话文档、一个新模板，以及对 6 个共享文件的独立编辑。两侧改动在 6 个文件上重叠，但**语义正交**：本地侧加 OO 透镜注解，远端侧加 `baseline_prototype` 人格基线原型契约。详见 proposal.md Why。

## Goals / Non-Goals

**Goals**
- 把 `104cce3` 线性引入本地历史（rebase，无 merge commit）。
- 6 个重叠文件达成「OO 透镜 + 人格基线原型」双契约并集，零内容丢失。
- 远端纯新增文件完整落位；本地独有文件不被遮蔽。
- 合并后跨契约一致性 grep 全绿，铁律（frontmatter 三键 / 29 技能 / auto_invokable 三处）不破。

**Non-Goals**
- 不 apply / archive 远端两个 change（`add-tendency-baseline-prototype` / `merge-usage-into-readme`）。
- 不 push、不 force-push、不自动 commit 最终结果（用户审查后自行处置）。
- 不改任何卡片字段契约、技能行为、安装逻辑。

## Decisions

### D1 — 保护机制选 `git stash -u`，而非 WIP commit

**选择**：同步前 `git stash push -u -m "oo-rearchitecture WIP"` 把工作树（含未跟踪的 `oo-model.md` / `event-inference.md` / `tools/`）整体入栈 → rebase → `git stash pop`。

**理由**：本地改动尚未通过用户审查，WIP commit 会污染 `main` 历史，rebase 后还需 squash/amend 清理；stash 保持历史干净，pop 失败可 `git stash drop` 回退到 rebase 前状态。

**备选**：WIP commit（历史多一个临时节点，需事后清理）；`git checkout -b wip-branch` 切分支（多一步分支管理，且 rebase 主分支后还要 cherry-pick 回来）。

### D2 — 引入远端用 `git pull --rebase origin main`，而非 merge

**选择**：rebase。

**理由**：仓库历史是线性 feature 链（clone → init → … → 76ee081），保持线性符合既有风格；merge 会引入一个 merge commit 打断链条。rebase 在「本地工作树已 stash 为空」的前提下，重放的是空集，实际等价于 fast-forward 到 `104cce3`，**不会产生冲突**。

**关键洞察**：因为 D1 先把工作树清空，rebase 阶段本地没有任何待重放的 commit，所以 `104cce3` 直接落到本地之上，**rebase 本身零冲突**。真正的调和发生在 D1 的 `git stash pop` 那一刻——stash 里的本地改动重新应用到已含远端内容的工作树上，git 对 6 个重叠文件报 conflict，此时按 D3 逐文件手工解决。

**备选**：merge（产生 merge commit，破坏线性历史）。

### D3 — 冲突解决策略：逐文件并集映射表，禁止整文件取舍

**选择**：`git stash pop` 触发 conflict 后，对每个重叠文件打开冲突标记，按下方映射表手工保留两侧 hunk。MUST NOT 用 `git checkout --ours/--theirs`。

**六文件并集映射表**（「本地侧」= stash 中的 OO 改动，「远端侧」= `104cce3` 的内容）：

| 文件 | 本地侧新增（保） | 远端侧新增（保） | 冲突热点 |
|---|---|---|---|
| `references/card-schema.md` | 各卡类型小节的 OO 透镜注解块（NcObject 子类视角） | `character_tendency` 小节 `baseline_prototype` 字段行 + 说明段 + 扩展示例 | character_tendency 小节：OO 注解与 baseline_prototype 字段表行相邻共存 |
| `references/skill-catalog.md` | 六组表新增「OO 归属」列（表头 6→7 列）+ 每行 OO 方法映射 | `nc-注册`/`nc-动向`/`nc-校阅` 三行职责文案扩展（baseline_prototype / 检查④） | 表头列数合并为 7 列；三行扩展文案落在「简要职责」列，OO 归属列独立保留 |
| `SKILL.md` | body 内 OO 透镜段落 + tools/ 引用 + reference 文件列表 | nc-注册/nc-动向/nc-校阅 速查表行 + 硬规则 14 措辞扩展 | frontmatter 三键不动；body 两段并集 |
| `README.md` | OO 心智模型 blurb + tools/ 目录树项 + 新 reference 文件 | 卡表 character_tendency 行 baseline_prototype + 硬规则 16 措辞扩展 | 技能表/卡表行级合并 |
| `AGENTS.md` | 尾部 3 条 checklist（OO 透镜 / 事件推演 / tools 只读）+ 禁区 tools/ 条目 + 骨架清单 tools/ | 尾部 1 条 checklist（baseline_prototype registry-backed） | 尾部 checklist 四条并集；禁区节仅本地侧改 |
| `references/data-layering.md` | 四层 OO 存储投影注解块 | `.yaml` 行 tendency-prototypes.yaml + 注册前置规则扩句 | 注解块与 yaml 表行/规则段并存 |

**操作要点**：每个文件的冲突 hunk 数量少（多为「同一区域两侧各插一段」），手工把两侧文本都留下即可；若 git 把两侧插入判定为同一行替换型冲突，则手动拼接为「远端行在前、本地注解在后」（或反之，以阅读顺序自然为准），删除 `<<<<<<<`/`=======`/`>>>>>>>` 标记。

### D4 — 验证分层：先结构后语义

**选择**：合并后按三层验证，任一层失败即停并报告。
1. **结构层**：`git status` 工作树仅剩预期文件；`git log --oneline -3` 确认 `104cce3` 在 tip 之下、本地 OO 文件存在。
2. **契约层**：proposal 载明的四组 grep（baseline_prototype 六处 / oo-model.md 六处 / frontmatter 三键 / 29 技能计数）。
3. **工具层**：`python3 tools/nc_validate.py --help` 可运行（确认 stdlib 单文件未被 rebase 破坏）；`openspec list --json` 显示 4 个 change（含远端两个新的）。

**理由**：结构错（文件丢/历史乱）比语义错（某行措辞漂移）更致命，先验结构可快速止损。

## Risks / Trade-offs

- [stash pop 冲突比预期复杂，手工调和耗时] → 映射表已预先厘清每文件两侧内容与热点，调和是「按表填」而非「现场判断」；若某文件 hunk 过多，可对该文件单独 `git checkout --theirs` 取远端版再手工补回本地 OO 注解（仅限单文件降级，非全局取舍）。
- [`.omo/run-continuation/*.json` 等运行时文件也被 stash/pop 卷入] → 这些是 opencode 会话状态，无害；pop 后若冲突可 `git checkout -- .omo/` 丢弃其本地改动（非交付物）。
- [远端两 change 的 spec 与本地 card-schema 描述可能语义不一致] → 本 change 不调和 spec 语义，只做 git 层并集；spec 级一致性由各自 change 的 apply 阶段负责，超出本 change 边界。
- [rebase 后本地 tip 与 origin 分叉，用户 push 时需处理] → 本 change 明确不 push；push 策略（force-with-lease 与否）留给用户在审查后决策，不在本 change 内执行。

## Migration Plan

1. `git stash push -u -m "oo-rearchitecture WIP"` → 确认 `git status` 干净。
2. `git pull --rebase origin main` → 本地 tip 前进到含 `104cce3` 的新 tip（零冲突，因工作树空）。
3. `git stash pop` → 6 文件报 conflict，按 D3 映射表逐文件手工并集调和，`git add` 已解决文件。
4. 跑 D4 三层验证。
5. 停止。工作树处于「已调和、未 commit」状态，交由用户审查后决定 commit/push。

**回滚**：任一步失败 → `git rebase --abort`（若在 rebase 中）或 `git reset --hard <rebase前tip>` + `git stash pop` 恢复本地 OO 改动；最坏情况 `git stash drop` 后从 `oo-rearchitecture` 的 openspec 产物重建（产物已在 `openspec/changes/oo-rearchitecture/`，不受影响）。

## Open Questions

- 用户是否希望本 change 完成后顺手把 `oo-rearchitecture` 的未提交改动一并 commit？（本 change 默认不 commit，留待用户。）
- 远端 `merge-usage-into-readme` change 若后续被 apply，会与本地 README 的 OO blurb 再次冲突——是否需要在本次调和时预读该 change 的 design 以提前规避？（默认否，避免越界。）
