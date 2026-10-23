# Spec Delta

## Purpose

定义 `nc-素材`（nc-material）录入链路的合规规则：网页 URL 抓取前的 robots.txt 校验、禁止路径直接拦截、抓取成功后的版权提醒、动态渲染/登录/反爬失败处理，以及配套的中英文提示文案与工具定位声明（单点自用摘录，非爬虫）。

## ADDED Requirements

### Requirement: 素材录入入口

`nc-素材` SHALL 支持三种录入来源：本地文件、纯文本、网页 URL。入库时原样封存原始内容，分配 id + 来源/版权/分类标签，建立原料基线；原文不可原地覆盖；纳入统一检索池。传入链接时 MUST 先校验目标站点 robots.txt。

#### Scenario: 本地文件入库
- **WHEN** 作者执行 `nc-素材 ./notes/灵感片段.txt`
- **THEN** 生成 `co-` 语料卡（或 res/ 封存记录），附来源标签，等待作者确认分类

### Requirement: robots.txt 优先拦截

拿到 URL 后，系统 MUST 优先读取目标站点 `robots.txt`；只要该文件对目标路径标记为 Disallow，直接拦截、不发起页面请求，输出 robots 拦截提示并终止流程。系统 MUST NOT 尝试任何绕过 robots.txt、反爬、登录校验的手段；遇到动态 JS、鉴权、反爬、robots 禁止，全部终止抓取流程，不重试。

#### Scenario: robots 禁止路径
- **WHEN** 作者提交 `nc-素材 https://example.com/article`，且 example.com 的 robots.txt 对该路径 Disallow
- **THEN** skill 输出「根据站点 robots.txt 规则，该路径不允许抓取……请手动复制文本保存至 res/inbox，再使用 nc-素材」并终止，不请求该页面

#### Scenario: 反爬页面
- **WHEN** 目标页面存在反爬限制或需要登录
- **THEN** skill 输出失败提示（建议手动复制文本放入 res/inbox 或联系资源提供方），终止，不重试、不模拟浏览器突破

### Requirement: 版权提醒必出

即使 robots.txt 未明确禁止、页面静态抓取成功，抓取成功后 MUST 固定附带版权提醒：「仅用于你的个人创作参考，请确认你有权引用该内容，遵守著作权相关法律法规」。随后展示标题并询问导入范围（全文 / 片段 / 摘要 / 取消）。

#### Scenario: 抓取成功
- **WHEN** robots 无禁止且静态抓取成功
- **THEN** skill 展示页面标题 + 版权提醒，询问作者选择导入范围

### Requirement: 中英文提示文案

系统 SHALL 提供两套跟随工程 lang 参数切换的提示文案：robots 禁止场景（中/英）、通用版权提醒（中/英）、动态/登录/反爬失败场景（中/英）。中文文案示例：「提示：根据站点 robots.txt 规则，该路径不允许抓取。工具不再继续获取内容。请手动复制文本保存至 res/inbox，再使用 nc-素材；或者联系内容提供方获取授权文本。本工具不绕过站点访问规则。」

#### Scenario: 英文工程
- **WHEN** 工程 `--lang en` 且触发 robots 拦截
- **THEN** 输出英文 Notice 文案而非中文

### Requirement: 工具定位声明

文档（SKILL.md / README / 定稿规范）MUST 包含顶层合规声明：Novel-Cards 仅提供轻量化单点内容摘录辅助；工具主动遵从目标网站 robots.txt 协议；所有网页内容的使用合法性、著作权风险由创作者本人承担；本工具不承担因内容摘抄、引用带来的法律责任。单次单链接，无批量采集能力，不商用。

#### Scenario: 合规声明可见
- **WHEN** 用户阅读 SKILL.md 或 USAGE.md
- **THEN** 能在合规小节找到上述定位与责任划分声明
