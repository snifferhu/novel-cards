# Proposal

## Why

`README.md`（422 行，偏仓库参考）与 `USAGE.md`（855 行，使用说明 + FAQ + 迁移）是两份互补但**六块内容双写**的顶层文档（安装 / 工作流 / 写作闭环 / 通胀过滤器 / 硬规则速查 / 触发方式各自出现两遍），入口还互相推诿——README 第一行就把「日常使用」踢给 USAGE，读者要跳一次文件才能上手；两处双写已经开始漂移（一致性自检清单被迫维护「五处 / 三处 / 四处」计数）。作者选定方案：**合并为单文档**——使用说明全部集中进 README，USAGE 内容并入后不再承载正文。

## What Changes

- **README.md 全面重排重写**为「使用优先」单入口：顶部加目录（合并后约 1100 行，无目录不可用），前半部为使用说明主线（定位 → 安装 → 初始化工程 → 三场景操作路径 → 触发方式 → 完整工作流 → 各类卡提示语 → 动线 vs 图谱 → 写作闭环 → 过滤器 → 提案制铁律 → 批量场景），后半部为参考（29 技能 / 16+ 卡类型 / 四层分层 / 图谱 / 硬规则 26 条 / 合规 / 贡献 / License），尾部收 FAQ、v0→v1 迁移、故障回滚、术语对照（自 USAGE 迁入）。
- **双写去重**：六块重叠内容各保留一份权威版本——安装/初始化以 USAGE §2/§3 为权威（README 快速开始收为其摘要+链接锚点），硬规则以 README 26 条速览为权威（USAGE §12 删除），工作流/闭环/过滤器/触发方式按「讲用法」口径合并进使用说明主线。
- **USAGE.md 收缩为重定向桩**（约 10 行）：指向 README 对应章节 + **保留顶层合规声明段**。不裸删——`references/compliance.md` 要求顶层声明 MUST 写入 SKILL.md / README / USAGE 三处，待归档 spec `material-compliance` 亦有「用户阅读 SKILL.md 或 USAGE.md」场景；桩保契约、保 install.sh 载荷复制行、保外部链接不失效。
- **引用面同步（9 处）**：README 内链接/目录/规则 26 计数（四处处→三处处）、AGENTS.md 两处自检计数（技能集合五处处→四处处；触发词 SKILL/README/USAGE 三处处→SKILL/README 两处处）、`references/card-schema.md` FAQ 指路改指 README、`install.sh` 尾部「详细使用见 USAGE.md」改指 README、双语 `templates/quickstart-*.md` 迁移指路改指 README 迁移章节。
- **不动**：`references/compliance.md` 的「三处」放置要求（桩仍含声明，契约继续成立）、`install.sh` 的 USAGE 复制行（桩随载荷安装，声明可达）、待归档 change 的 spec。
- **无 BREAKING**：无 API/卡片/技能行为变化；纯文档单源化。

## Capabilities

### New Capabilities

- `repo-docs`: 本 skill 仓库自身的顶层文档契约——README 为唯一内容源（完整使用说明 + 参考 + FAQ/迁移/回滚/术语），USAGE.md 仅存重定向桩且 MUST 保留顶层合规声明，双写禁止（同一主题只允许一份权威正文），一致性计数清单随单源化收敛。

### Modified Capabilities

（无——`material-compliance` 的声明放置经桩设计继续成立，无 spec 级行为变化；其余能力不涉及。）

## Impact

- **本仓库顶层文档**：`README.md`（重排重写，约 422 → 1100 行）、`USAGE.md`（855 → 约 10 行桩）。
- **引用修正**：`AGENTS.md`（两条自检计数）、`references/card-schema.md`（1 处 FAQ 指路）、`install.sh`（1 行文案；复制行不动）、`templates/quickstart-zh.md` / `quickstart-en.md`（各 1 处迁移指路）。
- **不受影响**：SKILL.md（未引用 USAGE）、references 其余文档、templates 卡模板、全部 29 技能与 18 卡类型、使用方工程骨架生成逻辑、待归档 change。
- **风险面**：文档体量合并期间的内容丢失 → 以迁移映射清单（design 载明逐节去向）+ 验证任务「USAGE 正文章节全部可在 README 找到对应锚点」兜底。
