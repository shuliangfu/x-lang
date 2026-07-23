# Xlang Registry 包管理网站架构规划

> **文档目的**：规划 Xlang 官方包管理网站（Xlang Registry，域名 `registry.xlang.dev`）的整体架构、实施路线与依赖格式。
>
> **配套文档**：[xlang-toml-实现分析.md](xlang-toml-实现分析.md)、[xlang.toml](../xlang.toml)、[自举方法.md](自举方法.md)。
>
> **域名状态**：`registry.xlang.dev` 已注册（2026-07-21 确认）。
>
> **最后更新**：2026-07-21（初版，远期规划）。

---

## 0. 一句话结论

**自举完成（0.3）后，0.4-0.6 做本地包管理器 + xlang.toml `[dependencies]` 格式定型；0.7 正式上线 `registry.xlang.dev`（后端用 XLANG 自身编写 + PostgreSQL）；1.0+ 扩展私有仓库 / CI 集成 / 安全扫描。现在全力冲刺自举，包管理网站不阻塞当前主线。**

---

## 1. 生态路线图与时机分析

### 1.1 阶段划分

| 阶段 | 版本区间 | 时间（预计） | 是否建包管理网站 | 核心任务 |
|------|---------|-------------|------------------|----------|
| 0 | 0.1 ~ 0.3 | 2026 年 10-12 月 | 否 | 语言自举 + 基础工具链 |
| 1 | 0.4 ~ 0.6 | 2027 年 Q1-Q2 | 否（规划期） | std 完善 + 早期本地包管理器 |
| 2 | 0.7 ~ 0.9 | 2027 年 Q3-Q4 | **是（正式上线）** | 包管理系统 + 网站 |
| 3 | 1.0+ | 2028 年及以后 | 全面运营 | 生态繁荣 / 私有仓库 / 企业功能 |

### 1.2 为什么 0.7 是最佳时机

**过早（现在或自举刚完）的坏处**：
- 语言 API 频繁 breaking，用户包大量废弃
- std 不完善，可发布的包很少
- 吸引不到真实用户，网站变"空站"
- 分散自举与核心优化精力

**0.7 时机的优势**：
- 语言已有一定稳定性
- std 相对完善，有实际可发布的库
- 已有 x-shujs、类脑 AI 等种子项目
- 社区开始形成，有早期用户反馈

### 1.3 与自举的关系

| 项 | 依赖自举？ | 说明 |
|----|-----------|------|
| xlang.toml `[dependencies]` 格式 | 否 | 纯 schema 设计，0.4 即可定型 |
| 本地包管理器（xlang add/publish） | **是** | 需 XLANG 编译器稳定 |
| Registry 后端用 XLANG 写 | **是** | 自举完成后练手，验证语言能力 |
| Registry 前端 | 否 | 可用 TypeScript/React，不阻塞 |

---

## 2. 域名体系规划

### 2.1 主域名体系

| 域名 | 用途 | 优先级 | 状态 |
|------|------|--------|------|
| `xlang.dev` | 主站 / 官网 | P0 | 已注册 |
| `registry.xlang.dev` | 官方包仓库 | P0 | **已注册** |
| `docs.xlang.dev` | 文档站 | P1 | 待注册 |
| `api.xlang.dev` | Registry 后端 API | P1 | 待注册（或复用 registry 子域） |
| `play.xlang.dev` | 在线 Playground | P2 | 待注册 |
| `cdn.xlang.dev` | 静态资源 / 包下载加速 | P2 | 待注册 |

### 2.2 Registry 命名

候选名：
- **Xlang Registry**（推荐，简洁专业）
- Xlang Package Registry
- Xlang Crates（类似 crates.io）
- Xlang Hub

**采用：Xlang Registry**，对外品牌名统一用此。

### 2.3 立即可做的准备

| 项 | 动作 | 时机 |
|----|------|------|
| DNS 解析 | `registry.xlang.dev` 指向 placeholder 页 | 现在 |
| TLS 证书 | Let's Encrypt 免费 HTTPS | DNS 解析后 |
| 品牌页 | placeholder 页面（"Coming Soon · 2027"） | 现在 |
| 域名监测 | 定期续费提醒 | 现在 |

---

## 3. 系统架构

### 3.1 总体架构图

```
┌──────────────────────────────────────────────────────────┐
│                   用户层（User-facing）                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Web UI      │  │ xlang CLI    │  │ docs.xlanglang   │  │
│  │ (React/TS)  │  │ (xlang add/  │  │ (自动生成)       │  │
│  │             │  │  publish)   │  │                 │  │
│  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │
└─────────┼────────────────┼─────────────────┼────────────┘
          │                │                 │
          ▼                ▼                 ▼
┌──────────────────────────────────────────────────────────┐
│                   API 网关层（API Gateway）                │
│  registry.xlang.dev  ·  api.xlang.dev              │
│  ┌──────────────────────────────────────────────────┐    │
│  │  REST/JSON API  ·  鉴权  ·  限流  ·  审计日志     │    │
│  └──────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────┐
│                   业务层（Backend · 用 XLANG 写）            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │
│  │ 包元数据  │ │ 版本管理  │ │ 用户/组织 │ │ 搜索/索引   │  │
│  │ Package  │ │ Version  │ │ Auth     │ │ Search     │  │
│  └──────────┘ └──────────┘ └──────────┘ └────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │
│  │ 发布流水线│ │ 下载统计  │ │ 文档生成  │ │ 安全扫描    │  │
│  │ Publish  │ │ Stats    │ │ Docs     │ │ Audit      │  │
│  └──────────┘ └──────────┘ └──────────┘ └────────────┘  │
└──────────────────────────────────────────────────────────┘
          │                │                 │
          ▼                ▼                 ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ PostgreSQL       │ │ 对象存储      │ │ CDN              │
│ (元数据/用户/版本) │ │ (包 tarball) │ │ cdn.xlang.dev │
│                  │ │ S3/MinIO     │ │ (下载加速)        │
└──────────────────┘ └──────────────┘ └──────────────────┘
```

### 3.2 技术选型

| 层 | 技术 | 理由 |
|----|------|------|
| Web UI | React + TypeScript + Vite | 主流、生态丰富、SSR 友好 |
| API 网关 | Nginx + 反向代理 | 成熟稳定，支持限流/TLS |
| **后端** | **XLANG 自身编写** | 自举完成后练手，验证语言能力（HTTP server + JSON + DB driver） |
| 数据库 | PostgreSQL | 成熟、JSON 支持、全文搜索 |
| 对象存储 | MinIO（自建）或 S3（云） | 包 tarball 存储 |
| CDN | Cloudflare 或自建 | 全球下载加速 |
| 搜索 | PostgreSQL FTS → 后期 Elasticsearch | 简单起步，按需升级 |
| CI/CD | GitHub Actions | 与 GitHub 仓库集成 |
| 容器 | Docker + Docker Compose | 部署一致 |

### 3.3 为什么后端用 XLANG 写

**核心理由**：
1. **自举验证**：Registry 是真实生产负载，验证 XLANG 的 HTTP/JSON/DB/并发能力
2. **dogfooding**：用 Xlang 写 Xlang 生态基础设施，最强信任信号
3. **性能优势**：XLANG 无 GC / zero-copy，适合高并发 API server
4. **语言演进驱动**：真实场景暴露 std 的不足，反哺 std 完善

**前提条件**（0.7 前必须具备）：
- `std.http` server 端能力（当前只有 client）
- `std.json` 高性能解析/序列化
- `std.crypto` TLS（或用 reverse proxy 卸载 TLS）
- PostgreSQL 协议驱动（或用 C FFI 调 libpq）
- `std.async` CPS codegen 稳定

**风险缓解**：若 XLANG 某项能力在 0.7 仍未就绪，后端可临时用 Go/Rust 写过渡层，XLANG 逐步替换。

---

## 4. 数据模型（PostgreSQL）

### 4.1 核心表

```sql
-- 用户 / 组织
CREATE TABLE users (
  id            BIGSERIAL PRIMARY KEY,
  username      VARCHAR(64) UNIQUE NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,        -- argon2
  role          VARCHAR(16) DEFAULT 'user',   -- user | admin
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

CREATE TABLE organizations (
  id          BIGSERIAL PRIMARY KEY,
  name        VARCHAR(64) UNIQUE NOT NULL,
  owner_id    BIGINT REFERENCES users(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE org_members (
  org_id      BIGINT REFERENCES organizations(id),
  user_id     BIGINT REFERENCES users(id),
  role        VARCHAR(16) DEFAULT 'member',   -- owner | admin | member
  PRIMARY KEY (org_id, user_id)
);

-- 包
CREATE TABLE packages (
  id            BIGSERIAL PRIMARY KEY,
  name          VARCHAR(128) UNIQUE NOT NULL,  -- e.g. "std-extra"
  namespace     VARCHAR(64),                   -- 个人/组织命名空间
  description   TEXT,
  repository    VARCHAR(512),                  -- git url
  homepage      VARCHAR(512),
  license       VARCHAR(64),                   -- SPDX
  owner_id      BIGINT REFERENCES users(id),
  org_id        BIGINT REFERENCES organizations(id),
  latest_version VARCHAR(64),
  total_downloads BIGINT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 版本
CREATE TABLE package_versions (
  id            BIGSERIAL PRIMARY KEY,
  package_id    BIGINT REFERENCES packages(id),
  version       VARCHAR(64) NOT NULL,          -- semver
  yanked        BOOLEAN DEFAULT FALSE,
  checksum      VARCHAR(128) NOT NULL,         -- sha256
  tarball_key   VARCHAR(255) NOT NULL,         -- 对象存储 key
  readme        TEXT,
  changelog     TEXT,
  features      JSONB,                         -- features 表
  dependencies  JSONB,                         -- 依赖列表
  xlang_version  VARCHAR(64),                   -- 所需 xlang 版本
  size_bytes    BIGINT,
  published_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (package_id, version)
);

-- 依赖关系（用于反向依赖查询）
CREATE TABLE package_dependencies (
  version_id       BIGINT REFERENCES package_versions(id),
  dep_package_name VARCHAR(128) NOT NULL,
  dep_version_req  VARCHAR(64) NOT NULL,       -- semver range
  dep_kind         VARCHAR(16) DEFAULT 'normal', -- normal | dev | build
  PRIMARY KEY (version_id, dep_package_name)
);

-- 下载统计
CREATE TABLE download_stats (
  package_id BIGINT REFERENCES packages(id),
  version_id BIGINT REFERENCES package_versions(id),
  date       DATE NOT NULL,
  count      BIGINT DEFAULT 0,
  PRIMARY KEY (version_id, date)
);

-- API Token
CREATE TABLE api_tokens (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT REFERENCES users(id),
  token_hash  VARCHAR(255) NOT NULL,
  name        VARCHAR(128),
  scopes      JSONB,                           -- ["publish", "read"]
  last_used_at TIMESTAMPTZ,
  expires_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 全文搜索索引
CREATE INDEX idx_packages_search ON packages
  USING GIN (to_tsvector('english', name || ' ' || coalesce(description, '')));
CREATE INDEX idx_versions_pkg ON package_versions(package_id, published_at DESC);
```

### 4.2 保留包名规则

- `std-*`：官方 std 扩展保留
- `xlang-*`：官方工具保留
- `x-*`：x-kernel 生态保留
- 单字母包名保留给官方

---

## 5. API 设计（REST/JSON）

### 5.1 核心 API

| Method | Path | 用途 |
|--------|------|------|
| GET | `/api/v1/packages` | 列出包（分页 + 搜索） |
| GET | `/api/v1/packages/:name` | 包详情 |
| GET | `/api/v1/packages/:name/versions` | 版本列表 |
| GET | `/api/v1/packages/:name/:version` | 版本详情 |
| GET | `/api/v1/packages/:name/:version/dependencies` | 版本依赖 |
| GET | `/api/v1/packages/:name/:version/download` | 下载 tarball（重定向到 CDN） |
| GET | `/api/v1/packages/:name/reverse-deps` | 反向依赖 |
| POST | `/api/v1/packages` | 创建包（需 auth） |
| PUT | `/api/v1/packages/:name` | 更新包元数据（需 auth） |
| PUT | `/api/v1/packages/:name/:version/yank` | yank 版本 |
| PUT | `/api/v1/packages/:name/:version/unyank` | unyank |
| POST | `/api/v1/publish` | 发布新版本（需 auth + tarball） |
| GET | `/api/v1/users/:username` | 用户主页 |
| GET | `/api/v1/orgs/:name` | 组织主页 |
| POST | `/api/v1/tokens` | 创建 API token |
| GET | `/api/v1/me` | 当前用户（需 auth） |

### 5.2 发布协议（类似 crates.io）

```
PUT /api/v1/publish
Content-Type: multipart/form-data
Authorization: Bearer <token>

  {
    "metadata": {
      "name": "std-extra",
      "version": "0.2.0",
      "description": "...",
      "dependencies": [...],
      "features": {...},
      "xlang_version": "0.7"
    },
    "tarball": <binary .xlangpkg>
  }
```

**tarball 格式**：`.xlangpkg` = gzip tar，包含 `xlang.toml` + `src/` + `README.md` + `LICENSE`。

### 5.3 鉴权

- Web UI：session cookie
- CLI：API token（`xlang login` 生成，存 `~/.xlang/credentials.toml`）
- 所有 publish 操作需 token + 2FA（管理员）

---

## 6. xlang.toml `[dependencies]` 格式

### 6.1 基础格式（0.4 定型）

```toml
[dependencies]
# Registry 依赖（semver range）
"std-extra" = "0.2"
"json-fast" = "^1.2.0"
"logger" = { version = "0.1.5", optional = true }

# Git 依赖
"my-lib" = { git = "https://github.com/user/my-lib", branch = "main" }
"feat-lib" = { git = "https://github.com/user/feat-lib", tag = "v0.3.0" }

# Path 依赖（本地开发）
"local-utils" = { path = "../local-utils" }

[dev-dependencies]
"xlang-test-harness" = "0.1"

[build-dependencies]
"xlang-codegen-tool" = "0.2"
```

### 6.2 semver range 语法（与 Cargo 一致）

| 写法 | 含义 |
|------|------|
| `"1.2.3"` | `=1.2.3` 精确版本 |
| `"^1.2.3"` | `>=1.2.3, <2.0.0`（默认，兼容更新） |
| `"~1.2.3"` | `>=1.2.3, <1.3.0`（补丁更新） |
| `"1.2"` | `^1.2.0` |
| `"1"` | `^1.0.0` |
| `"*"` | 任意版本 |
| `">=1.2.0, <2.0.0"` | 显式 range |

### 6.3 features 传递

```toml
[dependencies]
"web-server" = { version = "0.3", features = ["tls", "websocket"] }
"web-server" = { version = "0.3", default-features = false, features = ["tls"] }

[features]
default = ["std"]
full = ["std", "async", "logger/logger-json"]
```

### 6.4 lockfile（xlang.lock）

每次 `xlang build` 生成 `xlang.lock`，锁定具体版本：

```toml
# xlang.lock — 自动生成，勿手动编辑
[[package]]
name = "std-extra"
version = "0.2.5"
checksum = "sha256:abc123..."
source = "registry+https://registry.xlang.dev"

[[package]]
name = "my-lib"
version = "0.1.0"
source = "git+https://github.com/user/my-lib#abc123commit"
```

---

## 7. 本地包管理器 CLI

### 7.1 命令设计

| 命令 | 用途 | 类比 |
|------|------|------|
| `xlang init` | 初始化新项目（生成 xlang.toml） | `cargo init` / `npm init` |
| `xlang add <pkg>` | 添加依赖到 xlang.toml | `npm install` |
| `xlang add <pkg> --dev` | 添加 dev 依赖 | `npm install --save-dev` |
| `xlang remove <pkg>` | 移除依赖 | `npm uninstall` |
| `xlang update` | 更新所有依赖到 lockfile 允许的最新版 | `cargo update` |
| `xlang update <pkg>` | 更新单个依赖 | — |
| `xlang fetch` | 下载依赖到本地缓存（不构建） | `cargo fetch` |
| `xlang build` | 构建（自动解析依赖） | `cargo build` |
| `xlang run` | 构建并运行 | `cargo run` |
| `xlang test` | 构建并测试 | `cargo test` |
| `xlang check` | 类型检查（不生成 binary） | `cargo check` |
| `xlang publish` | 发布到 Registry | `cargo publish` / `npm publish` |
| `xlang login` | 登录 Registry（存 token） | `npm login` |
| `xlang logout` | 登出 | `npm logout` |
| `xlang search <query>` | 搜索包 | `npm search` |
| `xlang info <pkg>` | 显示包详情 | `npm info` |
| `xlang yank <pkg>@<ver>` | yank 版本 | `cargo yank` |

### 7.2 缓存目录

```
~/.xlang/
├── credentials.toml          # API token（xlang login）
├── registry/
│   └── cache/                # 下载的 tarball 缓存
│       ├── std-extra-0.2.5.xlangpkg
│       └── ...
├── git/                      # git 依赖克隆
│   └── db/
└── config.toml               # 全局配置（registry URL 等）
```

### 7.3 全局配置 `~/.xlang/config.toml`

```toml
[registry]
default = "https://registry.xlang.dev"
# 私有 registry（企业版）
# "private" = "https://registry.company.com"

[net]
git-fetch-with-cli = true     # 用系统 git 而非内置
```

---

## 8. 安全与审核

### 8.1 发布安全

| 威胁 | 缓解 |
|------|------|
| 包名抢注 | 保留名规则 + 早期用户认证 |
| 恶意代码 | 上传时静态扫描 + 社区举报 |
| 版本篡改 | tarball sha256 校验 + lockfile |
| Token 泄露 | 2FA + token 过期 + 撤销机制 |
| 供应链攻击 | 可复现构建 + 构建日志公开 |

### 8.2 审核流程

1. **自动检查**：上传时扫描 `extern function` / `unsafe` / 网络调用
2. **社区举报**：用户可举报恶意包
3. **管理员审核**：争议包人工审核
4. **Yank 机制**：问题版本可 yank（不删除，但 `xlang build` 拒绝新用户）

### 8.3 保留名规则

| 前缀 | 保留给 | 规则 |
|------|--------|------|
| `std-*` | 官方 std 扩展 | 仅 `xlanglang` 组织可发布 |
| `xlang-*` | 官方工具 | 仅 `xlanglang` 组织可发布 |
| `x-*` | x-kernel 生态 | 仅认证组织可发布 |
| 单字母 | 官方 | 保留 |

---

## 9. 实施阶段

### 阶段 1（0.4-0.6，准备期）

**目标**：本地包管理器可用，xlang.toml `[dependencies]` 格式定型。

**范围**：
- xlang.toml `[dependencies]` 格式定稿（§6）
- `xlang add` / `remove` / `update` / `fetch` 命令
- git + path 依赖支持（无需 Registry）
- `xlang.lock` lockfile 生成
- 本地缓存 `~/.xlang/registry/cache/`

**不包含**：Registry 网站、publish 命令、在线搜索

**触点**：
- 新建：`compiler/src/driver/package_manager.x`
- 改：`compiler/src/main.x` 子命令分发
- 改：`xlang.toml` schema 校验

### 阶段 2（0.7，正式上线）

**目标**：`registry.xlang.dev` 上线，支持搜索/发布/下载。

**范围**：
- 后端（XLANG 编写）：HTTP server + PostgreSQL + 对象存储
- 前端（React/TS）：搜索/包详情/用户主页/文档
- `xlang login` / `publish` / `search` / `info` / `yank` 命令
- semver 解析 + 依赖解析
- CDN 接入

**触点**：
- 新建：`registry/` 仓库（独立 repo 或 monorepo 子目录）
- 新建：`registry-frontend/` React 应用
- 改：`compiler/src/driver/package_manager.x` 加 Registry 协议

### 阶段 3（0.8-0.9，生态建设）

**目标**：文档生成、CI 集成、统计、私有仓库。

**范围**：
- `docs.xlang.dev` 自动生成包文档
- GitHub Actions 集成（自动 publish on tag）
- 下载统计 / 趋势图
- 私有 Registry 支持（企业版）
- 镜像加速（国内镜像）

### 阶段 4（1.0+，全面运营）

**目标**：生态繁荣、安全审核、企业功能。

**范围**：
- 可复现构建验证
- 安全扫描自动化
- 组织/团队管理
- 包迁移工具（从其他语言）
- VS Code 插件集成（依赖浏览 / 更新提示）

---

## 10. 风险与约束

### 10.1 XLANG 后端能力风险

**风险**：0.7 时 XLANG 的 HTTP server / PostgreSQL driver 可能不成熟。

**缓解**：
- 0.4-0.6 期间补齐 `std.http` server + DB driver
- 若 XLANG 后端不就绪，过渡期用 Go/Rust 写，XLANG 逐步替换
- TLS 可由 Nginx reverse proxy 卸载，XLANG 后端只处理明文 HTTP

### 10.2 语义化版本解析

**风险**：semver 解析复杂（pre-release / build metadata / range 交集）。

**缓解**：
- 复用成熟 semver 规范（SemVer 2.0）
- 阶段 1 用简化版（仅 `^` / `~` / 精确），阶段 2 完整实现
- lockfile 锁定具体版本，避免每次解析

### 10.3 包名抢注

**风险**：恶意用户抢注常见包名（如 `json` / `logger`）。

**缓解**：
- 保留名规则（§8.3）
- 早期邀请制（0.7 前仅认证用户可发布）
- 争议包名仲裁机制

### 10.4 规模扩展

**风险**：包数量增长后搜索/下载性能下降。

**缓解**：
- 搜索：PostgreSQL FTS → Elasticsearch（>10k 包时）
- 下载：CDN 缓存 + 对象存储多副本
- 数据库：读写分离 + 连接池

---

## 11. 决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 域名 | `registry.xlang.dev` | 已注册；符合行业惯例 |
| 品牌名 | Xlang Registry | 简洁专业 |
| 后端语言 | XLANG 自身 | dogfooding + 验证语言能力 |
| 前端 | React + TypeScript | 生态丰富、SSR 友好 |
| 数据库 | PostgreSQL | 成熟、JSON 支持、全文搜索 |
| 对象存储 | MinIO（自建）/ S3（云） | 灵活、成本可控 |
| 包格式 | `.xlangpkg`（gzip tar） | 与 crates.io 一致 |
| lockfile | `xlang.lock`（TOML） | 人类可读、git diff 友好 |
| semver range | Cargo 风格（`^` / `~`） | 用户熟悉、规范成熟 |
| 上线时机 | 0.7（2027 Q3-Q4） | 语言稳定 + std 完善 + 社区形成 |
| 包名保留 | `std-*` / `xlang-*` / `x-*` | 防抢注、保护官方生态 |

---

## 12. 与现有文档的关系

| 文档 | 关系 |
|------|------|
| [xlang.toml](../xlang.toml) | `[dependencies]` 占位，阶段 1 定型 |
| [xlang-toml-实现分析.md](xlang-toml-实现分析.md) | xlang.toml 阶段 4 = 本文档阶段 1 |
| [自举方法.md](自举方法.md) | 自举完成是本文档阶段 1 的前置 |
| [当前问题分析.md](当前问题分析.md) | 当前阻塞项，不包含包管理 |

---

## 13. 立即可做的准备（不阻塞自举）

| 项 | 动作 | 耗时 |
|----|------|------|
| DNS 解析 | `registry.xlang.dev` 指向 placeholder | 10 分钟 |
| TLS 证书 | Let's Encrypt 申请 | 30 分钟 |
| Placeholder 页 | "Xlang Registry · Coming 2027" | 1 小时 |
| 域名续费提醒 | 设置日历提醒 | 5 分钟 |
| xlang.toml `[dependencies]` schema | 本文档 §6 已定稿 | 0（已完成） |

**当前主线仍是自举**。包管理网站是 2027 年的事，现在只做"零成本准备"（DNS + placeholder）。
