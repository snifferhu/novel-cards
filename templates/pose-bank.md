---
id: po-<slug>
type: pose
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: <姿态名，如"招牌戒备姿态">
pose_tag: signature        # signature / habit / combat / relax / special
core: <固定内核（招牌不变的部分）>
slots:                     # 环境变量插槽定义（每次调用替换）
  left_arm: {default: 垂落}
  right_hand: {default: 持械}
slot_default:              # P3 兜底值（未绑定快照时用）
  left_arm: 垂落
  right_hand: 持械
multi_view:                # 多视角文案（可选）
  host_view: <旁观者看到的画面>
  self_view: <角色自我感知>
extra_constraint: <使用约束，如"左臂受伤时左臂不得抬起"；无则留空>
---

# 姿态 · <姿态名>

## 定位

`pose`（`po-`，存放于 `cards/pose-bank/`）解决跨场景复用一致性。一个 pose =
【固定内核（招牌不变）+ 环境变量插槽（每次调用替换）+ 多视角文案 + 使用约束】。
内核锁死不改，保证辨识度统一；插槽随环境/伤势/情绪变化，适配场景，不出戏。

## 插槽填充三级优先级（MUST 遵循）

| 优先级 | 来源 | 说明 |
|---|---|---|
| **P1** | 桥段本地手动覆写（`slot_override`） | 覆盖一切自动值，作者显式指定某次调用的插槽取值 |
| **P2** | 当前时间锚点快照状态自动填充 | 默认，作者零填写，全章统一；从 snapshot（`sn-*`）读取此刻伤势/环境状态 |
| **P3** | pose 默认兜底（`slot_default`） | 未绑定快照时使用，短篇常见 |

填充后 MUST 跑 `extra_constraint` 校验（如"水下不可鼓腮"），冲突进入 `nc-校阅`
意见，**不自动改文字**（hard-rules.md 规则 15）。

## 最小示例

```yaml
name: 招牌戒备姿态
pose_tag: signature
core: 重心下沉，双肘护胸，目光锁定对方咽喉
slots:
  left_arm: {default: 垂落}
  right_hand: {default: 持械}
slot_default: {left_arm: 垂落, right_hand: 持械}
extra_constraint: 左臂受伤时左臂不得抬起
```

## 与积木/快照的配合

- pose 卡被 `module`（`md-*`）的 `view_mod` 引用，或被 `plotpoint`（`pp-*`）的
  `pose_refs` 引用。
- P2 填充依赖 `snapshot`（`sn-*`）的 `used_pose` 字段反向校验「此刻状态能否支撑
  该 pose」。

## 包围盒与多视角增强（可选字段）

| 字段 | 类型 | 说明 |
|---|---|---|
| `pose_bounds` | object | 姿态包围盒 `{h, w, d}`（米），对接 actor_bounding 空间校验；deep 模式 SPACE_001 据此判定姿态是否超出场景净空间 |
| `part_detail` | object | 六部位细节：`head` / `shoulder` / `hand_arm` / `torso` / `leg_foot` / `facial_tendency` |
| `multi_view_module` | object | 五视角文案：`view_self` / `view_front` / `view_side` / `view_back` / `view_distant` |
| `fit_mood` | array | 适配情绪列表（如 `[戒备, 专注]`） |
| `unfit_mood` | array | 不适配情绪列表（如 `[狂喜, 崩溃]`） |
| `variant_text` | object | 长短两版描写文本 `{short, full}` |

deep 模式 SHALL 调用 space_snapshot 校验姿态包围盒是否超出场景净空间（SPACE_001）；
simple 模式仅作描写素材调用。P1>P2>P3 插槽优先级铁律不变。

### 最小示例（斜倚握扇，假名占位）

```yaml
name: 斜倚握扇
pose_tag: relax
core: 身体斜倚椅背，右手持扇轻抵下颌，目光微垂
slots:
  left_arm: {default: 搭在扶手上}
  right_hand: {default: 持扇抵颌}
slot_default: {left_arm: 搭在扶手上, right_hand: 持扇抵颌}
pose_bounds: {h: 1.65, w: 0.65, d: 0.75}
part_detail:
  head: 微垂，目光半阖
  shoulder: 放松下沉
  hand_arm: 右手持扇轻抵下颌，左臂搭扶手
  torso: 斜倚椅背约 15°
  leg_foot: 右腿交叠于左腿上
  facial_tendency: 似笑非笑，嘴角微扬
multi_view_module:
  view_self: 觉得此刻从容不迫
  view_front: 对方看到斜倚的姿态与半阖的目光
  view_side: 侧面轮廓呈慵懒弧线
  view_back: 背影松散，肩线柔和
  view_distant: 远处只见一个懒洋洋的剪影
fit_mood: [从容, 慵懒, 审视]
unfit_mood: [惊恐, 暴怒]
variant_text:
  short: 斜倚着，扇子抵在下巴上
  full: 他整个人斜陷进椅背里，右手那柄折扇松松地抵着下颌，目光半阖，像是对眼前的一切都提不起真正的兴趣——但搭在扶手上的左手手指微微收紧，泄露了另一层心思
extra_constraint: 坐姿类姿态，站立场景不可用
```
