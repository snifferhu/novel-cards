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
