# 书内谱系（lineage）Demo · SHZ 假名样例

> 本目录为 `examples/lineage-demo/` 书内谱系管理 Demo，用于验证
> nc-谱系新增 / nc-谱系修改 / nc-谱系移除 / nc-谱系查询 四技能在浅目录 +
> index.yaml 双轨制下的行为。所有 IP / 卷 / 章节均为虚构假名（SHZ=山河志），
> 不对应任何真实作品或人物。命名规范与 schema 契约见 `references/lineage.md`。

## 1. 目录结构（浅层级 ≤1 层）

```
SHZ/
├─ index.yaml            # 本书逻辑谱系索引（真值，nc-lineage-* 自动维护）
├─ MAI/                  # 正传正文（仅一层，不再往下套）
│  ├─ SHZ-MAI-001.md     # 卷一
│  └─ SHZ-MAI-001-CH05.md # 卷一第五章（章节用文件名后缀，不建子目录）
├─ ABR/
│  └─ SHZ-ABR-V01.md
├─ PRO/
│  ├─ SHZ-PRO-S10.md
│  └─ SHZ-PRO-S30.md
├─ CAR/
├─ DRF/
├─ TST/
└─ REF/
```

**铁律**：IP 根目录下最多一层物料子文件夹，MUST NOT 出现二级嵌套；时序顺序靠
`index.yaml` 的 `follow` 字段表达，不靠文件夹顺序。

## 2. index.yaml（SHZ 假名样例）

```yaml
ip_id: SHZ
ip_name: 山河志
status: writing
last_modified: "2026-10-28"
lineage:
  - uid: SHZ-MAI-001
    type: MAI
    vol: "001"
    title: "卷一 风起荒原"
    follow: null
    status: finished
    archived: false
    children: [SHZ-MAI-001-CH01, SHZ-MAI-001-CH05]
  - uid: SHZ-MAI-001-CH01
    type: MAI
    vol: "001"
    ch: "01"
    title: "第一章 荒原来客"
    file_path: "./MAI/SHZ-MAI-001-CH01.md"
    status: finished
    archived: false
  - uid: SHZ-MAI-001-CH05
    type: MAI
    vol: "001"
    ch: "05"
    title: "第五章 雨夜渡口相逢"
    file_path: "./MAI/SHZ-MAI-001-CH05.md"
    status: writing
    archived: false
  - uid: SHZ-MAI-002
    type: MAI
    vol: "002"
    title: "卷二 江海归舟"
    follow: SHZ-MAI-001        # 时序依赖：接在卷一之后
    status: waiting
    archived: false
    children: []
  - uid: SHZ-ABR-V01
    type: ABR
    ver: V01
    title: "山河志精简梗概 3k-5k"
    file_path: "./ABR/SHZ-ABR-V01.md"
    status: writing
    archived: false
related:
  abr:   ["SHZ-ABR-V01"]
  promo: ["SHZ-PRO-S10", "SHZ-PRO-S30"]
  car:   ["SHZ-CAR-ROL"]
```

## 3. 四条测试调用指令

### 3.1 nc-谱系新增（登记新卷 + 挂靠已有文稿）

```bash
# 新增卷二（已在 index.yaml，此处演示增量登记卷三）
nc-谱系新增 --ip SHZ --type MAI --vol 003 --title "卷三 雪落长街"
# 预期：index.yaml 追加 SHZ-MAI-003 条目 + 生成 SHZ/MAI/SHZ-MAI-003.md 空白文件
#       + last_modified 更新 + CHANGELOG 记录【新增 SHZ-MAI-003】

# 挂靠已有 md（不新建文件，仅登记索引）
nc-谱系新增 --ip SHZ --type MAI --vol 001 --ch 06 --title "第六章 山道伏击" \
  --exist-file ./MAI/SHZ-MAI-001-CH06.md
# 预期：index.yaml 登记 SHZ-MAI-001-CH06 并绑定从属卷一，跳过新建文件
```

### 3.2 nc-谱系修改（调时序 / 改状态）

```bash
# 调整时序：卷二前置依赖改成卷一（已如此，演示幂等）
nc-谱系修改 --ip SHZ --id SHZ-MAI-002 --follow SHZ-MAI-001
# 改状态：卷一定稿
nc-谱系修改 --ip SHZ --id SHZ-MAI-001 --status finished
# 预期：仅改 index.yaml 逻辑关系，默认不动文件名
```

### 3.3 nc-谱系移除（软删除优先）

```bash
# 软删除：归档某章节（文件保留，查询默认过滤）
nc-谱系移除 --ip SHZ --id SHZ-MAI-001-CH05
# 预期：index.yaml 置 archived: true，文件保留；nc-谱系查询 默认不显示它

# 恢复软删除条目
nc-谱系新增 --restore SHZ-MAI-001-CH05
# 硬删除（高危，需二次确认）
nc-谱系移除 --ip SHZ --id SHZ-MAI-001-CH05 --hard
# 预期：确认后删索引条目 + 本地文件；未确认则中止
```

### 3.4 nc-谱系查询（最常用）

```bash
# 查整 IP 完整谱系树
nc-谱系查询 --ip SHZ
# 预期输出（文字谱系树）：
# 【SHZ 山河志】
# ├─ MAI-001 卷一 风起荒原 [finished]
# │  ├─ CH01 荒原来客
# │  └─ CH05 雨夜渡口相逢 [writing]
# └─ MAI-002 卷二 江海归舟 [waiting]
#    ↳ 前置依赖：MAI-001
# 配套物料：
# • ABR-V01 精简梗概
# • PRO-S10 / PRO-S30

# 只看正传时序链
nc-谱系查询 --ip SHZ --filter MAI
# 含归档条目
nc-谱系查询 --ip SHZ --show-archived
```

## 4. 只读运行时校验（tools/nc_validate.py audit）

`nc_validate.py audit <project>` 会对每本书的 `index.yaml`（若存在）做四项只读校验，
缺失视为未启用 book-lineage、向后兼容不报错：

| 校验项 | 违规示例 | 预期发现 |
|---|---|---|
| uid 全局唯一 | 两条 `SHZ-MAI-001` | `[lineage] index.yaml 重复 uid: SHZ-MAI-001` |
| 命名格式（IP≥3字符+7类缩写） | `SHZ-XYZ-001` | `[lineage] ... 类型码不在 7 类白名单: SHZ-XYZ-001（XYZ）` |
| follow 无环 | 001→002→001 | `[lineage] ... follow 成环: SHZ-MAI-001 → SHZ-MAI-002 → SHZ-MAI-001` |
| 浅目录深度 ≤1 | `MAI/VOL001/` 二级嵌套 | `[lineage] .../MAI 出现二级嵌套目录 VOL001（谱系目录深度须 ≤1 层）` |
