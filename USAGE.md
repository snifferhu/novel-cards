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
| 空目录约定 | 工程中已有 `cards/` 与 `manuscript/`（可用下方脚本一键生成） |

**没有以上条件的用户请先不要触发 skill**，否则会拿到缺失路径提示。

---

## 1. 三种安装方式

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

`install.sh` **不代为执行**项目级安装。若必须内联到某个小说工程，请
手动：

```bash
mkdir -p <project>/.opencode/skills
cp -r novel-cards <project>/.opencode/skills/
```

---

## 2. 初始化使用方工程骨架

假设你的小说工程在 `~/my-novel`：

```bash
./install.sh --project ~/my-novel
```

生成：

```
~/my-novel/
  cards/
    characters/   plotpoints/   items/
    scenes/       foreshadow/   timeline/
    factions/     snapshots/    darklayer/
  reflections/    # 反思卡（单章复盘）
  manuscript/
  graph/          # 关系图谱 HTML（复杂关系可视化）
  drafts/
    practice/     # 练习稿（过滤器未通过 / 用户标记）
```

每个目录都有一个 `.gitkeep`，空目录也可被 git 追踪。

**注意**：`.gitkeep` 是占位文件，不影响 skill 读取。你可以：
- 保留（推荐，便于未来清理时看到"这里曾是空目录"）
- 删除（不影响功能，因为已存在的空目录 skill 也能读）

---

## 3. 触发 skill：说什么话

### 3.1 统一前缀触发（推荐，好记）

以 `nc-` 为统一前缀，后接卡片类型或操作：

| 提示语 | 动作 |
|---|---|
| `nc-人物 姜璃` | 建/更新人物卡 |
| `nc-桥段 chapter-012` | 建桥段卡 |
| `nc-道具 青铜钥匙` | 建道具卡 |
| `nc-场景 月光审判台` | 建场景卡 |
| `nc-伏笔 孤儿院信件` | 建伏笔卡 |
| `nc-动线 青铜钥匙` | 建动线卡（追踪道具跨章节流向） |
| `nc-势力 神智会` | 建势力卡 |
| `nc-快照 chapter-050` | 建状态快照卡 |
| `nc-暗线 母亲的舌头` | 建暗线卡 |
| `nc-图谱 青铜钥匙` | 生成 HTML 关系图谱 |
| `nc-复盘 chapter-050` | 建反思卡（单章复盘） |
| `nc-过滤 职场逆袭新角度` | 对新素材跑通胀过滤器三问 |

**为什么用前缀**：避免自然语言被误触发到其他 skill。前缀明确、好记、
类似 spec-kitty 的 `spec:` 风格。

### 3.2 自然语言触发（无前缀，兜底）

以下说法**也会**激活 skill：

- 「维护小说卡片体系」 / 「走提案制」
- 「新增/更新人物卡」 / 「添加一张伏笔卡」
- 「整理这一章出现的道具 / 场景」
- 「梳理动线」 / 「生成关系图谱」
- 「埋个伏笔」 / 「回收一下这个伏笔」
- 「这条暗线要收」 / 「暗线人物和主书 X 有关」
- 「写章节状态快照」 / 「做一下时间线快照」
- 「复盘这一章」 / 「这一章哪里卡住了」 / 「沉淀一下这一章」
- 「过滤一下这个素材」 / 「这个题材值不值得做」 / 「这个角度别人能不能抄」

**未命中时的兜底**：直接说 `加载 novel-cards skill`。

---

## 4. 完整工作流（一次交互的全流程）

以"新增人物卡"为例：

```
用户：nc-人物 姜璃，她是主角，在 chapter-003 首次出场，
    属于神智会，师承苏叶。

AI：（读上下文：manuscript/chapter-003.md、cards/factions/fa-shenzhi-hui.md、
    cards/characters/ch-su-ye.md）

    建议保存到：cards/characters/ch-jiang-li.md

    ```markdown
    ---
    id: ch-jiang-li
    type: character
    status: draft
    created: 2025-01-20
    updated: 2025-01-20
    name: 姜璃
    role: protagonist
    faction: fa-shenzhi-hui
    first_appearance: chapter-003
    age: 24
    ---

    ## 性格
    外冷内热，理性至上...

    ## 关系
    - 与 ch-su-ye 是师徒关系；详细交汇见 tl-jiang-li-journey 动线卡的
      mentions 段；复杂关系图见 graph/tl-jiang-li-journey-graph.html
    ```
```

**用户三种响应**：

| 响应 | AI 后续动作 |
|---|---|
| `确认` / `OK` / `保存` | 用户手动复制代码块到编辑器并保存 |
| `role 改成 deuteragonist` | AI 重新出提案（仅修改该字段） |
| `不要` / `pass` | AI 记录被拒，不再重提 |

---

## 5. 九类卡 + 反思卡：每类的典型提示语

| 卡片 | 前缀式提示语 | 输出位置 |
|---|---|---|
| 人物 | `nc-人物 姜璃` | `cards/characters/ch-jiang-li.md` |
| 桥段 | `nc-桥段 chapter-012` | `cards/plotpoints/pp-moonlit-trial.md` |
| 道具 | `nc-道具 青铜钥匙` | `cards/items/it-bronze-key.md` |
| 场景 | `nc-场景 月光审判台` | `cards/scenes/sc-moonlit-arena.md` |
| 伏笔 | `nc-伏笔 孤儿院信件` | `cards/foreshadow/fs-orphan-letter.md` |
| 动线 | `nc-动线 青铜钥匙` | `cards/timeline/tl-bronze-key.md` |
| 势力 | `nc-势力 神智会` | `cards/factions/fa-shenzhi-hui.md` |
| 快照 | `nc-快照 chapter-050` | `cards/snapshots/sn-chapter-050.md` |
| 暗线 | `nc-暗线 母亲的舌头` | `cards/darklayer/dk-mother-tongue.md` |
| 图谱 | `nc-图谱 青铜钥匙` | `graph/tl-bronze-key-graph.html` |
| 反思 | `nc-复盘 chapter-050` | `reflections/chapter-050.md` |
| 过滤 | `nc-过滤 <素材摘要>` | 对话中输出判定提案（不落盘） |

---

## 6. 动线卡 vs 关系图

**关系动态不再有独立卡类型**。原来的关系动态卡已合并到动线卡里，
复杂关系用 HTML 图谱表达。

### 何时用动线卡（`cards/timeline/`）

追踪**单一对象**跨章节跨场景的完整轨迹。一个对象一张卡。

```
nc-动线 青铜钥匙
```

- `track: item`（也可能是 `character` / `faction` / `place` / `other`）
- `target: it-bronze-key`
- 正文变化轨迹表记录每个章节的状态/位置/事件
- `mentions` 段简要记录与其他对象的交汇

### 何时用关系图谱（`graph/`）

当**多个对象**之间的关系密度超过 Markdown 表格可表达范围时。
尤其是：多角色三角关系、跨势力协作、含暗示/潜在关系。

```
nc-图谱 青铜钥匙
```

AI 会基于相关 `timeline` 卡的 `mentions` 段生成 SVG 图谱，节点类型
用颜色区分（人物 / 势力 / 道具 / 场景），实线=明确关系，虚线=暗示关系，
带箭头=有向关系。

### 两者的分工

| 需求 | 用哪个 |
|---|---|
| 单个人物的成长弧线 | 动线卡（`track: character`） |
| 单个道具的完整流向 | 动线卡（`track: item`） |
| 两个角色之间的师徒演变 | 动线卡的 `mentions` + 图谱 |
| 三方势力博弈 | 图谱 |
| 一条贯穿全书的主题线 | 动线卡（`track: other`） |
| 关系网络全景 | 图谱 |

---

## 7. 写作闭环：从"写完一章"到"下一章更强"

线性流程（素材→AI→卡片→文章）会退化成一次性消费系统。闭环的核心
是**每篇文章都被复盘，复盘结论被显式写回卡片**。

### 7.1 单章复盘的典型流程

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
  created: 2026-10-21
  updated: 2026-10-21
  chapter: chapter-050
  title: 第五章复盘
  ---

  ## stuck
  - 卡点 1：姜璃与苏叶的对手戏推不动...
  - 卡点 2：孤儿院失踪事件真相浮出水面太快...

  ## shone
  - 亮点 1：审判台场景的空间描写...

  ## why
  - 根本原因 A：苏叶人物卡缺少「个人欲望」字段...
  - 根本原因 B：伏笔卡 fs-orphan-letter 的 planted_at 定得太晚...

  ## insights
  - 认知 1：人物卡的「目标」需区分「立场」与「欲望」...
  - 认知 2：情感铺垫必须至少提前一章埋设伏笔...

  ## action_items
  - [ ] 更新 cards/characters/ch-su-ye.md：把「目标」拆为「立场」与「欲望」
  - [ ] 新建 cards/foreshadow/fs-orphan-letter.md：planted_at: chapter-049
  - [ ] 补素材：需要口述「苏叶个人欲望」的具体素材（先过 nc-过滤）
```

用户确认后落盘到 `reflections/chapter-050.md`。

### 7.2 反哺阶段

反思卡落盘后，AI 逐条读 `action_items`，每条单独出反哺提案：

```
用户：反思卡已落盘，反哺吧

AI：读 action_items[0]：更新 cards/characters/ch-su-ye.md
    → 出反哺提案（修改人物卡的目标字段）
    → 用户逐条确认

AI：读 action_items[1]：新建 cards/foreshadow/fs-orphan-letter.md
    → 出反哺提案（新建伏笔卡）
    → 用户确认

AI：读 action_items[2]：补素材（先过过滤器）
    → 出过滤器三问提案
    → 判定通过后进入素材池，不通过进 drafts/practice/
```

### 7.3 闭环健康度

一个健康闭环系统随时间应观察到：

- 反思卡数量 ≈ 已完稿章节数
- 卡片的 `updated` 时间戳持续刷新
- 图谱节点/边数量单调递增
- 后续章节引用历史反思卡 `rf-*` id 的频率上升

**如果反思卡存在但卡片 `updated` 长期不变，说明反哺断了。**

详细见 `references/loop.md`。

---

## 8. 通胀过滤器：新素材入库前的三问

不过滤的后果：素材库膨胀但产出效率不变，选题时面对一堆同质化素材
无从下手。

### 8.1 典型用法

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

### 8.2 三问详解

| 问题 | 判定要点 | 反例（不算独家洞察） |
|---|---|---|
| Q1 公共领域性 | 是 → 需靠角度差异化；否 → 自带排他性 | — |
| Q2 三个月复刻性 | 是 → 角度不新鲜；否 → 稀缺 | — |
| Q3 独家洞察 | 有 → 护城河；无 → 只能练习 | 「我比别人更努力」<br>「我文笔更好」<br>「这个题材我很喜欢」 |

### 8.3 判定矩阵

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

### 8.4 反思卡反哺也要过

反思卡的 `action_items` 中如果包含「补素材」条目，同样必须先过过滤器
才能进入素材池或 `drafts/practice/`。

详细见 `references/filter.md`。

---

## 9. 提案制铁律：AI 会做什么、不会做什么

**AI 会做**：
- 读你的 `cards/`、`manuscript/`、`reflections/`
- 出**完整** Markdown 提案（含 frontmatter + 正文）或完整 HTML 图谱代码
- 在提案前说明**建议保存路径**
- 校验硬规则（伏笔合法组合 / 暗线命名空间 / 五字段 / track 分类 /
  reflection 五段结构 / 过滤器判定记录）
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

## 10. 硬规则速查

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
```

完整规则与违规响应模板见 `references/hard-rules.md`。

---

## 11. 批量操作场景

### 一次处理一整章

```
用户：nc-整理 chapter-020，把所有新出场的人物、道具、场景列出来出卡，
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

AI 会先扫描所有相关 timeline 卡的 `mentions` 段，然后生成图谱 HTML。

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

## 12. 常见问题

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
如果暗线人物的真相身份本身就是主书人物，仍用主书的 `ch-*` id 引用。

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

---

## 13. 故障回滚

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
rm -rf ~/my-novel/cards ~/my-novel/manuscript ~/my-novel/graph        ~/my-novel/reflections ~/my-novel/drafts
# 或精细删除空目录
find ~/my-novel/cards ~/my-novel/reflections ~/my-novel/graph      ~/my-novel/drafts -name '.gitkeep' -delete
```

---

## 14. 术语对照

| 术语 | 中文 | 含义 |
|---|---|---|
| skill | 技能 | OpenCode / Claude Code 的可加载行为定义 |
| frontmatter | 前置元数据 | Markdown 文件头部 YAML 块 |
| proposal | 提案 | AI 输出、等用户确认后再落盘的完整卡片 Markdown / HTML |
| consumer project | 使用方工程 | 加载本 skill 的小说仓库 |
| timeline | 动线 | 单一对象跨章节跨场景的完整追踪卡 |
| relation graph | 关系图谱 | 多对象关系网络的 HTML + SVG 可视化 |
| dark layer | 暗线 | 读者不可见的真相层，独立命名空间 |
| payoff | 伏笔回收 | 之前埋下的线索在后续章节得到呼应 |
| canonical | 权威 | 主书人物链（与暗线对应） |
| track | 追踪类型 | 动线卡的分类字段（character/item/faction/place/other） |
| reflection | 反思卡 | 单章复盘的元卡片，含 stuck/shone/why/insights/action_items 五段 |
| action_items | 反哺动作 | 反思卡中把新认知写回其他卡片的清单 |
| filter | 通胀过滤器 | 新素材入库前的三问 gate |
| practice | 练习稿 | 过滤器判定未通过、进 drafts/practice/ 的素材 |
| Q3 独家洞察 | 否决项 | 过滤器三问中的第三问，无洞察一律练习稿 |
