---
id: co-<slug>
type: corpus
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []           # 语义标签数组（感官描写/香氛/室内光影/克制情欲/留白短句等，需经 registry/tags-registry.yaml 注册）
source: <来源>     # 摘抄 / 片段 / 参考文本 / URL
purpose: null      # 服务的桥段/动线 id（pp-* / tl-*），无则留空
text: |
  <原始参考语料文本>
extract: |
  <人工萃取：可用词组、句式、氛围感表达（写作时直接参考）>
notes: <区分表层情欲描写词与深层思辨隐喻词，两类分开标记防止混同>
---

# 语料 · <slug>

## 用途说明

<这段语料服务于哪个桥段/动线/词频卡，解决什么选词问题。>

## 原始语料

见 frontmatter `text` 字段。

## 人工萃取

见 frontmatter `extract` 字段——可直接复用的词组、句式、氛围感表达。

## 分层标记

- **表层**：<表层情欲/感官描写词，用于过渡段落>
- **深层**：<深层思辨/隐喻词，只留给可读懂暗线的读者>

> 两类 MUST 分开标记，禁止在同一个句子内混用（参见 lexstat 卡 `blank_rule.avoid_overdescribe`）。
