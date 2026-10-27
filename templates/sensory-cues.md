---
id: su-<slug>
type: sensory_cue
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
cue_type: sound            # sound / music / scent / light / atmosphere
bind_target: ac-<slug>     # 绑定的角色/场景 id（ac-* / sc-*）
description: <氛围信号描述>
---

# 感官标记 · <slug>

## 定位

`sensory_cue`（`su-`，存放于 `cards/custom/sensory_cue/`）：声音/乐曲/气味/光影等
氛围触发器，可绑定角色/场景，供桥段引用；**本身不是剧情事件**，用于塑造标志性
氛围信号。

> 注意区分：sensory_cue 是「氛围信号」（王熙凤未进院先闻笑声），不是「剧情动作」
> （那是 plotpoint）。它不推进情节，只建立条件反射式的读者联想。

## cue_type 枚举

| cue_type | 含义 | 示例 |
|---|---|---|
| `sound` | 标志性声响 | 王熙凤的笑声、脚步声 |
| `music` | 乐曲/旋律 | 某角色的专属 BGM |
| `scent` | 气味标识 | 某角色身上的冷木质香 |
| `light` | 光影特征 | 某场景的特定光色 |
| `atmosphere` | 综合氛围 | 进入某势力领地时的压迫感 |

## 最小示例（王熙凤笑声）

```yaml
cue_type: sound
bind_target: ac-wang-xifeng
description: 人还没进院子，笑声先传过来，所有人安静下来
```

## 与桥段的配合

桥段卡（`pp-*`）通过正文引用本 sensory_cue 来唤起氛围信号；若需跨动线同步
（如气味随角色移动扩散），SHALL 走 module 积木（`md-*`）的 `trigger_map` 绑定
对应 timeline 节点，不在正文零散写联动。

## 五感信号组（可选增强字段）

一条 cue MAY 含多条跨通道信号，全部信号根 MUST 落在原生五感之一（延续五感公理硬规则），
玄幻衍生感知经 `perception_alias` 建模为子标签变体。

| 字段 | 类型 | 说明 |
|---|---|---|
| `sensory_signals[]` | array | 五感信号数组，每条含以下字段 |
| `sensory_signals[].sense_channel` | enum | `sight` / `hearing` / `smell` / `taste` / `touch`（原生五感根） |
| `sensory_signals[].perception_alias` | string | 玄幻灵觉映射别名（如「灵嗅」/「神视」），写实留空 |
| `sensory_signals[].signal_content` | string | 信号内容描述 |
| `sensory_signals[].base_intensity` | int | 基础强度 1~10 |
| `sensory_signals[].attenuation_rule` | enum | 衰减规则：`distance` / `static` / `trigger` |
| `sensory_signals[].max_distance` | float | 最大有效距离（米），`attenuation_rule: distance` 时必填 |
| `sensory_signals[].maskable` | bool | 是否可被同通道更强信号掩蔽 |
| `sensory_signals[].fade_note` | string | 衰减备注（如「超出 max_distance 后线性衰减至不可感知」） |

### 时序动线（timeline_trace，可选）

实现「人未到声先至」的时序编排：

| 字段 | 类型 | 说明 |
|---|---|---|
| `timeline_trace.pre_visible_delay` | float | 信号先于本体可见的延迟秒数（如 3 = 声音先到 3 秒） |
| `timeline_trace.sequence_rule[]` | array | 信号到达顺序（如 `[听觉先抵达, 嗅觉次之, 看见人影最后]`） |

deep 模式 SHALL 校验时序合理性（信号先于本体抵达、延迟与角色位置/距离自洽）；
simple 模式只记录不校验。违和抛 L2_WARN（CUE_001）。

### 情绪注意力偏向（可选）

| 字段 | 类型 | 说明 |
|---|---|---|
| `attention_bias` | string | 该信号对注意力的偏向影响（如「强制吸引视线」/「引发警觉」） |
| `induced_mood_tendency` | string | 诱导的情绪倾向（如「不安」/「敬畏」） |
| `hormone_tendency` | string | 激素反应倾向（如「肾上腺素上升」/「皮质醇升高」） |

### 最小示例（丁春秋随行靡乐，假名占位）

```yaml
cue_type: music
bind_target: ac-角色-甲
description: 丝竹靡乐随角色-甲同行，腐花香隐约萦绕
sensory_signals:
  - sense_channel: hearing
    perception_alias: ""
    signal_content: 丝竹乐曲，低回婉转
    base_intensity: 5
    attenuation_rule: distance
    max_distance: 30
    maskable: true
    fade_note: 超出 30m 后线性衰减
  - sense_channel: smell
    perception_alias: ""
    signal_content: 腐花香，甜腻刺鼻
    base_intensity: 4
    attenuation_rule: distance
    max_distance: 15
    maskable: false
    fade_note: 超出 15m 后快速消散
timeline_trace:
  pre_visible_delay: 3
  sequence_rule: [听觉先抵达, 嗅觉次之, 看见人影最后]
attention_bias: 强制吸引注意力
induced_mood_tendency: 不安
hormone_tendency: 肾上腺素轻微上升
```
