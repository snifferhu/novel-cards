---
id: rf-<chapter-id>
type: reflection
status: draft            # draft | reviewed | closed
created: YYYY-MM-DD
updated: YYYY-MM-DD
chapter: chapter-<n>     # 关联的正文章节 id
title: 第<n>章复盘
---

# 反思卡 · <title>

> 用途：单章完稿后的复盘卡，记录写作过程中的卡点、亮点、原因与新认知，
> 并把结论反哺回素材库 / 其他卡片。
> 提案制：AI 只把完整草案输出到对话，由用户确认后落盘到 `reflections/`。
> 命名：文件路径 `reflections/<chapter-id>.md`，id 前缀 `rf-`（如 `rf-chapter-050`）。

## 正文章节

### 1. 卡点（stuck）
（写作过程中出现的具体卡点：桥段推不动、人物行为不自然、素材不足、逻辑不闭合等）

- 卡点 1：<描述>
  - 出现于：<具体情节位置>
  - 现象：<卡住了什么、卡了多久>
  - 归因假设：<为什么卡住，可写多个>
- 卡点 2：<...>

### 2. 亮点（shone）
（本章写得顺畅、出彩、超出预期的段落）

- 亮点 1：<描述>
  - 位置：<具体段落/桥段>
  - 出彩点：<为什么有效>
  - 可复用性：<这段的手法能否迁移到后续章节>
- 亮点 2：<...>

### 3. 归因（why）
（把卡点与亮点的根本原因拎出来，区分「技法问题」与「素材问题」与「结构问题」）

- 根本原因 A：<...>
- 根本原因 B：<...>

### 4. 新认知（insights）
（本章写作沉淀出的新认知：人物理解、世界观补丁、技法经验、伏笔规划等）

- 认知 1：<一句话结论>
- 认知 2：<一句话结论>

### 5. 反哺动作（action_items）
（把新认知落到具体的卡片修改上，明确到卡 id；actor 前缀 ac-）

- [ ] 更新 `cards/characters/ac-xxx.md`：<改什么>
- [ ] 新建 `cards/foreshadow/fs-xxx.md`：<内容摘要>
- [ ] 更新 `graph/tl-xxx-graph.html`：<补哪条边>
- [ ] 补素材：<需要搜集/口述的补充素材，先过 nc-素材 入库前 gate>

## 关联

- 正文：`manuscript/chapter-050.md`
- 相关卡：`<cards/...>`
- 相关图谱：`<graph/...>`
