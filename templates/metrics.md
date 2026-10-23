---
id: mt-<slug>
type: metric
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
bind_range: chapter-001~chapter-030   # 绑定的章节区间
dimensions:                            # 指标维度（张力/爆点密度/信息载荷/五感释放节奏等）
  - tension
  - burst_density
  - info_payload
  - sensory_release_rhythm
values:                                # 各维度的数值条目
  tension: {avg: 5.2, peak_chapter: chapter-014, peak_value: 9}
  burst_density: {per_10k_chars: 3.1, strategic_bursts: [pp-entry-scene]}
  info_payload: {new_facts_per_chapter_avg: 7}
  sensory_release_rhythm: {five_sense_balance: {visual: 0.3, auditory: 0.2, olfactory: 0.15, gustatory: 0.05, tactile: 0.3}}
---

# 量化指标 · <章节区间>

## 定位

`metric`（`mt-`）挂载张力、爆点、信息载荷等量化指标，供长篇深度打磨与批量统计
分析使用；数值索引同步写入 `index/metric-index.json`。

## 用途

- **长篇深度打磨**：定位张力曲线异常段（持续高张力无留白 / 该爆不爆）
- **批量统计分析**：伏笔回收周期分布、爆点密度趋势、五感信息释放节奏均衡度
- **导出外部工具**：作为思维导图/时序图/数据库的数据源之一

## 数据来源

- 张力值来自 `lexstat`（`lx-`）卡的 `tension_curve`
- 爆点密度来自 `plotpoint`（`pp-`）卡的 `strategic_burst` 标注 + timeline 节点 `burst` 字段
- 五感释放节奏来自 `item` 黑盒感知层 + corpus 卡分层标记
- 数值索引由 skill 指令驱动同步至 `index/metric-index.json`，不重新解析全部 md 文件
