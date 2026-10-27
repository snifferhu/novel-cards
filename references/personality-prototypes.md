# 人格基线原型库（personality-prototypes.md）

novel-cards v1.0 提供 **16 个人格基线原型**：爽文默认 6 原型 + deep 扩展 10 原型。
每个原型含**六轴初始值**（取值 -10~+10）、`prototype_note`（性格描述 + 滑动方向约束）、
适用身份说明与避雷点。原型取值 MUST 经 `nc-注册` 写入使用方工程
`registry/tendency-prototypes.yaml` 后方可用于 `character_tendency` 卡的
`baseline_prototype` 字段，延续 v1.0 已有的「注册前置」铁律。

> **免责声明**：障碍类原型（bpd / aspd / npd-* 等）**仅小说创作基线，不能作为临床诊断**。
> 本库是写作辅助工具，不替代任何心理学专业评估。

## 六轴定义

| 轴 | 英文 key | 语义 | 取值范围 |
|---|---|---|---|
| 风险倾向 | `risk` | 负 = 规避风险 / 求稳；正 = 冒险 / 冲动 | -10 ~ +10 |
| 共情能力 | `empathy` | 负 = 冷漠 / 低共情；正 = 高共情 / 敏感 | -10 ~ +10 |
| 冲动控制 | `impulse_control` | 负 = 易冲动 / 难自控；正 = 克制 / 自律 | -10 ~ +10 |
| 信任倾向 | `trust` | 负 = 戒备 / 多疑；正 = 开放 / 易信人 | -10 ~ +10 |
| 欲望导向 | `desire_orient` | 负 = 克制欲望 / 延迟满足；正 = 追求即时满足 / 物欲强 | -10 ~ +10 |
| 攻击性 | `aggression` | 负 = 温和 / 回避冲突；正 = 好斗 / 主动攻击 | -10 ~ +10 |

## 爽文默认 6 原型

simple 模式下原型仅作素材参考，不读取 `prototype_note` 的滑动约束；deep 模式下突破
轴边界抛 L2_WARN（PERSON_001）。

### steadfast（坚忍型）

| 轴 | 初始值 |
|---|---|
| risk | -2 |
| empathy | 7 |
| impulse_control | 7 |
| trust | 4 |
| desire_orient | 3 |
| aggression | -2 |

- **prototype_note**：沉稳可靠、重情义、长期主义；滑动约束——risk 与 aggression 两端
  均受限（不易突然变激进或极端保守），empathy 高位稳定；适合「隐忍爆发」弧光。
- **适用身份**：主角 / 核心配角，承担长线情感锚点。
- **避雷点**：避免写成无情绪波动的木头人；需保留 1-2 个失控触发点。
- **推荐模式**：simple / deep 均可。

### fierce（刚烈型）

| 轴 | 初始值 |
|---|---|
| risk | 5 |
| empathy | 3 |
| impulse_control | 2 |
| trust | 2 |
| desire_orient | 4 |
| aggression | 8 |

- **prototype_note**：血性刚烈、不服就干、快意恩仇；滑动约束——aggression 高位锁定
  （不会突然变得温顺），risk 中高位；适合「以暴制暴 → 学会收手」弧光。
- **适用身份**：热血主角 / 武戏担当 / 反派镜像角色。
- **避雷点**：避免全程暴躁无层次；需设计「被迫低头」的关键桥段制造反差。
- **推荐模式**：simple（爽文快节奏）/ deep（需推演暴力后果连锁）。

### cunning（狡黠型）

| 轴 | 初始值 |
|---|---|
| risk | 3 |
| empathy | -1 |
| impulse_control | 8 |
| trust | -3 |
| desire_orient | 5 |
| aggression | 2 |

- **prototype_note**：心思缜密、算无遗策、表面温和内里冷硬；滑动约束——impulse_control
  高位锁定（极少失态），trust 低位（不易真正交心）；适合「布局者 → 被情感击穿」弧光。
- **适用身份**：谋士型主角 / 幕后操盘手 / 智斗线核心。
- **避雷点**：避免写成全知全能；必须保留「算漏一步」的破绽来源。
- **推荐模式**：deep（需推演博弈链与反制）。

### righteous（正道型）

| 轴 | 初始值 |
|---|---|
| risk | -1 |
| empathy | 8 |
| impulse_control | 6 |
| trust | 5 |
| desire_orient | 2 |
| aggression | 3 |

- **prototype_note**：嫉恶如仇、坚守底线、侠义心肠；滑动约束——empathy 高位稳定，
  aggression 中位（为正义而怒但非滥杀）；适合「信念动摇 → 重建」弧光。
- **适用身份**：侠义主角 / 正道领袖 / 导师型角色。
- **避雷点**：避免写成道德完人；需设计「两难抉择」让底线被考验。
- **推荐模式**：simple / deep 均可。

### reckless（莽撞型）

| 轴 | 初始值 |
|---|---|
| risk | 9 |
| empathy | 4 |
| impulse_control | -4 |
| trust | 6 |
| desire_orient | 5 |
| aggression | 6 |

- **prototype_note**：胆大包天、不计后果、凭直觉行事；滑动约束——risk 高位锁定
  （不会突然变得谨慎），impulse_control 低位（极易冲动）；适合「莽夫 → 学会谋略」弧光。
- **适用身份**：成长型主角 / 喜剧担当 / 破局者。
- **避雷点**：避免每次莽撞都靠运气过关；需有「莽撞付出代价」的桥段。
- **推荐模式**：simple（爽文节奏）/ deep（推演莽撞的连锁灾难）。

### greedy（贪欲型）

| 轴 | 初始值 |
|---|---|
| risk | 4 |
| empathy | -4 |
| impulse_control | 1 |
| trust | -2 |
| desire_orient | 9 |
| aggression | 5 |

- **prototype_note**：唯利是图、欲望驱动、为达目的不择手段；滑动约束——desire_orient
  高位锁定（贪欲不会消退只会升级），empathy 低位；适合「得寸进尺 → 众叛亲离」弧光。
- **适用身份**：反派 / 黑化配角 / 欲望线驱动力角色。
- **避雷点**：避免写成纯脸谱化恶人；需给贪欲一个「合理起点」（如童年匮乏）。
- **推荐模式**：deep（需推演贪欲升级的连锁反应与反噬）。

## Deep 扩展 10 原型

以下 10 个原型在 deep 模式下启用完整 `prototype_note` 滑动约束校验（PERSON_001 L2_WARN）；
simple 模式下仅作素材参考。

### avoidant（回避型依恋）

| 轴 | 初始值 |
|---|---|
| risk | -6 |
| empathy | 2 |
| impulse_control | 5 |
| trust | -7 |
| desire_orient | -2 |
| aggression | -5 |

- **prototype_note**：害怕亲密、主动疏远、用冷漠保护自己；滑动约束——trust 低位深度锁定
  （不会突然疯狂黏人，除非有重大触发事件 + override_note）；risk 低位（回避一切情感风险）。
- **适用身份**：情感拉扯线女主 / 外冷内热角色。
- **避雷点**：避免写成无情机器人；内心独白需暴露「渴望靠近又恐惧」的矛盾。
- **推荐模式**：deep（需推演信任缓慢建立的长弧线）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### anxious（焦虑型依恋）

| 轴 | 初始值 |
|---|---|
| risk | 4 |
| empathy | 6 |
| impulse_control | -3 |
| trust | 3 |
| desire_orient | 4 |
| aggression | 2 |

- **prototype_note**：极度渴望亲密、患得患失、反复确认；滑动约束——trust 中位波动大
  （在「全信」与「全疑」间剧烈摆动），impulse_control 低位（情绪上头时行为失控）；
  BPD 式大幅波动合法（短时间多轴跳变不告警）。
- **适用身份**：情感拉扯线角色 / 虐恋线核心。
- **避雷点**：避免写成无理取闹；每次焦虑发作需有具体触发事件绑定。
- **推荐模式**：deep（需推演焦虑-安抚循环的节奏）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### npd-grandiose（自恋型·浮夸型）

| 轴 | 初始值 |
|---|---|
| risk | 3 |
| empathy | -8 |
| impulse_control | 4 |
| trust | -4 |
| desire_orient | 7 |
| aggression | 4 |

- **prototype_note**：夸大自我、需要崇拜、表演性关怀；滑动约束——empathy 深度低位锁定
  （共情上限锁死，从 -8 试图拉到 +2 即抛 PERSON_001 L2_WARN，需 override_note +
  change_log 记录触发事件）；desire_orient 高位（对关注/崇拜的渴求）。
- **适用身份**：权力型反派 / 魅力型枭雄 / 偶像型角色暗面。
- **避雷点**：避免写成纯自大狂；需展示「脆弱内核」的裂缝时刻。
- **推荐模式**：deep（需推演自恋供给断裂时的崩溃连锁）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### npd-vulnerable（自恋型·脆弱型）

| 轴 | 初始值 |
|---|---|
| risk | -5 |
| empathy | -6 |
| impulse_control | 3 |
| trust | -6 |
| desire_orient | 3 |
| aggression | 1 |

- **prototype_note**：敏感自卑、被动攻击、表面谦逊内里玻璃心；滑动约束——empathy 低位
  锁定（同 npd-grandiose 共情上限限制），trust 低位（极难真正信任他人）；与浮夸型区别：
  不主动炫耀，而是通过「受害者姿态」获取关注。
- **适用身份**：隐忍型反派 / 表面温柔实则操控的角色。
- **避雷点**：避免写成纯可怜虫；被动攻击行为需有具体桥段支撑。
- **推荐模式**：deep。
- **⚠️ 仅小说创作基线，非临床诊断。**

### bpd（边缘型）

| 轴 | 初始值 |
|---|---|
| risk | 5 |
| empathy | 3 |
| impulse_control | -7 |
| trust | -2 |
| desire_orient | 4 |
| aggression | 5 |

- **prototype_note**：情绪剧烈波动、理想化-贬低交替、恐惧抛弃；滑动约束——**波动幅度
  极大是固有特征**（短时间 risk 从 5 跳到 8、empathy 从 3 跳到 -2 均合法，不告警）；
  impulse_control 深度低位（冲动行为频繁）。
- **适用身份**：虐恋线核心 / 高张力情感戏角色。
- **避雷点**：避免刻板化为「疯女人」；每次极端行为需有触发事件 + 心理逻辑。
- **推荐模式**：deep（必须推演情绪摆动的连锁影响）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### aspd（反社会型）

| 轴 | 初始值 |
|---|---|
| risk | 6 |
| empathy | -9 |
| impulse_control | 2 |
| trust | -8 |
| desire_orient | 6 |
| aggression | 8 |

- **prototype_note**：缺乏共情、操纵利用、无视规则；滑动约束——empathy 深度低位锁定
  （几乎不可能真正产生共情，任何 empathy 上调均需 override_note）；trust 深度低位
  （不信任任何人，所有关系都是工具）；aggression 高位。
- **适用身份**：高智商反派 / 犯罪线核心 / 冷血执行者。
- **避雷点**：避免写成纯恶魔；魅力来自「精密算计」而非单纯残忍。
- **推荐模式**：deep（需推演操纵链与反制）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### hpd（表演型）

| 轴 | 初始值 |
|---|---|
| risk | 3 |
| empathy | 1 |
| impulse_control | -2 |
| trust | 2 |
| desire_orient | 6 |
| aggression | 2 |

- **prototype_note**：戏剧化表达、寻求关注、情绪浅而快；滑动约束——empathy 中低位
  （情感体验浅薄但不如 aspd 极端）；desire_orient 中高位（对被关注的渴求）；
  情绪波动快但幅度不如 bpd 剧烈。
- **适用身份**：社交场核心角色 / 娱乐圈线 / 表面光鲜内里空洞的角色。
- **避雷点**：避免写成纯作秀；需有「独处时真实状态」的对照场景。
- **推荐模式**：deep。
- **⚠️ 仅小说创作基线，非临床诊断。**

### melancholic（忧郁型）

| 轴 | 初始值 |
|---|---|
| risk | -7 |
| empathy | 5 |
| impulse_control | 6 |
| trust | 0 |
| desire_orient | -4 |
| aggression | -6 |

- **prototype_note**：持续低落、自我否定、消极退缩；滑动约束——risk 深度低位
  （极度回避一切变化），aggression 深度低位（几乎不主动攻击）；desire_orient 低位
  （对事物失去兴趣）；长期趋势向更低偏移（若无反转事件）。
- **适用身份**：悲剧线角色 / 治愈系故事中的「被拯救者」/ 抑郁弧光主角。
- **避雷点**：避免浪漫化抑郁；需展示功能损害（工作/社交/日常）而非仅「文艺忧伤」。
- **推荐模式**：deep（需推演低谷-微光-再低谷的波动节奏）。
- **⚠️ 仅小说创作基线，非临床诊断。**

### zealot（狂热型）

| 轴 | 初始值 |
|---|---|
| risk | 7 |
| empathy | -3 |
| impulse_control | 3 |
| trust | 5 |
| desire_orient | 4 |
| aggression | 9 |

- **prototype_note**：信仰驱动、非黑即白、为理念不惜一切；滑动约束——aggression 高位
  锁定（对「异端」的攻击性不会消退），trust 中位（对「自己人」高度信任但对「外人」
  极度排斥）；risk 高位（为信仰甘愿赴死）。
- **适用身份**：极端组织领袖 / 宗教狂热者 / 意识形态反派。
- **避雷点**：避免写成纯粹疯子；其逻辑体系内部必须自洽（读者能理解「为什么他这么想」）。
- **推荐模式**：deep（需推演信仰崩塌时的全面崩溃）。
- **推荐模式**：deep。

### stoic（斯多葛型）

| 轴 | 初始值 |
|---|---|
| risk | -3 |
| empathy | 3 |
| impulse_control | 9 |
| trust | 2 |
| desire_orient | -5 |
| aggression | -3 |

- **prototype_note**：极度自律、情绪内敛、接受不可控之事；滑动约束——impulse_control
  深度高位锁定（几乎不会失态，任何冲动行为均需重大触发 + override_note）；
  desire_orient 低位（对物质/感官享受淡漠）；empathy 中位（理性关怀而非感性共情）。
- **适用身份**：导师型角色 / 军师 / 历经沧桑后的主角终态。
- **避雷点**：避免写成无感情石头；「不动声色」≠「没有内心戏」，需有独处时的微表情泄露。
- **推荐模式**：deep（需推演「绝对克制」被打破的那一刻的冲击力）。

## 选型提问清单

nc-角色 建卡时引导作者回答以下问题，推荐匹配原型 + 对应六轴初始值建议，走提案制等用户确认。

### Q0（前置）：模式选择

> 你的作品走 simple（爽文快节奏）还是 deep（深度写实推演）路线？
> - simple → 优先从爽文 6 原型中选
> - deep → 可从全部 16 原型中选

### 核心 5 问

| # | 问题 | 指向轴 |
|---|---|---|
| Q1 | 这个角色的**核心驱动力**是什么？（复仇/守护/求知/自由/权力/爱） | desire_orient + risk |
| Q2 | 面对压力时，TA 的**第一反应**是？（战斗/逃跑/冻结/讨好） | aggression + risk + impulse_control |
| Q3 | TA **信任别人**的模式是？（轻易相信/极度多疑/选择性信任/视人为工具） | trust |
| Q4 | 发生冲突时，TA 的**处理策略**是？（正面硬刚/冷处理/操纵/逃避/求助） | aggression + impulse_control + empathy |
| Q5 | TA 对**他人痛苦**的反应是？（深切共情/无感/利用/不适但压抑） | empathy |

### 快速选型对照表

| 原型 | 适合身份 | 叙事优势 | 避雷点 | 推荐模式 |
|---|---|---|---|---|
| steadfast | 主角/核心配角 | 长线情感锚点，读者代入感强 | 避免木头人 | simple/deep |
| fierce | 热血主角/武戏担当 | 爽感直接，节奏快 | 避免全程暴躁 | simple/deep |
| cunning | 谋士/幕后操盘手 | 智斗张力，反转空间大 | 避免全知全能 | deep |
| righteous | 侠义主角/正道领袖 | 价值观清晰，读者认同感强 | 避免道德完人 | simple/deep |
| reckless | 成长型主角/喜剧担当 | 破局能力强，喜剧效果 | 避免全靠运气 | simple/deep |
| greedy | 反派/黑化配角 | 欲望驱动，动机明确 | 避免脸谱化 | deep |
| avoidant | 情感拉扯线女主 | 慢热张力，破冰时刻冲击力强 | 避免无情机器人 | deep |
| anxious | 虐恋线核心 | 情绪密度高，读者揪心 | 避免无理取闹 | deep |
| npd-grandiose | 权力型反派/枭雄 | 魅力与危险并存 | 避免纯自大狂 | deep |
| npd-vulnerable | 隐忍型反派/操控者 | 表里反差，揭露时刻震撼 | 避免纯可怜虫 | deep |
| bpd | 虐恋线核心 | 高张力情感戏，戏剧性强 | 避免刻板化 | deep |
| aspd | 高智商反派/犯罪线 | 精密算计，猫鼠游戏 | 避免纯恶魔 | deep |
| hpd | 社交场核心/娱乐圈线 | 表面光鲜，反差揭露 | 避免纯作秀 | deep |
| melancholic | 悲剧线/治愈系 | 情感深度，治愈弧光 | 避免浪漫化抑郁 | deep |
| zealot | 极端组织领袖/意识形态反派 | 信仰崩塌时刻极具冲击力 | 避免纯疯子 | deep |
| stoic | 导师/军师/主角终态 | 「绝对克制」被打破的瞬间极具张力 | 避免无感情石头 | deep |

## 一人一原型铁律

一个角色 **MUST 只绑定一个** `baseline_prototype`；**MUST NOT** 同时标记两个原型。
当 frontmatter 出现 `baseline_prototype: [a, b]` 数组形式时，nc-校阅 抛 **L1_HARD**：
不支持多原型叠加，须选单一主原型。

**想要混合特质时**：选最接近的主原型，然后手动微调六轴数值（在 registry 条目的
`six_axes` 基础上增减），或在 tend- 卡的 `notes` 字段注明「基于 X 原型，Y 轴手动调整为 Z」。

## 双模式行为差异

| 维度 | simple 档 | deep 档 |
|---|---|---|
| 原型加载 | 仅加载六轴初始值作为素材参考 | 加载六轴初始值 + prototype_note 滑动约束 |
| 轴越界 | 不校验（轴可自由飘动） | 突破 prototype_note 声明的轴上下限 → PERSON_001 L2_WARN |
| 豁免机制 | 不适用 | `override_note` + `change_log` 记录触发事件可豁免 |
| 多原型叠加 | L1_HARD（双模式共用） | L1_HARD（双模式共用） |

详见 `references/hard-rules.md` 规则 27（双模式剖面开关）与 `references/review-rules.md`
PERSON_001 条目。
