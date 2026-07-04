# STBL-004：`import std.*` 解析与 `-L` 布局 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STBL-001（Tier-S 注册表）、TOOL-007（包管理器）、TOOL-008（依赖锁定）、`resolve_import_file_path_multi`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4（import 规则与物理布局） |
| 2 | 打开 `tests/baseline/stbl-import-std-layout.tsv`（resolve 探针） |
| 3 | `./tests/run-stbl-004-import-std-layout-gate.sh` |
| 4 | 交叉阅读 `analysis/tool-pkgmgr-v1.md`（K1–K6）与 `analysis/tool-deps-lock-v1.md` |

---

## 2. import 解析规则

`import("std.io");` 中的路径为 **dotted 模块 ID**（与 TOOL-007 **K1-package-id** 一致）。编译器在 **lib_roots**（由 `-L` 与 `shux.pkg.tsv` 的 `lib_root` 行提供）上按序探测：

| 优先级 | 模式 | 示例 `import("std.io")` | 物理路径（`lib_root=.`） |
|--------|------|----------------------|--------------------------|
| 1 | `{root}/{a}/{b}/.../{last}.x` | 末段单文件 | `std/io.x`（若存在） |
| 2 | `{root}/{a}/{b}/.../mod.x` | **目录模块（std 主路径）** | `std/io/mod.x` |
| 3 | 单段 `foo` | `import preprocess` | `{root}/preprocess/preprocess.x` |

**多 `-L`**：从左到右尝试每个 lib_root，首个可读文件命中即成功（**K2-lib-roots**）。

**入口目录 fallback**：单段 import 可在入口 `.x` 同目录查找（多文件工程，见 `runtime.c` `resolve_import_file_path_multi`）。

**禁止**：`import xxx.c` — 仅 `.x` 模块可 import（`docs/05-函数与模块.md`）。

---

## 3. `-L` 库根布局

仓库标准布局（**bundled**，**K4-bundled-tier**）：

```
{repo}/                 ← 典型 -L . 指向此处
├── core/               ← import core.*
│   └── types/mod.x
├── std/                ← import std.*
│   ├── io/mod.x
│   ├── fs/mod.x
│   └── http/
│       ├── mod.x      ← import("std.http")
│       └── http.c      ← extern 实现，非 import 目标
└── tests/
```

| 约定 | 说明 |
|------|------|
| **扁平 std** | 无 `stdlib/`；`std/<name>/mod.x` 为主模块文件 |
| **core 同构** | `core/<name>/mod.x` 或 `core/<name>.x` |
| **测试** | `shux check -L . tests/foo/main.x`；项目根为默认 lib_root |
| **多根** | `shux -L . -L vendor/foo` — vendor 覆盖或补充 bundled |

---

## 4. 物理路径映射（Tier-S 样例）

权威模块列表：`tests/baseline/stbl-tier-s-registry.tsv`（≥28 模块）。

| import | 物理路径（`-L .`） | 备注 |
|--------|-------------------|------|
| `std.io` | `std/io/mod.x` | Tier-S |
| `std.fs` | `std/fs/mod.x` | Tier-S |
| `std.http` | `std/http/mod.x` | Tier-S |
| `std.json` | `std/json/mod.x` | Tier-S |
| `std.process` | `std/process/mod.x` | Tier-S |
| `core.types` | `core/types/mod.x` | core 对照 |

gate 对 manifest 中每条 `resolve` 行执行 `tool_pkg_resolve_import` 校验。

---

## 5. C `.o` 按需链接（ABI）

`.x` 中 `extern function foo_c` 由 **链接阶段** 解析，不走 import 路径：

| 层次 | 说明 |
|------|------|
| **按需** | 仅当模块被 import 且调用 extern 时，driver 链入对应 `std/*/xxx.o` |
| **构建** | `make -C compiler ../std/http/http.o` 或 gate 内 `ensure_std_c_o` |
| **全量** | 编译器自身 `STD_AND_PANIC_O` 含常用 std `.o`（自举 driver） |

模块变更 RFC 须填 ABI §（STBL-003 模板 §3）。

---

## 6. TOOL-007/008 联动

| 工具 | 与 import / `-L` 关系 |
|------|----------------------|
| **TOOL-007** | `shux.pkg.tsv` 声明 `lib_root` 与 `require`；`shux-deps-resolve.sh` 用与 driver 一致的解析子集探测文件 |
| **TOOL-008** | `shux.pkg.lock.tsv` 锁定 require 路径与 digest；`shux-deps-verify.sh` 保证可重复构建 |
| **STBL-001** | Tier-S manifest 登记各 `std.*` 的 `mod.x` 与 baseline TSV |

v1 **无** 网络 registry；`core.*` / `std.*` 均为仓库 bundled。

---

## 7. 验证与门禁

```bash
./tests/run-stbl-004-import-std-layout-gate.sh
```

manifest：`tests/baseline/stbl-import-std-layout.tsv`

烟测：`tests/import-std-layout/check_imports.x`（多 `std.*` import + `shux check -L .`）

**report** 示例：

```
shux: [SHUX_STBL_IMPORT_STD] status=ok resolve=12 check=1 skip=0
```
