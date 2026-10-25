# Design

## Context

两份顶层文档并存且六块双写：`README.md`（422 行，仓库参考+部分使用内容）与 `USAGE.md`（855 行，使用路径+FAQ+迁移+回滚）。入口互踢：README 首行把日常使用推给 USAGE。一致性自检被迫维护跨两文档的计数（AGENTS.md 技能集合「五处」、触发词「三处」；README 规则 26「四处」）。

硬约束（核查所得）：

- `references/compliance.md`：顶层合规声明 MUST 写入 SKILL.md / README / **USAGE** 三处；待归档 spec `material-compliance` 有「用户阅读 SKILL.md 或 USAGE.md」应见声明的场景 → **USAGE.md 不可裸删**。
- `install.sh`：L355 随载荷复制 USAGE.md 到安装目标；L297 尾部文案指向 USAGE.md。
- 双语 `templates/quickstart-*.md` 与 `references/card-schema.md` 各有指向 USAGE 具体内容（迁移章节 / FAQ）的指路。
- v0→v1 迁移章节在上一 change 中被要求「置顶 USAGE.md」（restructure design 决策）——文档拓扑改变后该决策需重议而非盲从。
- 用户已选定范围：合并为单文档（README + USAGE 合并，USAGE 删除或只留重定向）。

## Goals / Non-Goals

**Goals:**

- README 成为唯一内容源：完整使用说明主线 + 参考 + FAQ/迁移/回滚/术语，带目录，单文件可独立上手。
- USAGE.md 收缩为重定向桩，保住合规声明三处放置、install.sh 载荷契约与外部链接。
- 消除六块双写；一致性自检计数随单源化收敛。
- 迁移零丢失：USAGE 每个正文章节在 README 有明确去向（映射表驱动）。

**Non-Goals:**

- 不改任何技能行为、卡片 schema、frontmatter 三键、安装脚本逻辑（仅 1 行文案）。
- 不动 references/ 与 templates/ 卡模板内容结构（仅指路修正）。
- 不动待归档 change 的 spec；不重排 references/ 或 templates/ 顶层组织（用户未选全仓重整）。
- 不新增构建/依赖/测试设施。

## Decisions

### D1: USAGE = 重定向桩（而非裸删）

**选择**：USAGE.md 保留为约 10 行桩：一句「已合并入 README」+ README 对应锚点清单（迁移/FAQ/回滚）+ **顶层合规声明段原文保留**。

**候选对比**：

- **裸删**（被拒）：需改 compliance.md「三处」要求 + 待归档 spec `material-compliance` 场景（改一个已完成 change 的 spec，流程上不可取）+ install.sh 复制行 + 两处 quickstart 指路，且任何站外旧链接 404。
- **留桩**（采纳）：合规声明三处放置的字面契约继续成立（桩内含声明）；install.sh 两行都无需动；外部链接落到桩后仍可导航到内容；改动面收敛到「内容迁移 + 指路修正」。

### D2: 合并后 README 结构（含 USAGE 逐节映射，防丢失的权威清单）

```
# novel-cards（定位段：单入口声明）
（目录 TOC：全部一级/二级节锚点链接）
## 这个仓库是什么 / 目录结构            ← README 保留
## 安装（三种方式 + 快速开始）          ← README 快速开始〔缩为 30 秒版〕+ USAGE §2〔权威〕+ USAGE §0 前置条件；含 v0.x 工程迁移一行 callout
## 初始化使用方工程                     ← USAGE §3〔权威〕
## 使用说明（主线）
  ### 三场景操作路径                   ← USAGE §4
  ### 触发方式：说什么话               ← README 触发场景 + USAGE §5〔合并去重〕
  ### 一次交互的完整工作流             ← README 工作流程五步 + USAGE §6〔合并〕
  ### 各类卡典型提示语                 ← USAGE §7
  ### 动线卡 vs 关系图                 ← USAGE §8
  ### 写作闭环                         ← README 写作闭环 + USAGE §9〔合并〕
  ### 通胀过滤器                       ← README 过滤器 + USAGE §10〔合并〕
  ### 提案制铁律                       ← USAGE §11
  ### 批量操作场景                     ← USAGE §13
## 参考
  ### 29 技能速览（六组）              ← README 保留
  ### 16+ 卡类型速览                   ← README 保留
  ### 四层数据分层 / HTML 关系图谱     ← README 保留
  ### 硬规则速览（26 条）              ← README 保留〔权威〕；USAGE §12 删除
  ### 使用方工程约束 / 贡献            ← README 保留
## 常见问题 FAQ                         ← USAGE §14
## v0 → v1 迁移指引与故障回滚           ← USAGE §1 + §15
## 术语对照                             ← USAGE §16
## 合规声明                             ← README 保留
## License                              ← README 保留
```

迁移位置说明：上一 change 要求迁移「置顶 USAGE」，前提是 USAGE 是旧工程用户的落点；合并后 README 面向新用户主线，迁移移至尾部附录区，改由**安装节内一行 callout + TOC 锚点**保证可达——拓扑变了，旧决策按新拓扑重释，不算推翻。

### D3: 双写去重权威规则

| 主题 | 权威 | 处置 |
|---|---|---|
| 安装 / 初始化 | USAGE §0/§2/§3 | README 快速开始缩为摘要+锚点，细节归安装节 |
| 硬规则速查 | README 26 条 | USAGE §12 整节删除 |
| 触发 / 工作流 / 闭环 / 过滤器 | 合并后使用说明主线 | 两版按「讲用法」口径择长合并，不并列保留 |
| 技能表 / 卡表 / 分层 / 图谱 | README | USAGE 无对应权威内容，直接移入其余 |
| FAQ / 迁移 / 回滚 / 术语 | USAGE | 整体移入 README 附录区 |

### D4: 目录（TOC）为硬要求

合并后约 1100 行，无目录不可用。TOC 覆盖全部二级节，锚点按 GitHub CJK slug 规则手工核对；验证任务逐一验锚。次级三级节（使用说明/参考内部）不入 TOC，避免噪音。

### D5: 一致性计数收敛

- 技能集合一致：五处（含 USAGE）→ **四处**（SKILL / README / skill-catalog / skill-reference-zh）——改 AGENTS.md 自检。
- 触发词前缀一致：三处（SKILL/README/USAGE）→ **两处**（SKILL/README）——改 AGENTS.md 自检。
- README 规则 26：四处 → **三处**（SKILL/README/skill-catalog）——在 README 重写中同步。
- 桩不含技能表/触发词表，故计数清单不再包含 USAGE——这是「双写禁止」的直接推论，写进 repo-docs spec。

## Risks / Trade-offs

- **合并搬运丢内容** → 缓解：D2 映射表为逐节去向清单；验证任务要求 USAGE 每个 `##` 节在 README 有对应内容（grep 锚点 + 抽样比对）。
- **TOC 锚点失效**（GitHub CJK slug）→ 缓解：验证任务逐锚点核对；降级风险仅是跳转不便，正文无损。
- **README 过长影响可读** → 缓解：TOC + 使用/参考两大分区；接受单文件长度（用户明确选单文档）。
- **桩被误当内容仍完整** → 桩首行明确「正文已迁 README，本文件仅存档指路与合规声明」。
- **quickstart 指路若漏改** → 指路仍经桩可达（桩含锚点清单），漏改为体验降级而非断裂；验证任务仍全量核。

## Migration Plan

无数据迁移。回滚 = git revert（纯文档）。旧外部链接 → 桩导航，无死链。

## Open Questions

（无阻塞；TOC 是否含三级节、README 定位段措辞在实施 review 时可微调。）
