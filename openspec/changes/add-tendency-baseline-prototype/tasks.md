# Tasks

## 1. references/ 规范文档（契约层，先行）

- [x] 1.1 更新 `references/card-schema.md`：character_tendency 小节字段表新增可选行 `baseline_prototype`（registry-backed 枚举、注册前置、创作参考锚点非临床诊断），字段说明段补「与现行滑动字段分工 / 同角色多卡共享或分维声明 / 未声明零影响」，示例区补一个带 `baseline_prototype: npd-grandiose` 的扩展示例并标注「示例，需经 nc-注册 后方可使用」；验证：五必备字段+新增可选字段说明齐全，示例 YAML 可解析且不与现有最小示例冲突
- [x] 1.2 更新 `references/skill-catalog.md`：nc-动向 入参行（约 L158）增补可选 `baseline_prototype`（含未注册拦截语义）；nc-校阅 职责行（约 L72）增补「原型边界漂移建议级检查（检查④）」；核对 nc-初始化 产物描述若枚举 registry 文件则补 `tendency-prototypes.yaml`；验证：入参与职责描述与 specs 逐字对齐
- [x] 1.3 更新 `references/hard-rules.md`：规则 16（注册前置，约 L27/L330）适用范围措辞从「自定义卡片类型或动线 track 标签」扩为含「动向卡人格基线原型枚举取值」，规则详解节补 tendency-prototypes.yaml 一句；验证：规则 16 在总表与详解节两处措辞一致
- [x] 1.4 更新 `references/layout.md`：registry 文件清单（约 L22-25）收录 `tendency-prototypes.yaml`（注释标明「动向卡人格基线原型白名单（骨架 only，经 nc-注册 写入）」）；验证：清单含该文件且与 card-schema/skill-catalog 引用文件名一致

## 2. templates/（骨架层）

- [x] 2.1 更新 `templates/tendencies.md`：frontmatter 骨架加可选行 `# baseline_prototype: <原型 key>  # 可选：人格基线原型，取值须经 nc-注册`；字段说明表加 `baseline_prototype`（❌ 可选）行；正文补「人格基线原型」小节（registry boundary_hints 机制 + 检查④提醒语义 + npd-* 示例块标注需注册）；验证：模板五必备字段不变，新增行均为可选注释形式
- [x] 2.2 更新 `templates/skill-reference-zh.md`：nc-动向 行（约 L33 职责 + L92 入参）与 nc-校阅 职责行同步 baseline_prototype / 检查④；验证：与 skill-catalog.md 措辞一致
- [x] 2.3 更新 `templates/skill-reference-en.md`：同步 2.2 的英文对应行（约 L37/L97 + nc-校阅行）；验证：中英两模板行结构一一对应

## 3. 顶层文档一致性

- [x] 3.1 更新 `README.md`：16+ 卡类型表 character_tendency 行「关键专属字段」增补 `baseline_prototype`；硬规则速览第 16 条措辞同步扩展；技能速览中 nc-动向/nc-校阅 职责短句同步；验证：与 references 对应段零语义差异
- [x] 3.2 更新 `USAGE.md`：Q16（角色性格怎么记，约 L763）补一句「可选 `baseline_prototype` 声明人格基线原型（如自恋型两类创作原型），滑动边界由 nc-校阅 检查④提醒」；验证：不改变 Q16 现有流程描述
- [x] 3.3 核对 `SKILL.md` body：速查表 nc-动向/nc-校阅 行与路由规则是否需同步（预计仅职责短语微调）；验证：frontmatter 仍仅 name/description/license 三键（YAML dump 确认），29 技能计数不变
- [x] 3.4 更新 `AGENTS.md`：编辑自检清单追加一条「baseline_prototype 为 registry-backed 可选枚举：词表只在示例出现、nc-初始化 骨架零预置、检查④为建议级」；验证：清单条目与本 change specs 一致

## 4. 验证

- [x] 4.1 运行 `openspec validate --changes add-tendency-baseline-prototype` 通过；grep 自检：新增措辞未触碰 `dimension`/`baseline`/`direction_rule`/`history` 现有语义描述，无「AI 直接写卡」类措辞，路径全为相对路径
- [x] 4.2 纸面演练双分支：①注册 npd-grandiose（共情 hint max_drift:2）→ nc-动向 建卡传原型成功 → 共情维度漂移 4 触发检查④提醒；②未注册取值被拦截、无声明卡检查④静默、registry 缺失不报错——确认每步指向的文档/模板文件存在且字段对得上
