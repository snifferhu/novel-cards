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
    scenes/       foreshadow/   relationships/
    factions/     snapshots/    darklayer/
  manuscript/
```

每个目录都有一个 `.gitkeep`，空目录也可被 git 追踪。

**注意**：`.gitkeep` 是占位文件，不影响 skill 读取。你可以：
- 保留（推荐，便于未来清理时看到"这里曾是空目录"）
- 删除（不影响功能，因为已存在的空目录 skill 也能读）

---

## 3. 触发 skill：说什么话

`SKILL.md` 的 `description` 决定了触发时机。以下说法**都会**激活 skill：

### 明确触发（推荐）

```
「用 novel-cards 帮我维护一下人物卡」
「我要走提案制」
「新增/更新人物卡」
「整理一下这一章出现的道具」
「埋个伏笔」/「回收一下这个伏笔」
「梳理一下姜璃和苏叶的关系」
```

### 隐式触发（可能命中）

```
「帮我把这一章拆一下结构」
「画一张势力关系图」
「这条暗线准备怎么收」
```

**未命中时的兜底**：直接说 `加载 novel-cards skill`。

---

## 4. 完整工作流（一次交互的全流程）

以"新增人物卡"为例：

```
用户：帮我给姜璃建一张人物卡，她是主角，在 chapter-003 首次出场，
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
    - 与 ch-su-ye 是师徒，见 rel-shi-tu
    ```
```

**用户三种响应**：

| 响应 | AI 后续动作 |
|---|---|
| `确认` / `OK` / `保存` | 用户手动复制代码块到编辑器并保存 |
| `role 改成 deuteragonist` | AI 重新出提案（仅修改该字段） |
| `不要` / `pass` | AI 记录被拒，不再重提 |

---

## 5. 九类卡：每类的典型提示语

| 卡片 | 提示语示例 | 输出位置 |
|---|---|---|
| 人物 | 「为 ch-jiang-li 建卡」 | `cards/characters/ch-jiang-li.md` |
| 桥段 | 「chapter-012 是重要桥段，帮我建 pp 卡」 | `cards/plotpoints/pp-moonlit-trial.md` |
| 道具 | 「记录那把青铜钥匙」 | `cards/items/it-bronze-key.md` |
| 场景 | 「月光审判台」 | `cards/scenes/sc-moonlit-arena.md` |
| 伏笔 | 「埋个伏笔：孤儿院信件的下落」 | `cards/foreshadow/fs-orphan-letter.md` |
| 关系 | 「梳理姜璃和苏叶的师徒关系」 | `cards/relationships/rel-shi-tu-jiang-su.md` |
| 势力 | 「神智会的势力卡」 | `cards/factions/fa-shenzhi-hui.md` |
| 快照 | 「chapter-050 状态快照」 | `cards/snapshots/sn-chapter-050.md` |
| 暗线 | 「母亲的舌头这条暗线」 | `cards/darklayer/dk-mother-tongue.md` |

---

## 6. 提案制铁律：AI 会做什么、不会做什么

**AI 会做**：
- 读你的 `cards/` 与 `manuscript/`
- 出**完整** Markdown 提案（含 frontmatter + 正文）
- 在提案前说明**建议保存路径**
- 校验硬规则（伏笔合法组合 / 暗线命名空间 / 五字段）
- 检测到你提供的卡不合规时，**指出违规点**并给出修正提案

**AI 不会做**：
- 直接 `edit` / `write` 你工程里的卡片文件
- 修改你的 `AGENTS.md` / `CLAUDE.md` / `.gitignore`
- 创建 `cards/` 与 `manuscript/` 之外的目录
- 使用绝对路径或 `$HOME`

如果你发现 AI 有上述行为，**说明 skill 版本错误或触发到了错误 skill**，
请 `./install.sh --link` 重新软链并检查。

---

## 7. 硬规则速查

```
1. 不直接落盘 —— 只出提案
2. 伏笔合法 —— 有 payoff_chapter 或 status: unresolved
3. 暗线隔离 —— cards/darklayer/，dk- 前缀，references_to_main 单向引用
4. 五字段必备 —— id / type / status / created / updated
5. frontmatter 三键 —— name / description / license（skill 自身约束）
```

完整规则与违规响应模板见 `references/hard-rules.md`。

---

## 8. 批量操作场景

### 一次处理一整章

```
用户：读 chapter-020，把所有新出场的人物、道具、场景列出来出卡，
     伏笔单独提出，我逐条确认。
```

AI 会**分批次**出提案，每批 1–3 张卡；不会一次性倾倒 20 张。

### 一次性梳理关系

```
用户：把 ch-jiang-li 目前的所有关系整理成 rel- 卡提案
```

AI 会先扫描已有 rel- 卡，判断哪些需要新建、哪些需要更新 `arcs`。

### 时间线快照

```
用户：chapter-050 是个分水岭，做一张 snapshot，标记势力格局变化
```

AI 会引用已 arch 的所有 faction 卡与关键 plotpoint 卡。

---

## 9. 常见问题

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
# 缺任一必备字段的卡片
grep -rLE '^(id|type|status|created|updated):' cards/ --include='*.md'
```

### Q7：我能用本 skill 编辑小说正文吗？

不能。本 skill 的边界是"卡片体系"，正文编辑不在其职责范围内。
`manuscript/` 目录只是被读取作为上下文，AI 不会主动改。

---

## 10. 故障回滚

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
rm -rf ~/my-novel/cards ~/my-novel/manuscript
# 或精细删除空目录
find ~/my-novel/cards -name '.gitkeep' -delete
```

---

## 11. 术语对照

| 术语 | 中文 | 含义 |
|---|---|---|
| skill | 技能 | OpenCode / Claude Code 的可加载行为定义 |
| frontmatter | 前置元数据 | Markdown 文件头部 YAML 块 |
| proposal | 提案 | AI 输出、等用户确认后再落盘的完整卡片 Markdown |
| consumer project | 使用方工程 | 加载本 skill 的小说仓库 |
| dark layer | 暗线 | 读者不可见的真相层，独立命名空间 |
| payoff | 伏笔回收 | 之前埋下的线索在后续章节得到呼应 |
| canonical | 权威 | 主书人物链（与暗线对应） |
