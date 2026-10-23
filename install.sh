#!/usr/bin/env bash
# novel-cards install script
#
# Usage:
#   ./install.sh [--target opencode|claude|both] [--link] [--project <path>]
#
# Modes:
#   --target opencode   Install to ~/.config/opencode/skills/novel-cards/
#   --target claude     Install to ~/.claude/skills/novel-cards/
#   --target both       Install to both (default)
#   --link              Use symlinks instead of copying (dev mode)
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
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
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
    "$PROJECT/drafts/practice"

  # .gitkeep：仅当不存在时写入（幂等，不覆盖已有文件）
  for d in \
    "$PROJECT/config" \
    "$PROJECT/registry" \
    "$PROJECT/index" \
    "$PROJECT/templates" \
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
    "$PROJECT/drafts/practice"; do
    [ -e "$d/.gitkeep" ] || touch "$d/.gitkeep"
  done

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

  echo "Done. Project skeleton created (v1.0 full directory tree)."
  echo "Reminder: this skill does NOT write card / reflection / graph files —"
  echo "you must author them (with AI proposals)."
  echo "For interactive init (agents.md + registry defaults), run: nc-初始化"
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
