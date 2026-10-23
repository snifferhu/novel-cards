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
