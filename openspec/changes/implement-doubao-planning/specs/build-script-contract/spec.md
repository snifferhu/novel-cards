# Spec Delta

## Purpose

明确 `build.sh` / `build.cmd` 构建脚本的职责契约：脚本只做文件遍历、目录准备、历史快照归档、生成导出请求标记文件，绝不实现文档渲染引擎；真正的合并 / 转 docx / pdf 由 nc-导出 skill 承接。跨平台（Linux/macOS vs Windows）逻辑对齐，仅时间戳命令等系统调用有差异。本仓库内 build.sh / build.cmd 只以骨架形式存在（由 install.sh --project 生成），真实执行在使用方工程。

## ADDED Requirements

### Requirement: 脚本职责边界

`build.sh` / `build.cmd` MUST 只做四件事：① 创建 release/ 与 history/ 目录（不存在则新建）② 归档本次版本快照到 history/（cards + 元文件 changelog/latest/index/README/agents/project.yaml）③ 生成 `release/export_request.json` 导出请求标记文件（含 spec/timestamp/formats/include_cards/include_draft/include_index）④ 输出提示「请调用 nc-导出 读取 export_request.json 执行渲染」。MUST NOT 在脚本内实现任何 Markdown→PDF/Word 转换逻辑、不调用 pandoc、不依赖第三方库。

#### Scenario: 脚本执行后产物

- **WHEN** 使用方工程根目录执行 `./build.sh`
- **THEN** 生成 `history/snapshot_<TIMESTAMP>_cards/` + `history/snapshot_<TIMESTAMP>_meta/` + `release/export_request.json`，脚本退出码 0，终端输出下一步提示「请调用 nc-export」

#### Scenario: 脚本不直接产出 PDF

- **WHEN** 执行 build.sh 后检查 release/ 目录
- **THEN** release/ 下只有 export_request.json，无 .pdf/.docx 文件（渲染由后续 nc-导出 完成）

### Requirement: 历史快照双重回溯

每次 build SHALL 向 history/ 写入一份完整快照（卡片全量 + 元文件），与 changelog.md 形成双重回溯机制。快照目录命名 `snapshot_<YYYYMMDD_HHMMSS>`。MUST NOT 自动清理旧快照，由作者自行定期清理。

#### Scenario: 多次 build 累积快照

- **WHEN** 连续执行 3 次 build.sh
- **THEN** history/ 下累积 3 个不同时间戳的快照目录，互不覆盖

#### Scenario: 回滚依据

- **WHEN** 升级失败需回滚
- **THEN** 从 history/ 找到升级前快照目录，将 cards + meta 覆盖回项目根即可恢复

### Requirement: 跨平台对齐

`build.sh`（bash，Linux/macOS）与 `build.cmd`（batch，Windows）SHALL 保持逻辑步骤一一对应：目录准备 → 快照归档 → 生成 export_request.json → 提示调用 nc-导出。差异仅限：时间戳获取命令（date vs wmic）、复制命令（cp -r vs xcopy）、JSON 生成方式（heredoc vs echo 块）。export_request.json 的字段结构两端 MUST 完全一致。

#### Scenario: 双端 export_request 等价

- **WHEN** 同一工程分别在 Linux 与 Windows 执行 build
- **THEN** 两端生成的 export_request.json 除 timestamp 外字段完全一致，可被同一 nc-导出 流程消费

### Requirement: 导出范围可配置

`export_request.json` 中 `include_cards` / `include_draft` / `include_index` 三个布尔字段 SHALL 支持作者按需调整：只想要文稿不带卡片时设 `include_cards: false`。脚本默认值全部为 true。

#### Scenario: 仅导出不带卡片

- **WHEN** 作者手动改 export_request.json 的 `include_cards: false` 后调用 nc-导出
- **THEN** 导出产物不含卡片附录，仅正文 + 索引（若 include_index 为 true）
