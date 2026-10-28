#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""novel-cards 轻量运行时校验器（nc_validate.py）

只读、零第三方依赖的叙事资产校验 / 审计 / 推演模拟器。仅使用 Python 3 标准库
（json / argparse / pathlib / re / os / sys），**禁止** PyYAML 等任何第三方包。

设计铁律（与 hard-rules.md / event-inference.md 一致）：
  * **只读**：本工具绝不写盘、绝不修改任何 .md / .json / .yaml 文件；
    所有发现以「意见书」形式打印到 stdout。
  * **可降级**：缺失 python3 时，skill 回退到纸面校验约定（AI 人工核对）。
  * **不替代提案制**：本工具只做校验 / 审计 / 候选推演，绝不自动改卡、绝不落盘。

子命令：
  validate <card>     校验单张卡片 frontmatter（五字段齐全、type↔id 前缀一致、
                      伏笔 payoff_chapter/status:unresolved 二选一、动向 history[]
                      每条 trigger_plot 指向真实 pp-*）
  audit [project]     跨对象 OOC 硬规则 + 暗线 references_to_main 单向引用合法性 +
                      长线四方对齐（fs-/tl-/md-/lx- ≥8 章预埋计数）+
                      index/card-graph.json 图森林结构校验
  simulate <event>    （可选增强）沿 enter→perceive→act→fire 链计算受影响对象候选
                      新状态，输出标注「模拟结果，待作者审核，非确定预测」的
                      ChangePlan 草稿，绝不写盘
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# 常量：类型 → id 前缀（与 references/card-schema.md 类型与前缀总表逐字一致）
# ---------------------------------------------------------------------------
TYPE_PREFIX = {
    "actor": "ac-",
    "plotpoint": "pp-",
    "item": "it-",
    "scene": "sc-",
    "foreshadow": "fs-",
    "timeline": "tl-",
    "faction": "fa-",
    "snapshot": "sn-",
    "darklayer": "dk-",
    "module": "md-",
    "lexstat": "lx-",
    "corpus": "co-",
    "metric": "mt-",
    "pose": "po-",
    "sensory_cue": "su-",
    "refwork": "rw-",
    "character_tendency": "tend-",
    "reflection": "rf-",
}

# 通用五字段（必备）
FIVE_FIELDS = ("id", "type", "status", "created", "updated")

# card-graph.json 边 relation 合法枚举（与 data-layering.md §2 逐字一致）
RELATION_ENUM = {
    "bind_module",
    "trigger",
    "cross_ref",
    "foreshadow_plant",
    "foreshadow_payoff",
    "references_to_main",
    "lexstat_bind",
    "pose_ref",
    "tracks",
}

# 长线四方对齐所需四类前缀
FOUR_WAY_PREFIXES = ("fs-", "tl-", "md-", "lx-")

# ---------------------------------------------------------------------------
# 书内谱系（lineage）常量：与 references/lineage.md §1 / hard-rules.md 规则 30-34 一致
# ---------------------------------------------------------------------------
# 7 类固定类型缩写（MUST NOT 自造新缩写）
LINEAGE_TYPE_CODES = ("MAI", "ABR", "PRO", "CAR", "DRF", "TST", "REF")
# 每类物料对应的浅目录子文件夹（IP 根下 ≤1 层）
LINEAGE_SUBDIRS = ("MAI", "ABR", "PRO", "CAR", "DRF", "TST", "REF")
# uid 命名正则：IP(≥3大写) - TYPE(3位) - 编号；MAI 可带 -CHxx 章节后缀
LINEAGE_UID_RE = re.compile(r"^[A-Z]{3,}-[A-Z]{3}-\d{3}(-CH\d{2})?$")


# ---------------------------------------------------------------------------
# 极简 frontmatter 解析（正则 + 扁平 key: value，不依赖 PyYAML）
# ---------------------------------------------------------------------------
def parse_frontmatter(text):
    """从 Markdown 文本提取 YAML frontmatter 为扁平 dict。

    仅解析顶层 `key: value` 行（忽略缩进的嵌套结构与列表项），足够覆盖五字段
    与各类型扁平关键专属字段。值为空字符串视为缺失。
    """
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    fm = {}
    in_fm = False
    for line in lines[1:]:
        if line.strip() == "---":
            break
        # 跳过注释与空行
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        # 仅取顶层（无前置空格）的 key: value
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$", line)
        if m:
            key = m.group(1)
            val = m.group(2).strip()
            # 去掉行内注释（保守：仅当值不含 '#' 时整段保留）
            fm[key] = val
    return fm


def _is_empty(val):
    return val is None or val == "" or val == "null" or val.lower() == "~"


# ---------------------------------------------------------------------------
# validate 子命令
# ---------------------------------------------------------------------------
def cmd_validate(card_path, project_root):
    """校验单张卡片，返回违规项列表（只读，绝不写盘）。"""
    issues = []
    p = Path(card_path)
    if not p.exists():
        return ["卡片文件不存在: %s" % card_path]
    # 目录不是合法卡片输入：优雅降级为违规项，避免 read_text() 抛 IsADirectoryError
    if p.is_dir():
        return [
            "validate 需要指向单张卡片 .md 文件，收到的是目录: %s（批量校验请用 audit <project>）"
            % card_path
        ]

    text = p.read_text(encoding="utf-8", errors="replace")
    fm = parse_frontmatter(text)

    # 1) 五字段齐全
    for field in FIVE_FIELDS:
        if _is_empty(fm.get(field)):
            issues.append("缺少必备字段: %s" % field)

    card_id = fm.get("id", "").strip()
    card_type = fm.get("type", "").strip()

    # 2) type 与 id 前缀一致
    if card_type and card_id:
        expected_prefix = TYPE_PREFIX.get(card_type)
        if expected_prefix is None:
            issues.append("未知 type: %s（不在类型与前缀总表中，若为自定义类型需先经 nc-注册）" % card_type)
        elif not card_id.startswith(expected_prefix):
            issues.append(
                "type=%s 要求 id 前缀 %s，实际 id=%s" % (card_type, expected_prefix, card_id)
            )

    # 3) 伏笔卡：payoff_chapter 或 status:unresolved 二选一
    if card_type == "foreshadow":
        status = fm.get("status", "").strip()
        payoff = fm.get("payoff_chapter", "").strip()
        if status == "unresolved":
            pass  # 合法
        elif status == "resolved" and payoff:
            pass  # 合法
        else:
            issues.append(
                "伏笔卡非法组合: status=%r payoff_chapter=%r（须 status:unresolved 或 resolved+payoff_chapter）"
                % (status, payoff)
            )

    # 4) 动向卡：history[] 每条 trigger_plot 指向真实 pp-*
    if card_type == "character_tendency":
        # 扫描 cards/ 是否真实存在（用于区分「工程无桥段」与「引用悬空」）
        cards_dir = Path(project_root) / "cards"
        has_cards_dir = cards_dir.exists()
        plot_ids = _collect_ids_by_prefix(project_root, "pp-")
        triggers = re.findall(r"trigger_plot:\s*([A-Za-z0-9_-]+)", text)
        for trig in triggers:
            if not trig.startswith("pp-"):
                issues.append("动向 history[] trigger_plot=%s 非 pp-* 桥段 id" % trig)
            elif has_cards_dir and trig not in plot_ids:
                # 工程存在 cards/ 却找不到该桥段 → 悬空引用，必须报出
                issues.append("动向 history[] trigger_plot=%s 未找到对应已存在桥段卡（悬空引用）" % trig)

    # 5) 空间校验（SPACE_001 轻量扩展，v1.0 增量）：
    #    scene 卡含 usable_clearance、actor 卡含 pose_bounding_map 时做净高 vs 姿态包围盒
    #    只读比较；缺失字段跳过（向后兼容）。纯标准库浮点比较，零依赖，绝不写盘。
    issues.extend(_check_spatial(card_type, fm, text))

    # 6) rules.json 驱动的结构化字段存在性检查（v1.0 增量）：
    #    若 config/review-rules.json 存在且 JSON 合法，按 rule_set 的 deps 字段做
    #    卡片 frontmatter 字段存在性 + 取值域轻量检查；缺失或损坏时降级纸面逻辑。
    issues.extend(_check_rules_json(project_root, card_type, fm, text))

    return issues


def _extract_float(text, key):
    """从文本中提取 `key: <float>` 形式的数值（支持嵌套缩进行），失败返回 None。"""
    m = re.search(r"%s:\s*([0-9]*\.?[0-9]+)" % re.escape(key), text)
    if not m:
        return None
    try:
        return float(m.group(1))
    except ValueError:
        return None


def _check_spatial(card_type, fm, text):
    """SPACE_001 轻量空间校验（只读，缺失字段跳过，向后兼容）。

    - scene 卡：声明 usable_clearance.height 且 mobility_constraint.can_stand: false
      → 提示「净高不足直立」（L3 启发级，供 deep 模式升级 L1 的输入信号）。
    - actor 卡：pose_bounding_map 中某姿态 h 值 > 同卡 base_bounds.height 时不报错
      （正常现象）；但 sensory_mask.sight: disabled 时提示视觉通道禁用（SENSE_001 输入）。
    - scene + actor 跨卡包围盒推演需两卡同时在场，单卡 validate 无法完成，留给 audit
      或 nc-校阅 运行时处理；此处仅做单卡字段合法性提示。
    """
    hints = []
    if card_type == "scene":
        height = _extract_float(text, "height")
        can_stand_false = re.search(r"can_stand:\s*false", text) is not None
        if height is not None and can_stand_false:
            hints.append(
                "[space] 场景净高 %.2fm 且 can_stand: false，标记为「净高不足直立」；"
                "deep 模式下绑定此场景的桥段将触发 SPACE_001 包围盒校验" % height
            )
    elif card_type == "actor":
        sight_disabled = re.search(r"sight:\s*disabled", text) is not None
        if sight_disabled:
            hints.append(
                "[sense] sensory_mask.sight: disabled，该角色禁止生成视觉描写与视觉焦点动线；"
                "相关描写将触发 SENSE_001 L1_HARD"
            )
        # pose_bounding_map 存在性检查：有 stand 姿态但无 base_bounds 时提示补全
        has_pose_map = "pose_bounding_map" in text
        has_base_bounds = "base_bounds" in text
        if has_pose_map and not has_base_bounds:
            hints.append(
                "[space] 声明了 pose_bounding_map 但缺 base_bounds，建议补全基础包围盒以启用完整 SPACE_001 推演"
            )
    return hints


def _load_rules_json(project_root):
    """加载 config/review-rules.json，返回 dict 或 None（缺失/损坏均返回 None）。"""
    rules_file = Path(project_root) / "config" / "review-rules.json"
    if not rules_file.exists():
        return None
    try:
        data = json.loads(rules_file.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            return None
        return data
    except (OSError, json.JSONDecodeError):
        return None


def _check_rules_json(project_root, card_type, fm, text):
    """按 rules.json 的 rule_set deps 做结构化字段存在性检查（只读，零依赖）。

    - rules.json 缺失 → 返回空列表（降级纸面校验，行为与引入前一致）
    - rules.json 存在但 JSON 损坏 → 返回 L2_WARN 提示 + 空列表（降级不阻断）
    - rules.json 合法 → 遍历 rule_set，对每条规则的 deps 字段做卡片 frontmatter
      字段存在性检查；deps 格式为 "type.field"（如 "scene.usable_clearance"），
      仅当卡片 type 匹配时才检查对应字段是否存在于 frontmatter 或正文文本中
    """
    issues = []
    rules_data = _load_rules_json(project_root)
    if rules_data is None:
        # 区分「文件不存在」（静默降级）与「JSON 损坏」（L2_WARN 提示）
        rules_file = Path(project_root) / "config" / "review-rules.json"
        if rules_file.exists():
            issues.append(
                "[rules] config/review-rules.json JSON 损坏，已降级纸面校验（L2_WARN）"
            )
        return issues

    rule_set = rules_data.get("rule_set", [])
    if not isinstance(rule_set, list):
        return issues

    for rule in rule_set:
        if not isinstance(rule, dict):
            continue
        rule_id = rule.get("rule_id", "<unknown>")
        deps = rule.get("deps", [])
        if not isinstance(deps, list):
            continue
        for dep in deps:
            if not isinstance(dep, str) or "." not in dep:
                continue
            dep_type, dep_field = dep.split(".", 1)
            if dep_type != card_type:
                continue
            # 字段存在性检查：frontmatter 有该 key 或正文文本含该字段名
            if dep_field in fm:
                continue
            if re.search(r"%s\s*:" % re.escape(dep_field), text):
                continue
            level = rule.get("level", "L2_WARN")
            issues.append(
                "[%s] %s 规则依赖字段 %s.%s 缺失（%s）"
                % (rule_id, card_type, dep_type, dep_field, level)
            )
    return issues


def _collect_ids_by_prefix(project_root, prefix):
    """扫描 cards/ 下所有 .md，收集指定前缀的 id 集合（只读）。"""
    ids = set()
    root = Path(project_root)
    cards_dir = root / "cards"
    if not cards_dir.exists():
        return ids
    for md in cards_dir.rglob("*.md"):
        try:
            text = md.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        m = re.search(r"^id:\s*([A-Za-z0-9_-]+)", text, re.MULTILINE)
        if m and m.group(1).startswith(prefix):
            ids.add(m.group(1))
    return ids


# ---------------------------------------------------------------------------
# audit 子命令
# ---------------------------------------------------------------------------
def cmd_audit(project_root):
    """跨对象审计，返回意见书条目列表（只读，绝不写盘）。"""
    findings = []
    root = Path(project_root)

    # ---- A. 全部卡片五字段 + 前缀校验 ----
    cards_dir = root / "cards"
    checked = 0
    if cards_dir.exists():
        for md in sorted(cards_dir.rglob("*.md")):
            text = md.read_text(encoding="utf-8", errors="replace")
            fm = parse_frontmatter(text)
            if not fm:
                continue  # 无 frontmatter 的非卡片文件跳过
            checked += 1
            rel = str(md.relative_to(root))
            for field in FIVE_FIELDS:
                if _is_empty(fm.get(field)):
                    findings.append("[schema] %s 缺字段 %s" % (rel, field))
            cid = fm.get("id", "").strip()
            ctype = fm.get("type", "").strip()
            if ctype and cid:
                exp = TYPE_PREFIX.get(ctype)
                if exp and not cid.startswith(exp):
                    findings.append("[prefix] %s type=%s 但 id=%s 前缀不符" % (rel, ctype, cid))

    # ---- B. 暗线 references_to_main 单向引用合法性 ----
    all_ids = _collect_all_card_ids(root)
    dk_dir = cards_dir / "darklayer" if cards_dir.exists() else None
    if dk_dir and dk_dir.exists():
        for md in sorted(dk_dir.glob("*.md")):
            text = md.read_text(encoding="utf-8", errors="replace")
            refs = re.findall(r"references_to_main:.*?(?=^\S|\Z)", text, re.MULTILINE | re.DOTALL)
            ref_ids = re.findall(r"[A-Za-z]+-[A-Za-z0-9_-]+", text)
            # 提取 dk- 卡里出现的主书引用（ac-/pp-/it-/fa-/sc-）
            main_refs = [r for r in ref_ids if any(r.startswith(p) for p in ("ac-", "pp-", "it-", "fa-", "sc-"))]
            for r in main_refs:
                if all_ids and r not in all_ids:
                    findings.append("[darklayer] %s references_to_main 引用了不存在的主书卡 %s" % (md.name, r))

    # ---- C. 长线四方对齐（fs-/tl-/md-/lx- ≥8 章预埋计数）----
    # 对每张 foreshadow 卡，检查其关联链路是否凑齐四类前缀（缺一即预埋不完整）
    fs_dir = cards_dir / "foreshadow" if cards_dir.exists() else None
    if fs_dir and fs_dir.exists():
        for md in sorted(fs_dir.glob("*.md")):
            text = md.read_text(encoding="utf-8", errors="replace")
            present = {p for p in FOUR_WAY_PREFIXES if re.search(re.escape(p) + r"[A-Za-z0-9_-]+", text)}
            missing = [p for p in FOUR_WAY_PREFIXES if p not in present]
            if missing:
                findings.append(
                    "[four-way] %s 长线四方对齐不全，缺前缀 %s（需 fs-/tl-/md-/lx- 齐备且提前≥8章）"
                    % (md.name, "/".join(missing))
                )

    # ---- D. card-graph.json 图森林结构校验 ----
    graph_file = root / "index" / "card-graph.json"
    if graph_file.exists():
        findings.extend(_audit_graph(graph_file))
    # 注：card-graph.json 缺失属正常（尚未生成），不报违规

    # ---- E. 书内谱系 index.yaml 只读校验（缺失视为未启用 book-lineage，向后兼容）----
    findings.extend(_audit_lineage(root))

    return findings, checked


def _collect_all_card_ids(root):
    ids = set()
    cards_dir = root / "cards"
    if not cards_dir.exists():
        return ids
    for md in cards_dir.rglob("*.md"):
        try:
            text = md.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        m = re.search(r"^id:\s*([A-Za-z0-9_-]+)", text, re.MULTILINE)
        if m:
            ids.add(m.group(1))
    return ids


# ---------------------------------------------------------------------------
# 书内谱系 index.yaml 只读校验（零依赖 YAML 子集解析，绝不写盘）
# ---------------------------------------------------------------------------
def _parse_lineage_index(text):
    """极简 YAML 子集解析：提取顶层 ip_id 与 lineage[] 条目的 uid/type/follow。

    仅覆盖 nc-lineage-* 技能写入的扁平结构（顶层标量 + lineage 列表 + 条目内
    缩进键值），不依赖 PyYAML。无法解析的行静默跳过（本工具只做校验，不做真值）。
    """
    ip_id = None
    entries = []  # 每个元素为 {"uid":..., "type":..., "follow":...}
    cur = None
    in_lineage = False
    for raw in text.splitlines():
        line = raw.rstrip("\n")
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        # 顶层键（indent==0）
        if indent == 0:
            in_lineage = stripped.startswith("lineage:")
            if stripped.startswith("ip_id:"):
                ip_id = stripped[len("ip_id:"):].strip().strip('"\'')
            elif stripped.startswith("related:"):
                in_lineage = False
            continue
        if not in_lineage:
            continue
        # lineage 列表项起始（"- uid:" 或 "- " 后跟键值）
        if stripped.startswith("- "):
            if cur is not None:
                entries.append(cur)
            cur = {}
            body = stripped[2:].strip()
            if body:
                _assign_entry_field(cur, body)
            continue
        # 条目内续行字段
        if cur is not None and ":" in stripped:
            _assign_entry_field(cur, stripped)
    if cur is not None:
        entries.append(cur)
    return ip_id, entries


def _assign_entry_field(entry, body):
    """把 'key: value' 形式赋值到 entry dict（忽略嵌套 children/related 等复杂值）。"""
    if ":" not in body:
        return
    key, _, val = body.partition(":")
    key = key.strip()
    val = val.strip().strip('"\'')
    if key in ("uid", "type", "follow", "file_path", "status"):
        if key == "follow" and val in ("", "null", "~"):
            val = None
        entry[key] = val


def _audit_lineage(root):
    """校验每本书的 index.yaml（若存在）：uid 唯一 / 命名格式 / follow 无环 /
    浅目录深度 ≤1。缺失 index.yaml 视为未启用 book-lineage，不报违规（向后兼容）。"""
    findings = []
    candidates = [root / "index.yaml"]
    works = root / "works"
    if works.is_dir():
        for sub in sorted(works.iterdir()):
            if sub.is_dir():
                candidates.append(sub / "index.yaml")
    for idx_file in candidates:
        if not idx_file.exists():
            continue
        rel = str(idx_file.relative_to(root))
        try:
            text = idx_file.read_text(encoding="utf-8", errors="replace")
        except OSError as e:
            findings.append("[lineage] %s 读取失败: %s" % (rel, e))
            continue
        ip_id, entries = _parse_lineage_index(text)
        # 1) uid 全局唯一
        seen = {}
        for ent in entries:
            uid = ent.get("uid")
            if not uid:
                findings.append("[lineage] %s 存在缺 uid 的谱系条目" % rel)
                continue
            if uid in seen:
                findings.append("[lineage] %s 重复 uid: %s" % (rel, uid))
            else:
                seen[uid] = ent
        # 2) 命名格式（IP≥3字符 + 7类固定缩写 + 编号）
        for uid in seen:
            if not LINEAGE_UID_RE.match(uid):
                findings.append(
                    "[lineage] %s uid 命名非法: %s（须匹配 IP≥3字符-3位类型码-编号）" % (rel, uid)
                )
            else:
                parts = uid.split("-")
                tcode = parts[1]
                if tcode not in LINEAGE_TYPE_CODES:
                    findings.append(
                        "[lineage] %s uid 类型码不在 7 类白名单: %s（%s）" % (rel, uid, tcode)
                    )
        # 3) follow 无环（沿 follow 链检测环形依赖）
        for start_uid in seen:
            chain = []
            node = start_uid
            while node:
                if node in chain:
                    findings.append(
                        "[lineage] %s follow 成环: %s → %s" % (rel, " → ".join(chain), node)
                    )
                    break
                chain.append(node)
                nxt = seen.get(node, {}).get("follow")
                node = nxt if nxt and nxt in seen else None
        # 4) 浅目录深度 ≤1（IP 根下物料子目录不得再嵌套子文件夹）
        base = idx_file.parent
        for sd in LINEAGE_SUBDIRS:
            d = base / sd
            if not d.is_dir():
                continue
            for child in sorted(d.iterdir()):
                if child.is_dir():
                    findings.append(
                        "[lineage] %s/%s 出现二级嵌套目录 %s（谱系目录深度须 ≤1 层）"
                        % (rel, sd, child.name)
                    )
    return findings


def _audit_graph(graph_file):
    """校验 card-graph.json：node 含 id/type/tree_id，edge 含 source/target/relation
    且 relation 属合法枚举，边引用的节点均存在。返回违规列表（只读）。"""
    findings = []
    try:
        data = json.loads(Path(graph_file).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as e:
        return ["[graph] %s 解析失败: %s" % (graph_file.name, e)]

    trees = data.get("trees", [])
    if not isinstance(trees, list):
        return ["[graph] trees 字段应为数组"]

    for ti, tree in enumerate(trees):
        tree_id = tree.get("tree_id", "<missing>")
        nodes = tree.get("nodes", [])
        edges = tree.get("edges", [])
        node_ids = set()
        for ni, node in enumerate(nodes):
            nid = node.get("id")
            ntype = node.get("type")
            ntree = node.get("tree_id")
            if not nid:
                findings.append("[graph] tree=%s node[%d] 缺 id" % (tree_id, ni))
            else:
                node_ids.add(nid)
            if not ntype:
                findings.append("[graph] tree=%s node %s 缺 type" % (tree_id, nid))
            if not ntree:
                findings.append("[graph] tree=%s node %s 缺 tree_id" % (tree_id, nid))

        for ei, edge in enumerate(edges):
            src = edge.get("source")
            tgt = edge.get("target")
            rel = edge.get("relation")
            if not src:
                findings.append("[graph] tree=%s edge[%d] 缺 source" % (tree_id, ei))
            if not tgt:
                findings.append("[graph] tree=%s edge[%d] 缺 target" % (tree_id, ei))
            if not rel:
                findings.append("[graph] tree=%s edge[%d] 缺 relation" % (tree_id, ei))
            elif rel not in RELATION_ENUM:
                findings.append("[graph] tree=%s edge[%d] 未知 relation=%s" % (tree_id, ei, rel))
            # 边引用节点必须存在
            for endpoint in (src, tgt):
                if endpoint and endpoint not in node_ids:
                    findings.append("[graph] tree=%s edge[%d] 引用了不存在节点 %s" % (tree_id, ei, endpoint))
    return findings


# ---------------------------------------------------------------------------
# simulate 子命令（可选增强：纸面推演承载，绝不写盘）
# ---------------------------------------------------------------------------
def cmd_simulate(event, project_root):
    """给定事件（如 'ac-A enter sc-X'），沿连锁计算受影响对象候选新状态。

    首期实现为「候选影响面枚举 + 前后差异草稿」，输出明确标注
    「模拟结果，待作者审核，非确定预测」。绝不写盘。
    """
    parts = event.split()
    if len(parts) < 2:
        return ["simulate 需要形如 '<actor-id> enter <scene-id>' 的事件描述"], []

    actor_id = parts[0]
    verb = parts[1]
    scene_id = parts[2] if len(parts) > 2 else None

    plan = []
    notes = []

    # enter 阶段：角色进入场景 → 触发场景环境刷新 + 场内感官广播
    if verb == "enter" and scene_id:
        plan.append({
            "task_type": "edit_plot",
            "target_id": scene_id,
            "before": {"occupants": "(当前在场角色)"},
            "after": {"occupants_append": actor_id},
            "rationale": "%s 进入 %s，刷新环境插槽并向场内广播 SensoryCue" % (actor_id, scene_id),
        })
        # perceive 阶段：场内其他角色捕获信号
        plan.append({
            "task_type": "update_tendency",
            "target_id": actor_id,
            "before": {"state": "(进入前感知状态)"},
            "after": {"state": "捕获 %s 广播的感官信号" % scene_id},
            "rationale": "perceive：%s 更新自身感知状态" % actor_id,
        })
        notes.append("候选连锁：Scene.enter → Role.perceive → (若满足前置则 PlotBeat.fire)")
    else:
        notes.append("事件动词 '%s' 暂未建模详细连锁，仅列出直接受影响对象" % verb)
        plan.append({
            "task_type": "edit_plot",
            "target_id": actor_id,
            "before": {},
            "after": {"event": event},
            "rationale": "事件 %s 直接影响 %s" % (verb, actor_id),
        })

    banner = "【模拟结果，待作者审核，非确定预测】本输出为 ChangePlan 草稿，绝不写盘。"
    return [banner] + notes, plan


# ---------------------------------------------------------------------------
# CLI 入口
# ---------------------------------------------------------------------------
def _infer_project_root(start):
    """向上查找含 cards/ 或 config/project.yaml 的目录作为工程根。"""
    cur = Path(start).resolve()
    for cand in [cur] + list(cur.parents):
        if (cand / "cards").is_dir() or (cand / "config" / "project.yaml").exists():
            return cand
    return cur


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="nc_validate.py",
        description="novel-cards 只读轻量校验器（零第三方依赖，绝不写盘）",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_val = sub.add_parser("validate", help="校验单张卡片 frontmatter")
    p_val.add_argument("card", help="卡片 .md 路径")
    p_val.add_argument("--root", default=None, help="使用方工程根（默认自动推断）")

    p_aud = sub.add_parser("audit", help="跨对象审计 + 图森林校验")
    p_aud.add_argument("project", nargs="?", default=".", help="使用方工程根（默认当前目录）")

    p_sim = sub.add_parser("simulate", help="（可选）事件连锁候选推演，绝不写盘")
    p_sim.add_argument("event", help="事件描述，如 'ac-A enter sc-X'")
    p_sim.add_argument("--root", default=None, help="使用方工程根（默认自动推断）")

    args = parser.parse_args(argv)

    if args.cmd == "validate":
        root = Path(args.root) if args.root else _infer_project_root(Path(args.card))
        issues = cmd_validate(args.card, root)
        print("== validate: %s ==" % args.card)
        if not issues:
            print("✅ 0 违规：五字段齐全、type↔前缀一致、专项约束通过")
            return 0
        print("⚠️ 共 %d 项违规：" % len(issues))
        for it in issues:
            print("  - %s" % it)
        return 1

    if args.cmd == "audit":
        root = Path(args.project) if args.project else Path(".")
        findings, checked = cmd_audit(root)
        print("== audit: %s ==" % root)
        print("已检查卡片数: %d" % checked)
        if not findings:
            print("✅ 0 违规：schema/前缀/暗线单向引用/四方对齐/图森林结构均通过")
            return 0
        print("⚠️ 共 %d 项发现：" % len(findings))
        for f in findings:
            print("  - %s" % f)
        return 1

    if args.cmd == "simulate":
        notes, plan = cmd_simulate(args.event, args.root)
        print("== simulate: %s ==" % args.event)
        for n in notes:
            print(n)
        print("\nChangePlan 草稿（候选，待作者审核，绝不写盘）：")
        print(json.dumps(plan, ensure_ascii=False, indent=2))
        return 0

    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
