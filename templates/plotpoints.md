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
