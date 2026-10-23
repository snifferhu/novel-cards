---
id: md-<slug>
type: module
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
name: <积木名称，如"推门入场姿态模块">
bind_scene: sc-<slug>        # 绑定场景 id（可选）
trigger_map:                 # 积木联动：键为 timeline id，值为 node_id（+ 可选 pose/自定义卡引用）
  tl-<slug>: node_01         # 例：发型动线 node_01（高髻固定，发簪就位）
  # tl-scent: node_01        # 例：气味动线 node_01（冷木质香随气流扩散）
  # tl-light: node_01        # 例：光影动线 node_01（自然光切断，切换室内顶冷白光）
  # tl-costume: node_01      # 例：服装动线 node_01（挺括长裙，线条收敛）
view_mod:                    # 多视角视图模块（只写在 module，不写进正文或动线卡）
  host_view: <房主/旁观者视角看到的画面>
  self_view: <角色自我感知>
  hidden_view: <暗线视角（dk-*），正在进入的凝视结构>
trigger_expect: <爆点预期：铺垫哪一级爆点>
---

# 积木 · <积木名称>

## 定位

`module`（`md-`）是**最小调度单元**。其 `trigger_map` SHALL 可自由绑定任意数量、
任意 track 类型的 timeline 节点 + pose + 自定义类型卡片（symbol/metric 等），
**MUST NOT 锁死固定四感组合**。同一 module 可在不同章节复用，通过修改绑定的
动线节点产生不同效果。

**铁律**：跨动线同步变化 MUST 走 module 积木模块，禁止在正文或动线卡里零散写
联动（hard-rules.md 规则 19）。多视角视图（host/self/hidden）**只写在 module**，
不进正文、不写进动线卡。

## trigger_map 说明

| 键（timeline id） | 值（node_id） | 含义 |
|---|---|---|
| `tl-hairstyle` | `node_01` | 高髻固定，发簪就位 |
| `tl-scent` | `node_01` | 冷木质香随气流扩散 |
| `tl-light` | `node_01` | 自然光切断，切换室内顶冷白光 |
| `tl-costume` | `node_01` | 挺括长裙，线条收敛 |

每个 timeline 节点的 `bind_module` 反向指向本 module id，形成双向绑定。
`trigger_foreshadow` 在对应 timeline 节点上声明，触发伏笔埋点。

## 最小示例（进门积木）

```yaml
name: 推门入场姿态模块
bind_scene: sc-main-parlor
trigger_map:
  tl-hairstyle: node_01   # 高髻固定，发簪就位
  tl-scent: node_01       # 冷木质香随气流扩散
  tl-light: node_01       # 自然光切断，切换室内顶冷白光
  tl-costume: node_01     # 挺括长裙，线条收敛
view_mod:
  host_view: 房主视角看到的画面（端庄、有距离感）
  self_view: 女主自我感知（清楚自己正在扮演符号）
  hidden_view: 暗线视角（dk-power-gaze：正在进入凝视结构）
trigger_expect: 情绪基线铺垫，为后续第14章发簪摘落爆点蓄力
```

## 复用说明

同一 module 在不同章节复用时，仅修改 `trigger_map` 中各 timeline 的 `node_id`
指向，即可在不同时间锚点产生不同效果；`view_mod` 与 `trigger_expect` 可保持
不变或按章节微调。
