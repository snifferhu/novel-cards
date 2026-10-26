# Tasks

## 1. config 骨架与 registry 白名单

- [x] 1.1 `references/layout.md`：registry 清单新增 `pen-names.yaml`（笔名白名单，骨架 only）；目录树补 `works/` 顶层目录说明（每本书 = `works/<work-id>/` 子空间，含 cards/manuscript/index/graph/registry + 单书 config 片段）
- [x] 1.2 `config/project.yaml` 模板（install.sh 内嵌 + references 描述）：增可选 `works[]` 数组（元素含 `id / title / mode / lang / default_pen_name / tree_id_root`）+ 可选 `active_work` 指针；保留既有 `lang / mode / pipeline_option` 工程级字段
- [x] 1.3 `nc-初始化` 产物骨架：新增 `registry/pen-names.yaml` 空骨架（零预置条目，占位注释）；`works/` 目录 .gitkeep
- [x] 1.4 验证：`works[]` 缺失时视为隐式单本（唯一 work-id = 工程根），存量单本工程行为回归不变

## 2. install.sh 文案与 --project 骨架

- [x] 2.1 `install.sh` 头部注释：补齐「获取来源（git clone URL `github.com:snifferhu/novel-cards.git` / release tarball 条件表述）→ 放置约定（脚本自定位 SRC，任意目录可运行；--link 需长期保留源目录）→ 安装方式（copy vs link、双端 target）」四步说明
- [x] 2.2 `install.sh --project` 生成骨架：新增 `works/` 目录（.gitkeep）+ `registry/pen-names.yaml` 占位 + `config/project.yaml` 预填首个 work 条目
- [x] 2.3 `install.sh` 结尾提示语：从「跑 --project」扩为指向 quickstart 四步下一步指引（初始化 → 首卡）
- [x] 2.4 验证：`./install.sh --project /tmp/test-novel` 幂等生成含 `works/` + `pen-names.yaml` 的骨架，重复执行零变更

## 3. nc-初始化 新书分支

- [x] 3.1 `nc-初始化` 检测当前目录上下文：已初始化工程根（有 config/project.yaml）→「追加一本书」分支；空目录 → 既有「新工程」分支
- [x] 3.2 「追加一本书」分支：在 `works/<新work-id>/` 生成该书完整子空间骨架 + 追加 `works[]` 条目（至少 `id / title / mode / tree_id_root`）+ 更新 `active_work` 指针
- [x] 3.3 `default_pen_name` 声明校验：若指向未在 `registry/pen-names.yaml` 注册的 key，拦截提示先走 `nc-注册`
- [x] 3.4 验证：同工程连建两本书，作品 A 既有卡片 / 图森林 / 配置零改动

## 4. nc-* 技能 --work 作用域参数

- [x] 4.1 全部 `nc-*` 创作 / 审计 / 导出技能接受可选 `--work <work-id>` 参数；路径解析改为「工程根 + （可选）works/<id>/」前缀拼接（集中处理，不散落硬编码）
- [x] 4.2 缺省默认书确定规则落地：① 显式 `--work` → 用之；② 否则读 `active_work` 指针；③ 否则 `works[]` 恰好一条 → 即之；④ 否则多书无指针 → 提示作者用 `--work` 指定并列出候选（不静默猜测）
- [x] 4.3 输出标注：多书场景下操作输出标注「正在操作的书 = <work-id>」；单本工程无需标注
- [x] 4.4 验证：`--work book-b` 只在 `works/book-b/` 读写，绝不触碰其他作品；单本工程缺省行为与引入前逐字一致

## 5. 跨书检索与总览

- [x] 5.1 `nc-检索` 支持 `--all-works` 跨全部作品检索，结果每条带 `work-id` 归属标签
- [x] 5.2 `nc-检索`（或总览查询）支持「列出本工程所有作品及状态」（work-id / title / mode / 默认笔名 / 卡片数量概览），不展开单书正文
- [x] 5.3 验证：跨书检索命中正确标注所属书；总览只列清单不展开正文

## 6. 多笔名署名管理

- [x] 6.1 `registry/pen-names.yaml` 契约：条目含 `key / display_name / note`，经 `nc-注册` 写入，skill 不内置锁死词表
- [x] 6.2 `nc-注册` 支持登记笔名条目（沿用既有注册前置机制）
- [x] 6.3 `nc-导出` 出成品按生效笔名落署名（作品 `default_pen_name` 或章节覆写）
- [x] 6.4 `nc-成稿` 提案头部标注署名
- [x] 6.5 章节级覆写载体：新增可选 frontmatter 字段 `pen_name`（与五必备字段并列的可选项），引用已注册笔名 key；未注册取值拦截
- [x] 6.6 验证：注册笔名 → 设作品默认 → 导出落署名；章节覆写生效；未注册 key 被拦截；无声明存量作品导出留空不报错

## 7. 文档闭环（快速开始四步 + 自检）

- [x] 7.1 README「快速开始」节重写为四步主线（获取 / 放置 / 安装 / 落地首卡）+ 装后自检小节；详细步骤锚点链接到 quickstart，避免双写漂移
- [x] 7.2 `templates/quickstart-zh.md` / `quickstart-en.md` 双语同步四步闭环 + 自检命令（skills 面板确认 novel-cards 可见 / 触发词试探）
- [x] 7.3 获取来源：git clone 给确切 URL；tarball 做条件表述（有 tag 给链接，无则指向 GitHub Source code 按钮，不虚构版本号）
- [x] 7.4 端到端纸面演练：克隆 → 安装 → `--project ~/my-novel` → `nc-初始化` → `nc-角色 "新建主角"` → `nc-初始化 --new-work` 第二本 → `nc-角色 --work book-b` → `nc-导出` 落署名，全链路无断点

## 8. 一致性自检与收尾

- [x] 8.1 frontmatter 三键（name/description/license）grep 自检，无 opencode 专属键混入
- [x] 8.2 29 技能计数 / auto_invokable（仅 nc-量化/nc-图谱/nc-节奏）/ 六组分类五处一致（SKILL.md 速查表 / README / skill-catalog / USAGE / skill-reference 模板）
- [x] 8.3 `references/skill-catalog.md` 相关行补 `--work` / 署名入参（nc-初始化 新书分支 / nc-检索 --all-works / nc-导出 落署名 / nc-成稿 署名标注 / nc-注册 笔名）
- [x] 8.4 OO 透镜一致性：`works/` 表述为 StoryWorld 下挂多个作品子容器，不新增 NcObject 基类 / 子类，oo-model.md 类层次不变
- [x] 8.5 验证：`refwork.author` 语义保持「外部对标作品作者」不变，与本变更「本工程署名主体」正交；提案制铁律 / 审计只读铁律 / tools 只读运行时不受影响
