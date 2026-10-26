# Proposal

## Why

`inbox/doubao-对话-2026-10-26.md`（8740 行）是一份与豆包 AI 的完整规划对话，提出了 novel-cards v0.9-expansion 扩展体系：双模式剖面开关（simple/deep）、空间规则校验、人格基线原型库（爽文 6 + deep 10）、感官标记/姿态/道具/桥段/势力/快照六套新卡片模板、机器可读校阅规则库（rules.json）、小轿车闭环测试 Demo、防空炮铁律定调规范、对外宣讲稿，以及远期 GUI / 多领域插件 / 开源私有分层等方向。

当前仓库已落地 v1.0 主体（29 技能 / 16+ 卡类型 / OO 透镜 / 四层数据分层），但上述 doubao 对话中提出的能力**大部分尚未实现**。本变更的目标是：**系统性地盘点这些未实现项，区分「近期可实施」与「长期 TODO-only」**，为后续迭代提供清晰的优先级清单与 OpenSpec 跟踪载体。

## What Changes

### 近期可实施项（本变更范围内记录，供后续 change 拆解实施）

1. **双模式剖面开关（world_base_profile: simple/deep）**
   - `config/project.yaml` 新增 `world_base_profile` 字段
   - 单卡片 `profile_override` 局部覆写机制
   - 子模块自动开关联动（deep 全开 / simple 精简）
   - 影响 `nc-校阅` / `nc-研判` / `nc-编排` 三个技能的校验松紧度

2. **空间规则校验（SPACE_001）**
   - `space_snapshot` 场景空间卡（净高/宽度/深度/障碍物/活动约束）
   - `actor_bounding` 角色包围盒（身高/姿态包围盒映射/感官掩码 sense_mask）
   - 小轿车案例：内部净高不足 → L1 硬错
   - 联动前庭觉/触觉动线

3. **人格基线原型库扩展**
   - 爽文默认 6 原型（steadfast/fierce/cunning/righteous/reckless/greedy）
   - Deep 完整版 10 原型（avoidant/anxious/npd-grandiose/npd-vulnerable/bpd/aspd/hpd/melancholic/zealot/stoic）
   - 六轴滑动标尺（risk/empathy/impulse_control/trust/desire_orient/aggression）
   - 原型选型提问清单 + 快速选型对照表
   - 经 `nc-注册` 写入 registry 白名单后方可使用

4. **感官标记卡模板增强（sensory_cue）**
   - 五感信号组（sense_channel/perception_alias/base_intensity/attenuation_rule/max_distance/maskable）
   - 触发规则（trigger_mode/trigger_condition/terminate_condition）
   - 时序动线（pre_visible_delay/sequence_rule）— 人未到声先至
   - 情绪&注意力偏向（attention_bias/induced_mood_tendency/hormone_tendency）
   - 丁春秋示例填充

5. **姿态库卡模板增强（pose-bank）**
   - 姿态占用包围盒（pose_bounds h/w/d）对接 space 校验
   - 分部位细节（head/shoulder/hand_arm/torso/leg_foot/facial_tendency）
   - 多视角模块（view_self/view_front/view_side/view_back/view_distant）
   - 描写变体（short/full）

6. **道具卡模板增强（prop/item）**
   - 物理层（bounding/mass/hardness/portable/penetrable）
   - 多状态图谱（state_list: default/active/broken，各态绑定 sensory_cue）
   - 感知动线（perception_trace 五感描述 + perception_alias）
   - 伏笔时序图谱（foreshadow_timeline: pre_plant/pickup/hint_degree）
   - 交互规则（interact_rule: can_grab/can_throw/trigger_on_touch/trigger_on_hold）

7. **桥段节点卡模板增强（plot-beat/plotpoint）**
   - 时序定位（chapter_no/sequence_index/beat_type）
   - 张力参数（tension_base/is_strategic_climax）
   - 参与资产绑定（actor/prop/cue/space/pose ids）
   - 因果与伏笔链路（precondition/postcondition/foreshadow_link）
   - 情绪&性格推演入口（mood_shift_summary/personality_trigger_actor_ids）

8. **势力卡模板增强（faction）**
   - 核心底层设定（core_purpose/core_rule/value_axis）
   - 人员结构（leader/core_member/outer_member）
   - 对外关系（relation_map: ally/rival/hostile/subordinate/secret_collude）
   - 势力专属感官招牌（signature_cue_ids）
   - 行事风格推演基线（default_reaction/restraint_factor）
   - 内部派系分裂（inner_factions）

9. **多视角静态快照卡增强（snapshot）**
   - 时间锚点（chapter_no/beat_id/moment_tag）
   - 全局基础环境（base_space_id/active_cue_ids/active_props）
   - 多视角模块（perspectives: pov_actor/perception_text/cognition_bias/focus_point/known_info/unknown_info）
   - 客观真相层（objective_fact）
   - 后续联动（reuse_plans: recall_beat_ids/retell_by_actor_ids）

10. **机器可读校阅规则库（rules.json）**
    - 全局开关配置（global_switch + auto_enable_map）
    - 错误分级（L1_HARD/L2_WARN/L3_INSPIRATION）
    - 规则条目（SENSE_001/FOCUS_001/HORMONE_001/COG_001/CAUSAL_001/SPACE_001/PERSON_001/CUE_001/PROP_001/BEAT_001/FACTION_001/SNAP_001）
    - 人格基线池 + 滑动轴定义

11. **小轿车闭环测试 Demo**
    - 全套 6 张卡片（space_snapshot/actor_bounding/nc-动向/prop/plot-beat/snapshot）
    - 测试调用指令（nc-校阅/nc-研判/nc-检索/nc-导出）
    - 预期输出对照（SPACE_001 L1 硬错 + PERSON_001 L2 警告）

12. **防空炮铁律定调规范**
    - 四大铁律：无卡不推演 / 人格不允许空炮 / 感官空间物理绝不脑补 / 不生成未定义剧情
    - 系统能力边界（能做 vs 绝对不做）
    - 顶层一句话规范：有卡有据、无卡停推、越界告警、转变留档、零空炮脑补

13. **agents.md 意图路由引导增强**
    - 意图匹配表（素材入库/资产检索/逻辑校验/人物推演/批量调整/产物导出/新建卡片/项目初始化/合规筛查）
    - 交互规则（识别→推荐→确认→执行）
    - 禁止行为（不得无指令自动修改卡片/正文/标尺）

14. **build.sh/build.cmd 脚本说明**
    - 职责边界：只做备份/目录准备/生成导出请求，不实现渲染引擎
    - 跨平台差异（Linux/macOS vs Windows）
    - history 快照归档机制

15. **MIGRATION.md 版本迁移文档**
    - 版本策略（0.x 实验版 / 1.x 稳定版）
    - 兼容原则（字段新增不改旧卡 / 改名删除需迁移脚本 / skill 别名永久保留 / 规则 ID 永久不变）
    - 升级判定标准 + 回滚方案 + 废弃策略

### 长期 TODO-only 项（本变更仅记录，不实施）

1. **GUI 客户端**（Tauri + Vue3，InkOS 风格三栏布局）
   - 创作模式（小说/桥段/角色动线）+ 战略模式（个人知识库/目标拆解/局势推演/复盘看板）
   - 多端联动（手机/网页/桌面）
   - 需要独立 `gui-spec.md` 设计文档
   - 前置条件：先验证文本 Agent + 私有规则包的付费闭环

2. **内核二进制打包**
   - 将 nc_validate.py 编译为独立可执行文件
   - 跨平台分发（Windows/Linux/macOS）
   - 依赖：Go/Rust 重写或 PyInstaller 打包

3. **高级图谱视图**
   - 交互式 SVG/Canvas 图谱（拖拽/缩放/筛选/动画）
   - 积木联动总图的动态渲染
   - 多作品并行图谱切换

4. **跨平台 PDF/Word 导出技能增强**
   - Pandoc 底层封装为独立 skill
   - 模板定制（封面/目录/页眉页脚/字体）
   - 批量导出多章节

5. **多领域插件架构**
   - 内核与领域规则解耦（narrative/business/research/law/education）
   - 可插拔插件包加载机制
   - 商务包（bs-fact/bs-stake/bs-project/bs-risk/bs-proposal/bs-timeline）
   - 科研论文包（rs-paper/rs-claim/rs-evidence/rs-counter/rs-gap/rs-logic）
   - 自定义领域注册能力

6. **开源/私有分层发布策略**
   - 双仓库分离（公开 MIT + 私有加密）
   - 开源层：工具外壳/模板/脚手架/纯文字理论
   - 私有层：模型互锁拓扑/校验触发条件/阈值/标注案例库/反教条仲裁规则
   - 规则包轻度加密 + 密钥管理
   - `.gitignore` 强制屏蔽私有资产

7. **spec-personal-knowledge-base.md**
   - 个人知识库分支的 Schema
   - 新增专属 skill（非小说场景）
   - 与小说模式的开关隔离规则

8. **后 AI 时代文学创作方向研究**
   - 短线迎合（算法多巴胺）vs 长线深耕（公共情感锚点）
   - 4 个核心母题（虚假满足后的失重/重建共识/两种孤独对照/慢的价值）
   - 深度路线故事大纲（主角：浸泡在算法私域信息流中的都市人）

## Capabilities

### New Capabilities

- `dual-mode-profile`: 双模式剖面开关（simple/deep）+ profile_override 局部覆写 + 子模块自动开关联动，控制 nc-校阅/nc-研判/nc-编排 的校验松紧度
- `spatial-validation`: 空间规则校验（SPACE_001）— space_snapshot 场景空间卡 + actor_bounding 角色包围盒 + 感官掩码 sense_mask + 碰撞/位移/重心推演
- `personality-prototype-library`: 人格基线原型库 — 爽文 6 原型 + deep 10 原型 + 六轴滑动标尺 + 原型选型提问清单 + 快速选型对照表 + registry 白名单注册
- `review-rule-engine`: 机器可读校阅规则库（rules.json）— 全局开关/auto_enable_map/错误分级（L1/L2/L3）/12 条规则条目/人格基线池/滑动轴定义
- `card-template-enhancement`: 六套卡片模板增强 — sensory_cue（五感信号组/时序动线/触发规则）/ pose-bank（包围盒/多视角/描写变体）/ prop（物理层/多状态/伏笔时序/交互规则）/ plot-beat（时序/张力/资产绑定/因果链路）/ faction（核心设定/关系网络/感官招牌/派系暗流）/ snapshot（多视角/认知偏差/客观真相/复用计划）
- `closed-loop-test-demo`: 小轿车闭环测试 Demo — 6 张卡片 + 测试调用指令 + 预期输出对照，验证整套系统链路
- `anti-hallucination-doctrine`: 防空炮铁律定调规范 — 四大铁律（无卡不推演/人格不空炮/感官空间不脑补/不生成未定义剧情）+ 能力边界 + 顶层一句话规范
- `intent-routing-guide`: agents.md 意图路由引导增强 — 意图匹配表 + 交互规则 + 禁止行为
- `build-script-contract`: build.sh/build.cmd 脚本契约 — 职责边界（备份/目录/导出请求）+ 跨平台差异 + history 快照归档
- `migration-guide`: MIGRATION.md 版本迁移文档 — 版本策略 + 兼容原则 + 升级判定 + 回滚方案 + 废弃策略

### Modified Capabilities

（无 — 本变更为新增能力，不修改现有 spec 的需求）

## Impact

- **config/**: `project.yaml` 新增 `world_base_profile` / `profile_override` / 子模块开关字段
- **registry/**: `tendency-prototypes.yaml` 扩展人格基线原型白名单（爽文 6 + deep 10）
- **templates/**: 六套卡片模板增强（sensory-cues.md / pose-bank.md / items.md / plotpoints.md / factions.md / snapshots.md）
- **references/**: 新增 `review-rules.md`（机器可读规则库）/ `spatial-validation.md`（空间校验细则）/ `personality-prototypes.md`（人格原型库）/ `anti-hallucination.md`（防空炮铁律）/ `migration.md`（版本迁移指南）
- **SKILL.md**: 速查表补充双模式说明 + 防空炮铁律摘要
- **README.md**: 补充双模式/空间校验/人格原型/rules.json 的能力描述
- **USAGE.md**: 补充双模式使用路径 + 测试 Demo 运行指引
- **install.sh --project**: 骨架新增 `config/review-rules.json` 占位 + `registry/tendency-prototypes.yaml` 扩展
- **tools/nc_validate.py**: 可选扩展 validate 子命令支持 rules.json 驱动的规则校验（保持只读铁律）
- **inbox/**: 本变更源文档 `doubao-对话-2026-10-26.md` 归档引用
