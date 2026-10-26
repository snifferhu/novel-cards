# Design

## Context

本仓库是 novel-cards skill 定义仓库（非小说工程本身）。doubao 对话提出的 v0.9-expansion 扩展体系需要落到本仓库的交付物中：`SKILL.md` / `references/` / `templates/` / `install.sh --project` 骨架 / `tools/nc_validate.py`。约束来自 AGENTS.md 禁区：不生成真实卡片数据、registry/config 模板只放骨架占位、frontmatter 三键铁律、提案制不可绕过、tools 只读零依赖。

See proposal.md — Why / What Changes for full scope. Specs define the behavior contracts; this design covers how those behaviors map onto the existing repo structure.

## Goals / Non-Goals

**Goals**
- 将双模式剖面开关、空间校验、人格原型库、规则引擎、六套模板增强、测试 Demo、防空炮铁律、意图路由、build 契约、迁移指南共 10 项能力，以「文档 + 模板骨架 + registry 白名单结构 + 可选运行时扩展」的形式落进本仓库交付物
- 保持 v1.0 主体（29 技能 / 16+ 卡类型 / OO 透镜 / 四层分层）完全不变，新能力全部为增量叠加
- 所有新增字段向后兼容：存量卡缺失新字段按默认值处理，行为不变
- 长期 TODO-only 项（GUI / 内核打包 / 高级图谱 / 跨平台导出增强 / 多领域插件 / 开源私有分层 / personal-kb spec / 后 AI 文学方向）仅在本 change 的 proposal 中记录，不产生任何实施任务

**Non-Goals**
- 不实现 GUI 客户端、不做 Tauri/Vue3 工程
- 不把 nc_validate.py 编译为二进制或引入第三方依赖
- 不创建多领域插件架构（business/research 包）
- 不落地开源/私有双仓库分层与规则包加密
- 不在本仓库内写任何真实小说卡片内容（examples/ 只放假名占位）

## Decisions

### D1: 双模式开关落在 config/project.yaml 而非新文件

`world_base_profile` / `profile_override` / 子模块开关全部作为 `config/project.yaml` 的新增可选字段，不另建 `config/profile.yaml`。

**理由**：使用方工程已有 `config/project.yaml` 承载 lang/mode/pipeline_option，剖面开关与 mode（long/mid/short）天然正交但同属「工程级配置」，集中一处避免配置碎片化。auto_enable_map 联动逻辑由 nc-校阅/nc-研判/nc-编排 三个技能在运行时读取 project.yaml 计算，不落地为独立配置文件。

**备选**：独立 `config/profile.yaml` —— 被否，因为增加一个文件却无独立生命周期，且 install.sh --project 骨架要多维护一个占位。

### D2: rules.json 作为 config 层真值，nc_validate.py 可选消费

`config/review-rules.json` 是使用方工程的 `.json` 层机器真值（对齐四层分层的 index/ 定位，但归属 config/ 因为是规则配置而非图森林）。本仓库只在 `templates/` 提供骨架示例（字段结构 + 占位），真实 12 条规则取值由使用方工程经 nc-初始化 生成。

`tools/nc_validate.py` 的 validate 子命令 MAY 扩展为：若 `config/review-rules.json` 存在则按其 rule_set 驱动结构化校验，缺失时降级纸面校验（现有行为）。扩展 MUST 保持零第三方依赖（仅 Python3 标准库 json/re/pathlib）、只读不写盘。

**理由**：规则库是「配置白名单」性质（人工少量维护或经 nc-注册），归 config/ 比归 index/ 更准确；index/ 专供图森林真值。nc_validate.py 保持可选运行时定位不变。

**备选**：规则写死在 references/*.md 自然语言 —— 被否，因为 doubao 对话明确要求「机器可读 JSON 规则条目给 Agent 解析」，自然语言无法被确定性执行。

### D3: 人格原型走 registry 白名单 + nc-注册 前置

爽文 6 原型 + deep 10 原型的定义（六轴初始值 + prototype_note + 适用身份 + 避雷点）落在 `registry/tendency-prototypes.yaml`，延续 v1.0 已有的 `baseline_prototype` registry-backed 可选枚举机制。本仓库 templates 中该 yaml 只放骨架（字段结构 + 注释说明「需经 nc-注册」），零预置具体原型条目——与现有 `npd-*` 词表处理方式一致。

**理由**：AGENTS.md 自检清单明确「baseline_prototype 为 registry-backed 可选枚举，nc-初始化 骨架零预置具体条目」。16 个原型的具体数值属于「使用方工程运行时数据」，不应硬编码进 skill 仓库。选型提问清单与快速对照表作为 references 文档（自然语言引导），不进 registry。

**备选**：原型数值直接写进 templates/tendencies.md —— 被否，违反「registry 模板只放骨架」禁区。

### D4: 六套模板增强走「既有模板加可选字段」而非新卡类型

sensory_cue / pose / item / plotpoint / faction / snapshot 六类卡在 v1.0 已存在对应模板（templates/sensory-cues.md / pose-bank.md / items.md / plotpoints.md / factions.md / snapshots.md）。doubao 提出的新字段（五感信号组 / 包围盒 / 多状态 / 张力参数 / 关系网络 / 多视角）全部作为**可选增强字段**追加到既有模板，不新建卡类型、不改 id 前缀、不改目录。

**例外**：`space_snapshot` 与 `actor_bounding` 在 v1.0 无独立卡类型。决策：
- `space_snapshot` 复用 `scene` 卡（sc-）扩展 `usable_clearance` / `mobility_constraint` / `obstacle_list` 字段，不新建 type
- `actor_bounding` 复用 `actor` 卡（ac-）扩展 `base_bounds` / `pose_bounding_map` / `sensory_mask` 字段，不新建 type

**理由**：避免卡类型膨胀（v1.0 已 16+ 类），空间与包围盒本质是场景/角色的属性维度而非独立叙事实体。OO 透镜下它们是 NcObject 的属性扩展，不是新子类。

**备选**：新建 `space` / `bounding` 两个 type —— 被否，破坏 16+ 类稳定集合，且需同步改 card-schema / skill-catalog / oo-model 三处一致性。

### D5: 小轿车 Demo 落 examples/ 用假名占位

6 张 Demo 卡以结构骨架 + 假名占位形式放 `examples/car-demo/`（如 `角色-甲` / `场景-车厢` / `道具-玉佩`），遵守 AGENTS.md「examples/ 只放结构骨架与假名占位」禁区。预期输出对照表作为 `examples/car-demo/expected-output.md`。使用方工程初始化后可参考此样例自行填充真实内容。

**理由**：本仓库绝不写真实业务数据；Demo 的价值在于展示字段如何填充 + 链路如何跑通，假名足够。

### D6: 防空炮铁律落 SKILL.md body + references/anti-hallucination.md

四大铁律 + 能力边界 + 顶层一句话规范，摘要进 SKILL.md body 硬规则区（作为第 27 条硬规则候选或并入既有 nc-研判/nc-校阅 描述），全文落 `references/anti-hallucination.md`。不动 frontmatter（三键铁律）。

### D7: 长期 TODO-only 项不落任何交付物

GUI / 内核打包 / 高级图谱 / 跨平台导出 / 多领域插件 / 开源私有分层 / personal-kb / 后 AI 文学方向，仅在 proposal.md 的「长期 TODO-only 项」章节记录，不产生 specs / design 决策 / tasks 任务。后续如需实施，另起独立 OpenSpec change。

## Risks / Trade-offs

- [rules.json 12 条规则的 simple/deep 双行为描述可能随迭代频繁变动] → rule_id 永久不变只改逻辑（MIGRATION.md 兼容原则④）；本仓库只放骨架，真实规则在使用方工程，skill 仓库不受影响
- [space/actor 字段扩展可能与存量 scene/actor 卡的自定义字段冲突] → 新字段全部可选，缺失按默认值；nc-校阅 对无新字段的存量卡行为不变（向后兼容铁律）
- [nc_validate.py 扩展 rules.json 驱动可能引入 bug] → 保持可选运行时定位，缺失/损坏时降级纸面校验；扩展代码隔离在独立函数，不影响既有 validate/audit/simulate 三子命令
- [16 原型数值放 registry 导致使用方工程初始化负担] → nc-初始化 可交互式引导选择常用原型子集，不强制全量注册
- [双模式 auto_enable_map 联动逻辑分散在三个技能] → 联动映射表单一来源（review-rules.json 的 auto_enable_map），三个技能都读同一份，不各自硬编码
- [examples/ 假名 Demo 可能被误认为真实数据] → 文件名与正文显式标注「示例占位，非真实内容」

## Migration Plan

本变更为纯增量，无需使用方工程迁移：
1. 升级 skill 仓库（git pull 或重新 install.sh）
2. 使用方工程可选执行 `nc-初始化` 刷新 config/project.yaml 骨架（新增 world_base_profile 等可选字段占位）+ registry/tendency-prototypes.yaml 骨架
3. 存量工程不执行 nc-初始化 也完全正常——所有新字段可选，缺省行为 = v1.0
4. 回滚：git revert skill 仓库即可，使用方工程无破坏性变更

## Open Questions

- `space_snapshot` 是否需要在 card-schema.md 的 type 表中单列一行（作为 scene 的子形态说明），还是仅在 scenes.md 模板内描述？倾向后者，待实施时确认
- nc_validate.py 的 rules.json 驱动校验是否在本 change 实施，还是留作后续独立 change？倾向本 change 只做骨架 + 文档，运行时扩展另起 change（控制范围）
- 小轿车 Demo 的 expected-output.md 是否需要覆盖 simple/deep 双模式完整输出样例，还是只列关键告警？倾向完整样例（回归验证基准价值更高）
