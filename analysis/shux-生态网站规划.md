# Shuxlang 生态网站规划

> **文档目的**：规划 `shuxlang.com` 下的 Shux 生态核心网站体系，只围绕 Shux 语言生态必需的网站，不铺陈非生态内容。
>
> **配套文档**：[shux-registry-架构规划.md](shux-registry-架构规划.md)（Registry 详细架构）、[shux-toml-实现分析.md](shux-toml-实现分析.md)、[自举方法.md](自举方法.md)。
>
> **域名状态**：`shuxlang.com` + `registry.shuxlang.com` 已注册（2026-07-21 确认）。其余子域名均为 `shuxlang.com` 子域，无需单独注册，只需 DNS 占位。
>
> **最后更新**：2026-07-21（精简版，聚焦 Shux 生态核心）。

---

## 0. 一句话结论

**Shux 生态只需 5 个核心网站：www（官网）+ docs（文档）+ blog（博客）+ registry（包管理）+ play（Playground）。全部前端用自研 dweb 框架一个项目搞定；registry 后端用 SHUX 自身写（dogfooding）。**

---

## 1. 核心网站矩阵

### 1.1 五大核心网站

| 子域名 | 用途 | 优先级 | 上线阶段 | 不可替代性 |
|--------|------|--------|---------|-----------|
| `www.shuxlang.com` | 官方介绍官网 + 下载入口 | P0 | 自举期（0.3） | 必需（门面） |
| `docs.shuxlang.com` | 文档 + 教程 + std API | P0 | 自举期（0.3） | 必需（学习入口） |
| `blog.shuxlang.com` | 开发动态 + 版本发布 | P0 | 自举期（0.3） | 必需（生态动态） |
| `registry.shuxlang.com` | 依赖包管理 | P0 | 0.7 | 必需（生态核心） |
| `play.shuxlang.com` | 在线 Playground | P1 | 0.3-0.4 | 必需（降低试用门槛） |

### 1.2 域名体系原则

1. **主域重定向**：`shuxlang.com` → `www.shuxlang.com`
2. **统一 HTTPS**：全部强制 HTTPS（Let's Encrypt）
3. **统一 DNS**：Cloudflare 管理（便于 CDN + 安全防护）
4. **统一设计语言**：颜色 / 字体 / 导航栏全站一致
5. **统一技术栈**：5 个网站前端用自研 **dweb 框架**（多应用架构，一个项目搞定）

---

## 2. 优先级与阶段划分

### 2.1 P0 — 自举期（0.3，2026 年 Q4）

**目标**：建立官方门面 + 文档 + 动态，让外界能找到 Shux。

| 网站 | 核心功能 | 内容来源 |
|------|---------|---------|
| `www.shuxlang.com` | 首页 + 特性 + 安装 + 快速上手 + 下载（含 nightly） | 手写 |
| `docs.shuxlang.com` | 语言手册 + std API + 教程 + 学习路径 | `docs/` + `std/` 自动生成 |
| `blog.shuxlang.com` | 开发日志 + 版本发布 + 技术深度 | Markdown |

**关键约束**：
- 3 个网站统一用 dweb 框架，一个项目多应用部署
- 自举期即可启动，不阻塞主线

### 2.2 P1 — 自举完成早期（0.3-0.7）

**目标**：降低试用门槛 + 包管理上线。

| 网站 | 上线时机 | 核心价值 |
|------|---------|---------|
| `play.shuxlang.com` | 0.3-0.4 | **最高 ROI**：零安装体验 Shux |
| `registry.shuxlang.com` | 0.7 | 生态核心：包搜索/发布/版本管理 |

---

## 3. 各网站详细规划

### 3.0 dweb 多应用统一架构

**核心思路**：5 个网站作为一个 **dweb 项目的多个 app**，一个仓库、一次构建、统一部署。

**项目结构示意**：
```
shuxlang-web/                       # dweb 项目（一个仓库搞定全部网站）
├── apps/
│   ├── www/                        # www.shuxlang.com（官网 + 下载页）
│   ├── docs/                       # docs.shuxlang.com（文档 + 教程 + 学习路径）
│   ├── blog/                       # blog.shuxlang.com（博客）
│   ├── play/                       # play.shuxlang.com（Playground）
│   └── registry-frontend/          # registry.shuxlang.com（前端，调后端 API）
├── shared/                         # 共享组件 / 布局 / 主题
│   ├── components/                 # 统一导航栏 / 页脚 / 代码块
│   ├── theme/                      # 统一颜色 / 字体 / 暗色模式
│   └── lib/                        # 共享工具函数
├── content/                        # 共享内容源
│   ├── blog/posts/                 # 博客 Markdown
│   ├── docs/                       # 文档 Markdown
│   └── learn/                      # 学习路径内容
├── dweb.config.toml                # dweb 框架配置（多 app 路由 + 子域映射）
└── package.toml                    # 项目元数据
```

**dweb 框架的职责**：
- **多 app 路由**：根据请求的 Host 头分发到对应 app
- **共享组件**：所有 app 共用 `shared/` 下的导航栏、页脚、主题
- **统一构建**：一次 `dweb build` 产出全部 app 产物
- **子域映射**：`dweb.config.toml` 声明 app → 子域映射
- **统一设计语言**：主题层保证全站视觉一致

**与 Registry 后端的关系**：
- `registry.shuxlang.com` 的**前端**（搜索 UI / 包详情页 / 用户主页）是 dweb 项目的一个 app
- Registry **后端 API** 独立于 dweb 项目，用 SHUX 自身写（dogfooding）
- 前端通过 HTTP 调用后端 API，前后端解耦

### 3.1 `www.shuxlang.com` — 官网

**定位**：Shux 官方门面 + 下载入口。

**核心页面**：
- 首页：Hero（一句话价值主张）+ 特性卡片 + 代码示例 + 安装命令 + CTA
- 特性页：无 GC / zero-copy / 自举 / asm backend / 跨平台
- 安装页：macOS / Linux / Windows / 源码构建
- 下载页：稳定版 + nightly 版本统一入口
- 快速上手：5 分钟教程
- 生态页：跳转 registry / play / docs / blog
- 关于页：项目历史 + 团队 + 路线图

**技术栈**：dweb 框架（www app）

**内容来源**：手写 + 从 `README.md` / `analysis/` 同步

### 3.2 `docs.shuxlang.com` — 文档站

**定位**：语言手册 + std API + 教程 + 学习路径。

**核心内容**：
- 语言手册：语法 / 类型系统 / 所有权 / async / FFI
- std API：从 `std/*.x` 自动生成（类似 rustdoc）
- 编译器手册：CLI / shux.toml / 自举流程 / 贡献指南
- 教程：Getting Started → 进阶 → 系统编程
- 学习路径：新手 → 进阶 → 系统编程 → 自举贡献
- 互动示例：嵌入 Playground 运行
- 版本切换：0.3 / 0.4 / ... / latest / nightly

**技术栈**：dweb 框架（docs app）

**自动生成**：`shux doc` 命令从 `std/*.x` 的 docblock 生成 API 参考

### 3.3 `blog.shuxlang.com` — 博客

**定位**：开发动态 + 版本发布 + 技术深度文章。

**内容类型**：
- 版本发布说明（Release Notes）
- 开发日志（自举进度 / 重大改动）
- 技术深度（codegen 剖析 / asm backend 设计 / 自举方法论）
- 社区故事（用户案例 / 贡献者访谈）
- benchmark 结果

**技术栈**：dweb 框架（blog app，Markdown → 渲染）

**发布流程**：GitHub Actions 自动从 `content/blog/posts/*.md` 同步到 dweb blog app

### 3.4 `registry.shuxlang.com` — 包管理网站

**详见**：[shux-registry-架构规划.md](shux-registry-架构规划.md)

**摘要**：
- **前端**：dweb 项目的一个 app（`apps/registry-frontend/`）
- **后端 API**：用 SHUX 自身写（dogfooding），独立部署
- 数据库：PostgreSQL + 对象存储
- 0.7 正式上线
- 包搜索 / 发布 / 版本管理 / 文档 / 下载统计

**核心功能**：
- 包搜索（全文搜索 + 标签筛选）
- 包详情页（README / 版本 / 依赖 / 下载统计）
- 用户主页（发布的包 / 组织）
- 发布流程（`shux publish` CLI）
- 文档自动生成（从包内 docblock）

### 3.5 `play.shuxlang.com` — 在线 Playground

**定位**：零安装体验 Shux，最高 ROI 的获客工具。

**核心功能**：
- 代码编辑器（Monaco Editor，VS Code 同款）
- 语法高亮（复用 `editors/tree-sitter-shux`）
- 一键运行 + 输出面板
- 代码分享（短链 + 服务端存储）
- 示例预加载（新手友好）
- 多版本切换（0.3 / 0.4 / nightly）
- AST / IR 可视化（教学场景）

**技术方案**：
- **宿主框架**：dweb（play app）
- **编辑器**：Monaco Editor
- **运行方案 A（推荐）**：shux 编译为 WASM，浏览器内全栈运行
  - 优势：零后端成本、全球低延迟、隐私友好
  - 挑战：WASM 后端需在 0.4-0.5 期间补齐
- **运行方案 B（过渡）**：远程沙箱（Docker 容器）
  - 优势：0.3 即可上线
  - 劣势：后端成本、延迟、安全风险

**上线时机**：0.3-0.4（先用方案 B 过渡，0.5 切 WASM）

---

## 4. 统一设计规范

### 4.1 视觉语言

| 项 | 规范 |
|----|------|
| 主色 | 待定（建议深色系，体现系统语言气质） |
| 字体 | 正文：Inter / 思源黑体；代码：JetBrains Mono |
| Logo | Shux 官方 Logo（待设计） |
| 图标 | Lucide / Heroicons |
| 暗色模式 | 全站支持 |

### 4.2 导航栏（全站统一，dweb shared 层保证）

```
[Shux Logo]  [特性] [文档] [包] [Playground] [博客] [GitHub]
```

- 5 个网站共享顶部导航栏
- 当前网站高亮
- 移动端折叠为汉堡菜单

### 4.3 页脚（全站统一）

```
© 2026 Shuxlang · AGPL-3.0 · GitHub · Discord · 联系 · 状态 · 隐私
```

### 4.4 代码块样式

- 全站统一代码高亮主题（与 VS Code 插件一致）
- 复制按钮 + 行号 + 语言标识（`shux` / `bash` / `toml`）

---

## 5. 技术基础设施

### 5.1 DNS 与 CDN

| 项 | 选择 | 理由 |
|----|------|------|
| DNS 托管 | Cloudflare | 免费、API 完善、CDN 集成 |
| CDN | Cloudflare | 全球边缘缓存、DDoS 防护 |
| 对象存储 | MinIO（自建）/ S3（云） | 包 tarball + 静态资源源站 |

**说明**：CDN 是基础设施层，不作为独立网站对外提供界面。

### 5.2 TLS 证书

- 全站 HTTPS 强制
- Let's Encrypt 免费证书（自动续期）
- Cloudflare 边缘 TLS（源站可明文或自签）

### 5.3 部署架构

| 网站 | 部署方式 | 理由 |
|------|---------|------|
| www / docs / blog / play | dweb 项目统一部署 | 多应用一个项目，一次构建全部上线 |
| registry 前端 | dweb 项目（registry-frontend app） | 复用统一项目 |
| registry 后端 | 自建 VPS（SHUX 后端） | 需要数据库 + 对象存储 |

### 5.4 CI/CD

| 流水线 | 触发 | 动作 |
|--------|------|------|
| dweb 项目构建 | push 到 `main` | dweb 统一构建全部 app → 部署 |
| nightly 构建 | 每日定时 | 编译 shux → 上传对象存储 → www 下载页更新 |
| registry 后端部署 | push 到 `registry/` | Docker 构建 → VPS 部署（独立于 dweb 项目） |

---

## 6. 上线时间线

### 6.1 总览

```
2026 Q4 (自举期 0.3)
  └─ P0: www + docs + blog（dweb 项目起步）
     · 3 个 app，统一部署

2027 Q1-Q2 (0.4-0.6)
  └─ P1 早期: play（方案 B 远程沙箱）

2027 Q3-Q4 (0.7)
  └─ P1 完成: registry 前端 + 后端 + play 切 WASM
```

### 6.2 详细时间线

| 时间 | 里程碑 | 上线网站 |
|------|--------|---------|
| 2026-07 | DNS 占位 | `shuxlang.com` + 5 个子域 placeholder |
| 2026-10 | 自举完成（0.3） | www / docs / blog |
| 2027-01 | 0.4 | play（方案 B） |
| 2027-09 | 0.7 | **registry**（前端 + 后端）+ play 切 WASM |

---

## 7. 域名配置清单

### 7.1 子域名配置（仅 5 个核心 + 主域）

`shuxlang.com` 主域已注册，所有子域名无需单独注册，只需 DNS 配置。

| 子域名 | 优先级 | 建议配置时机 |
|--------|--------|-------------|
| `www.shuxlang.com` | P0 | 立即 |
| `docs.shuxlang.com` | P0 | 立即 |
| `blog.shuxlang.com` | P0 | 立即 |
| `play.shuxlang.com` | P1 | 立即（防配置遗漏） |
| `registry.shuxlang.com` | P0 | **已配置** |

### 7.2 立即可做（零成本）

| 项 | 动作 | 耗时 |
|----|------|------|
| 主域 DNS | 确认 `shuxlang.com` DNS 指向 Cloudflare | 5 分钟 |
| 子域占位 | 5 个子域名设置 placeholder A 记录 | 15 分钟 |
| TLS 证书 | 主域 + www 申请 Let's Encrypt | 30 分钟 |
| 续费提醒 | 设置 `shuxlang.com` 续费日历提醒 | 5 分钟 |
| Placeholder 页 | `shuxlang.com` 放 "Shux · Coming 2026 Q4" 页面 | 1 小时 |

---

## 8. 成本估算

### 8.1 P0 阶段（2026 Q4）

| 项 | 方案 | 月成本 |
|----|------|--------|
| www / docs / blog 托管 | dweb 项目（Cloudflare Pages / 自建） | $0-5 |
| 域名 | shuxlang.com（已注册） | $10/年 |
| TLS | Let's Encrypt | $0 |
| **合计** | | **~$1-5/月** |

### 8.2 P1 阶段（2027 Q3，含 Registry）

| 项 | 方案 | 月成本 |
|----|------|--------|
| VPS（Registry 后端） | 2C4G VPS | $10-20 |
| PostgreSQL | 自建或托管 | $5-15 |
| 对象存储 | MinIO 自建 / S3 | $5-20（按量） |
| CDN | Cloudflare | $0-20（按流量） |
| play 后端（方案 B 过渡） | 容器服务 | $10-30 |
| **合计** | | **~$30-100/月** |

---

## 9. 风险与约束

### 9.1 精力分散风险

**风险**：过早投入网站建设，拖慢自举主线。

**缓解**：
- P0 网站内容从已有文档同步，dweb 项目 1-2 周完成
- P1 严格按版本里程碑，不抢自举资源
- 自举完成前，网站只做"门面"，不做"生态"

### 9.2 后端能力风险

**风险**：0.7 时 SHUX 的 HTTP server / PostgreSQL driver 不成熟。

**缓解**：见 [registry 架构文档](shux-registry-架构规划.md) §10.1（过渡期用 Go/Rust，SHUX 逐步替换）。

### 9.3 安全风险

**风险**：Registry / Playground 被滥用（恶意包 / 代码执行）。

**缓解**：
- Registry：保留名规则 + yank 机制 + 安全扫描
- Playground：沙箱隔离 + 资源限制 + 速率限制

---

## 10. 决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 核心网站数量 | 5 个（www/docs/blog/registry/play） | 聚焦 Shux 生态必需 |
| 主域名 | `shuxlang.com` | 已注册；简洁；体现语言品牌 |
| 子域名策略 | `<功能>.shuxlang.com` | 清晰、可扩展、符合行业惯例 |
| **网站前端技术栈** | **自研 dweb 框架（多应用架构）** | 一个项目搞定 5 个网站；统一设计/组件/路由；自研可控 |
| Registry 后端语言 | SHUX 自身 | dogfooding + 验证语言能力（独立于 dweb 项目） |
| Playground 运行方案 | 先方案 B（远程沙箱）→ 切 WASM | 0.3 快速上线，0.5 降本 |
| DNS / CDN | Cloudflare | 免费、全球、API 完善 |
| 部署 | dweb 项目统一部署 + VPS（Registry 后端） | 前端一个项目，后端独立 |
| 统一设计 | 全站共享导航栏 + 页脚 + 代码块 | 品牌一致性（dweb 框架层保证） |
| 上线顺序 | www/docs/blog → play → registry | 门面 → 获客 → 生态 |
| 子域占位 | 立即占位 5 个核心子域名 | 防配置遗漏；零成本 |

---

## 11. 与现有文档的关系

| 文档 | 关系 |
|------|------|
| [shux-registry-架构规划.md](shux-registry-架构规划.md) | Registry 的详细架构（本文档 §3.4 摘要） |
| [shux-toml-实现分析.md](shux-toml-实现分析.md) | shux.toml 配置（包管理器依赖） |
| [自举方法.md](自举方法.md) | 自举完成是 P1 的前置 |
| [当前问题分析.md](当前问题分析.md) | 当前阻塞项，不包含网站 |

---

## 12. 立即可做（零成本，不阻塞自举）

| 项 | 动作 | 耗时 |
|----|------|------|
| 主域 DNS | 确认 `shuxlang.com` DNS 指向 Cloudflare | 5 分钟 |
| 子域占位 | 5 个核心子域名设置 placeholder A 记录 | 15 分钟 |
| TLS | 主域 + www 申请 Let's Encrypt | 30 分钟 |
| Placeholder | `shuxlang.com` 放 "Coming 2026 Q4" 页 | 1 小时 |
| 续费提醒 | 设置 `shuxlang.com` 续费日历提醒 | 5 分钟 |

**当前主线仍是自举**。生态网站是 2026 Q4 - 2027 Q3 的事，现在只做"零成本占位"（DNS + placeholder + 续费提醒）。
