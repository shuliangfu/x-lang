# TOOL-007 包管理器（package manager）方案 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`TOOL-006`（脚手架）、`TOOL-008`（依赖锁定）、`resolve_import_file_path`、`import`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 设计原则 K1–K6 |
| 2 | 打开 `tests/baseline/tool-pkgmgr.tsv`（包目录 + manifest 契约） |
| 3 | `./tests/run-tool-pkgmgr-gate.sh` |
| 4 | 原型：`./scripts/shux-deps-resolve.sh tests/fixtures/pkgmgr/shux.pkg.tsv` |

---

## 2. 设计原则 K1–K6

权威：`tests/baseline/tool-pkgmgr.tsv`（**6** 条 `rule_*`）。

| 原则 | 说明 | 现状 / 原型 |
|------|------|-------------|
| **K1-package-id** | 包 ID = dotted `import` 路径（`core.mem`） | 编译器已用 |
| **K2-lib-roots** | 多根解析：`-L` / manifest `lib_root` 行 | `resolve_import_file_path_multi` |
| **K3-manifest** | 项目清单 `shux.pkg.tsv`（v1 原型，非网络） | `tests/fixtures/pkgmgr/` |
| **K4-bundled-tier** | `core.*` / `std.*` 为 **bundled**（随仓库） | 仓库根 `core/` `std/` |
| **K5-resolve-proto** | `shux-deps-resolve.sh` 校验 require→文件 | `scripts/shux-deps-resolve.sh` |
| **K6-local-only** | v1 **无** registry 拉取；path/workspace 本地 | TOOL-008 锁文件 |

**解析规则**（与 driver 一致）：

1. `{lib_root}/{a}/{b}/.../{last}.x`（`a.b.c` → 路径）
2. `{lib_root}/{a}/{b}/.../mod.x`（目录模块）
3. 单段 `foo` → `{lib_root}/foo/foo.x`

---

## 3. `shux.pkg.tsv` 原型格式

```tsv
# 列：kind	key	value	notes
meta	name	demo-app	项目名
meta	version	0.1.0	semver 字符串
lib_root	.	repo	相对清单目录
require	core.mem	bundled	声明依赖
require	core.types	bundled	声明依赖
```

`shux-deps-resolve.sh` 读取清单，对每个 `require` 在 `lib_root` 列表中探测文件；全命中则 exit 0。

---

## 4. 包目录（bundled catalog）

`tests/baseline/tool-pkgmgr-catalog.tsv` 登记 **8** 个 `core.*` 模块（与 `core/*/mod.x` 对齐）。

---

## 5. 最小原型（prototype）烟测

| case_id | 路径 | 期望 |
|---------|------|------|
| `case_demo` | `tests/fixtures/pkgmgr/` | resolve OK + `main.x` 编译（native shux） |
| `case_import` | `tests/import/main.x` | 既有 import 回归 |

**report** 示例：

```
tool-pkgmgr report requires=2/2 roots=1 resolve=OK
```

---

## 6. 非目标（v1）

- 无 central registry / `shux add` 网络下载。
- 无 semver 求解器（精确 path 声明）。
- 锁文件与可重复构建见 **TOOL-008**。

---

## 7. 验证与门禁

```bash
./tests/run-tool-pkgmgr-gate.sh   # runnable：manifest + resolve hooks
./scripts/shux-deps-resolve.sh tests/fixtures/pkgmgr/shux.pkg.tsv
./tests/run-pkgmgr-resolve.sh
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-pkgmgr-v1.md` |
| manifest | `tests/baseline/tool-pkgmgr.tsv` |
| catalog | `tests/baseline/tool-pkgmgr-catalog.tsv` |
| fixture | `tests/fixtures/pkgmgr/` |
| 原型 CLI | `scripts/shux-deps-resolve.sh` |
| 库 | `tests/lib/tool-pkgmgr.sh` |

**TOOL-007 状态：定版 ✅**
