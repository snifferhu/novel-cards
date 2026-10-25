# 使用说明（USAGE.md）

本文档面向**日常使用方**（AI + 作者），回答"我怎么用它写我的小说"。
项目本身是什么请看 `README.md`；skill 硬规则与技术细节看 `SKILL.md` 与
`references/`。

---

## 0. 前置条件

| 项 | 说明 |
|---|---|
| AI 客户端 | **OpenCode** 或 **Claude Code**（或其他支持 skill 机制的 agent） |
| 使用方工程 | 一个小说仓库，已 `git init` |
| 空目录约定 | 工程中已有 `cards/`（含各类型子目录）与 `manuscript/`（可用下方脚本一键生成） |

**没有以上条件的用户请先不要触发 skill**，否则会拿到缺失路径提示。

---

## 1. v0 → v1 迁移指引（旧使用方工程升级必读）

如果你是从 **v0（九类卡 + `ch-` 前缀 + 12 触发词）** 升级到 **v1.0（15+ 类卡 +
`ac-` 前缀 + 24 技能）** 的旧工程，请按本节执行一次性硬切换。**不做双轨兼容逻辑**：
迁移完成后旧写法不再被识别。

### 1.1 批量替换 frontmatter（sed 命令）

在**使用方工程根目录**执行（先 `git status` 确认工作区干净、当前分支正确）：

```bash
# ① type: character → type: actor（全部 .md 卡片）
grep -rlE '^type: character' cards/ --include='*.md' \
  | xargs sed -i 's/^type: character$/type: actor/'

# ② id: ch- → id: ac-（角色卡 id 前缀）
grep -rlE '^id: ch-' cards/characters/ --include='*.md' \
  | xargs sed -i 's/^id: ch-/id: ac-/'

# ③ 正文 / cross_ref 中对 ch-* 角色的引用一并替换
#    （建议先用 grep 预览命中范围，确认无误再执行）
grep -rnE '\bch-[a-z0-9-]+' cards/ manuscript/ reflections/ --include='*.md'
# 预览确认后，对命中的文件执行等价的全局标识符替换（ch-xxx → ac-xxx）
```

> ⚠️ **务必先 dry-run 预览**：把每条 `sed -i` 前的管道换成 `grep -n` 先看命中行，
> 确认无误再加 `-i` 落盘。`ch-` → `ac-` 是全局标识符替换，误伤面大。

### 1.2 补齐新增目录

旧工程缺少的 v1.0 目录，用本仓库 `install.sh --project` 幂等补齐（不覆盖已有文件）：

```bash
cd /path/to/novel-cards && ./install.sh --project /path/to/your/novel
```

会补齐：`cards/modules/`、`cards/lexstats/`、`cards/corpus/`、`cards/metrics/`、
`cards/pose-bank/`、`cards/custom/sensory_cue/`、`cards/custom/refwork/`、
`registry/`、`index/`、`res/inbox/`、`history/`、`release/`、`export/`、
`config/project.yaml` 等。

### 1.3 触发词对照表（旧 12 → 新 24）

| 旧触发词（v0） | 新触发词（v1.0） | 变化说明 |
|---|---|---|
| `nc-人物` | `nc-角色`(nc-role) | **更名**；type `character`→`actor`，id `ch-`→`ac-` |
| `nc-桥段` | `nc-桥段`(nc-plot) | 保留，英文别名 `nc-plot` |
| `nc-道具` | `nc-道具`(nc-item) | 保留，新增黑盒三层建模 |
| `nc-场景` | `nc-场景`(nc-scene) | 保留 |
| `nc-伏笔` | `nc-伏笔`(nc-foreshadow) | 保留，长线四方对齐约束 |
| `nc-动线` | 自定义 track 标签改经 `nc-注册`(nc-reg) 登记；动线卡仍走建卡 | track 白名单化 |
| `nc-势力` | `nc-势力`(nc-faction) | 保留 |
| `nc-快照` | `nc-快照`(nc-snapshot) | 语义明确为「时间锚点状态切片」 |
| `nc-暗线` | `nc-暗线`(nc-thread) | 保留中文名，英文名 `nc-thread` |
| `nc-图谱` | `nc-图谱`(nc-graph) | 保留，积木联动总图 |
| `nc-复盘` | `nc-复盘`(nc-retrospect) | 保留 |
| `nc-过滤` | 并入 `nc-素材` 入库前自动 gate | 三问逻辑内嵌，仍可手动复检 |

**新增技能（v0 无对应）**：`nc-初始化` / `nc-素材` / `nc-清洗` / `nc-检索` /
`nc-姿态` / `nc-感官标记` / `nc-对标` / `nc-积木` / `nc-量化` / `nc-词频` /
`nc-成稿` / `nc-校阅` / `nc-节奏` / `nc-守卫` / `nc-定稿` / `nc-导出`。

完整 24 技能清单见 `references/skill-catalog.md`。

### 1.4 迁移后验证

```bash
# 应无输出（除迁移说明文档外不再有 ch- 残留）
grep -rnE '\bch-[a-z0-9-]+' cards/ --include='*.md'
# 应无输出（不再有 type: character）
grep -rnE '^type: character$' cards/ --include='*.md'
```

两条都为空即迁移完成，新技能可正常工作。

---

## 2. 三种安装方式

```bash
# 克隆本仓库
git clone git@github.com:snifferhu/novel-cards.git
cd novel-cards
```

### 方式 A · 复制模式（推荐日常使用）

```bash
./install.sh                        # 同时装到 OpenCode 与 Claude Code 全局
./install.sh --target opencode      # 只装 OpenCode
./install.sh --target claude        # 只装 Claude Code
```

**特点**：修改 skill 需要重新 clone 或手动同步。**优点**：不受源仓库变动影响。

### 方式 B · 软链模式（推荐 skill 开发者）

```bash
./install.sh --link                 # 同时软链两端
./install.sh --link --target claude # 只软链 Claude Code
```

**特点**：本仓库 `SKILL.md` / `templates/` 改动**即时生效**。

### 方式 C · 项目级（不推荐，见 AGENTS.md 第 3 节）

`install.sh` **不代为执行**项目级安装。若必须内联到某个小说工程，请手动：

```bash
mkdir -p <project>/.opencode/skills
cp -r novel-cards <project>/.opencode/skills/
```

---

## 3. 初始化使用方工程骨架

假设你的小说工程在 `~/my-novel`：

```bash
./install.sh --project ~/my-novel
```

生成的 v1.0 完整目录骨架（每目录含 `.gitkeep`，并写入 `config/project.yaml` /
`agents.md` 兜底 / `build.sh` / `build.cmd` / `README.md` / `CHANGELOG.md` /
`latest.md` 占位文件；幂等，重复执行不覆盖已有文件）：

```
~/my-novel/
  agents.md               # Agent 引导（兜底版；nc-初始化 生成交互式完整版）
  config/
    project.yaml          # lang / mode / pipeline_option
  registry/               # .yaml 静态配置白名单
  index/                  # .json 机器索引 / 图森林真值
  res/inbox/              # 原始素材封存区
  templates/              # 每类卡独立模板
  cards/
    characters/           # type: actor（id 前缀 ac-，目录名保留 characters）
    plotpoints/           # 桥段卡 pp-
    items/                # 道具卡 it-（黑盒三层）
    scenes/               # 场景卡 sc-
    foreshadow/           # 伏笔卡 fs-
    timeline/             # 动线卡 tl-（积木驱动）
    factions/             # 势力卡 fa-
    snapshots/            # 快照卡 sn-（时间锚点状态切片）
    darklayer/            # 暗线卡 dk-（独立命名空间）
    modules/              # 积木模块卡 md-（最小调度单元）
    lexstats/             # 词频张力卡 lx-
    corpus/               # 语料卡 co-
    metrics/              # 量化指标卡 mt-
    pose-bank/            # 姿态卡 po-
    custom/
      sensory_cue/        # 感官标记卡 su-
      refwork/            # 对标作品档案卡 rw-
  reflections/            # 反思卡 rf-（独立于 cards/）+ 审计意见书
  manuscript/             # 正文章节
  graph/                  # 关系图谱 HTML（消费 index/card-graph.json 渲染）
  export/                 # nc-导出 中间产物
  release/                # nc-导出 成品（PDF/Word）
  history/                # nc-定稿 工程快照归档
  drafts/practice/        # 练习稿（过滤器未通过 / 用户标记）
  build.sh build.cmd      # 构建脚本骨架
  README.md CHANGELOG.md latest.md
```

`.gitkeep` 是占位文件，不影响 skill 读取，可保留（推荐）或删除。

---

## 4. 三种使用场景的操作路径

v1.0 把日常使用收敛为**三条主线路径**。新手只需记住自己属于哪一类，跟着走即可。
详细节点编排见 `references/loop.md`。

### 场景一 · 从零原创写作

```
[可选] nc-素材（灵感/参考入库）→ nc-清洗（杂乱才走）→ nc-检索（找可复用资产）
   ↓
搭建叙事单元（并行多选）：nc-角色 / nc-道具（黑盒三层）/ nc-场景；[游离] nc-姿态
   ↓
nc-桥段（剧情单元、绑角色/道具/pose、标章节、注爆点）
   长篇并行：nc-伏笔 / nc-快照 / nc-势力 / nc-暗线
   ↓
nc-积木（编排动线/伏笔/pose 触发关系）；[备选] nc-量化
   ↓
nc-图谱（渲染叙事森林/时序/关系图自查逻辑）
   ↓
nc-成稿（读全部卡片出正文初稿，--length short/mid/long，提案制落盘 manuscript/）
   nc-词频（词频向量+感官均衡约束，纯约束不出正文）
   ↓
[写稿完成后] nc-校阅（叙事审计，内置调用 nc-节奏）
   ↓
[对外分发才走] nc-守卫（隐私+合规扫描）
   ↓
[可选] nc-定稿（工程快照归档锁定）→ [需导出] nc-导出（Word/PDF）
   ↓
nc-复盘（沉淀洞察回流素材库，开启新一轮构思）
```

### 场景二 · 外部作品对标拆解

```
nc-素材（原作原文/截图转写/摘抄入库）→ nc-清洗（OCR/网页必走）→ nc-检索（避免重复建卡）
   ↓
nc-对标（创建作品总档案，独立 tree_id 隔离）
   ↓
并行建卡：nc-角色 / nc-道具 / nc-场景 / nc-伏笔（梳理回收链）/
         nc-快照（按章节切片）/ nc-暗线（梳理隐秘主线与信息差）
   ↓
nc-桥段（原作剧情拆成桥段单元）→ nc-积木（梳理触发逻辑与因果链）
   ↓
nc-量化（统计节奏/张力/信息投放）→ nc-图谱（时序图/关系图）
   ↓
nc-校阅（复核理解偏差）→ nc-复盘（总结套路沉淀进素材供后续创作复用）
```

### 场景三 · 纯素材整理（只囤资料不写故事）

```
nc-素材（原始文本入库原样留底）→ nc-清洗（杂乱素材降噪生成干净副本）→ nc-检索（随时调取）
```

不需要走角色/桥段等任何创作类技能。

### 长短篇分级（mode 决定默认启用集）

| mode | 篇幅 | 默认启用 | 默认关闭（手动开才可用） |
|---|---|---|---|
| **short** | ≤3万，单主线少量角色 | 素材/清洗/检索/角色/桥段/道具/场景/积木/成稿(--length short)/复盘/简易节奏（词频可选） | 注册复杂track、伏笔、势力、暗线、快照、量化、对标、多树森林图谱、校阅/定稿/导出 |
| **mid** | 3~15万，主线+少量支线 | 短篇全套 + 伏笔、快照、完整节奏、基础量化、基础图谱 | 势力、暗线、快照状态、多独立叙事森林、大规模对标 |
| **long** | >15万，多支线多势力 | 全部技能全开 | 无 |

短篇用户默认看不到复杂长线建模技能，不被大量概念压垮；长篇解锁全部能力。
配置存于 `registry/work-length-config.yaml`。

---

## 5. 触发 skill：说什么话

### 5.1 统一前缀触发（推荐，好记，24 个均支持英文别名）

以 `nc-` 为统一前缀，后接操作对象：

| 提示语 | 动作 |
|---|---|
| `nc-角色 姜璃` | 建/更新叙事行动单元卡（人/蛤蟆/器灵等） |
| `nc-桥段 chapter-012` | 建桥段卡 |
| `nc-道具 青铜钥匙` | 建道具卡（黑盒三层） |
| `nc-场景 月光审判台` | 建场景卡 |
| `nc-伏笔 孤儿院信件` | 建伏笔卡（payoff 硬约束） |
| `nc-动线 青铜钥匙` | 建动线卡（追踪对象跨章节流向，积木驱动） |
| `nc-势力 神智会` | 建势力卡 |
| `nc-快照 chapter-050` | 建时间锚点状态切片卡 |
| `nc-暗线 母亲的舌头` | 建暗线卡（独立命名空间） |
| `nc-积木 进门名场面` | 建积木模块（trigger_map 联动） |
| `nc-图谱 青铜钥匙` | 生成 HTML 关系图谱 |
| `nc-成稿 chapter-012 --length long` | 读全部卡片出正文初稿提案 |
| `nc-词频 chapter-012` | 词频向量+感官均衡约束校验 |
| `nc-校阅 第5章` | 叙事审计（只出意见不改稿） |
| `nc-复盘 chapter-050` | 建反思卡（单章复盘） |
| `nc-过滤 职场逆袭新角度` | 对新素材跑通胀过滤器三问（手动复检入口） |

完整 24 技能中英双语映射见 `references/skill-catalog.md`。

### 5.2 自然语言触发（无前缀，兜底）

以下说法**也会**激活 skill：

- 「维护小说卡片体系」 / 「走提案制」
- 「新增/更新角色卡」 / 「添加一张伏笔卡」
- 「整理这一章出现的道具 / 场景」
- 「梳理动线」 / 「搭一个积木模块」 / 「生成关系图谱」
- 「埋个伏笔」 / 「回收一下这个伏笔」
- 「这条暗线要收」 / 「暗线人物和主书 X 有关」
- 「写章节状态快照」 / 「做一下时间线快照」
- 「成稿这一章」 / 「出一版正文初稿」
- 「复盘这一章」 / 「这一章哪里卡住了」 / 「沉淀一下这一章」
- 「过滤一下这个素材」 / 「这个题材值不值得做」 / 「这个角度别人能不能抄」
- 「校阅一下设定一致性」 / 「检查一下节奏」 / 「做个合规扫描」
- 「导出成 PDF」

**未命中时的兜底**：直接说 `加载 novel-cards skill`。

---

## 6. 完整工作流（一次交互的全流程）

以"新增角色卡"为例：

```
用户：nc-角色 姜璃，她是主角，在 chapter-003 首次出场，
    属于神智会，师承苏叶。

AI：（读上下文：manuscript/chapter-003.md、cards/factions/fa-shenzhi-hui.md、
    cards/characters/ac-su-ye.md）

    建议保存到：cards/characters/ac-jiang-li.md

    ```markdown
    ---
    id: ac-jiang-li
    type: actor
    status: draft
    created: 2026-10-23
    updated: 2026-10-23
    name: 姜璃
    classification: protagonist
    faction: fa-shenzhi-hui
    first_appearance: chapter-003
    age: 24
    ---

    ## 性格
    外冷内热，理性至上...

    ## 关系
    - 与 ac-su-ye 是师徒关系；详细交汇见 tl-jiang-li-journey 动线卡的
      mentions 段；复杂关系图见 graph/tl-jiang-li-journey-graph.html
    ```
```

**用户三种响应**：

| 响应 | AI 后续动作 |
|---|---|
| `确认` / `OK` / `保存` | 用户手动复制代码块到编辑器并保存 |
| `classification 改成 deuteragonist` | AI 重新出提案（仅修改该字段） |
| `不要` / `pass` | AI 记录被拒，不再重提 |

---

## 7. 15+ 类卡：每类的典型提示语

| 卡片 | type | id 前缀 | 前缀式提示语 | 输出位置 |
|---|---|---|---|---|
| 角色 | `actor` | `ac-` | `nc-角色 姜璃` | `cards/characters/ac-jiang-li.md` |
| 桥段 | `plotpoint` | `pp-` | `nc-桥段 chapter-012` | `cards/plotpoints/pp-moonlit-trial.md` |
| 道具 | `item` | `it-` | `nc-道具 青铜钥匙` | `cards/items/it-bronze-key.md` |
| 场景 | `scene` | `sc-` | `nc-场景 月光审判台` | `cards/scenes/sc-moonlit-arena.md` |
| 伏笔 | `foreshadow` | `fs-` | `nc-伏笔 孤儿院信件` | `cards/foreshadow/fs-orphan-letter.md` |
| 动线 | `timeline` | `tl-` | `nc-动线 青铜钥匙` | `cards/timeline/tl-bronze-key.md` |
| 势力 | `faction` | `fa-` | `nc-势力 神智会` | `cards/factions/fa-shenzhi-hui.md` |
| 快照 | `snapshot` | `sn-` | `nc-快照 chapter-050` | `cards/snapshots/sn-chapter-050.md` |
| 暗线 | `darklayer` | `dk-` | `nc-暗线 母亲的舌头` | `cards/darklayer/dk-mother-tongue.md` |
| 积木 | `module` | `md-` | `nc-积木 进门名场面` | `cards/modules/md-action-entry.md` |
| 词频 | `lexstat` | `lx-` | `nc-词频 chapter-012` | `cards/lexstats/lx-ch012.md` |
| 语料 | `corpus` | `co-` | `nc-素材 <参考文本>` | `cards/corpus/co-*.md` |
| 量化 | `metric` | `mt-` | `nc-量化 第10~20章` | `cards/metrics/mt-*.md` |
| 姿态 | `pose` | `po-` | `nc-姿态 招牌戒备` | `cards/pose-bank/po-001.md` |
| 感官标记 | `sensory_cue` | `su-` | `nc-感官标记 王熙凤笑声` | `cards/custom/sensory_cue/su-*.md` |
| 对标作品 | `refwork` | `rw-` | `nc-对标 <作品名>` | `cards/custom/refwork/rw-*.md` |
| 反思 | `reflection` | `rf-` | `nc-复盘 chapter-050` | `reflections/chapter-050.md`（不入 `cards/`） |

---

## 8. 动线卡 vs 关系图

**关系动态不再有独立卡类型**。原来的关系动态卡已合并到动线卡里，
复杂关系用 HTML 图谱表达。

### 何时用动线卡（`cards/timeline/`）

追踪**单一对象**跨章节跨场景的完整轨迹。一个对象一张卡。

```
nc-动线 青铜钥匙
```

- `track: item`（也可能是 `character` / `faction` / `place` / `other` / 已注册自定义类型）
- `target: it-bronze-key`
- 每个节点 SHOULD 通过 `bind_module` 绑定一个 pose/module 积木
- `mentions` 段简要记录与其他对象的交汇

### 何时用关系图谱（`graph/`）

当**多个对象**之间的关系密度超过 Markdown 表格可表达范围时。
尤其是：多角色三角关系、跨势力协作、含暗示/潜在关系、积木联动总图。

```
nc-图谱 青铜钥匙
```

AI 会基于相关 `timeline` 卡的 `mentions` 段 + `index/card-graph.json` 图森林
生成 SVG 图谱，节点类型用颜色区分（角色 / 势力 / 道具 / 场景），实线=明确关系，
虚线=暗示关系，带箭头=有向关系。

### 两者的分工

| 需求 | 用哪个 |
|---|---|
| 单个人物的成长弧线 | 动线卡（`track: character`） |
| 单个道具的完整流向 | 动线卡（`track: item`） |
| 两个角色之间的师徒演变 | 动线卡的 `mentions` + 图谱 |
| 三方势力博弈 | 图谱 |
| 一条贯穿全书的主题线 | 动线卡（`track: other`） |
| 关系网络全景 / 积木联动 | 图谱 |

---

## 9. 写作闭环：从"写完一章"到"下一章更强"

线性流程（素材→AI→卡片→文章）会退化成一次性消费系统。闭环的核心
是**每篇文章都被复盘，复盘结论被显式写回卡片**。

### 9.1 单章复盘的典型流程

```
写完 chapter-050 → 落盘到 manuscript/chapter-050.md
     ↓
用户：nc-复盘 chapter-050
     ↓
AI 读：manuscript/chapter-050.md、
      cards/snapshots/sn-chapter-050.md（若有）、
      涉及到的 plotpoints / characters / foreshadow 卡
     ↓
AI 出反思卡提案（reflections/chapter-050.md）：

  ---
  id: rf-chapter-050
  type: reflection
  status: draft
  created: 2026-10-23
  updated: 2026-10-23
  chapter: chapter-050
  title: 第五章复盘
  ---

  ## stuck
  - 卡点 1：姜璃与苏叶的对手戏推不动...
  - 卡点 2：孤儿院失踪事件真相浮出水面太快...

  ## shone
  - 亮点 1：审判台场景的空间描写...

  ## why
  - 根本原因 A：苏叶角色卡缺少「个人欲望」字段...
  - 根本原因 B：伏笔卡 fs-orphan-letter 的 setup_chapter 定得太晚...

  ## insights
  - 认知 1：角色卡的「目标」需区分「立场」与「欲望」...
  - 认知 2：情感铺垫必须至少提前一章埋设伏笔...

  ## action_items
  - [ ] 更新 cards/characters/ac-su-ye.md：把「目标」拆为「立场」与「欲望」
  - [ ] 新建 cards/foreshadow/fs-orphan-letter.md：setup_chapter: chapter-049
  - [ ] 补素材：需要口述「苏叶个人欲望」的具体素材（先过 nc-素材 入库 gate）
```

用户确认后落盘到 `reflections/chapter-050.md`。

### 9.2 反哺阶段

反思卡落盘后，AI 逐条读 `action_items`，每条单独出反哺提案：

```
用户：反思卡已落盘，反哺吧

AI：读 action_items[0]：更新 cards/characters/ac-su-ye.md
    → 出反哺提案（修改角色卡的目标字段）
    → 用户逐条确认

AI：读 action_items[1]：新建 cards/foreshadow/fs-orphan-letter.md
    → 出反哺提案（新建伏笔卡）
    → 用户确认

AI：读 action_items[2]：补素材（先过过滤器）
    → 出过滤器三问提案
    → 判定通过后进入素材池，不通过进 drafts/practice/
```

### 9.3 闭环健康度

一个健康闭环系统随时间应观察到：

- 反思卡数量 ≈ 已完稿章节数
- 卡片的 `updated` 时间戳持续刷新
- 图谱节点/边数量单调递增
- 后续章节引用历史反思卡 `rf-*` id 的频率上升

**如果反思卡存在但卡片 `updated` 长期不变，说明反哺断了。**

详细见 `references/loop.md`。

---

## 10. 通胀过滤器：新素材入库前的三问

不过滤的后果：素材库膨胀但产出效率不变，选题时面对一堆同质化素材
无从下手。现为 `nc-素材` 入库前**自动 gate**，同时保留手动 `nc-过滤` 复检入口。

### 10.1 典型用法

```
用户：nc-过滤 想写一个职场复仇故事，主角用数据建模反击

AI：【通胀过滤器提案】素材：职场复仇 + 数据建模反击

Q1 公共领域性：是 — 职场逆袭属公共领域套路
Q2 三个月复刻性：是 — 数据题材已被多个作者用同一角度
Q3 独家洞察：无 — 用户描述未包含只有作者能提供的经验

判定：练习稿
去向：drafts/practice/

请确认：
(1) 同意此判定
(2) 补充独家洞察后重新评估
(3) 覆盖判定（用户强制排期，AI 需记录理由）
```

### 10.2 三问详解

| 问题 | 判定要点 | 反例（不算独家洞察） |
|---|---|---|
| Q1 公共领域性 | 是 → 需靠角度差异化；否 → 自带排他性 | — |
| Q2 三个月复刻性 | 是 → 角度不新鲜；否 → 稀缺 | — |
| Q3 独家洞察 | 有 → 护城河；无 → 只能练习 | 「我比别人更努力」<br>「我文笔更好」<br>「这个题材我很喜欢」 |

### 10.3 判定矩阵

| Q1 | Q2 | Q3 | 判定 | 去向 |
|---|---|---|---|---|
| 是 | 是 | 否 | ❌ 练习稿 | `drafts/practice/` |
| 是 | 是 | 是 | ⚠️ 需强化独家洞察 | 用户决定 |
| 是 | 否 | 是 | ✅ 可排期 | 素材池 |
| 否 | 是 | 否 | ⚠️ 门槛题材但无洞察 | 补洞察再评估 |
| 否 | 是 | 是 | ✅ 可排期 | 素材池 |
| 否 | 否 | 是 | ✅ 强推荐 | 优先排期 |
| **任意** | **任意** | **否** | ❌ 练习稿（Q3 是否决项） | `drafts/practice/` |

**Q3 是否决项**：没有独家洞察的素材，无论题材多小众、多稀缺，都只能是
练习稿。

### 10.4 反思卡反哺也要过

反思卡的 `action_items` 中如果包含「补素材」条目，同样必须先过过滤器
才能进入素材池或 `drafts/practice/`。

详细见 `references/filter.md`。

---

## 11. 提案制铁律：AI 会做什么、不会做什么

**AI 会做**：
- 读你的 `cards/`、`manuscript/`、`reflections/`、`index/`
- 出**完整** Markdown 提案（含 frontmatter + 正文）或完整 HTML 图谱代码
- 在提案前说明**建议保存路径**
- 校验硬规则（伏笔合法组合 / 暗线命名空间 / 五字段 / track 分类 /
  reflection 五段结构 / 过滤器判定记录 / 四层数据分层）
- 检测到你提供的卡不合规时，**指出违规点**并给出修正提案

**AI 不会做**：
- 直接 `edit` / `write` 你工程里的卡片、反思卡、图谱 HTML、练习稿
- 修改你的 `AGENTS.md` / `CLAUDE.md` / `.gitignore`
- 创建 `cards/` 与 `manuscript/` 之外的目录（`graph/`、`reflections/`、
  `drafts/` 除外，仅生成文件）
- 使用绝对路径或 `$HOME`

如果你发现 AI 有上述行为，**说明 skill 版本错误或触发到了错误 skill**，
请 `./install.sh --link` 重新软链并检查。

---

## 12. 硬规则速查

```
 1. 不直接落盘 —— 只出提案
 2. 伏笔合法 —— 有 payoff_chapter 或 status: unresolved
 3. 暗线隔离 —— cards/darklayer/，dk- 前缀，references_to_main 单向引用
 4. 五字段必备 —— id / type / status / created / updated
 5. 动线分类 —— track 字段声明追踪对象类型
 6. 图谱分离 —— HTML 存 graph/，不入 cards/
 7. 反思卡结构 —— stuck / shone / why / insights / action_items 五段必备
 8. 过滤器 gate —— 新素材先过三问，Q3（独家洞察）是否决项
 9. frontmatter 三键 —— name / description / license（skill 自身约束）
10. 四层数据分层 —— .md 业务源头 / .json 图森林真值 / .yaml 配置白名单 / .html 展示投影
11. 审计类技能只读 —— nc-校阅 / nc-节奏 / nc-守卫 只出意见绝不改稿
12. 五感公理 —— 感知动线根 MUST 落在原生五感之一
13. 道具黑盒三层 —— item 卡支持物理/感知/抽象非感知层
14. pose 插槽三级优先级 —— P1 桥段覆写 > P2 快照填充 > P3 默认兜底
15. 注册前置 —— 自定义类型/track 标签 MUST 先经 nc-注册 写入 registry
16. 素材合规 fail-closed —— 网页抓取先校验 robots.txt，禁止路径直接拦截
17. actor 与 item 区分 —— 拥有独立意志主动行动的道具 SHALL 建模为 actor
18. 跨动线同步走 module —— MUST 走积木 trigger_map，禁止零散写联动
19. 长线四方对齐 —— 长线爆点 MUST 满足 fs- + tl- + md- + lx- 提前 ≥8 章预埋
```

完整规则与违规响应模板见 `references/hard-rules.md`。

---

## 13. 批量操作场景

### 一次处理一整章

```
用户：nc-检索 chapter-020，把所有新出场的人物、道具、场景列出来出卡，
     伏笔单独提出，我逐条确认。
```

AI 会**分批次**出提案，每批 1–3 张卡；不会一次性倾倒 20 张。

### 追踪一条动线

```
用户：nc-动线 青铜钥匙，从 chapter-003 到 chapter-042 的完整流向
```

AI 会扫描所有相关章节，生成变化轨迹表；如果同时涉及多个角色的交互，
提示"是否需要生成图谱？"。

### 一次性梳理关系图谱

```
用户：nc-图谱 姜璃，把她的所有关联对象画成图
```

AI 会先扫描所有相关 timeline 卡的 `mentions` 段 + card-graph.json，然后生成图谱 HTML。

### 时间线快照

```
用户：nc-快照 chapter-050，这是个分水岭，标记势力格局变化
```

AI 会引用已 arch 的所有 faction 卡与关键 timeline 卡。

### 单章完稿后复盘

```
用户：nc-复盘 chapter-050

用户：反哺

用户：action_items 的第 4 条跳过，其他都出提案
```

### 新素材入库前过滤

```
用户：nc-过滤 想写一个关于 AI 编辑的元小说，反思这个系统本身

用户：nc-过滤 想写个职场逆袭故事（可能被判为练习稿）

用户：这个我强制排期（覆盖判定，AI 需记录理由）
```

---

## 14. 常见问题（FAQ）

### Q1：AI 说找不到 `cards/` 目录怎么办？

工程骨架没建。运行：
```bash
cd /path/to/novel-cards && ./install.sh --project /path/to/your/novel
```

### Q2：AI 直接开始写卡片文件了？

这不是本 skill 该有的行为。可能原因：
- Skill 未加载，AI 在凭"常识"操作
- Skill 版本过旧（`./install.sh --link` 刷新）

明确回复：`停止写入，走提案制`。

### Q3：AI 出的提案我不喜欢怎么办？

回复 `改一下 <具体字段> <新值>` 或 `不要`。
**不要**说"你自己看着办"——AI 会按提案制要求等你决策。

### Q4：伏笔卡 AI 拒绝给我出？

大概率你给的组合非法。合法组合只有两种：
- `status: unresolved`（未回收）
- `status: resolved` + `payoff_chapter: chapter-XX`（已回收）

见 `references/hard-rules.md` 规则 3 完整表格。

### Q5：darklayer 卡的 `references_to_main` 应该指向谁？

指向**表面层人物**（读者视角看到的那个），不指向真相身份。
如果暗线人物的真相身份本身就是主书人物，仍用主书的 `ac-*` id 引用。

### Q6：我怎么检查现有卡片合规性？

```bash
# 缺任一必备字段的卡片（cards/ 与 reflections/ 都适用）
grep -rLE '^(id|type|status|created|updated):' cards/ reflections/ --include='*.md'
```

### Q7：我能用本 skill 编辑小说正文吗？

不能。本 skill 的边界是"卡片体系 + 反思卡 + 过滤器提案"，正文编辑不在
其职责范围内。`manuscript/` 目录只是被读取作为上下文，AI 不会主动改。

### Q8：动线卡什么时候用、什么时候画图？

- **单对象**跨章节变化 → 动线卡
- **多对象**之间关系网络 → 图谱
- **两者都需要** → 动线卡 `mentions` 简要记录 + 图谱详细描述
  动线卡的 `graph` 字段（可选）指向对应图谱 HTML。

### Q9：图谱 HTML 我能直接编辑吗？

可以。图谱是标准 HTML + SVG，任何编辑器都能改。AI 也会以完整 HTML
代码形式出提案，你可以修改节点位置、颜色、边类型后再保存。

### Q10：我为什么找不到 `relationships/` 目录？

`relationships/` 已合并到 `timeline/`。旧用法（关系动态卡）请改用
动线卡表达，复杂关系用图谱。

### Q11：反思卡是必须每章一张吗？

不是。反思卡是**按需**使用。建议每章完稿后写一张，但如果你写短篇或
章节很轻，可以每 3-5 章合并复盘一次。

### Q12：反思卡放 `cards/` 里可以吗？

**不可以**。反思卡是**元卡片**（关于创作过程，不是小说内容），必须放在
`reflections/` 独立目录，**不进入** `cards/`。违反此约定的常见错误：
把 `rf-*` id 放进 `cards/reflections/`。

### Q13：过滤器判定为练习稿的素材会删除吗？

不会。判定为练习稿的素材保留在 `drafts/practice/`。后续如果出现新的
独家洞察，可以按 `nc-过滤` 重新评估升级。用户主动标记为练习稿的素材
也不受过滤器约束。

### Q14：过滤器可以覆盖吗？

可以。过滤器是辅助不是决策。用户可覆盖判定，但 AI 需在练习稿文件顶部
记录覆盖理由（三行以内），便于日后复盘。

### Q15：过滤器对已有卡片更新有用吗？

没有。过滤器只对**新素材**（首次入库的题材/口述/灵感/反思卡反哺回来的
素材）触发，更新已有卡片不触发。

### Q16：角色性格怎么记？我想刻画一个人物从克制慢慢变放荡，每次转变都有事件推动

用 **`nc-动向`**(nc-tendency) 建一张 `character_tendency`（`tend-`）滑动标尺卡：
`target_role` 绑 `ac-*` 角色、`dimension: 克制↔放荡`、`baseline` 初始刻度、
`direction_rule` 长期趋势方向；此后每落地一个新桥段，就在 `history[]` 追加一条
`{value, trigger_plot: pp-*, description}`，把这次性格偏移绑定到那个具体桥段事件上。
基线初始状态仍写在 `actor` 角色卡上，动向卡只记"沿某维度的渐进滑动"，二者互补不替代。
刻画带人格病理类稳定基线的角色（如自恋型人格的浮夸型 / 脆弱型创作原型）时，可给
tend- 卡加可选字段 `baseline_prototype` 声明滑动边界锚点（取值先经 `nc-注册` 写入
`registry/tendency-prototypes.yaml`），`nc-校阅` 检查 ④ 会在受限方向漂移超容差时
出建议级提醒。
详见 `references/card-schema.md` 的 character_tendency 小节。

### Q17：想批量改剧情 / 基于一批素材扩写整条故事线怎么办？

用 **`nc-编排`**(nc-compose)。它根据指定素材（`--source`）、原有剧情资产
（`--reference`）、情节目标（`--prompt`）与模式（`--mode expand/rewrite/restructure`）
自动生成一套结构化【编排执行计划】（新增桥段 / 修改桥段 / 归档旧桥段 / 更新角色动向 /
绑定感官标记四类任务）。**先交你逐条审核**（同意/编辑/移除/新增/整体约束），你确认
【计划定稿开始执行】后才顺序执行，执行前自动跑 `nc-校阅` 扫冲突，遇红色冲突暂停退回
计划页。全程禁止静默修改。若是**少量资产的单点推演**（拿 A/B/C 方案评估走向好坏），
则走 `nc-研判`(nc-analyze)，它只出建议报告不改卡。详见 `references/loop.md` 创作迭代分支。

### Q18：改书名 / 全局更换角色或势力代号用什么？

用 **`nc-更名`**(nc-rename)，专门处理**全局标识符替换**：
- 改项目主标题（故事书名）→ 同步更新根 README/project.yaml/CHANGELOG/latest.md 及导出模板页眉
- 全局代号重命名（角色/势力/核心道具代号）→ 跨所有卡片/伏笔/快照/桥段/图谱引用统一替换

安全机制：**先输出【替换预览清单】**（每一处要改的文件 + 原文片段），你确认批准后才批量
写入，并自动在 history 生成本次变更快照、CHANGELOG 追加记录。边界：不动 `res/` 原始素材，
不改正文里的自然口语称呼（如文中「阿三」）。若你想改的是**内容**（性格/暗线/桥段情节，
非改名），走对应本体技能（`nc-角色`/`nc-暗线`/`nc-桥段`），不走 `nc-更名`。

---

## 15. 故障回滚

**卸载 skill**（软链模式）：
```bash
rm ~/.config/opencode/skills/novel-cards
rm ~/.claude/skills/novel-cards
```

**卸载 skill**（复制模式）：
```bash
rm -rf ~/.config/opencode/skills/novel-cards
rm -rf ~/.claude/skills/novel-cards
```

**回滚 skill 版本**：
```bash
cd novel-cards
git checkout <tag-or-commit>
./install.sh --link   # 或无 --link 走复制
```

**清理使用方工程骨架**：
```bash
rm -rf ~/my-novel/cards ~/my-novel/manuscript ~/my-novel/graph \
       ~/my-novel/reflections ~/my-novel/drafts
# 或精细删除空目录
find ~/my-novel/cards ~/my-novel/reflections ~/my-novel/graph \
     ~/my-novel/drafts -name '.gitkeep' -delete
```

---

## 16. 术语对照

| 术语 | 中文 | 含义 |
|---|---|---|
| skill | 技能 | OpenCode / Claude Code 的可加载行为定义 |
| frontmatter | 前置元数据 | Markdown 文件头部 YAML 块 |
| proposal | 提案 | AI 输出、等用户确认后再落盘的完整卡片 Markdown / HTML |
| consumer project | 使用方工程 | 加载本 skill 的小说仓库 |
| actor | 叙事行动单元 | 拥有独立主观视角、可参与桥段的行动单元（不限人类），id 前缀 ac- |
| timeline | 动线 | 单一对象跨章节跨场景的完整追踪卡（积木驱动） |
| module | 积木模块 | 最小调度单元，trigger_map 绑定多类动线/pose/卡片 |
| relation graph | 关系图谱 | 多对象关系网络的 HTML + SVG 可视化 |
| dark layer | 暗线 | 整条明面叙事的隐性逻辑，独立命名空间 dk- |
| character_tendency | 角色动向 | 带触发事件的连续滑动标尺，刻画渐进人物弧光，tend- |
| lexstat | 词频张力卡 | 词频向量 + 感官均衡强约束，lx- |
| snapshot | 快照 | 时间锚点全局状态切片，区别于 timeline 的变化曲线 |
| payoff | 伏笔回收 | 之前埋下的线索在后续章节得到呼应 |
| canonical | 权威 | 主书人物链（与暗线对应） |
| track | 追踪类型 | 动线卡的分类字段（character/item/faction/place/other/自定义） |
| reflection | 反思卡 | 单章复盘的元卡片，含 stuck/shone/why/insights/action_items 五段 |
| action_items | 反哺动作 | 反思卡中把新认知写回其他卡片的清单 |
| filter | 通胀过滤器 | 新素材入库前的三问 gate |
| practice | 练习稿 | 过滤器判定未通过、进 drafts/practice/ 的素材 |
| Q3 独家洞察 | 否决项 | 过滤器三问中的第三问，无洞察一律练习稿 |
| auto_invokable | 可自动唤起 | 技能属性标记：true 表示可被其他技能内部自动调用（仅底层可见） |
