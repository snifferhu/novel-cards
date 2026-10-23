# 素材合规（compliance.md）

`nc-素材`（nc-material）录入链路的合规规则：网页 URL 抓取前的 robots.txt 校验、
禁止路径直接拦截、抓取成功后的版权提醒、动态渲染/登录/反爬失败处理，以及配套的
中英文提示文案与工具定位声明（单点自用摘录，非爬虫）。

## 1. 核心准则

1. 拿到 URL，**优先读取目标站点 `robots.txt`**。只要 `robots.txt` 里对该路径标记为
   禁止抓取（Disallow），**直接拦截，不发起页面请求**，直接提示作者。
2. 就算 `robots.txt` 没明确禁止、页面本身可以静态抓取，抓取成功后依然固定附带
   版权提醒，告知仅限个人创作参考、自行承担使用责任。
3. **不尝试任何绕过** `robots.txt`、反爬、登录校验的手段；遇到动态 JS、鉴权、反爬、
   robots 禁止，全部终止抓取流程，不重试。
4. 定位重申：**这不是爬虫，只是单点自用摘录工具**；不批量、不商用、不突破站点声明规则。

## 2. 素材录入入口

`nc-素材` SHALL 支持三种录入来源：本地文件、纯文本、网页 URL。入库时原样封存原始
内容，分配 id + 来源/版权/分类标签，建立原料基线；原文不可原地覆盖；纳入统一检索池。
传入链接时 MUST 先校验目标站点 robots.txt。

- **本地文件**：`nc-素材 ./notes/灵感片段.txt` → 生成 `co-` 语料卡（或 res/ 封存记录），
  附来源标签，等待作者确认分类。
- **纯文本**：直接粘贴文本入库。
- **网页 URL**：走下方 robots.txt 校验链路。

## 3. robots.txt 校验链路（fail-closed 原则）

```
nc-素材 https://xxx/article
  ↓
拉取并解析站点 robots.txt
  ├─ robots 标记禁止此路径 → 输出 robots 拦截提示，直接终止（不请求该页面）
  └─ robots 无禁止
      ↓
    尝试静态文本抓取
      ├─ 抓取成功 → 展示标题 + 弹出版权提醒，询问导入范围（全文/片段/摘要/取消）
      └─ 抓取失败（动态JS/登录/反爬）→ 输出失败提示，终止（不重试、不模拟浏览器突破）
```

**fail-closed 原则**：任何不确定情况（robots 解析失败、网络异常、无法判定是否允许）
一律按「禁止」处理，终止流程并提示作者手动处理，绝不默认放行。

### 行为约束

- **robots 禁止路径**：输出拦截提示并终止，**不请求该页面**。
- **反爬/登录页面**：输出失败提示（建议手动复制文本放入 `res/inbox` 或联系资源提供方），
  终止，不重试、不模拟浏览器突破。
- **抓取成功**：展示页面标题 + 版权提醒，询问作者选择导入范围（全文 / 片段 / 摘要 / 取消）。

## 4. 四套中英文提示文案（跟随工程 lang 切换）

以下四套文案中英各一份齐全，由工程 `config/project.yaml` 的 `lang` 参数（zh/en）决定
输出哪一套。

### 4.1 robots 禁止场景

**中文**：

> 提示：根据站点 robots.txt 规则，该路径不允许抓取。工具不再继续获取内容。请手动复制
> 文本保存至 res/inbox，再使用 nc-素材；或者联系内容提供方获取授权文本。本工具不绕过
> 站点访问规则。

**English**:

> Notice: The site's robots.txt disallows crawling for this path. Content will not be
> fetched. Please manually copy the content and save it to res/inbox for nc-material, or
> request authorized text from the content owner. This tool will not bypass site rules.

### 4.2 通用版权提醒（抓取成功后必出，不变）

**中文**：

> 版权提醒：仅用于你的个人创作参考，请确认你有权引用该内容，遵守著作权相关法律法规。

**English**:

> Copyright notice: This is only for your personal creative reference. Please confirm you
> have the right to quote this content and comply with copyright laws.

### 4.3 动态 / 登录 / 反爬失败场景

**中文**：

> 提示：该页面为动态渲染 / 需要登录 / 存在反爬限制，无法自动抓取。请手动复制需要的文本，
> 保存文件放入 res/inbox，再执行 nc-素材；或者联系资源提供方获取可直接使用的文本版本。

**English**:

> Notice: This page is dynamically rendered, login-required or protected by anti-crawling
> rules, cannot be fetched automatically. Please manually copy the content, save it to
> res/inbox and use nc-material, or contact the content provider for available text.

### 4.4 导入范围询问（抓取成功后）

**中文**：

> 已抓取《{标题}》。请选择导入范围：(1) 全文 (2) 指定片段 (3) 摘要 (4) 取消。
> {版权提醒}

**English**:

> Fetched "{title}". Choose import scope: (1) full text (2) specified excerpt (3) summary
> (4) cancel. {copyright notice}

## 5. 工具定位声明（顶层合规声明，MUST 写入 SKILL.md / README / USAGE）

> Novel-Cards 仅提供轻量化单点内容摘录辅助。工具会主动遵从目标网站 robots.txt 协议；
> 所有网页内容的使用合法性、著作权风险，由创作者本人承担。本工具不承担因内容摘抄、
> 引用带来的法律责任。单次单链接，无批量采集能力，不商用。

## 6. nc-素材 备注（能力边界）

> 支持本地文件、纯文本、网页 URL 录入；传入链接时先校验站点 robots.txt，若规则禁止抓取
> 则直接终止；仅做静态页面文本提取，不绕过反爬、登录限制；单次单链接，无批量采集能力；
> 附带版权提示，仅用于个人创作自用。
