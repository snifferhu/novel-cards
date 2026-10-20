# 硬规则（hard-rules.md）

novel-cards skill 的所有行为准则集中于此。规则分为**不可变硬规则**（AI 必须遵守）
与**提案-确认流程**（AI 与用户交互的形态）。

## 规则一览

| # | 规则 | 强度 |
|---|---|---|
| 1 | AI 绝不直接 `edit` / `write` 使用方工程的卡片文件 | 硬性 |
| 2 | AI 回写卡片一律以**完整 Markdown 提案**输出到对话，等用户确认后由用户落盘 | 硬性 |
| 3 | 伏笔卡（`type: foreshadow`）必须关联 `payoff_chapter` **或** 显式标注 `status: unresolved`；二者皆缺视为非法 | 硬性 |
| 4 | 暗线卡（`type: darklayer`）使用独立命名空间（`cards/darklayer/`），不混入主书人物链；与主书人物的引用只通过显式字段 `references_to_main` 串接 | 硬性 |
| 5 | 所有卡片 frontmatter 至少含 `id` / `type` / `status` / `created` / `updated` 五字段 | 硬性 |
| 6 | 双端兼容：`SKILL.md` frontmatter 只允许 `name` / `description` / `license` 三键 | 硬性（针对 skill 本身，不是卡片） |

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
- ❌ "接下来我会创建 ..."（针对卡片文件）
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
# 列出缺少任一必备字段的卡片
grep -rLE '^(id|type|status|created|updated):' cards/ --include='*.md'
```

或按类型分目录检查：

```bash
for dir in cards/*/; do
  grep -rLE '^(id|type|status|created|updated):' "$dir" --include='*.md'
done
```

**空行处理**：`created` / `updated` 值为空应视为缺失。ISO 8601 建议格式：
`YYYY-MM-DD` 或 `YYYY-MM-DDTHH:MM:SSZ`。

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
