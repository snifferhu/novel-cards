---
id: rw-<slug>
type: refwork
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
title: <作品名>
author: <作者>          # 无则留空
genre: <题材>           # 无则留空
study_focus: <拆解学习重点：伏笔回收手法/节奏/世界观等>
tree_id: refwork-<slug>  # 归属子图标记（与原创主线 main 隔离）
---

# 对标作品档案 · <作品名>

## 定位

`refwork`（`rw-`，存放于 `cards/custom/refwork/`）：外部参考作品档案，登记基础
信息，用于对标拆解。拆解产物带独立 `tree_id` 存于 `index/card-graph.json` 森林，
**与原创主线（`tree_id: main`）隔离**，跨子图无边连接。

## 拆解维度（按 study_focus 选取）

- **伏笔回收手法**：<该作品如何预埋与回收长线伏笔，回收周期分布>
- **节奏控制**：<张力曲线形态、爆点密度、留白策略>
- **世界观构建**：<设定分层、信息披露节奏>
- **人物塑造**：<动机设计、成长弧线、配角功能>
- **其他**：<自定义拆解角度>

## 与原创主线的隔离规则

- 本档案及其拆解产物 MUST 使用独立 `tree_id`（如 `refwork-<slug>`），MUST NOT
  混入 `tree_id: main` 的原创节点。
- 拆解得出的可复用技法以「认知」形式沉淀到反思卡（`rf-*`）或语料卡（`co-*`），
  而非直接复制原作的卡片 id 进原创主线。
