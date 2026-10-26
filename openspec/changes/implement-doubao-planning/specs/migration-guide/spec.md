# Spec Delta

## Purpose

提供 `MIGRATION.md` 版本迁移文档能力：定义版本策略（0.x 实验版 schema 可能变动 / 1.x 稳定版优先兼容层）、五条兼容原则（字段新增不改旧卡 / 改名删除需迁移脚本 / skill 别名永久保留 / 规则 ID 永久不变 / profile_override 机制保留）、升级判定标准、回滚方案与废弃策略，使使用方工程在跨版本升级时有明确的改动点说明与操作路径。本仓库内 MIGRATION.md 只以模板骨架形式存在（由 install.sh --project 生成占位），真实内容由使用方工程随版本迭代填充。

## ADDED Requirements

### Requirement: 版本策略声明

`MIGRATION.md` SHALL 声明版本号格式「主版本.次版本-标记」及两档策略：0.x 实验版（schema 可能变动，不保证向前兼容，建议升级前手动备份 history + cards）；1.x 稳定正式版（schema 变动优先做兼容层，重大改动才强制迁移，系统内置自动迁移转换）。当前基线版本 MUST 在文档顶部明确标注。

#### Scenario: 实验版升级提示

- **WHEN** 使用方工程当前为 0.x 版本，准备升级到下一 0.x
- **THEN** MIGRATION.md 提示「实验标记版本，建议升级前手动备份 history + cards」

### Requirement: 五条兼容原则

`MIGRATION.md` SHALL 列出后续所有版本 MUST 遵守的五条兼容原则：① 字段新增——旧卡片无需改动，缺失字段自动取默认值 ② 字段改名/删除——属破坏性变更，必须写迁移脚本或手动迁移步骤并在文档置顶 ③ skill 中英别名一旦发布尽量永久保留不随意废除 ④ 规则 ID（SPACE_001/BEAT_001 等）一旦定义永久不变，只修改规则逻辑 ⑤ profile_override 全局/单卡片剖面切换机制作为底层基础能力保留不砍。

#### Scenario: 新增字段向后兼容

- **WHEN** 新版本为 sensory_cue 卡新增 `maskable` 字段
- **THEN** 存量无该字段的 cue 卡按默认值（false）处理，无需迁移，nc-校阅 行为不变

#### Scenario: 字段改名触发迁移

- **WHEN** 新版本将 `pre_visible_delay` 改名为 `signal_lead_time`
- **THEN** MIGRATION.md 置顶破坏性变更清单，提供方案 A（nc-migrate 自动遍历替换）或方案 B（手动批量替换表格），升级后执行 nc-校阅 --full 验证

### Requirement: 升级判定标准

`MIGRATION.md` SHALL 提供四档升级判定：✅ 仅新增卡片/规则/skill → 直接继续用旧卡无需迁移；⚠️ 字段重命名/结构重构/删除必填字段 → 破坏性升级提供迁移步骤；🧪 0.x 实验版 → 建议升级前手动备份；🚀 1.0+ 稳定版 → 系统内置自动迁移转换。

#### Scenario: 非破坏性升级

- **WHEN** 新版本仅新增 FACTION_001 规则与势力卡新可选字段
- **THEN** 判定为 ✅ 档，使用方工程无需任何手动操作

### Requirement: 回滚方案

`MIGRATION.md` SHALL 提供升级失败时的四步回滚：① 进入 history/ 找升级前自动生成的快照目录 ② 将快照内 cards + meta 文件覆盖回项目根 ③ 恢复 project.yaml 为升级前版本 ④ 执行 nc-检索 抽查资产 ID 引用是否正常。

#### Scenario: 升级失败回滚

- **WHEN** 升级后 nc-校阅 --full 报大量悬空 ID
- **THEN** 按四步回滚到升级前快照，恢复后 nc-检索 抽查确认引用正常

### Requirement: 废弃策略

`MIGRATION.md` SHALL 定义三档废弃处理：废弃 skill → 保留别名，调用时输出「该 skill 已废弃，推荐使用 xx」提示；废弃标签/旧字段 → 校阅时输出 L3 提示不抛 L1/L2 错误给过渡期；超过两个大版本的废弃字段 → 在下一个版本彻底移除。

#### Scenario: 废弃 skill 软提示

- **WHEN** 作者调用已废弃的旧 skill 别名
- **THEN** 系统输出废弃提示并推荐替代 skill，仍执行原逻辑（过渡期内）
