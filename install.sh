#!/usr/bin/env bash
# novel-cards install script
#
# 一键落地四步（从获取到第一张卡）：
#   1. 获取来源（二选一）：
#        - git clone https://github.com/snifferhu/novel-cards.git   # 持续开发跟更，推荐
#        - 下载 release tarball（GitHub 仓库页 Releases → Source code (tar.gz)；
#          若尚无 tag 则取最新 commit 的归档）。归档包是一次性快照，升级需重新下载。
#   2. 放置约定：本脚本以自身所在目录为源码根（SRC），克隆 / 解压目录可放任意位置，
#        无需安装到特定系统路径。注意：--link 软链模式要求源目录长期保留（删除即断链）；
#        copy 模式复制独立副本后不再依赖源目录。
#   3. 安装 skill 到 agent（copy vs link × 双端）：见下方 Modes / Examples。
#   4. 落地使用方工程：./install.sh --project <path> 生成空骨架 → 进入该目录跑
#        nc-初始化 交互式补全 → 第一条 nc-角色 / nc-桥段 指令建出第一张卡。
#        装完自检：在 agent 的 skills 面板确认 novel-cards 可见且描述正确。
#
# Usage:
#   ./install.sh [--target opencode|claude|both] [--link] [--project <path>]
#
# Modes:
#   --target opencode   Install to ~/.config/opencode/skills/novel-cards/
#   --target claude     Install to ~/.claude/skills/novel-cards/
#   --target both       Install to both (default)
#   --link              Use symlinks instead of copying (dev mode; source dir must persist)
#   --project <path>    Initialize consumer project skeleton at <path>
#
# Examples:
#   ./install.sh                          # Install to both, copy mode
#   ./install.sh --target opencode        # OpenCode global only
#   ./install.sh --link                   # Dev: symlink to repo root
#   ./install.sh --project ~/my-novel     # Init consumer skeleton

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="both"
MODE="copy"
PROJECT=""

usage() {
  sed -n '2,31p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"; shift 2 ;;
    --link)
      MODE="link"; shift ;;
    --project)
      PROJECT="$2"; shift 2 ;;
    -h|--help)
      usage ;;
    *)
      echo "Unknown option: $1" >&2
      usage ;;
  esac
done

 # --- Consumer project initialization ---
if [[ -n "$PROJECT" ]]; then
  echo "Initializing consumer project skeleton at: $PROJECT"

  # 存量检测：目标目录已有 config/project.yaml 或 cards/ 下存在 .md 时，提示先跑 nc-初始化
  # 生成迁移规划表再归位。仅打印提示，不改变下方幂等建骨架行为（绿地工程零提示）。
  _legacy_cfg=0; _legacy_cards=0
  [ -f "$PROJECT/config/project.yaml" ] && _legacy_cfg=1
  if [ -d "$PROJECT/cards" ] && find "$PROJECT/cards" -name '*.md' -print -quit 2>/dev/null | grep -q .; then
    _legacy_cards=1
  fi
  if [ "$_legacy_cfg" = 1 ] || [ "$_legacy_cards" = 1 ]; then
    echo "⚠️  检测到存量内容（config/project.yaml 或 cards/*.md），建议先运行 nc-初始化 生成迁移规划表再归位；本脚本仅补齐缺失目录，不覆盖已有文件。"
  fi

  # v1.0 完整目录树（与 references/layout.md 及 specs/consumer-project-layout 一致）
  mkdir -p \
    "$PROJECT/config" \
    "$PROJECT/registry" \
    "$PROJECT/index" \
    "$PROJECT/templates" \
    "$PROJECT/tools" \
    "$PROJECT/res/inbox" \
    "$PROJECT/cards/characters" \
    "$PROJECT/cards/plotpoints" \
    "$PROJECT/cards/items" \
    "$PROJECT/cards/scenes" \
    "$PROJECT/cards/foreshadow" \
    "$PROJECT/cards/timeline" \
    "$PROJECT/cards/factions" \
    "$PROJECT/cards/snapshots" \
    "$PROJECT/cards/darklayer" \
    "$PROJECT/cards/modules" \
    "$PROJECT/cards/lexstats" \
    "$PROJECT/cards/corpus" \
    "$PROJECT/cards/metrics" \
    "$PROJECT/cards/pose-bank" \
    "$PROJECT/cards/tendencies" \
    "$PROJECT/cards/custom/sensory_cue" \
    "$PROJECT/cards/custom/refwork" \
    "$PROJECT/reflections" \
    "$PROJECT/manuscript" \
    "$PROJECT/graph" \
    "$PROJECT/export" \
    "$PROJECT/release" \
    "$PROJECT/history" \
    "$PROJECT/drafts/practice" \
    "$PROJECT/works"

  # .gitkeep：仅当不存在时写入（幂等，不覆盖已有文件）
  for d in \
    "$PROJECT/config" \
    "$PROJECT/registry" \
    "$PROJECT/index" \
    "$PROJECT/templates" \
    "$PROJECT/tools" \
    "$PROJECT/res/inbox" \
    "$PROJECT/cards/characters" \
    "$PROJECT/cards/plotpoints" \
    "$PROJECT/cards/items" \
    "$PROJECT/cards/scenes" \
    "$PROJECT/cards/foreshadow" \
    "$PROJECT/cards/timeline" \
    "$PROJECT/cards/factions" \
    "$PROJECT/cards/snapshots" \
    "$PROJECT/cards/darklayer" \
    "$PROJECT/cards/modules" \
    "$PROJECT/cards/lexstats" \
    "$PROJECT/cards/corpus" \
    "$PROJECT/cards/metrics" \
    "$PROJECT/cards/pose-bank" \
    "$PROJECT/cards/tendencies" \
    "$PROJECT/cards/custom/sensory_cue" \
    "$PROJECT/cards/custom/refwork" \
    "$PROJECT/reflections" \
    "$PROJECT/manuscript" \
    "$PROJECT/graph" \
    "$PROJECT/export" \
    "$PROJECT/release" \
    "$PROJECT/history" \
    "$PROJECT/drafts/practice" \
    "$PROJECT/works"; do
    [ -e "$d/.gitkeep" ] || touch "$d/.gitkeep"
  done

  # tools/nc_validate.py：轻量只读校验器分发到使用方工程根（幂等，重复执行零变更）。
  # 本 skill 的 tools/ 为可选运行时——缺失时 skill 降级为纸面校验约定。
  if [ -f "$SRC/tools/nc_validate.py" ]; then
    if [ ! -f "$PROJECT/tools/nc_validate.py" ]; then
      cp "$SRC/tools/nc_validate.py" "$PROJECT/tools/nc_validate.py"
      chmod +x "$PROJECT/tools/nc_validate.py"
    fi
  fi

  # config/project.yaml：默认占位（仅当不存在时写入；nc-初始化 会交互式覆写）
  if [ ! -f "$PROJECT/config/project.yaml" ]; then
    cat > "$PROJECT/config/project.yaml" <<'YAML'
# novel-cards v1.0 工程配置（install.sh --project 生成的默认占位）
# nc-初始化 会根据作者选择交互式覆写本文件。
lang: zh          # zh | en
mode: short       # short | mid | long（长短篇预设，详见 registry/work-length-config.yaml）
# 双模式剖面开关（可选；缺省 = 隐式 simple，存量工程行为不变，不报错）：
# world_base_profile: simple    # simple | deep —— 全局校验松紧度唯一来源（simple 只拦 L1 硬错 / deep 全链路严格校验）
# profile_override 不在此处声明：单卡片局部覆写走各卡 frontmatter 的 profile_override 字段（仅作用于该卡及其直接关联资产）
# 子模块校验开关（auto_enable_map 按 world_base_profile 自动联动；显式覆盖值优先于联动结果）：
# check_visual_focus: false     # 视觉焦点校验（simple 档仅拦失明硬错 / deep 档完整权重验算）
# check_vestibular: false       # 前庭觉（平衡/眩晕/失重）校验
# check_interoception: false    # 内感受（饥饿/疼痛/体温/心跳）校验
# check_hormone_mutex: false    # 激素互斥组合合理性校验
# check_perception_defect: false  # 感知缺陷精细校验
# check_space_physics: false    # 空间物理（包围盒/位移/穿墙）校验
pipeline_option:
  enable_review: false        # 是否启用审稿分支（nc-校阅 + nc-节奏）
  enable_finalize: false      # 是否启用定稿分支（nc-定稿）
  enable_safety_guard: true   # 是否启用合规守卫（nc-守卫）
# 多本作品工作区（可选）：缺省 = 隐式单本工程（唯一 work-id = 工程根），行为与引入前一致。
# 经 nc-初始化 --new-work 追加新书时填充；每元素含 id/title/mode/lang/default_pen_name/tree_id_root。
# works:
#   - id: book-a
#     title: <书名>
#     mode: short            # 可覆写工程默认 mode
#     lang: zh
#     default_pen_name: pen-xxx   # 指向 registry/pen-names.yaml 的笔名 key（可选，须经 nc-注册）
#     tree_id_root: tree-book-a   # 该书图森林子树根标记
# active_work: book-a       # 当前默认书指针（--work 缺省时解析到此；多书无指针时技能会提示显式指定）
YAML
  fi

  # registry/pen-names.yaml 笔名白名单骨架（零预置条目，经 nc-注册 填充；仅当不存在时写入）
  if [ ! -f "$PROJECT/registry/pen-names.yaml" ]; then
    cat > "$PROJECT/registry/pen-names.yaml" <<'YAML'
# novel-cards v1.0 笔名白名单（install.sh --project 生成的空骨架）
# 多书署名用：每本作品在 config/project.yaml 的 works[].default_pen_name 引用此处的 key。
# 零预置条目——具体笔名经 nc-注册 写入（沿用「注册前置」硬规则，skill 不内置锁死词表）。
# 条目结构：key（全局唯一，供 default_pen_name / 章节 pen_name 覆写引用）/ display_name（落署名的显示名）/ note（备注，可选）。
# pen_names:
#   - key: pen-yexingke
#     display_name: 夜行客
#     note: 长篇玄幻用
YAML
  fi

  # config/review-rules.json 机器可读校阅规则库骨架（rule_set 给 2 条示例结构，完整 12 条经 nc-初始化 生成；仅当不存在时写入）
  if [ ! -f "$PROJECT/config/review-rules.json" ]; then
    cat > "$PROJECT/config/review-rules.json" <<'JSON'
{
  "spec_version": "1.0",
  "global_switch": {
    "world_base_profile": "simple",
    "check_visual_focus": false,
    "check_vestibular": false,
    "check_interoception": false,
    "check_hormone_mutex": false,
    "check_perception_defect": false,
    "check_space_physics": false
  },
  "auto_enable_map": {
    "simple": {
      "check_visual_focus": false,
      "check_vestibular": false,
      "check_interoception": false,
      "check_hormone_mutex": false,
      "check_perception_defect": false,
      "check_space_physics": false
    },
    "deep": {
      "check_visual_focus": true,
      "check_vestibular": true,
      "check_interoception": true,
      "check_hormone_mutex": true,
      "check_perception_defect": true,
      "check_space_physics": true
    }
  },
  "error_level": {
    "L1_HARD": "客观硬性冲突，必须修改，不可豁免",
    "L2_WARN": "合理性商榷，可填 override_note 豁免",
    "L3_INSPIRATION": "创作启发，非校验项"
  },
  "rule_set": [
    {
      "rule_id": "SENSE_001",
      "title": "感官通道权限校验",
      "level": "L1_HARD",
      "simple": "仅拦失明硬错（sensory_mask.sight: disabled 却写视觉描写）",
      "deep": "全七通道严格校验（sight/hearing/smell/taste/touch/vestibular/interoception）",
      "deps": ["actor.sensory_mask", "scene.env_note"]
    },
    {
      "rule_id": "SPACE_001",
      "title": "空间物理合理性校验",
      "level": "L1_HARD",
      "simple": "仅拦离谱穿墙/穿固体（penetrable: false 障碍被穿过）",
      "deep": "姿态包围盒 vs 场景净空 L1 推演 + 重心/平衡 L2 商榷（可 override_note 豁免）",
      "deps": ["scene.usable_clearance", "scene.mobility_constraint", "scene.obstacle_list", "actor.base_bounds", "actor.pose_bounding_map"]
    }
  ],
  "personality_baseline_pool": [],
  "personality_slide_axes": {
    "risk": {"range": [-10, 10], "semantic": "负=规避风险/正=冒险"},
    "empathy": {"range": [-10, 10], "semantic": "负=冷漠/正=高共情"},
    "impulse_control": {"range": [-10, 10], "semantic": "负=易冲动/正=克制"},
    "trust": {"range": [-10, 10], "semantic": "负=戒备/正=开放"},
    "desire_orient": {"range": [-10, 10], "semantic": "负=克制欲望/正=即时满足"},
    "aggression": {"range": [-10, 10], "semantic": "负=温和/正=好斗"}
  }
}
JSON
  fi

  # registry/tendency-prototypes.yaml 人格基线原型白名单骨架（零预置条目，经 nc-注册 填充；仅当不存在时写入）
  if [ ! -f "$PROJECT/registry/tendency-prototypes.yaml" ]; then
    cat > "$PROJECT/registry/tendency-prototypes.yaml" <<'YAML'
# novel-cards v1.0 人格基线原型白名单（install.sh --project 生成的空骨架）
# 动向卡 baseline_prototype 字段的取值白名单。零预置条目——具体原型经 nc-注册 写入
# （沿用「注册前置」硬规则，skill 不内置锁死词表）。
# v1.0 提供 16 个原型定义（爽文 6 + deep 10），完整六轴初始值 / prototype_note /
# 适用身份 / 避雷点见 skill 仓库 references/personality-prototypes.md。
# 条目结构：key（全局唯一）/ label（显示名）/ six_axes（六轴初始值 risk/empathy/
#   impulse_control/trust/desire_orient/aggression，取值 -10~+10）/ prototype_note
#   （滑动方向约束 + 适用身份 + 避雷点）/ boundary_hints[]（dimension_keywords →
#   constrained_direction + max_drift + note）。
# prototypes:
#   - key: steadfast
#     label: 坚忍型
#     six_axes: {risk: -2, empathy: 7, impulse_control: 7, trust: 4, desire_orient: 3, aggression: -2}
#     prototype_note: <滑动方向约束 + 适用身份 + 避雷点>
#     boundary_hints:
#       - dimension_keywords: [克制, 放荡]
#         constrained_direction: both
#         max_drift: 3
#         note: <提醒文案>
YAML
  fi

  # config/skills.yaml 占位：29 技能条目骨架（auto_invokable 默认值；仅当不存在时写入）
  if [ ! -f "$PROJECT/config/skills.yaml" ]; then
    cat > "$PROJECT/config/skills.yaml" <<'YAML'
# novel-cards v1.0 技能条目骨架（install.sh --project 生成的默认占位）
# nc-初始化 会根据作者选择交互式覆写本文件。
# auto_invokable: true = 可被其他技能在流程内部自动唤起；false = 仅作者主动触发。
# 仅 nc-metric / nc-graph / nc-rhythm 为 true，其余一律 user_trigger_only。
skills:
  # A. 工程初始化 & 素材资产
  nc-init:        { alias: nc-初始化,   group: A, auto_invokable: false }
  nc-material:    { alias: nc-素材,     group: A, auto_invokable: false }
  nc-clean:       { alias: nc-清洗,     group: A, auto_invokable: false }
  nc-query:       { alias: nc-检索,     group: A, auto_invokable: false }
  nc-reg:         { alias: nc-注册,     group: A, auto_invokable: false }
  nc-rename:      { alias: nc-更名,     group: A, auto_invokable: false }
  # B. 叙事卡片建模
  nc-role:        { alias: nc-角色,     group: B, auto_invokable: false }
  nc-pose:        { alias: nc-姿态,     group: B, auto_invokable: false }
  nc-item:        { alias: nc-道具,     group: B, auto_invokable: false }
  nc-scene:       { alias: nc-场景,     group: B, auto_invokable: false }
  nc-sensorycue:  { alias: nc-感官标记, group: B, auto_invokable: false }
  nc-tendency:    { alias: nc-动向,     group: B, auto_invokable: false }
  # C. 剧情结构
  nc-plot:        { alias: nc-桥段,     group: C, auto_invokable: false }
  nc-foreshadow:  { alias: nc-伏笔,     group: C, auto_invokable: false }
  nc-snapshot:    { alias: nc-快照,     group: C, auto_invokable: false }
  nc-faction:     { alias: nc-势力,     group: C, auto_invokable: false }
  nc-thread:      { alias: nc-暗线,     group: C, auto_invokable: false }
  nc-module:      { alias: nc-积木,     group: C, auto_invokable: false }
  nc-analyze:     { alias: nc-研判,     group: C, auto_invokable: false }
  nc-compose:     { alias: nc-编排,     group: C, auto_invokable: false }
  # D. 生成与可视化
  nc-metric:      { alias: nc-量化,     group: D, auto_invokable: true }
  nc-graph:       { alias: nc-图谱,     group: D, auto_invokable: true }
  nc-draft:       { alias: nc-成稿,     group: D, auto_invokable: false }
  nc-wordfreq:    { alias: nc-词频,     group: D, auto_invokable: false }
  # E. 审计校验
  nc-review:      { alias: nc-校阅,     group: E, auto_invokable: false }
  nc-rhythm:      { alias: nc-节奏,     group: E, auto_invokable: true }
  nc-safetyguard: { alias: nc-守卫,     group: E, auto_invokable: false }
  # F. 归档导出 & 复盘
  nc-finalize:    { alias: nc-定稿,     group: F, auto_invokable: false }
  nc-export:      { alias: nc-导出,     group: F, auto_invokable: false }
  nc-retrospect:  { alias: nc-复盘,     group: F, auto_invokable: false }
  # 分析模式专用（不计入六组 29 技能分类）
  nc-refwork:     { alias: nc-对标,     group: analysis, auto_invokable: false }
YAML
  fi

  # quickstart.md 兜底：仅当不存在时写入（完整版由 nc-初始化 按 --lang 生成）
  if [ ! -f "$PROJECT/quickstart.md" ]; then
    cat > "$PROJECT/quickstart.md" <<'MD'
# quickstart.md（novel-cards v1.0 兜底新手主线）

> 本文件为 `install.sh --project` 生成的最小兜底版本。
> 推荐运行 `nc-初始化`（skill 指令）以生成交互式完整版（含主线六步 + 进阶扩展分组）。

## 主线六步（最小闭环）

1. `nc-素材` 收纳入手素材 → 2. `nc-角色`/`nc-道具`/`nc-场景`/`nc-桥段` 建核心卡
→ 3.（可选）`nc-积木` 绑模块 → 4. `nc-成稿 --length short/mid/long` 出初稿
→ 5. `nc-校阅`（内置 `nc-节奏`）校阅调整 → 6. `nc-复盘` 沉淀经验回流素材库。

> **提案制**：每一步 AI 只输出完整 Markdown 提案到对话，你确认后自行落盘；AI 绝不直接写卡。

完整 29 技能清单见 `skill-reference.md`；Agent 行为契约见 `agents.md`。
MD
  fi

  # skill-reference.md 兜底：仅当不存在时写入（完整版由 nc-初始化 按 --lang 生成）
  if [ ! -f "$PROJECT/skill-reference.md" ]; then
    cat > "$PROJECT/skill-reference.md" <<'MD'
# skill-reference.md（novel-cards v1.0 兜底技能备查总表）

> 本文件为 `install.sh --project` 生成的最小兜底版本。
> 推荐运行 `nc-初始化`（skill 指令）以生成交互式完整版（含 29 技能全量总表 + auto_invokable 列 + 每技能入参/产物）。

## 六组技能（29 技能）

- **A. 工程初始化 & 素材资产**：nc-初始化 / nc-素材 / nc-清洗 / nc-检索 / nc-注册 / nc-更名
- **B. 叙事卡片建模**：nc-角色 / nc-姿态 / nc-道具 / nc-场景 / nc-感官标记 / nc-动向
- **C. 剧情结构**：nc-桥段 / nc-伏笔 / nc-快照 / nc-势力 / nc-暗线 / nc-积木 / nc-研判 / nc-编排
- **D. 生成与可视化**：nc-量化 / nc-图谱 / nc-成稿 / nc-词频
- **E. 审计校验**：nc-校阅 / nc-节奏 / nc-守卫
- **F. 归档导出 & 复盘**：nc-定稿 / nc-导出 / nc-复盘

> auto_invokable 仅 nc-量化 / nc-图谱 / nc-节奏 为 true，底层配置见 `config/skills.yaml`。
> 新手主线见 `quickstart.md`；Agent 行为契约见 `agents.md`。
MD
  fi

  # agents.md 兜底：仅当不存在时写入（完整版由 nc-初始化 按 --lang 生成）
  if [ ! -f "$PROJECT/agents.md" ]; then
    cat > "$PROJECT/agents.md" <<'MD'
# agents.md（novel-cards v1.0 兜底引导）

> 本文件为 `install.sh --project` 生成的最小兜底版本。
> 推荐运行 `nc-初始化`（skill 指令）以生成交互式完整版（含意图匹配表、技能速览、双语支持）。

## 身份

你是本工程的小说卡片创作助手，遵循 novel-cards skill 的提案制工作流。

## 铁律

1. 所有回写一律输出 Markdown 完整草案，用户确认后由用户落盘；AI 不直接写卡。
2. 四层数据分层：`.md` 业务源头 / `.json` 图森林真值 / `.yaml` 配置白名单 / `.html` 展示投影。
3. 审计类技能（nc-校阅 / nc-节奏 / nc-守卫）只出意见，绝不自动改稿。
4. 新素材经 `nc-素材` 入库前自动过通胀过滤器三问，Q3（独家洞察）是否决项。
5. 研判/编排只出建议与计划，绝不静默改卡；更名先预览后替换，不动原始素材。

## 意图路由引导（最小占位）

作者零散输入时，Agent 按以下 9 类信号识别意图并推荐 skill（只推荐不执行，等作者确认）：

| # | 输入信号 | 意图 | 推荐 skill |
|---|---|---|---|
| 1 | 丢链接/聊天记录/论文 | 素材入库 | nc-素材 + nc-清洗 |
| 2 | 查角色/道具/伏笔 | 资产检索 | nc-检索 |
| 3 | 查 bug/OOC/空间冲突 | 逻辑校验 | nc-校阅 |
| 4 | 角色会怎么做/选 A 还是 B | 人物剧情推演 | nc-研判 |
| 5 | 大改/删段/调换顺序 | 批量剧情调整 | nc-编排 |
| 6 | 导出 word/pdf | 产物导出 | nc-导出 |
| 7 | 新角色/新场景/新道具 | 新建叙事卡片 | 手动建卡 + nc-校阅 |
| 8 | 新项目/重置模板 | 项目初始化 | nc-初始化 |
| 9 | 违规内容/敏感描写 | 合规筛查 | nc-守卫 |

**禁止行为**：无指令不改卡 / 不改正文 / 不动动向标尺 / 不自建目录。
**显式指令优先**：作者直接写 `nc-xxx` 时跳过意图识别，直接执行。

完整版含交互规则四步话术与详细意图匹配表，由 `nc-初始化` 生成。

## 当前模式

- mode: short（可在 `config/project.yaml` 改为 mid / long）
- lang: zh

## 技能速览（六组）

- **A. 工程初始化 & 素材资产**：nc-初始化 / nc-素材 / nc-清洗 / nc-检索 / nc-注册 / nc-更名
- **B. 叙事卡片建模**：nc-角色 / nc-姿态 / nc-道具 / nc-场景 / nc-感官标记 / nc-动向
- **C. 剧情结构**：nc-桥段 / nc-伏笔 / nc-快照 / nc-势力 / nc-暗线 / nc-积木 / nc-研判 / nc-编排
- **D. 生成与可视化**：nc-量化 / nc-图谱 / nc-成稿 / nc-词频
- **E. 审计校验**：nc-校阅 / nc-节奏 / nc-守卫
- **F. 归档导出 & 复盘**：nc-定稿 / nc-导出 / nc-复盘

完整说明见 skill 仓库 `references/skill-catalog.md`。
MD
  fi

  # build 脚本骨架（仅当不存在时写入）
  # 职责边界：只做备份/目录准备/历史快照归档/生成 export_request.json，不调 pandoc、不渲染文档
  # 真正的合并/转 docx/pdf 由 nc-导出 skill 承接（读取 export_request.json 执行渲染）
  if [ ! -f "$PROJECT/build.sh" ]; then
    cat > "$PROJECT/build.sh" <<'SH'
#!/usr/bin/env bash
# novel-cards v1.0 构建脚本骨架（install.sh --project 生成）
# 职责边界：① 创建 release/ 与 history/ 目录 ② 归档版本快照到 history/
#           ③ 生成 release/export_request.json ④ 提示调用 nc-导出 执行渲染
# MUST NOT：在脚本内实现 Markdown→PDF/Word 转换、不调用 pandoc、不依赖第三方库
# 渲染交给 nc-导出（读取 export_request.json 后执行 Pandoc 底层跨平台导出）
set -euo pipefail

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SNAP_CARDS="history/snapshot_${TIMESTAMP}_cards"
SNAP_META="history/snapshot_${TIMESTAMP}_meta"

echo "[build] 步骤 1/4：准备目录 ..."
mkdir -p release history

echo "[build] 步骤 2/4：归档版本快照到 history/ ..."
mkdir -p "$SNAP_CARDS" "$SNAP_META"
[ -d cards ] && cp -r cards/. "$SNAP_CARDS/" || true
for f in CHANGELOG.md latest.md README.md agents.md config/project.yaml; do
  [ -f "$f" ] && cp "$f" "$SNAP_META/" || true
done
[ -d index ] && cp -r index/. "$SNAP_META/index/" || true

echo "[build] 步骤 3/4：生成 release/export_request.json ..."
cat > release/export_request.json <<EOF
{
  "spec": "novel-cards-export-request",
  "version": "1.0",
  "timestamp": "${TIMESTAMP}",
  "formats": ["pdf"],
  "include_cards": true,
  "include_draft": true,
  "include_index": true
}
EOF

echo "[build] 步骤 4/4：完成。"
echo "[build] 产物：history/snapshot_${TIMESTAMP}_{cards,meta}/ + release/export_request.json"
echo "[build] 下一步：请调用 nc-导出 读取 export_request.json 执行渲染（Pandoc 底层，跨平台 PDF/Word）"
SH
    chmod +x "$PROJECT/build.sh"
  fi
  if [ ! -f "$PROJECT/build.cmd" ]; then
    cat > "$PROJECT/build.cmd" <<'CMD'
@echo off
REM novel-cards v1.0 build script skeleton (Windows)
REM 职责边界：只做备份/目录准备/历史快照归档/生成 export_request.json，不调 pandoc、不渲染文档
REM 真正的合并/转 docx/pdf 由 nc-导出 skill 承接（读取 export_request.json 执行渲染）
REM 渲染交给 nc-导出（读取 export_request.json 后执行 Pandoc 底层跨平台导出）
setlocal enabledelayedexpansion

REM 步骤 1/4：准备目录
if not exist release mkdir release
if not exist history mkdir history

REM 时间戳获取（Windows 用 wmic 或 for /f date /t，此处简化为固定格式）
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set DT=%%a
set TIMESTAMP=!DT:~0,8!_!DT:~8,6!
set SNAP_CARDS=history\snapshot_%TIMESTAMP%_cards
set SNAP_META=history\snapshot_%TIMESTAMP%_meta

REM 步骤 2/4：归档版本快照到 history/
if exist cards mkdir "%SNAP_CARDS%" 2>nul
if exist cards xcopy /E /I /Y cards "%SNAP_CARDS%\" >nul
mkdir "%SNAP_META%" 2>nul
for %%f in (CHANGELOG.md latest.md README.md agents.md) do (
  if exist %%f copy /Y %%f "%SNAP_META%\" >nul
)
if exist index xcopy /E /I /Y index "%SNAP_META%\index\" >nul

REM 步骤 3/4：生成 release/export_request.json
(
  echo {
  echo   "spec": "novel-cards-export-request",
  echo   "version": "1.0",
  echo   "timestamp": "%TIMESTAMP%",
  echo   "formats": ["pdf"],
  echo   "include_cards": true,
  echo   "include_draft": true,
  echo   "include_index": true
  echo }
) > release\export_request.json

REM 步骤 4/4：完成
echo [build] Done.
echo [build] Output: history\snapshot_%TIMESTAMP%_{cards,meta}\ + release\export_request.json
echo [build] Next: invoke nc-export to read export_request.json and render (Pandoc-based cross-platform PDF/Word)
endlocal
CMD
  fi

  # MIGRATION.md 占位（仅当不存在时写入；真实内容由使用方工程随版本迭代填充）
  if [ ! -f "$PROJECT/MIGRATION.md" ]; then
    cat > "$PROJECT/MIGRATION.md" <<'MD'
# MIGRATION.md（novel-cards v1.0 迁移指南占位）

> 本文件为 `install.sh --project` 生成的最小占位版本。
> 真实内容由使用方工程随版本迭代填充（每次升级追加改动点说明与操作路径）。

## 当前基线版本

**v1.0**（稳定正式版）

## 版本策略

| 档位 | 标记 | 策略 |
|---|---|---|
| 0.x | 实验版 | schema 可能变动，不保证向前兼容；建议升级前手动备份 `history/` + `cards/` |
| 1.x | 稳定正式版 | schema 变动优先做兼容层，重大改动才强制迁移；系统内置自动迁移转换 |

## 五条兼容原则

1. **字段新增**：旧卡片无需改动，缺失字段自动取默认值（向后兼容）
2. **字段改名/删除**：属破坏性变更，必须写迁移脚本或手动迁移步骤并在本文档置顶
3. **skill 中英别名**：一旦发布尽量永久保留，不随意废除
4. **规则 ID**（SPACE_001 / BEAT_001 等）：一旦定义永久不变，只修改规则逻辑
5. **profile_override**：全局/单卡片剖面切换机制作为底层基础能力保留不砍

## 升级判定四档

| 档位 | 判定条件 | 操作 |
|---|---|---|
| ✅ 非破坏性 | 仅新增卡片类型/规则/skill | 直接继续用旧卡，无需迁移 |
| ⚠️ 破坏性 | 字段重命名/结构重构/删除必填字段 | 提供迁移步骤（方案 A 自动 / 方案 B 手动） |
| 🧪 实验版 | 0.x → 下一 0.x | 建议升级前手动备份 `history/` + `cards/` |
| 🚀 稳定版 | 1.0+ 重大升级 | 系统内置自动迁移转换 |

## 回滚四步

1. 进入 `history/` 找升级前自动生成的快照目录（`snapshot_<YYYYMMDD_HHMMSS>_{cards,meta}`）
2. 将快照内 `cards` + `meta` 文件覆盖回项目根
3. 恢复 `config/project.yaml` 为升级前版本
4. 执行 `nc-检索` 抽查资产 ID 引用是否正常

## 废弃策略三档

| 档位 | 处理方式 |
|---|---|
| 废弃 skill | 保留别名，调用时输出「该 skill 已废弃，推荐使用 xx」提示，仍执行原逻辑（过渡期内） |
| 废弃标签/旧字段 | 校阅时输出 L3 提示，不抛 L1/L2 错误给过渡期 |
| 超过两个大版本的废弃字段 | 在下一个版本彻底移除 |

## 待填充区

<!-- 每次版本升级在此追加：版本号 / 日期 / 改动点清单 / 迁移步骤 / 验证命令 -->
MD
  fi

  # README / CHANGELOG / latest.md 占位（仅当不存在时写入）
  if [ ! -f "$PROJECT/README.md" ]; then
    cat > "$PROJECT/README.md" <<'MD'
# <你的小说工程>

本工程使用 **novel-cards** skill 维护卡片体系。

- 卡片：`cards/`（16+ 类结构化卡片）
- 正文：`manuscript/`
- 反思：`reflections/`
- 图谱：`graph/`（消费 `index/card-graph.json` 渲染）
- 配置：`config/project.yaml` + `registry/`
- 索引：`index/`（机器可读真值）

详细使用见 novel-cards skill 仓库 `USAGE.md`。
MD
  fi
  if [ ! -f "$PROJECT/CHANGELOG.md" ]; then
    printf '%s\n' \
      '# CHANGELOG' \
      '' \
      '> 由 nc-定稿 追加变更记录。' \
      '' > "$PROJECT/CHANGELOG.md"
  fi
  if [ ! -f "$PROJECT/latest.md" ]; then
    printf '%s\n' \
      '# latest.md（断点状态）' \
      '' \
      '> 由 nc-定稿 更新当前进度断点。' \
      '' > "$PROJECT/latest.md"
  fi

  echo "Done. Project skeleton created (v1.0 full directory tree, incl. works/ + registry/pen-names.yaml)."
  echo "Reminder: this skill does NOT write card / reflection / graph files —"
  echo "you must author them (with AI proposals)."
  echo ""
  echo "Next steps (落地到第一张卡):"
  echo "  1. cd $PROJECT && 运行 nc-初始化   # 交互式补全 agents.md + registry 默认值 + config"
  echo "  2. nc-角色 \"新建主角 …\"            # 第一条创作指令，建出第一张卡（提案制，你确认后落盘）"
  echo "  3. 同项目再开一本：nc-初始化 --new-work   # 在 works/<新work-id>/ 追加作品，不另起工程"
  echo "  4. 多书操作加 --work <work-id>；署名经 nc-注册 登记笔名后由 nc-导出 落款"
  exit 0
fi

# --- Skill installation ---
install_to() {
  local dest_dir="$1"
  local dest="$dest_dir/novel-cards"

  mkdir -p "$dest_dir"

  if [[ -L "$dest" ]]; then
    echo "Removing existing symlink: $dest"
    rm "$dest"
  elif [[ -d "$dest" ]]; then
    local bak="$dest.bak.$(date +%s)"
    echo "Existing installation at $dest — backing up to $bak"
    mv "$dest" "$bak"
  fi

  if [[ "$MODE" == "link" ]]; then
    ln -s "$SRC" "$dest"
    echo "Linked: $dest -> $SRC"
  else
    if command -v rsync >/dev/null 2>&1; then
      rsync -a \
        --exclude '.git' \
        --exclude '.codegraph' \
        --exclude '.omo' \
        --exclude 'node_modules' \
        --exclude '.gitignore' \
        "$SRC/" "$dest/"
    else
      # fallback: cp with exclusions
      mkdir -p "$dest"
      cp -R "$SRC"/SKILL.md "$SRC"/references "$SRC"/templates "$SRC"/LICENSE "$SRC"/AGENTS.md "$dest/" 2>/dev/null || true
      [ -f "$SRC"/README.md ] && cp "$SRC"/README.md "$dest/"
      [ -f "$SRC"/USAGE.md ] && cp "$SRC"/USAGE.md "$dest/"
      [ -f "$SRC"/install.sh ] && cp "$SRC"/install.sh "$dest/"
    fi
    echo "Copied: $dest"
  fi
}

case "$TARGET" in
  opencode)
    install_to "$HOME/.config/opencode/skills"
    ;;
  claude)
    install_to "$HOME/.claude/skills"
    ;;
  both)
    install_to "$HOME/.config/opencode/skills"
    install_to "$HOME/.claude/skills"
    ;;
  *)
    echo "Invalid --target: $TARGET (expected opencode | claude | both)" >&2
    exit 1
    ;;
esac

echo ""
echo "Installation complete. Mode: $MODE | Target: $TARGET"
echo ""
echo "Verify:"
echo "  ls -la \$HOME/.config/opencode/skills/novel-cards/   # if target includes opencode"
echo "  ls -la \$HOME/.claude/skills/novel-cards/            # if target includes claude"
echo ""
echo "To use with a consumer project:"
echo "  $0 --project /path/to/your/novel"
