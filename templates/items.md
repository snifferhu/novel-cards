---
id: it-<slug>
type: item
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: 道具-甲
first_appearance: chapter-001
owner: null              # 当前持有者 id（ac-*），无主则留空
last_seen: chapter-001   # 最近出现章节
advanced_mode: false     # true 时展示三层分区并允许手动调整感知 track 绑定
blackbox:                # 黑盒三层结构；默认黑盒模式下由 skill 自动拆解填充
  physical: {}           # 物理层：材质/尺寸/耐久/限制/使用条件/客观规则
  perceptual: {}         # 感知层：五感映射（visual/auditory/olfactory/gustatory/tactile）
  abstract: []           # 抽象非感知层：绑定的权力/秘密/记忆/宿命/信任等 timeline id
cross_ref: []            # 与觉醒 actor 的互相引用 id（object-spirit 场景）
---

# 道具-甲

## 一句话

<这个道具是什么、为什么重要。>

## 黑盒三层建模

`item` 卡 SHALL 支持黑盒三层内部结构。**默认黑盒模式**：作者只自然描述道具，
skill 自动拆解写入图森林；**高级模式**（`advanced_mode: true`）打开后展示三层
分区并允许手动调整感知 track 绑定。

### 物理层（physical）

客观、可测量、不依赖观察者：

- 形态：<具体外观 / 材质 / 尺寸>
- 能力 / 用途：<它能做什么>
- 局限 / 代价：<使用它会付出什么代价 / 使用条件>
- 客观规则：<耐久 / 触发条件 / 失效条件>

### 感知层（perceptual）——五感公理

感知动线的根 MUST 落在人类原生五感之一。玄幻衍生感知 SHALL 建模为对应五感的
子标签变体，MUST NOT 新增脱离五感底层的独立感知大类：

| 字段 | 五感根 | 示例（含玄幻子标签） |
|---|---|---|
| `visual` | 视觉 | 族徽发光（神视/天眼 = 视觉延伸：穿透·望远·透视·多波段） |
| `auditory` | 听觉 | 剑鸣（灵听 = 听觉超距版） |
| `olfactory` | 嗅觉 | 血腥铁锈味（灵嗅/辨息 = 嗅觉超距高分率版） |
| `gustatory` | 味觉 | 苦涩回甘（灵味/道韵尝感 = 味觉抽象化） |
| `tactile` | 触觉 | 持握发烫（温·压·痛·肌理；灵识/神念扫描 = 触觉回声定位型探测；神魂刺痛 = 触觉痛觉投射到精神层面） |

### 抽象非感知层（abstract）

与感知动线平行、互不侵占，通过 timeline id 绑定：

- 权力：<如 `tl-authority-line`>
- 秘密：<如 `tl-blood-secret`>
- 记忆 / 宿命 / 信任 / 张力：<对应 timeline id>

## 流转时间线

| 章节 | 事件 | 当前持有者 |
|---|---|---|
| <chapter-001> | <首次出现 / 被谁获得> | `<ac-xxx>` |
| <chapter-00X> | <转手 / 遗失 / 被夺> | `<ac-yyy>` |

## 叙事弧线

建议取值：`dormant`（未激活）/ `awakened`（已激活）/ `corrupted`（异化）/
`consumed`（消耗掉）/ `destroyed`（被毁）/ `resolved`（叙事作用已结束）。

**器灵觉醒**：一旦该道具拥有独立意志主动行动，SHALL 另建 `actor` 卡
（classification: object-spirit），本卡保留物理本体描述，两卡通过 `cross_ref`
互相引用。

## 与伏笔的关联

- 是否为某伏笔的载体：<参见 foreshadow 卡 `fs-xxx`>
- 长线四方对齐：若为长线感官爆点载体，MUST 同时存在对应 `tl-` 节点、`md-`
  模块、`lx-` 词频卡，提前 ≥8 章预埋（详见 hard-rules.md 规则 20）
