# 硬规则（hard-rules.md）

novel-cards skill 的所有行为准则集中于此。规则分为**不可变硬规则**（AI 必须遵守）
与**提案-确认流程**（AI 与用户交互的形态）。

## 规则一览

| # | 规则 | 强度 |
|---|---|---|
| 1 | AI 绝不直接 `edit` / `write` 使用方工程的卡片、图谱、反思卡、练习稿文件 | 硬性 |
| 2 | AI 回写卡片一律以**完整 Markdown 提案**输出到对话，图谱以完整 HTML 提案输出，反思卡以完整五段结构输出，等用户确认后由用户落盘 | 硬性 |
| 3 | 伏笔卡（`type: foreshadow`）必须关联 `payoff_chapter` **或** 显式标注 `status: unresolved`；二者皆缺视为非法 | 硬性 |
| 4 | 暗线卡（`type: darklayer`）使用独立命名空间（`cards/darklayer/`），不混入主书人物链；与主书人物的引用只通过显式字段 `references_to_main` 串接 | 硬性 |
| 5 | 所有卡片 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated` 五字段 | 硬性 |
| 6 | 双端兼容：`SKILL.md` frontmatter 只允许 `name` / `description` / `license` 三键 | 硬性（针对 skill 本身，不是卡片） |
| 7 | 关系图谱 HTML 存放于使用方工程的 `graph/` 目录，**不进入** `cards/`；卡片正文可引用图谱文件，图谱本身无 frontmatter，不被视为卡片 | 硬性 |
| 8 | 动线卡（`type: timeline`）必须通过 `track` 字段声明追踪对象类型（`character` / `item` / `faction` / `place` / `other`），`target` 指向具体对象 id | 硬性 |
| 9 | 反思卡（`type: reflection`）存放于 `reflections/` 目录，正文必须含 `stuck` / `shone` / `why` / `insights` / `action_items` 五个二级标题；`action_items` 是唯一把新认知写回卡片的入口 | 硬性 |
| 10 | 所有新素材（首次入库的题材 / 口述灵感 / 反思卡反哺回来的素材）在写入 `cards/` 前必须过通胀过滤器三问；`Q3`（独家洞察）是否决项，无独家洞察一律进 `drafts/practice/` | 硬性 |

## 规则 1 & 2：提案制详解

### AI 输出格式

AI 在对话中输出卡片提案时，**必须**：

1. **完整可读**：一份提案 = 一份完整卡片 Markdown（含 frontmatter + 正文）
2. **代码块包裹**：用 ``` 代码块包裹，便于用户复制到编辑器
3. **明确目标路径**：在代码块前说明该卡片应保存到何处，例如
   `→ 建议保存路径：cards/characters/ch-jiang-li.md`
4. **不承诺落盘**：**禁止**在提案末尾写"我已写入文件"、"卡片已保存到..."
   这类措辞；应写"请确认后保存到上述路径"

### 用户确认方式

用户在确认提案时可能的输入形式：

- `保存` / `OK` / `确认` → 用户自行复制代码块到编辑器并保存
- `改一下 <字段>` → AI 重新输出修改后的提案
- `不要` / `pass` → AI 记录该提案被拒绝，不做进一步动作

### 禁止措辞（AI 输出时）

- ❌ "我已保存该卡片到 ..."
- ❌ "文件已写入"
- ❌ "接下来我会创建 ..."（针对卡片 / 反思卡 / 图谱文件）
- ✅ "建议保存到 ..."
- ✅ "请确认后复制到 ..."
- ✅ "以下是提案，未落盘"

## 规则 3：伏笔卡合法组合

| `status` | `payoff_chapter` | 合法性 | 说明 |
|---|---|---|---|
| `unresolved` | 缺失 | ✅ 合法 | 明确标记为未回收伏笔 |
| `unresolved` | 缺失或存在 | ✅ 合法 | 若已有回收章节但仍保持 unresolved，需 `notes` 说明理由 |
| `resolved` | `chapter-XX` 或 `chapter-XX.md` | ✅ 合法 | 已回收，指向具体章节 |
| `resolved` | 缺失 | ❌ **非法** | 已回收却无回收章节，逻辑不自洽 |
| 其他 | 缺失 | ❌ **非法** | 非法状态值或缺失状态 |

**校验逻辑（伪代码）**：

```python
def validate_foreshadow(fm):
    status = fm.get('status')
    payoff = fm.get('payoff_chapter')
    if status == 'unresolved':
        return True
    if status == 'resolved' and payoff:
        return True
    return False
```

## 规则 4：暗线边界表

| 允许 | 禁止 |
|---|---|
| `cards/darklayer/` 下 `dk-*` 命名的卡片 | 把 `dk-*` id 放入 `cards/characters/` 等主书目录 |
| 暗线卡通过 `references_to_main` 显式引用主书 id | 主书人物卡通过任何字段引用 `dk-*` id |
| 主书人物卡可通过 `aliases` / `disguises` 文本暗示暗线身份 | 主书人物卡通过 `character_id: dk-*` 类字段直接链接 |
| 暗线卡正文可详细描写暗线情节 | 主书卡正文大段引用暗线细节 |

**为什么这么设计**：暗线卡的存在本身是对读者的隐藏信息；如果主书卡通过字段
反向链接暗线，工具链检索时就会把暗线泄漏到主书上下文，破坏"暗"的语义。

## 规则 5：五字段检查法

用户或 CI 可用以下命令检查现有卡片是否合规：

```bash
# 列出缺少任一必备字段的卡片（cards/ 与 reflections/ 都适用）
grep -rLE '^(id|type|status|created|updated):' cards/ reflections/ --include='*.md'
```

或按类型分目录检查：

```bash
for dir in cards/*/ reflections/; do
  grep -rLE '^(id|type|status|created|updated):' "$dir" --include='*.md'
done
```

**空行处理**：`created` / `updated` 值为空应视为缺失。ISO 8601 建议格式：
`YYYY-MM-DD` 或 `YYYY-MM-DDTHH:MM:SSZ`。

## 规则 7：图谱与卡片分离

**背景**：Markdown 表格难以表达多节点、多类型的复杂关系（尤其是
"暗示关系"、"多角色三角"、"跨势力协作"等）。当关系密度超过表格可表达
范围时，使用 HTML + SVG 图谱。

**允许**：
- 图谱 HTML 存放于 `<consumer-root>/graph/`
- 卡片正文写 `见 graph/tl-xxx-graph.html` 提示
- 同一动线可对应一份图谱，也可对应多份（不同视角）

**禁止**：
- 图谱放入 `cards/` 目录
- 图谱文件带 frontmatter（YAML 前置元数据块）
- 卡片通过 `type: timeline` 直接内嵌 SVG 代码（应放 `graph/` 独立文件）
- 图谱通过 skill 硬规则校验（图谱不受五字段约束）

## 规则 8：动线卡 track 分类

动线卡通过 `track` 字段显式分类，便于检索：

| `track` 值 | `target` 指向 | 示例 |
|---|---|---|
| `character` | `ch-*` id | `tl-jiang-li-journey` |
| `item` | `it-*` id | `tl-bronze-key` |
| `faction` | `fa-*` id | `tl-shenzhi-rise` |
| `place` | `sc-*` id | `tl-shenzhi-hq` |
| `other` | 无固定类型 id | `tl-winter-season`（跨对象主题线） |

`target` 在 `track: other` 时可省略或填写自由字符串；其他取值必须指向
对应类型的有效卡片 id。

## 规则 9：反思卡结构

**背景**：反思卡用于把「写作过程本身的经验」显式沉淀下来，通过反哺机制
让下一篇文章继承上一篇文章的所有新认知。反思卡是**元卡片**，不是小说
内容的一部分，所以放在 `reflections/` 独立目录。

**允许**：
- 位置：`reflections/<chapter-id>.md`
- id：`rf-<chapter-id>`（例：`rf-chapter-050`）
- 正文五个二级标题按顺序出现：`stuck` / `shone` / `why` / `insights` /
  `action_items`
- `action_items` 使用 markdown 任务列表 `- [ ] <verb> <target-id-or-path>：<内容>`

**禁止**：
- 反思卡放入 `cards/` 目录
- 缺 `action_items` 段（即使本次没有反哺，也要留空段并写 `暂无`）
- `action_items` 出现模糊动作（如「优化人物刻画」「完善世界观」）
- 反思卡正文直接引用 `dk-*` 暗线 id（避免暗线泄漏到复盘上下文中）

**校验逻辑（伪代码）**：

```python
def validate_reflection(fm, body):
    if fm.get('type') != 'reflection':
        return False
    if not fm.get('chapter'):
        return False
    required_sections = ['stuck', 'shone', 'why', 'insights', 'action_items']
    for sec in required_sections:
        if f'## ' + sec not in body.lower():
            return False
    return True
```

**反哺动作格式约定**：

```markdown
- [ ] 更新 `cards/characters/ch-jiang-li.md`：把「表面身份」字段扩展为「三层身份」
- [ ] 新建 `cards/foreshadow/fs-orphan-letter.md`：埋第 50 章发现的信件伏笔
- [ ] 更新 `graph/tl-jiang-li-journey-graph.html`：补 `ch-su-ye` ↔ `fa-shenzhi-hui` 的暗示边
- [ ] 补素材：需要用户口述「孤儿院失踪事件」背后的第三层真相
```

**action_items 处理原则**：

- **逐条提案**：一条 action_item 单独出反哺提案，不批量静默执行
- **可回滚**：描述「改成什么」而非「删除什么」
- **可跳过**：用户可以跳过任何一条 action_item，AI 记录为 `skip`
- **完成后关闭**：全部处理完毕后，反思卡 `status` 可以从 `draft` 改为
  `closed`（同样走提案）

## 规则 10：通胀过滤器 gate

**背景**：素材是稀缺资源。不过滤的后果是素材库膨胀但产出效率不变，
写作选题时面对一堆同质化素材无从下手。过滤器给每个新素材一个明确
状态标签：「正式排期」或「练习稿」，两类都在库但只有一类进排期。

**触发时机**：

| 场景 | 是否触发 |
|---|---|
| 用户口述新素材 / 灵感 | ✅ 必须过 |
| 反思卡反哺回来的新素材 | ✅ 必须过 |
| 用户明确说「这个先当练习稿」 | ❌ 跳过（用户已判定） |
| 更新已有卡片 | ❌ 不过（不是新素材） |
| 用户说「nc-过滤 一下」 | ✅ 手动触发 |

**三问**：

| 问题 | 判定要点 |
|---|---|
| Q1. 公共领域性 | 这个题材是否是公共领域人人都能讨论的？是 → 需靠角度差异化；否 → 自带排他性 |
| Q2. 三个月复刻性 | 如果我不做，三个月后会不会有别人用同样角度做出来？是 → 角度不新鲜；否 → 稀缺 |
| Q3. 独家洞察 | 我的角度里有没有只有我知道、只有我能提供的特殊经验或洞察？ |

**判定矩阵**：

| Q1 | Q2 | Q3 | 判定 | 去向 |
|---|---|---|---|---|
| 是 | 是 | 否 | ❌ 练习稿 | `drafts/practice/` |
| 是 | 是 | 是 | ⚠️ 需强化独家洞察 | 用户决定 |
| 是 | 否 | 是 | ✅ 可排期 | 素材池 |
| 否 | 是 | 否 | ⚠️ 门槛题材但无洞察 | 补洞察再评估 |
| 否 | 是 | 是 | ✅ 可排期 | 素材池 |
| 否 | 否 | 是 | ✅ 强推荐 | 优先排期 |
| 否 | 否 | 否 | ⚠️ 门槛在但无洞察 | 补洞察 |
| **任意** | **任意** | **否** | ❌ **练习稿**（Q3 是否决项） | `drafts/practice/` |

**Q3 是否决项**：没有独家洞察的素材，无论题材多小众、多稀缺，都只能是
练习稿。因为写作最终比拼的是「你能提供的独家价值」，而不是「题材本身」。

**什么不算独家洞察**（避免自我欺骗）：

- 「我比别人更努力」— 努力不产生独家性
- 「我文笔更好」— 技法可训练，不构成护城河
- 「这个题材我很喜欢」— 喜好不等于稀缺
- 「我知道一些别人不知道的事」但无出处、无验证 — 需要具体证据

**输出格式（提案，不落盘）**：

```
【通胀过滤器提案】素材：<摘要>

Q1 公共领域性：<是/否> — <一句话理由>
Q2 三个月复刻性：<是/否> — <一句话理由>
Q3 独家洞察：<有/无> — <一句话理由，若有需指出独家洞察形态>

判定：<练习稿 / 需强化 / 可排期 / 强推荐>
去向：<drafts/practice/ 或 素材池>

请确认：
(1) 同意此判定
(2) 补充独家洞察后重新评估
(3) 覆盖判定（用户强制排期，AI 需记录理由）
```

**用户覆盖判定**：过滤器是辅助不是决策，用户可覆盖。覆盖时 AI 需在
练习稿文件顶部记录覆盖理由（三行以内），便于日后复盘。

## 违规响应模板

当 AI 检测到用户提供的卡片不符合硬规则时，**必须**：

1. **不直接修改**用户提供的原文
2. **在对话中指出违规点**，引用具体规则编号
3. **给出修正后的完整提案**，让用户对比决策

示例：

```
检测到违规：
- 规则 3：这是 `type: foreshadow` 卡片，缺少 `payoff_chapter`，
  也未标注 `status: unresolved`。合法组合有两种：
  a) 补 `status: unresolved`（若伏笔尚未回收）
  b) 补 `payoff_chapter: chapter-XX`（若已知回收章节）

建议提案（假设选 a）：
<完整卡片 Markdown>
```
