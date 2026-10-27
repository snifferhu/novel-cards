# Tasks

> 本 change 的任务范围 = 将 doubao 对话中「近期可实施项」落进 skill 仓库交付物（SKILL.md / references/ / templates/ / install.sh 骨架 / examples/）。长期 TODO-only 项（GUI / 内核打包 / 高级图谱 / 跨平台导出增强 / 多领域插件 / 开源私有分层 / personal-kb / 后 AI 文学方向）不产生任务。所有新增字段向后兼容，存量卡行为不变。

## 1. 双模式剖面开关（dual-mode-profile）

- [x] 1.1 `references/data-layering.md` 与 `references/hard-rules.md`：补充 `world_base_profile`（simple/deep）+ `profile_override` 局部覆写 + 子模块 auto_enable_map 联动表的说明，明确存量工程缺字段时隐式 simple、MUST NOT 报错；验证：文档含映射表且措辞与 spec 一致
- [x] 1.2 `templates/` 双语 agents/quickstart/skill-reference 模板：在配置节补充 `world_base_profile` / `profile_override` 占位说明（仅结构占位，不写具体取值）；验证：中英模板节结构一一对应、占位符集合一致
- [x] 1.3 `install.sh --project` 骨架：`config/project.yaml` 占位文件新增 `world_base_profile:` / `profile_override:` / 六个 `check_*` 开关的注释占位行（值留空或注释），幂等不覆盖已有；验证：重复执行 install.sh --project 零变更
- [x] 1.4 SKILL.md body：在硬规则速览 / 触发场景区补充双模式一句话说明（simple 只拦 L1 / deep 全链路 / profile_override 单卡覆写），不动 frontmatter 三键；验证：YAML frontmatter 解析仍只有 name/description/license 三键

## 2. 空间规则校验（spatial-validation）

- [x] 2.1 `references/card-schema.md`：scene 卡（sc-）补充可选字段 `usable_clearance` / `mobility_constraint` / `obstacle_list`；actor 卡（ac-）补充可选字段 `base_bounds` / `pose_bounding_map` / `sensory_mask`（七通道）；type/前缀表不变；验证：字段契约与 spec 一致，五字段必备仍成立
- [x] 2.2 `templates/scenes.md`：追加 space_snapshot 可选字段骨架（净高/宽深/活动约束/障碍物/env_note）+ 小轿车假名示例；`templates/characters.md`：追加 actor_bounding 可选字段骨架（身高/姿态包围盒/感官掩码）；验证：模板含五字段 + 新可选字段，路径为使用方工程相对路径
- [x] 2.3 `references/hard-rules.md`：新增 SPACE_001 空间校验规则说明（deep 包围盒/位移/重心推演，simple 仅拦穿墙；狭小空间动作 L2 商榷可 override_note 豁免）；验证：规则描述与 review-rule-engine spec 的 SPACE_001 条目对齐
- [x] 2.4 `tools/nc_validate.py`：validate 子命令扩展——若卡片含 `usable_clearance` + `pose_bounding_map` 则做净高 vs 姿态包围盒的只读比较（纯标准库浮点比较），缺失字段跳过；保持零依赖、只读、不替代提案制；验证：对含空间字段的样例卡输出 L1 提示，对无字段卡行为不变

## 3. 人格基线原型库（personality-prototype-library）

- [x] 3.1 `references/card-schema.md`：character_tendency（tend-）卡的 `baseline_prototype` 字段说明扩展为「registry-backed 枚举，爽文 6 + deep 10 原型须经 nc-注册」，六轴（risk/empathy/impulse_control/trust/desire_orient/aggression）取值 -10~+10；验证：与既有 baseline_prototype registry-backed 表述一致
- [x] 3.2 新建 `references/personality-prototypes.md`：爽文 6 原型 + deep 10 原型的完整定义（六轴初始值 + prototype_note + 适用身份 + 避雷点 + 推荐模式）+ 选型提问清单（Q0 + 核心 5 问）+ 快速选型对照表；障碍类标注「仅创作基线非临床诊断」；一人一原型铁律；验证：16 原型齐全、表格与清单完整
- [x] 3.3 `templates/tendencies.md`：补充 `baseline_prototype` 可选字段 + 六轴 slide_axes 骨架 + prototype_note 占位（不预置具体原型数值，标注「需经 nc-注册」）；`install.sh --project` 的 `registry/tendency-prototypes.yaml` 骨架保持零预置条目（仅字段结构注释）；验证：骨架无具体 npd-* 等词表取值，符合 AGENTS.md 禁区
- [x] 3.4 `references/skill-catalog.md`：nc-动向 技能描述补充「可选声明人格基线原型（爽文 6 / deep 10，须经 nc-注册）」；验证：29 技能集合与六组分类不变，仅描述增量

## 4. 机器可读校阅规则库（review-rule-engine）

- [x] 4.1 新建 `references/review-rules.md`：全局开关 + auto_enable_map（simple/deep 两套）+ 三级错误分级（L1_HARD/L2_WARN/L3_INSPIRATION）+ 12 条规则条目表（SENSE/FOCUS/HORMONE/COG/CAUSAL/SPACE/PERSON/CUE/PROP/BEAT/FACTION/SNAP，各含 level/simple 行为/deep 行为/deps）+ rule_id 永久稳定原则；验证：12 条齐全、分级定义与 spec 一致
- [x] 4.2 `templates/` 新增 `review-rules.json` 骨架模板（字段结构 + 占位，rule_set 给 1-2 条示例结构不给全量真实取值）；`install.sh --project` 骨架在 `config/` 下生成 `review-rules.json` 占位文件（幂等）；验证：JSON 骨架合法、重复 install 零变更
- [x] 4.3 `references/hard-rules.md`：nc-校阅 描述补充「规则驱动：优先读 config/review-rules.json，缺失降级纸面校验」+ 三级输出格式（🔴L1 附修改方案 / 🔵L2 附豁免选项 / 💡L3 启发）；验证：与 audit 只读铁律不冲突（只出意见绝不改稿）
- [x] 4.4 `tools/nc_validate.py`：validate 子命令扩展——若 `config/review-rules.json` 存在则按 rule_set 的 deps 字段做结构化字段存在性/取值域检查（纯标准库 json），缺失或 JSON 损坏时降级现有纸面逻辑；保持只读零依赖；验证：对含 rules.json 的样例工程输出带 rule_id 的检查结果，无 rules.json 时行为与现状一致

## 5. 六套卡片模板增强（card-template-enhancement）

- [x] 5.1 `templates/sensory-cues.md`：追加五感信号组（sensory_signals[]: sense_channel/perception_alias/base_intensity/attenuation_rule/max_distance/maskable/fade_note）+ 触发规则（trigger_mode/trigger_condition/terminate_condition）+ 时序动线（timeline_trace: pre_visible_delay/sequence_rule）+ 情绪注意力偏向（attention_bias/induced_mood_tendency/hormone_tendency）+ 丁春秋假名示例；验证：五感公理延续（根落原生五感，玄幻走 perception_alias）
- [x] 5.2 `templates/pose-bank.md`：追加 pose_bounds（h/w/d）+ part_detail（六部位）+ multi_view_module（五视角）+ fit_mood/unfit_mood + variant_text（short/full）+ 斜倚握扇假名示例；验证：P1>P2>P3 插槽优先级铁律不变
- [x] 5.3 `templates/items.md`：追加 physics（bounding/mass/hardness/portable/penetrable）+ state_list[]（default/active/broken 各绑 linked_sensory_cue_id）+ perception_trace（五感 + perception_alias）+ foreshadow_timeline（pre_plant/pickup/hint_degree）+ interact_rule + owner_history + 旧玉佩假名示例；验证：黑盒三层铁律不变，新字段均可选
- [x] 5.4 `templates/plotpoints.md`：追加 tension_base/is_strategic_climax/beat_type/sequence_index/precondition_beat_ids/postcondition_beat_ids/foreshadow_link/mood_shift_summary/personality_trigger_actor_ids + 参与资产绑定（actor/prop/cue/space/pose ids）；验证：strategic_burst 既有字段与 is_strategic_climax 关系说明清楚（复用或别名，二选一明确）
- [x] 5.5 `templates/factions.md`：追加 core_purpose/core_rule/value_axis/leader_actor_id/relation_map[]（五种 relation_type）/signature_cue_ids/default_reaction/restraint_factor/inner_factions[]/controlled_prop_ids/controlled_scene_ids + 逍遥派假名示例；验证：与 members/territory/conflicts 既有字段不冲突
- [x] 5.6 `templates/snapshots.md`：追加 beat_id/moment_tag/base_space_id/active_cue_ids/active_props/perspectives[]（pov_actor/perception_text/cognition_bias/focus_point/known_info/unknown_info）/objective_fact/reuse_plans + 车内争吵双视角假名示例；验证：时间锚点状态切片定位不变
- [x] 5.7 `references/card-schema.md`：同步上述六类卡的新增可选字段到字段契约表；验证：schema 与 templates 逐字段对齐

## 6. 小轿车闭环测试 Demo（closed-loop-test-demo）

- [x] 6.1 新建 `examples/car-demo/` 目录，放 6 张假名占位卡（场景-车厢 sc- / 角色-甲 ac- / 动向-甲 tend- / 道具-玉佩 it- / 桥段-车内争吵 pp- / 快照-定格 sn-），全部用假名 + 结构骨架，id 互相引用无悬空；验证：6 卡 id 引用闭环，文件头标注「示例占位非真实内容」
- [x] 6.2 `examples/car-demo/expected-output.md`：deep/simple 双模式的预期告警对照表（deep: SPACE_001 L1 + PERSON_001 L2 + FOCUS_001 L2；simple: 无 L1/L2 仅 L3）+ 4 条测试调用指令（nc-校阅/nc-研判/nc-检索/nc-导出）；验证：对照表与 review-rules spec 的规则行为一致
- [x] 6.3 USAGE.md：补充「初始化后冒烟测试」小节，指向 examples/car-demo 的 4 条调用指令；验证：路径为相对引用，无绝对路径

## 7. 防空炮铁律（anti-hallucination-doctrine）

- [x] 7.1 新建 `references/anti-hallucination.md`：四大铁律全文（无卡不推演/人格不空炮/感官空间物理不脑补/不生成未定义剧情）+ 系统能力边界（能做 5 项 vs 绝对不做 5 项）+ 顶层一句话规范「有卡有据、无卡停推、越界告警、转变留档、零空炮脑补」+ 各铁律的 WHEN/THEN 判定示例；验证：四铁律齐全、边界清单完整
- [x] 7.2 SKILL.md body：硬规则速览补充防空炮摘要（可作为第 27 条或并入 nc-研判/nc-校阅 描述），指向 references/anti-hallucination.md；frontmatter 不动；验证：YAML 三键解析通过，body 含铁律摘要
- [x] 7.3 `references/hard-rules.md`：nc-研判/nc-编排 条目补充「无卡不推演：缺资产卡直接返回资产不足，MUST NOT 脑补补设定」；验证：与既有「研判/编排只出建议与计划」铁律协同不矛盾

## 8. 意图路由引导（intent-routing-guide）

- [x] 8.1 `references/agents-guide.md`：补充意图匹配表（9 类输入信号 → 意图 → 推荐 skill → 提示）+ 交互规则四步话术模板 + 禁止行为清单（无指令不改卡/不建目录）+ 显式指令优先原则；验证：9 类意图齐全、话术模板可复制
- [x] 8.2 `templates/agents-zh.md` / `agents-en.md`：双语模板节结构同步补充意图匹配表占位 + 交互规则节 + 禁止行为节；验证：中英节结构一一对应、占位符集合一致
- [x] 8.3 `install.sh --project` 生成的 agents.md 兜底版：补充意图路由引导的最小占位段落；验证：兜底版与交互式完整版节结构兼容

## 9. build 脚本契约 + 迁移指南（build-script-contract / migration-guide）

- [x] 9.1 `install.sh --project` 生成的 `build.sh` / `build.cmd` 骨架：确保职责边界注释清晰（只做备份/目录/生成 export_request.json，不调 pandoc 不渲染），跨平台步骤对齐，export_request.json 含 include_cards/include_draft/include_index 三布尔默认 true；验证：双端脚本逻辑一一对应，注释含「渲染交给 nc-导出」
- [x] 9.2 新建 `references/migration.md`：版本策略（0.x/1.x）+ 五条兼容原则 + 升级判定四档 + 回滚四步 + 废弃三档策略；`install.sh --project` 骨架生成 MIGRATION.md 占位（当前基线版本 + 待填充区）；验证：五原则/四档/四步/三档齐全，占位幂等
- [x] 9.3 README.md / USAGE.md：补充「版本迁移」指引指向 references/migration.md + build 脚本职责边界一句话；验证：措辞与 spec 一致

## 10. 集成验证与一致性自检

- [x] 10.1 跑 AGENTS.md §7 编辑自检清单全项：frontmatter 三键 / 提案制无直接 edit-write 措辞 / 伏笔 payoff 二选一 / darklayer 隔离 / timeline track-target / 反思卡五段 rf- / 过滤器三问 Q3 否决 / 图谱 HTML 独立 / 五字段齐全 / 相对路径 / 双端兼容 / 无 relationship 残留 / 29 技能五处计数一致 / 六组分类三处一致 / auto_invokable 三项三处一致 / 三分拆文档对应 / 双语模板对应 / 四层分层三处一致 / 触发词前缀一致 / baseline_prototype registry-backed / OO 透镜对齐 / 事件推演对齐 / tools 只读三处一致；验证：逐项勾选通过
- [x] 10.2 `openspec validate --change implement-doubao-planning --strict` 通过（无长描述警告、Purpose ≥50 字符、scenario 四井号）；验证：命令退出码 0
- [x] 10.3 确认长期 TODO-only 项（GUI/内核打包/高级图谱/跨平台导出/多领域插件/开源私有分层/personal-kb/后AI文学）未在任何 tasks/specs/design 中产生实施任务，仅存在于 proposal.md 记录区；验证：grep 确认这些词只出现在 proposal 的 TODO-only 章节

## Workflow follow-up

- 本 change 的 specs 为新增能力 delta，archive 时由 OpenSpec 合并进 `openspec/specs/` 主规格。
- archive 前确认使用方工程侧（外部小说仓库）已按需消费新模板/规则骨架——本仓库不直接触达使用方工程。
- 后续如需实施 nc_validate.py 的 rules.json 完整驱动校验（本 change 仅做字段存在性/取值域轻量扩展），另起独立 change 控制范围。
