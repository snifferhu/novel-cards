# Spec Delta

## Purpose

定义本 skill 仓库自身的顶层文档契约：README 为唯一内容源，USAGE.md 仅存重定向桩（含合规声明），双写禁止，一致性计数清单随单源化收敛。纯文档单源化，不改变任何技能/卡片行为。

## ADDED Requirements

### Requirement: README 为唯一内容源单入口

`README.md` SHALL 是本仓库唯一的顶层内容源，独立可上手：含仓库定位与目录结构、安装与使用方工程初始化、**完整使用说明主线**（三场景操作路径、触发方式、完整工作流、各类卡提示语、动线 vs 图谱、写作闭环、通胀过滤器、提案制铁律、批量操作场景）、参考区（29 技能六组速览、16+ 卡类型速览、四层数据分层、HTML 关系图谱、硬规则速览、使用方工程约束、贡献、License）、附录区（FAQ、v0→v1 迁移指引与故障回滚、术语对照）、顶层合规声明。约束：

- 合并后体量 MUST 带覆盖全部二级节的目录（TOC），锚点可跳转。
- 同一主题 MUST 只允许一份权威正文（安装/初始化、硬规则、触发、工作流、闭环、过滤器等原双写主题各归一处），MUST NOT 两文档并列各存一份。
- `USAGE.md` 原正文各 `##` 节 SHALL 在 README 有对应章节（逐节迁移，不丢内容）。

#### Scenario: 新读者单文件上手

- **WHEN** 新作者只打开 `README.md`，按目录顺序阅读
- **THEN** 可完成安装 → 初始化工程 → 按三场景路径发出第一条 `nc-` 指令 → 理解提案制落盘流程，全程无需打开其他文件获取「怎么用」

#### Scenario: 双写主题单权威

- **WHEN** 对照合并前的两文档检查「硬规则速查」「安装方式」「写作闭环」等六个双写主题
- **THEN** 每个主题在 README 只剩一份权威正文（硬规则保留 26 条速览版；USAGE §12 类重复清单不存在）

### Requirement: USAGE.md 重定向桩契约

`USAGE.md` SHALL 收缩为重定向桩：首行明确「正文已合并入 `README.md`、本文件仅存指路与合规声明」，含指向 README 对应章节（安装 / 使用说明 / FAQ / 迁移 / 回滚）的锚点清单，并 MUST 原样保留**顶层合规声明**段。MUST NOT 再承载使用正文（技能表、触发词表、路径教程、FAQ 条目等一律不留在桩内）。`references/compliance.md` 要求的「声明写入 SKILL.md / README / USAGE 三处」SHALL 因桩内含声明而继续成立。

#### Scenario: 旧链接落桩可导航

- **WHEN** 任何来源（站外旧链接、quickstart 模板、install.sh 载荷文案）把读者带到 `USAGE.md`
- **THEN** 桩首行给出正文去向，锚点清单可直达 README 对应章节，且读者仍在桩内看到顶层合规声明

#### Scenario: 桩不含双写正文

- **WHEN** 检索 `USAGE.md` 全文
- **THEN** 不存在 29 技能表、`nc-` 触发词全集、FAQ 条目正文、v0→v1 迁移命令正文（仅存指向 README 的指路句）

### Requirement: 一致性计数清单随单源化收敛

跨文档一致性自检的计数处 SHALL 随单源化收敛，MUST NOT 继续把 `USAGE.md` 计入内容一致性位置（桩不含被计内容）：

- 29 技能集合一致：`SKILL.md` 速查表 / `README.md` 技能表 / `references/skill-catalog.md` / `templates/skill-reference-zh.md` **四处**。
- `nc-` 触发词前缀一致：`SKILL.md` description / `README.md` **两处**。
- README 硬规则「六组分类一致性」条：`SKILL.md` / `README.md` / `references/skill-catalog.md` **三处**。
- 上述计数 SHALL 同步改写于 `AGENTS.md` 自检清单与 README 硬规则速览，两处措辞一致。

#### Scenario: 技能集合四处校验

- **WHEN** 按 AGENTS.md 自检清单核对 29 技能集合一致性
- **THEN** 清单列出的四处位置各存在完整 29 技能集合且互相相同，USAGE 不在计数列表中

#### Scenario: 引用指路修正到 README

- **WHEN** 定位原指向 USAGE 具体内容的活引用（`references/card-schema.md` FAQ 指路、`install.sh` 尾部「详细使用见」、双语 `templates/quickstart-*.md` 迁移指路）
- **THEN** 三类指路全部改指 `README.md` 对应章节；`install.sh` 的载荷复制行与 `references/compliance.md` 的「三处」放置要求保持不变
