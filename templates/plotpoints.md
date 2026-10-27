---
id: pp-<slug>
type: plotpoint
status: draft          # draft | active | archived | official | candidate（备选方案不会自动替换主线剧情）
created: YYYY-MM-DD
updated: YYYY-MM-DD
title: <桥段标题>
chapter: chapter-001
summary: <一句话摘要>
participants: []       # 相关对象 id 数组（ac-* / it-* / sc-*）
lexstat_bind: null     # 绑定的词频张力卡 id（lx-*），写稿环节核心控制点
module_list: []        # 引用的积木模块 id 数组（md-*）
pose_refs: []          # 引用的姿态卡 id 数组（po-*）
foreshadow_links: []   # 关联伏笔 id 数组（fs-*）
strategic_burst: false # 是否战略爆点（true 时触发节奏豁免，nc-节奏 不对其报疏密告警）
pivotal: false         # 是否关键转折
setup_by: null
payoff_of: null
---

# <桥段标题>

## 一句话

<一句话概括这个桥段发生了什么、推动了什么。>

## 章节定位

- 所在章节：<chapter-00X>
- 章节内位置：<开端 / 中段 / 高潮 / 收束>

## 涉及角色

- `<ac-xxx>`：<在此桥段中的作用>
- `<ac-yyy>`：<在此桥段中的作用>

## 桥段展开

1. **触发**：<是什么点燃了这个桥段>
2. **过程**：<关键动作 / 对话 / 转折>
3. **结果**：<桥段结束后世界发生了什么变化>

## 联动绑定（v1.0 新增字段）

- **词频张力** `lexstat_bind`：指向 `lx-` 卡，强约束爆点段落高密词集中释放、
  爆点后强制留白（详见 card-schema.md lexstat 章节）。
- **积木模块** `module_list`：指向 `md-` 卡，跨动线同步变化 MUST 走 module
  （hard-rules.md 规则 19）。
- **姿态引用** `pose_refs`：指向 `po-` 卡，插槽填充按 P1>P2>P3 优先级
  （hard-rules.md 规则 15）。
- **伏笔关联** `foreshadow_links`：指向 `fs-` 卡，长线爆点需四方对齐
  （hard-rules.md 规则 20）。
- **战略爆点** `strategic_burst`：标记后 `nc-节奏` 对该桥段做疏密校验时自动豁免。

## 与暗线的关联

- 是否被暗线利用 / 扭曲：<参见 darklayer 卡 `dk-xxx`，如无填「无」>

## 与伏笔的关联

- 是否为某伏笔的埋点 / 回收：<参见 foreshadow 卡 `fs-xxx`>

## 张力参数与因果链路增强（可选字段）

deep 模式 SHALL 校验前置桥段是否提前发生、单章节爆点密度（战略爆点豁免）、预埋-回收
链路完整性；simple 模式仅登记。新字段全部可选，缺失时 MUST 按现有行为处理（向后兼容）。

| 字段 | 类型 | 说明 |
|---|---|---|
| `tension_base` | int | 基础张力值 1~10（BEAT_001 张力密度校验依据） |
| `is_strategic_climax` | bool | 是否战略高潮（与既有 `strategic_burst` 语义等价，二选一使用：`strategic_burst` 为节奏豁免标记，`is_strategic_climax` 为张力密度豁免标记；二者同时为 true 时以 `strategic_burst` 为准） |
| `beat_type` | enum | 桥段类型：`normal` / `foreshadow` / `payoff` / `turning` / `climax` / `resolution` |
| `sequence_index` | int | 章节内顺序索引（用于 BEAT_001 张力曲线排序） |
| `precondition_beat_ids[]` | array | 前置桥段 id 数组（pp-*），本桥段发生前 MUST 已发生 |
| `postcondition_beat_ids[]` | array | 后置桥段 id 数组（pp-*），依赖本桥段结果 |
| `foreshadow_link` | object | 伏笔链路：`plant_beat_id`（埋点桥段 pp-*）/ `payoff_beat_id`（回收桥段 pp-*） |
| `mood_shift_summary` | string | 情绪转变摘要（如「从容→警觉」） |
| `personality_trigger_actor_ids[]` | array | 触发性格变动的角色 id 数组（ac-*），联动 tend-* 动向卡 |
| `actor_involved_ids[]` | array | 参与角色 id 数组（ac-*） |
| `prop_involved_ids[]` | array | 参与道具 id 数组（it-*） |
| `cue_trigger_ids[]` | array | 触发的感官标记 id 数组（su-*） |
| `space_id` | string | 场景 id（sc-*），SPACE_001 空间校验依据 |
| `pose_refs[]` | array | 引用的姿态卡 id 数组（po-*，既有字段） |

### 最小示例（车内争吵，假名占位）

```yaml
title: 车内争吵
chapter: chapter-012
summary: 角色-甲与角色-乙在密闭车厢内因旧玉佩归属爆发争执
participants: [ac-角色-甲, ac-角色-乙, it-旧青玉佩, sc-车厢]
lexstat_bind: lx-chapter-012-tension
module_list: []
pose_refs: [po-斜倚握扇]
foreshadow_links: [fs-jade-origin]
strategic_burst: false
pivotal: true
tension_base: 7
is_strategic_climax: false
beat_type: turning
sequence_index: 3
precondition_beat_ids: [pp-玉佩拾取]
postcondition_beat_ids: [pp-玉佩断裂]
foreshadow_link:
  plant_beat_id: pp-玉佩拾取
  payoff_beat_id: pp-玉佩断裂
mood_shift_summary: 表面从容→暗流涌动→爆发
personality_trigger_actor_ids: [ac-角色-甲]
actor_involved_ids: [ac-角色-甲, ac-角色-乙]
prop_involved_ids: [it-旧青玉佩]
cue_trigger_ids: [su-jade-warm-01]
space_id: sc-车厢
```
