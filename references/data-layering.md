# 数据分层（data-layering.md）

novel-cards v1.0 的四层数据分层铁律（md / json / yaml / html）：各层的职责边界、
可读可写规则、`card-graph.json` 图森林标准 schema（节点 + 边 + tree_id）、registry
yaml 配置约定，以及 html 视图由 json 重生成的投影规则。

## 1. 四层数据分层铁律

> **面向对象透镜**：四层是同一批 `NcObject` 实例的四种存储投影——`.md` = 对象的可读
> 序列化（frontmatter 即公共属性 + 子类属性），`.json` = 对象间引用关系与数值的机器真值
> （`StoryWorld.objects` 的关系森林），`.yaml` = `StoryWorld.config` 的白名单，`.html` =
> `StoryWorld.export()` 的 graph 投影。OO 视角不改变任何层的职责边界与读写规则。完整类
> 层次见 `references/oo-model.md`。

| 文件类型 | 底层数据结构 | 主要位置 | 核心定位 | 能否改逻辑 |
|---|---|---|---|---|
| `.md` | 文档（内嵌 yaml frontmatter） | `cards/**`、`reflections`、`manuscript` | 【人类主编辑载体】卡片、积木、指标、反思、正文、摘抄 | ✅ 直接改，业务源头 |
| `.json` | 扁平数组 / 图（Graph/森林 Forest，节点+边） | `index/`、`graph/export` | 【机器索引、关系模型、数值索引】检索索引、卡片关系森林、metric 数值、词频向量 | ✅ 系统同步生成，优先经 nc- 指令改动 |
| `.yaml` | 配置树 | `registry/` | 注册表：类型、track、标签、动向人格基线原型白名单，偏静态配置 | ✅ 人工少量维护 |
| `.html` | 渲染视图（消费 json 图数据） | `graph/` | 可视化看板、关系图谱、时序图，纯展示层 | ❌ 不存业务逻辑；json 一变，html 重生成 |

### 同步规则

- **修改卡片后同步**：作者直接编辑某张 md 卡片后，下次执行相关 nc- 指令时，
  skill 检测 md 与 json 不一致并提案重新生成对应 `index/card-graph.json` 条目。
- **html 不存逻辑**：`index/card-graph.json` 更新后，`nc-图谱` 重新渲染
  `graph/*.html`，旧 html 被覆盖，html 文件中不含任何独立于 json 的业务数据。

## 2. card-graph.json 图森林 schema

`index/card-graph.json` SHALL 采用图森林结构：单一 JSON 文件内含多个互不连通的
子图（tree）。

### 节点（node）字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `id` | ✅ | 卡 id（含类型前缀，如 `ac-female-lead`） |
| `type` | ✅ | 卡类型（actor/timeline/module/foreshadow/lexstat 等） |
| `tree_id` | ✅ | 归属子图标记（单主线小说统一为 `main`；多对标作品各用独立 tree_id） |

### 边（edge）字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `source` | ✅ | 源节点 id |
| `target` | ✅ | 目标节点 id |
| `relation` | ✅ | 关系类型枚举，见下 |

### relation 枚举

| relation | 含义 |
|---|---|
| `bind_module` | timeline 节点绑定 module 积木 |
| `trigger` | module/桥段触发爆点或动线变更 |
| `cross_ref` | actor 与 item 互相引用（器灵觉醒） |
| `foreshadow_plant` | 伏笔埋点指向 |
| `foreshadow_payoff` | 伏笔回收指向 |
| `references_to_main` | 暗线单向引用主书卡 |
| `lexstat_bind` | 桥段绑定词频张力卡 |
| `pose_ref` | 桥段/快照引用姿态卡 |
| `tracks` | timeline 追踪对象（target） |

### 单图 vs 森林

- **单图**：全部卡片连通（单主线小说），所有节点 `tree_id: main`
- **森林**：多个互不连通的子图（多条独立动线/势力链/对标作品相互隔离），
  以不同 `tree_id` 标记，跨子图无边连接

### 最小 demo JSON（入场积木那套资产）

仅建了入场积木那套资产（`ac-female-lead`、`tl-hairstyle`、`md-action-entry`、
`fs-hairpin`、`lx-ch03`）时的 `card-graph.json`，呈现单 tree，节点间通过
`bind_module` / `trigger` / `foreshadow_plant` 边连通：

```json
{
  "version": "1.0",
  "trees": [
    {
      "tree_id": "main",
      "nodes": [
        {"id": "ac-female-lead", "type": "actor", "tree_id": "main"},
        {"id": "tl-hairstyle",   "type": "timeline", "tree_id": "main"},
        {"id": "md-action-entry","type": "module", "tree_id": "main"},
        {"id": "fs-hairpin",     "type": "foreshadow", "tree_id": "main"},
        {"id": "lx-ch03",        "type": "lexstat", "tree_id": "main"}
      ],
      "edges": [
        {"source": "tl-hairstyle", "target": "md-action-entry", "relation": "bind_module"},
        {"source": "md-action-entry", "target": "fs-hairpin", "relation": "foreshadow_plant"},
        {"source": "md-action-entry", "target": "lx-ch03", "relation": "trigger"},
        {"source": "tl-hairstyle", "target": "ac-female-lead", "relation": "tracks"}
      ]
    }
  ]
}
```

该示例可被任意 JSON 解析器解析。多作品对标场景下，`trees` 数组含多个子图对象，
分别以不同 `tree_id` 标记。

## 3. registry yaml 文件清单与结构约定

`registry/` 目录 SHALL 包含以下配置文件（偏静态配置，人工少量维护）：

| 文件 | 用途 |
|---|---|
| `work-length-config.yaml` | 长短篇模式（short/mid/long）与技能启用矩阵 |
| `work-setting.yaml` | pipeline_option 分支开关：`enable_review` / `enable_finalize` / `enable_safety_guard` |
| `safety-blacklist.yaml` | 守卫用强制合规禁区 + 作者自定义隐私禁区 |
| `types-registry.yaml` | 自定义卡片类型白名单（`nc-注册` 写入） |
| `tracks-registry.yaml` | 自定义动线 track 标签白名单（`nc-注册` 写入） |
| `tags-registry.yaml` | 语义标签白名单 |
| `burst-tags-registry.yaml` | 爆点标注白名单（strategic-burst / blank-transition 等） |
| `tendency-prototypes.yaml` | 动向卡人格基线原型白名单（`nc-注册` 写入，条目含 `boundary_hints`；骨架 only，零预置条目） |

**注册前置规则**：新增自定义卡片类型、动线标签或动向人格基线原型取值 MUST 先经
`nc-注册` 写入 registry 再建卡。例：作者需要一条「温度场」自定义感知动线 → 先执行 `nc-注册`
将 `temperature-field` 加入 track 白名单 registry，之后 timeline 卡才能使用该
track 值；刻画自恋型人格角色时 → 先经 `nc-注册` 登记原型（如 `npd-grandiose`
及其 `boundary_hints`），tend- 卡才能声明 `baseline_prototype: npd-grandiose`。

`work-setting.yaml` 结构示例：

```yaml
pipeline_option:
  enable_review: true      # 是否开启审稿（私人随笔/自娱直接 false 跳过）
  enable_finalize: true    # 是否开启定稿锁定（不发表就 false）
  enable_safety_guard: false  # 守卫默认关闭，需要时手动打开
```

## 4. index/ 产物清单

`index/` 目录 SHALL 包含（由 skill 指令驱动生成/更新）：

| 文件 | 用途 |
|---|---|
| `card-graph.json` | 图森林真值（节点+边+tree_id） |
| `metric-index.json` | 量化数值索引（mt- 卡同步） |
| `lex-batch.json` | 词频向量批量统计（lx- 卡同步） |
| 检索索引 | 素材/卡片资产的关键词+多维筛选索引 |
| query-cache | `nc-检索` 查询缓存 |

这些文件是后续批量统计分析（伏笔回收周期/爆点密度/五感信息释放节奏）与导出外部
工具（思维导图/时序/数据库）的数据源。例：统计全书伏笔回收周期分布 → skill 读取
`index/metric-index.json` + `index/card-graph.json` 中的 foreshadow 边计算，
不重新解析全部 md 文件。

## 5. html 重生成规则

- `graph/*.html` 是纯展示层，消费 `index/card-graph.json` 图数据渲染。
- **json 一变，html 重生成**：`nc-图谱` 检测到 `card-graph.json` 变更后重新渲染，
  旧 html 被覆盖。
- html 文件**不存业务逻辑**，不含任何独立于 json 的业务数据；可自由打开查看，
  不被视为卡片，无 frontmatter。
- 模板：`templates/relation-graph.html`（自包含 SVG，无外部依赖）。

## 6. 迁移与备份友好

整个使用方工程目录 MUST 可直接同步/备份/换机：md 可读、json 可解析、yaml 可校验，
资产不锁死在任何私有二进制格式。作者把整个工程目录复制到新机器，所有资产可用，
无需重新导入或转换格式。
