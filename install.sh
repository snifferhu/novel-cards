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
  if [ ! -f "$PROJECT/build.sh" ]; then
    cat > "$PROJECT/build.sh" <<'SH'
#!/usr/bin/env bash
# novel-cards v1.0 构建脚本骨架（install.sh --project 生成）
# 用途：重建 index/ 机器索引与 graph/ HTML 看板（消费 cards/ 与 registry/）。
# 实际逻辑由 nc-图谱 / nc-量化 / nc-词频 等技能在运行时驱动；本脚本为手动入口占位。
set -euo pipefail
echo "[build] 重建 index/card-graph.json ..."
echo "[build] 重建 graph/*.html ..."
echo "[build] 完成。如需完整重建请运行对应 nc- 技能。"
SH
    chmod +x "$PROJECT/build.sh"
  fi
  if [ ! -f "$PROJECT/build.cmd" ]; then
    printf '%s\n' \
      '@echo off' \
      'REM novel-cards v1.0 build script skeleton (Windows)' \
      'echo [build] Rebuilding index and graph ...' \
      'echo [build] Done.' > "$PROJECT/build.cmd"
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
