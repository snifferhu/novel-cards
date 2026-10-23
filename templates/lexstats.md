---
id: lx-<slug>
type: lexstat
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
bind_chapter: chapter-003      # 绑定章节
bind_plotpoint: pp-<slug>      # 绑定桥段 id（可选）
high_density_words: []         # 高存在感、强冲击词（爆点区域使用）
low_density_words: []          # 淡词、留白词（过渡、收束、留白段落使用）
forbidden_words: []            # 破坏氛围、直白说教的词，本章禁用
tension_curve:                 # 0~10 张力标尺
  start: 0
  rising: 0
  climax: 0
  release: 0
blank_rule:                    # 留白规则
  climax_after_para: <爆点后强制留白段落数>
  avoid_overdescribe: [不要同时堆砌 4 种感官在同一个句子]
checklist:                     # 校验指标清单
  - 感官词密度是否超标
  - 隐喻词是否只留给可读懂暗线的读者
  - 是否存在直接哲学旁白
---

# 词频张力 · <chapter-003>

## 定位

`lexstat`（`lx-`）是写稿环节的核心控制点。**强约束**：爆点段落高密词集中释放，
爆点之后强制留白，禁止持续堆叠感官描写。

## 张力曲线说明

`tension_curve` 用 0~10 标尺描述本章张力走势：

| 阶段 | 含义 | 用词策略 |
|---|---|---|
| `start` | 开篇基线 | 低密度词铺陈，建立氛围 |
| `rising` | 爬升段 | 逐步引入中密度词，节奏收紧 |
| `climax` | 爆点 | 高密度词集中释放，感官峰值 |
| `release` | 回落/留白 | 切回低密度词，强制留白 `climax_after_para` 段 |

## 最小示例

```yaml
high_density_words: [审视, 灼热, 绷紧]
low_density_words: [静, 微凉, 缓]
forbidden_words: [哲学旁白, 直白说教]
tension_curve: {start: 3, rising: 6, climax: 9, release: 4}
blank_rule:
  climax_after_para: 2   # 爆点后强制留白 2 段，不继续堆描写
  avoid_overdescribe: [不要同时堆砌 4 种感官在同一个句子]
checklist:
  - 感官词密度是否超标
  - 隐喻词是否只留给可读懂暗线的读者
  - 是否存在直接哲学旁白
```

## 与语料卡的配合

选词池来自 `corpus`（`co-`）卡的人工萃取；表层词与深层词分开标记，
避免在同一句内混用（参见 corpus 模板分层标记节）。
