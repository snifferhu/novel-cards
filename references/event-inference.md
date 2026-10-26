# 事件推演流程约定（event-inference.md）

novel-cards v1.0 的**事件驱动推演**透镜：把「让某对象发生某事」表述为一次
`dispatch_event`，沿 `enter → perceive → act → fire` 连锁传播，汇总为一份
**ChangePlan**，交作者审核后批量 `patch()` 落地，最后 `render()` 渲染正文。
本文档是**流程契约**——描述消息如何在对象间流动、变更如何被汇总与裁决；它**不是**
一条新的自动化管线，而是对既有 `nc-研判`（单点）/ `nc-编排`（批量三段式）能力的
面向对象重述。概念类定义见 `references/oo-model.md`。

> **核心铁律**：**候选变更绝不直接写盘，对象不自动覆盖自身。** 任何由事件推演产生的
> 状态变更都只以 ChangePlan 草案形式输出到对话，经作者逐条审核后才由作者落盘
> （走提案制）。这与 `hard-rules.md` 规则 1/2/24 完全一致——推演是「建议引擎」，
> 不是「执行器」。

## 1. 全流程总览

```
dispatch_event(event)                # 作者口述 / nc-研判 / nc-编排 触发一个事件
   │
   ▼
[enter]     Scene.enter(role)        # 角色进入场景：刷新环境插槽，广播 SensoryCue
   │
   ▼
[perceive]  Role.perceive(scene)     # 场内角色捕获广播的感官信号，更新感知状态
   │
   ▼
[act]       Role.act(trigger_event)  # 角色响应：沿 tend- 动向标尺滑动 + 切换 pose
   │              Prop.move_to(...)  # 道具动线移动（跨动线同步走 module.trigger_map）
   │              SensoryCue.broadcast()  # 氛围信号扩散
   │
   ▼
[fire]      PlotBeat.fire()          # 前置条件满足时引爆桥段，派发事件给在场对象
   │
   ▼
[ChangePlan]  汇总全部受影响对象的「候选新状态」（含前后差异）
   │
   ▼
[作者审核]  逐条 同意 / 编辑 / 移除 / 新增自定义任务 / 整体约束
   │
   ▼
[patch]     批量落地：每项调对应本体技能出提案 + CHANGELOG 追加 + history 快照
   │
   ▼
[render]    StoryWorld.export() 按 timeline 顺序调各对象 render() 拼接 manuscript/
```

> **OO ↔ 既有技能对齐**：`dispatch_event` 的入口 = `nc-研判`(单点推演) 或
> `nc-编排`(批量迭代)；`ChangePlan` = `nc-编排` 的 compose_plan 产物；`patch` 阶段
> 每项 = 调用对应专项技能（`nc-动向`/`nc-桥段`/`nc-感官标记`/…）出提案；`render`
> = `nc-成稿` 的 render 阶段。详见 `references/loop.md` 三场景流程与 §3.1 动向弧光链。

## 2. 各阶段语义

### 2.1 dispatch_event — 事件派发

- **输入**：一个自然语言事件（「让 A 进房间」「这批素材用上，老情节换掉」）或结构化
  事件描述。
- **路由**：
  - **单点评估**（少量资产、拿主意）→ 走 `StoryWorld.deliberate()`（`nc-研判`），
    只出方案 A/B/C 报告，**不改卡**。
  - **批量整线迭代 / 扩写 / 重构**（跨资产联动）→ 走 `StoryWorld.plan_modify()`
    （`nc-编排`），先生成 compose_plan 交作者逐条审核。
- **MUST NOT**：在派发阶段就静默修改任何卡片；派发只是「算出会发生什么」，不是
  「让它发生」。

### 2.2 enter → perceive → act → fire 连锁

| 阶段 | 方法 | 触发的状态变更（候选） |
|---|---|---|
| `enter` | `Scene.enter(role)` | 刷新场景环境插槽（光源/气味/声响），向场内广播相关 `SensoryCue` |
| `perceive` | `Role.perceive(scene)` | 场内角色捕获广播信号，更新自身感知状态 |
| `act` | `Role.act(trigger_event)` | 角色沿 `character_tendency`(`tend-`) 动向标尺滑动（**每次变动 MUST 绑定已存在的 `pp-*` 桥段推手**）+ 切换 `pose`(`po-`) 姿态（P1>P2>P3） |
| `act` | `Prop.move_to(scene, position)` | 道具动线位置变更；跨动线同步 MUST 走 `module` 的 `trigger_map`，禁止零散联动 |
| `act` | `SensoryCue.broadcast()` | 氛围信号向绑定范围内角色扩散 |
| `fire` | `PlotBeat.fire()` | 前置条件满足时引爆桥段，派发事件给在场 `Role`/`Prop`/`SensoryCue`，触发下一轮连锁 |

> **连锁边界**：连锁传播 MUST 受当前 mode 门控约束（见 §5）——短篇下 DarkLine /
> 长期 disposition_slide 等能力关闭，连锁不会跨越未启用的对象类型。

### 2.3 ChangePlan 汇总

连锁结束后，把所有受影响对象的**候选新状态**汇总为一份 ChangePlan。它是纯内存中的
结构化草案，**不落盘、不写文件**。

## 3. ChangePlan 结构约定

ChangePlan = `nc-编排`(nc-compose) 的 compose_plan 产物。逐项列明每个受影响对象的
变更，每项 MUST 标注**目标卡 id + 前后差异**。字段集与 skill-catalog 中 nc-编排 的
五类任务一一对应：

| ChangePlan 项类型 | 对应 compose_plan 任务 | 内容 |
|---|---|---|
| Role 属性变更 | `update_tendency` | 角色动向刻度变化（`tend-` 的 `history[]` 追加 `{value, trigger_plot, description}`）+ 推手桥段 id + pose 切换 |
| Prop 动线移动 | `edit_plot`（含动线节点） | 道具 `move_to` 后的位置/持有者变更 + 关联伏笔/动线节点检查 |
| SensoryCue 激活 | `bind_sensory_cue` | 某感官标记在本章被引用/激活 |
| PlotBeat 待引爆 | `create_plot` / `edit_plot` / `archive_plot` | 新建桥段 / 修改桥段 / 归档旧桥段（备选方案不自动替换主线） |
| DarkLine 进度变化 | `edit_plot`（暗线分支） | 暗线 `references_to_main` 挂接进度推进 / `reveal_chapter` 临近（仅 long 模式） |

**每项最小结构**（示意，非 frontmatter 字段）：

```yaml
- task_type: update_tendency          # 五类之一
  target_id: tend-lead-restraint      # 目标卡 id
  before: {current_value: 2}          # 变更前状态
  after:  {current_value: 3,          # 变更后状态
           history_append: [{value: 3, trigger_plot: pp-ch31-embrace, description: ...}]}
  rationale: 经历 ch31 接纳放荡面，克制刻度上滑一格   # 一句话理由
```

> **声明**：ChangePlan 就是 `nc-编排` 的 compose_plan。两者字段集零差异——本表只是
> 用 OO 视角（对象方法产生变更）重新命名了同一份计划。作者审核 ChangePlan = 审核
> compose_plan；批准执行 = 进入 `nc-编排` 的执行阶段。

## 4. 冲突处理三选一 + 决定权归作者

当 ChangePlan 中某项变更与现有对象状态存在**实质差异/冲突**时，MUST 提供三种处置
选项，**决定权一律归作者**（AI 不得自行拍板）：

| 选项 | 语义 | 落盘动作 |
|---|---|---|
| **保留旧实例** | 维持现状，本次变更作废 | 不动该卡，记录「跳过」 |
| **覆盖为新实例** | 采纳新状态 | **先归档**：把旧版本复制到 `history/<card-id>/<date>.md`（只读快照），再出新版提案 |
| **合并取部分字段** | 新旧各取一部分 | 出合并提案，明确列出哪些字段取新、哪些保留旧 |

> **与 card-schema 一致性**：此三选一与 `card-schema.md`「设定卡检索：差异不直接
> 覆盖，先归档 history」约定完全一致——实质差异 MUST NOT 原地覆盖，先归档再出新版
> 提案。`nc-编排` 执行前 MUST 前置跑一次 `nc-校阅` 扫描整套计划叠加后的冲突，遇红色
> 冲突暂停退回计划页，绝不强行执行（见 `hard-rules.md` 规则 24）。

## 5. patch 批量落地 + render 渲染

### 5.1 patch 批量落地

作者批准 ChangePlan 后，逐项落地：

1. 每项调用对应本体技能（`nc-动向`/`nc-桥段`/`nc-感官标记`/`nc-暗线`/…）**出完整
   Markdown 提案**到对话，标注目标路径。
2. 作者确认后由作者落盘（AI 绝不 `edit`/`write` 卡片文件）。
3. 每项落盘后：CHANGELOG 追加记录 + latest.md 更新 + 实质差异先做 `snapshot()` 归档。

> **铁律重申**：patch 阶段 AI 只出提案，落盘由作者完成；对象**MUST NOT** 自动覆盖
> 自己。全程禁止静默修改。

### 5.2 render 渲染（文字即视图）

- **文稿是投影，对象模型是唯一可信源。** `manuscript/chapter-*.md` 是对象状态流转
  之后 `render()` 序列化出的**文本投影**，不是真相本身。
- **改剧情 = 改状态再重渲**：要改正文，先改对象（走 ChangePlan → patch），再
  `StoryWorld.export()` 按 timeline 顺序调各对象 `render()` 重新拼接正文；**绝不**
  直接手改正文字符串绕过对象模型。
- **render 阶段**：`nc-成稿`(nc-draft) 读取已备好的全部卡片（设定/桥段/大纲/暗线/
  角色/道具/场景/pose/lexstat 约束向量），按 `--length short/mid/long` 控制篇幅档位，
  自动生成正文初稿，**走提案制**（标注目标路径 `manuscript/chapter-*.md`，作者校阅
  调整后落盘，MUST NOT 直接写入 `manuscript/`）。
- **约束输入**：render 消费 `nc-词频`(nc-wordfreq) 提供的词频向量作为强约束输入
  （爆点高密词集中释放、爆点后强制留白），但词频工具本身不出正文。

### 5.3 长短篇 mode 门控

事件推演的能力范围由 `registry/work-length-config.yaml` 的 mode 门控（**单一事实源**，
本文件**不另建独立门控表**）：

| mode | 事件推演可用能力 |
|---|---|
| **short** | 仅 `enter`/`perceive`/`act`(基础)/`fire` 基础连锁；**禁用 DarkLine（`dk-`）/ 长期 disposition_slide（`tend-`）/ 势力 / 量化 / 姿态**；连锁不跨越未启用对象类型 |
| **mid** | 开放 `foreshadow`/`module`/`timeline` 连锁；仍默认关闭 DarkLine / 量化 / 姿态（按需手动开启） |
| **long** | **全开**：含 DarkLine 进度变化 / 长期 disposition_slide 弧光 / 势力 / 量化 / 姿态 / 守卫 / 研判 / 编排 |

> **一致性**：上表数值与 `loop.md` §3 长短篇分级矩阵逐字一致（short 禁 ❌ 项、mid 关
> 势力/暗线/量化/姿态、long 全开），本表只是从「事件推演能力」视角复述同一张矩阵，
> 不引入新门控规则。mode 取值与默认启用集的权威定义在 `registry/work-length-config.yaml`。
