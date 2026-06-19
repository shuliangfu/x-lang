# LANG-002 import 跨平台一致性 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`compiler/docs/SX与C流水线同步状态.md`、`tests/run-import.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **语法一致** | 四种 import 形式在 C 与 .sx 流水线语义对齐 |
| **路径一致** | `a.b.c` → 文件路径规则全平台相同（`-L` 驱动） |
| **行为一致** | 同一 `.sx` 在 Linux / macOS / Windows 输出相同 |
| **无平台分支** | 用户源码不写 `#ifdef` / 路径分隔符差异 |

验收标准（NEXT LANG-002）：**同一源码跨平台行为一致** + 文档 + CI 烟测。

---

## 2. 四种 import 形式（v1）

| 形式 | 示例 | `import_kinds` |
|------|------|----------------|
| **整模块** | `import("std.io");` | 0 |
| **绑定** | `const io = import("std.io");` | 1 |
| **解构** | `const { print_str } = import("std.io");` | 2 |
| **关键字段** | `import("std.async");` | 0（`async` 作路径 IDENT） |

实现：`parser.sx` / `parser.c` `collect_imports`；typeck/codegen 见 `SX与C流水线同步状态.md`。

---

## 3. 路径解析规则（v1）

库根：`shux -L <root>`（可多次）；默认 `"."`。  
逻辑入口：`resolve_import_file_path_multi`（`runtime.c`）。

### 3.1 查找顺序

对每个 `lib_root`（按 `-L` 顺序）：

1. **扁平文件**：`<root>/<a>/<b>/<c>.sx`（`.` → `/`）
2. **单段 fallback**：`<root>/<name>/<name>.sx`（如 `preprocess/preprocess.sx`）
3. **模块目录**：`<root>/<a>/<b>/mod.sx`
4. **入口同目录**（单段）：`<entry_dir>/<name>.sx`
5. **入口相对**（带点）：`<entry_dir>/<...>.sx` 或 `mod.sx`（含包前缀去重）

### 3.2 路径写法约定

| 规则 | 说明 |
|------|------|
| **只用 `.` 分段** | `import("core.types");` — 禁止 `\` 或 `/` 出现在源码路径 |
| **小写 + 下划线** | 与仓库 `core/`、`std/` 布局一致 |
| **多 `-L`** | 先匹配的 root 优先（compiler + std 联调） |

### 3.3 跨平台文件系统

| 平台 | 行为 |
|------|------|
| Linux / macOS / Windows MSYS | 统一 POSIX 路径拼接；`-L .` 相对 repo 根 |
| 失败 | `shux: cannot open import 'path' (tried ...)` — 三平台文案一致 |

---

## 4. C 与 .sx 流水线对齐（v1）

| 能力 | C (`parser.c`) | .sx (`parser.sx`) | 测试 |
|------|----------------|-------------------|------|
| 整模块 import | ✅ | ✅ | `tests/import/main.sx` |
| const 绑定 | ✅ | ✅ | `const_binding.sx` |
| const 解构 | ✅ | ✅ | `const_select.sx`（整模块等价 body；解构 codegen 见文档） |
| 关键字路径段 | ✅ | ✅ | `tests/parser/import_std_async.sx` |
| 缺失模块 | ✅ 报错 | ✅ 报错 | `missing_module.sx` |

**v1 原则**：用户只写一套 import；平台差异仅在工具链与 `-L`，不在源码。

---

## 5. 跨平台烟测矩阵

| case | 脚本 | 验证 |
|------|------|------|
| `import_suite` | `run-import.sh` | 4 形式 + 缺失模块 |
| `stdlib_import` | `run-stdlib-import.sh` | 多 core 模块 |
| `async_keyword_path` | `parser/import_std_async.sx` | `async` 作路径段 |

矩阵文件：`tests/baseline/lang-import-crossplatform.tsv`  
门禁：`tests/run-lang-import-gate.sh`

---

## 6. 变更流程（v1）

1. 修改 `resolve_import_file_path_multi` 须更新本文 §3 + 增烟测
2. 新增 import 语法须 C/.sx 双 pipeline 同步（见 `SX与C流水线同步状态.md`）
3. 破坏性路径规则变更须 major 文档 bump

---

## 7. v2 预留

| 项 | 说明 |
|----|------|
| `const { a, b }` 全平台 codegen 前缀 | const_select 改解构形式硬门禁 |
| 包管理 / 版本锁 | TOOL-008 |
| 条件 import | LANG-001 feature gate |

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 烟测 | `tests/run-import.sh`、`tests/run-stdlib-import.sh` |
| 门禁 | `tests/run-lang-import-gate.sh` |
| 解析实现 | `compiler/src/runtime.c` |
| 同步状态 | `compiler/docs/SX与C流水线同步状态.md` |

**LANG-002 状态：定版 ✅**
