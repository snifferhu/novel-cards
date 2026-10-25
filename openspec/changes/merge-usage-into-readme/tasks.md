# Tasks

## 1. README.md 重排重写（单源主体，按 design D2 映射表搬运）

- [ ] 1.1 搬运 USAGE 正文入 README：按 design D2 结构建立新 README 骨架（定位段 + 二级目录 TOC + 安装/初始化/使用说明主线/参考/附录/合规/License 分区），将 USAGE §0/§1/§2/§3/§4/§6/§7/§8/§11/§13/§14/§15/§16 逐节迁入对应位置；验证：USAGE 每个 `##` 节标题都能在 README 找到对应章节（映射表无遗漏）
- [ ] 1.2 六块双写合并去重：安装（README 快速开始缩为 30 秒摘要+锚点，权威归安装节）、触发方式（README 触发场景 + USAGE §5 择长合并）、完整工作流（五步 + §6）、写作闭环、通胀过滤器、硬规则（保留 README 26 条版，USAGE §12 删除）；验证：每个主题全文仅一份权威正文，grep 无重复清单
- [ ] 1.3 README 收尾：TOC 覆盖全部二级节且锚点逐条核对（GitHub CJK slug）、规则 26 计数改三处、目录结构列表移除 USAGE 正文描述（标注为重定向桩）、安装节加 v0.x 迁移一行 callout、技能表/卡表/分层/图谱/合规/贡献节归位不动；验证：TOC 锚点全部可跳转，frontmatter/结构无（README 无 frontmatter），29 技能与 18 卡类型计数未变

## 2. USAGE.md 收缩为重定向桩

- [ ] 2.1 重写 USAGE.md 为约 10 行桩：首行「正文已合并入 README.md」声明 + 指向 README 安装/使用说明/FAQ/迁移/回滚的锚点清单 + 顶层合规声明段原文保留；验证：全文无技能表/触发词表/FAQ 条目/迁移命令正文（spec 桩契约），合规声明与 SKILL.md/README 所存为同一段文字

## 3. 引用面修正（计数与指路）

- [ ] 3.1 更新 `AGENTS.md` 两处自检：技能集合五处→四处（SKILL/README/skill-catalog/skill-reference-zh）、触发词三处→两处（SKILL/README）；验证：与 spec 计数收敛逐字一致
- [ ] 3.2 更新内容指路三类：`references/card-schema.md` FAQ 指路、`install.sh` 尾部「详细使用见 USAGE.md」、`templates/quickstart-zh.md` + `quickstart-en.md` 迁移指路 → 全部改指 README 对应章节；验证：`install.sh` 复制行（L355）与 `references/compliance.md`「三处」要求未动
- [ ] 3.3 全仓 grep 复核 `USAGE` 残留引用：逐条判定「合法（指向桩/合规三处/历史 change/inbox）」或「需修正（仍指向已迁走的内容）」；验证：无一处指路失效（合法清单外零命中）

## 4. 验证

- [ ] 4.1 openspec validate 通过；对照 spec 三 requirement 走查：README 单源（双写主题单权威 + TOC）、桩契约（无正文 + 含声明）、计数收敛（四处/两处/三处 且 AGENTS 与 README 措辞一致）
- [ ] 4.2 内容保全抽检：USAGE 迁移前 17 个 `##` 节逐一确认 README 对应内容存在（重点抽 §1 迁移 sed 命令、§14 FAQ 的 Q1-Q17、§16 术语表完整）；安装→初始化→第一条指令的模拟新读者路径在 README 内部闭环可走通
