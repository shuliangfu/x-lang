# C6 X ABI P0b 范围审计报告

**日期**：2026-07-19
**调查员**：assistant（静态源码全量扫描）
**状态**：审计完成；推荐 3 波拆分执行
**依据**：[X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.2 / §4.3
**目标**：为 P0b 实施提供精准范围 + 风险地图 + 分波策略

---

## 0. 摘要（TL;DR）

| 项 | 数值 | 状态 |
|----|------|------|
| 设计文档原始估计（P0b 核心范围） | ~14 个 C 运行时调用 | ✅ 全部已标注 `extern "C"` |
| 实测 `extern "C"` 声明总数（compiler + std） | **3035 个** | 多数为合法 C ABI（dispatch / runtime / libc 封装） |
| 实测 `extern function`（X ABI 默认）总数 | **2431 个** | 多数为 XLANG 模块桥接，合法保持 X ABI |
| 实测 `extern "x"`（显式 X ABI） | **0 个** | 设计允许，暂未使用 |
| **调用点 unsafe 包裹违规** | **9 处** | 🔴 P0 契约违反（main.x 6 + asm_libroot/std/fs/mod.x 3） |
| **声明/定义 ABI 不一致** | **3 处** | 🔴 main.x 声明 `extern "C"` vs runtime_io_abi.x 定义 X ABI |
| std/ 库 C 库包装待标注 | ~557+ 个 | 🟡 远期，自举前不强制（P0a 语义降级保护） |

**核心结论**：
1. **设计文档 §3.2.2 定义的 P0b 核心 14 个 C 运行时调用全部已正确标注** ✅
2. **真正待修复的 P0b 债务是 9 处 unsafe 包裹违规 + 3 处 ABI 一致性**（小债，可一波收口）
3. **std/ 库 ~557 个 C 库包装待标注是远期债**（自举前 P0a 语义降级下不阻塞，可顺延 P1 之后）
4. **P0b 拆分策略**：3 波收口（unsafe 修复波 → ABI 一致性波 → std/ 标注波远期）

---

## 1. 实测统计

### 1.1 总量统计（2026-07-19 全量扫描）

| ABI 类别 | 数量 | 说明 |
|---------|------|------|
| `extern "C" function`（C ABI） | **3035** | 调用 libc / 系统调用 / 被 C 调用的 dispatch 表 |
| `extern function`（X ABI 默认） | **2431** | XLANG-to-XLANG 桥接（`pipeline_typeck_*_c` / `ast_*_c` 等） |
| `extern "x" function`（显式 X ABI） | **0** | 语法槽位已就位，暂未使用 |
| **合计 extern 声明** | **5466** | — |

### 1.2 `extern "C"` 文件分布（Top 20）

| 文件 | 数量 | 性质 | 是否合法 C ABI |
|------|------|------|---------------|
| `compiler/src/asm/backend_enc_dispatch.x` | 231 | ASM 后端 dispatch 表（被 C 调用） | ✅ 合法 |
| `compiler/src/asm/backend_enc_dispatch_thin.x` | 230 | dispatch thin 镜像 | ✅ 合法 |
| `compiler/src/asm/pipeline_glue_strict_minimal.x` | 161 | seed 镜像（与 glue 同语义） | ✅ 合法 |
| `compiler/src/asm/backend_arch_emit_dispatch.x` | 135 | arch emit dispatch | ✅ 合法 |
| `compiler/src/asm/backend_arch_emit_dispatch_thin.x` | 135 | thin 镜像 | ✅ 合法 |
| `compiler/src/runtime/rt_run_asm_backend.x` | 122 | runtime → asm 后端桥接 | ✅ 合法 |
| `compiler/src/runtime.x` | 102 | runtime 桥接聚合 | ✅ 合法 |
| `compiler/src/runtime_link_abi.x` | 97 | link abi 桥接 | ✅ 合法 |
| `compiler/src/runtime/rt_run_compiler_parsed.x` | 96 | runtime → compiler 桥接 | ✅ 合法 |
| `compiler/src/asm/backend_try_inline_dispatch.x` | 90 | inline dispatch | ✅ 合法 |
| `compiler/src/runtime_pipeline_abi.x` | 83 | pipeline abi 桥接 | ✅ 合法 |
| `compiler/src/runtime/rt_run_x_emit.x` | 81 | runtime → x emit 桥接 | ✅ 合法 |
| `compiler/src/asm/backend_call_dispatch.x` | 79 | call dispatch | ✅ 合法 |
| `compiler/src/asm/simd_enc_thin.x` | 71 | SIMD dispatch thin | ✅ 合法 |
| `compiler/src/asm/backend.x` | 61 | backend 聚合 | ✅ 合法 |
| `compiler/src/diag_thin.x` | 53 | diag thin | ✅ 合法 |
| `compiler/src/asm/simd_loop.x` | 52 | SIMD loop dispatch | ✅ 合法 |
| `compiler/src/asm/backend_try_inline_dispatch_thin.x` | 46 | inline thin | ✅ 合法 |
| `compiler/src/runtime_driver_diagnostic.x` | 42 | driver diag 桥接 | ✅ 合法 |
| `std/fs/posix.x` | 40 | POSIX fs 封装 | ✅ 合法 |

**结论**：Top 20 全部是合法的 C ABI 使用（dispatch 表 / runtime 桥接 / libc 封装）。3035 个 `extern "C"` 中**绝大多数是合法的**，无需修改。

### 1.3 `extern function`（X ABI 默认）文件分布（Top 20）

| 文件 | 数量 | 性质 | 是否合法 X ABI |
|------|------|------|---------------|
| `compiler/src/parser/parser.x` | 261 | parser 内部桥接（C 实现 → X 调用） | ✅ 合法 |
| `std/http/mod.x` | 249 | 🟡 HTTP C 库包装（应标 `extern "C"`） | ⚠️ 待 P0b 扩展 |
| `compiler/src/typeck/typeck.x` | 238 | typeck 内部桥接 | ✅ 合法 |
| `compiler/src/ast/ast.x` | 189 | AST 内部桥接 | ✅ 合法 |
| `compiler/src/asm/backend.x` | 139 | backend 内部 | ✅ 合法 |
| `compiler/src/pipeline/pipeline.x` | 124 | pipeline 内部桥接 | ✅ 合法 |
| `std/socketio/mod.x` | 106 | 🟡 socket C 库包装 | ⚠️ 待 P0b 扩展 |
| `compiler/src/codegen/codegen.x` | 106 | codegen 内部桥接 | ✅ 合法 |
| `std/async/mod.x` | 42 | 🟡 async C 库包装 | ⚠️ 待 P0b 扩展 |
| `compiler/src/driver/compile.x` | 40 | driver 内部 | ✅ 合法 |
| `std/json/mod.x` | 37 | 🟡 JSON C 库包装 | ⚠️ 待 P0b 扩展 |
| `std/math/mod.x` | 32 | 🟡 math C 库包装 | ⚠️ 待 P0b 扩展 |
| `std/db/sqlite/mod.x` | 32 | 🟡 SQLite C 库包装 | ⚠️ 待 P0b 扩展 |
| `std/atomic/mod.x` | 30 | 🟡 atomic C 库包装 | ⚠️ 待 P0b 扩展 |
| `std/db/arrow/mod.x` | 29 | 🟡 Arrow C 库包装 | ⚠️ 待 P0b 扩展 |
| `compiler/src/main.x` | 29 | main 内部 | ✅ 合法 |
| `std/sync/mod.x` | 25 | sync 桥接 | ✅ 合法 |
| `std/net/mod.x` | 25 | net 桥接 | ✅ 合法 |
| `compiler/src/lsp/lsp_diag.x` | 25 | lsp 内部 | ✅ 合法 |
| `std/channel/mod.x` | 23 | channel 桥接 | ✅ 合法 |

**结论**：`extern function` 2431 个中，绝大多数是合法的 XLANG 模块桥接（按 [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.1 「ABI 判定标准」走 X ABI）。**只有 std/ 下的若干 mod.x 文件（http/socketio/async/json/math/sqlite/atomic/arrow 等）是 C 库包装**，按语义契约应改为 `extern "C"`（~557 个，远期债）。

---

## 2. 核心 14 个 C ABI 调用审计（设计文档 §4.3 定义）

### 2.1 声明状态（全部已标注 ✅）

按 [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.2 「需标注 `extern "C"` 的分布」定义的 14 个 C 运行时/系统调用，**全部已正确标注 `extern "C"`**：

| 文件 | 行号 | 函数 | 状态 |
|------|------|------|------|
| `compiler/src/parser/parser.x` | 36 | `std_fs_open(path: *u8): i32` | ✅ `extern "C"` |
| `compiler/src/parser/parser.x` | 37 | `std_fs_read(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/src/parser/parser.x` | 38 | `std_fs_close(fd: i32): i32` | ✅ `extern "C"` |
| `compiler/src/main.x` | 30 | `fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/src/main.x` | 31 | `fs_posix_close_c(fd: i32): i32` | ✅ `extern "C"` |
| `compiler/src/pipeline/pipeline.x` | 81 | `fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/src/pipeline/pipeline.x` | 82 | `fs_posix_close_c(fd: i32): i32` | ✅ `extern "C"` |
| `compiler/src/driver/emit.x` | 71 | `fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/src/driver/emit.x` | 72 | `fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/src/driver/emit.x` | 73 | `fs_posix_close_c(fd: i32): i32` | ✅ `extern "C"` |
| `compiler/asm_libroot/std/fs/mod.x` | 11 | `fs_open_read_c(path: *u8): i32` | ✅ `extern "C"` |
| `compiler/asm_libroot/std/fs/mod.x` | 12 | `fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/asm_libroot/std/fs/mod.x` | 13 | `fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize` | ✅ `extern "C"` |
| `compiler/asm_libroot/std/fs/mod.x` | 14 | `close(fd: i32): i32` | ✅ `extern "C"` |

**核心 14 个 C ABI 标注工作 100% 完成**（早期 P0a/P0b 阶段已收口）。

### 2.2 调用点 unsafe 包裹审计

| 文件 | 调用点 | 包裹状态 | 上下文模式 |
|------|-------|---------|------------|
| `compiler/src/parser/parser.x` | L10837 `std_fs_open(path)` | ✅ 在 L10832 `unsafe { }` 块内 | Cap-T001 whole-body unsafe FFI gate |
| `compiler/src/parser/parser.x` | L10840 `std_fs_read(fd, buf, 128)` | ✅ 在 L10832 `unsafe { }` 块内 | 同上 |
| `compiler/src/parser/parser.x` | L10841 `std_fs_close(fd)` | ✅ 在 L10832 `unsafe { }` 块内 | 同上 |
| `compiler/src/main.x` | L671 `fs_posix_write_c(fd, out.data, 262144)` | 🔴 **未包裹** | 普通函数体内 |
| `compiler/src/main.x` | L672 `fs_posix_close_c(fd)` | 🔴 **未包裹** | 同上 |
| `compiler/src/main.x` | L677 `fs_posix_write_c(fd, out.data, len as usize)` | 🔴 **未包裹** | 同上 |
| `compiler/src/main.x` | L678 `fs_posix_close_c(fd)` | 🔴 **未包裹** | 同上 |
| `compiler/src/main.x` | L685 `fs_posix_write_c(1, out.data, 262144)` | 🔴 **未包裹** | 同上（stdout 路径） |
| `compiler/src/main.x` | L690 `fs_posix_write_c(1, out.data, len as usize)` | 🔴 **未包裹** | 同上 |
| `compiler/src/driver/emit.x` | L178 `fs_posix_write_c(fd, buf, count)` | ✅ `unsafe { return ...; }` | thin unsafe wrap 模式 |
| `compiler/src/driver/emit.x` | L185 `fs_posix_close_c(fd)` | ✅ `unsafe { return ...; }` | thin unsafe wrap 模式 |
| `compiler/asm_libroot/std/fs/mod.x` | L18 `close(fd)` | ✅ `unsafe { return close(fd); }` | thin unsafe wrap |
| `compiler/asm_libroot/std/fs/mod.x` | L23 `fs_open_read_c(path)` | 🔴 **未包裹** | `open` 函数体内直接 return |
| `compiler/asm_libroot/std/fs/mod.x` | L33 `fs_posix_read_c(fd, buf, count)` | 🔴 **未包裹** | `read` 函数体内直接 return |
| `compiler/asm_libroot/std/fs/mod.x` | L38 `fs_posix_write_c(fd, buf, count)` | 🔴 **未包裹** | `write` 函数体内直接 return |
| `compiler/src/runtime_io_abi.x` | L101/383/393/403/487/524/534 `close(fd)` | ✅ 全部在 `unsafe { }` 块内 | runtime 内部封装 |

**违规总数：9 处**
- `compiler/src/main.x`：6 处（L671/672/677/678/685/690）— `driver_run_x_emit_c_set_path_and_run` 写文件/stdout 路径
- `compiler/asm_libroot/std/fs/mod.x`：3 处（L23/33/38）— `open`/`read`/`write` 三个封装函数

**未发现违规的正面对照**：
- `parser.x` 全文有 ~270 个 `unsafe { }` 块，遵循 Cap-T001 whole-body unsafe FFI gate 模式
- `driver/emit.x` 用 thin unsafe wrap 模式（每个 `extern "C"` 调用一个 `unsafe { return ...; }` 块）
- `runtime_io_abi.x` 全部 `extern "C"` 调用都在 `unsafe { }` 块内

### 2.3 P0 契约违反分析

按 [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.2 「过渡期语义降级（自举前）」：

| 阶段 | `extern "C"` 调用要求 | typeck 强制 |
|------|---------------------|------------|
| **自举前 P0a 槽位（当前）** | 解析为 C ABI，要求 unsafe | 🟡 **未强制**（语义降级） |
| **自举后 P1 语义** | C ABI，要求 unsafe | 🔴 **强制**（typeck error） |

**当前为什么没断链**：P0a typeck 槽位已识别 `extern "C"` 语法但**未激活强制 unsafe 检查**（语义降级）。typeck.x 中 `pipeline_typeck_check_extern_call_unsafe_boundary_c`（typeck.x:289）已声明但未启用 enforcement。

**P1 激活时风险**：若不修复 9 处违规，P1 激活 typeck 强制 unsafe 检查时，`main.x` 与 `asm_libroot/std/fs/mod.x` 编译失败 → **bootstrap 陷阱**（编译器自身无法编译）。

---

## 3. 声明/定义 ABI 一致性审计

### 3.1 发现的 3 处 ABI 不一致

`fs_posix_write_c` / `fs_posix_close_c` / `fs_posix_read_c` 三个函数存在**声明/定义 ABI 不匹配**：

| 函数 | 声明位置 | 声明 ABI | 定义位置 | 定义 ABI | 一致性 |
|------|---------|---------|---------|---------|-------|
| `fs_posix_write_c` | `main.x:30` | `extern "C"` | `runtime_io_abi.x:188` | `export function`（X ABI 默认） | 🔴 不匹配 |
| `fs_posix_close_c` | `main.x:31` | `extern "C"` | `runtime_io_abi.x:164` | `export function`（X ABI 默认） | 🔴 不匹配 |
| `fs_posix_read_c` | `pipeline.x:81` / `driver/emit.x:71` | `extern "C"` | `runtime_io_abi.x:176` | `export function`（X ABI 默认） | 🔴 不匹配 |

### 3.2 当前为什么不断链

P0a 语义降级下：
- `extern "C"`（声明侧）→ 按 C ABI 生成调用约定
- `export function`（定义侧，X ABI 默认）→ **也按 C ABI 生成**（语义降级，行为完全一致）

两边 codegen 行为一致，链接通过。

### 3.3 P1 激活时风险

P1 激活 X ABI 专用调用约定后：
- 声明侧期望 C ABI 调用约定（System V / AAPCS）
- 定义侧按 X ABI 调用约定（自定义寄存器分配、严格布局）
- **签名匹配但调用约定不匹配** → 参数寄存器错位 / 栈帧布局错乱 / 运行期 UB

### 3.4 修复方向

`runtime_io_abi.x` 的 `fs_posix_*` 三个函数实际封装的是 libc `write`/`close`/`read`（POSIX 系统调用），按 [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.1 ABI 判定标准应标 `extern "C"`：

```xlang
// runtime_io_abi.x 当前（X ABI 默认，与声明不一致）
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize { ... }

// 修复后（与 main.x:30 声明一致）
export extern "C" function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize { ... }
```

**注意**：`runtime_io_abi.x` 这三个函数的函数体内调用 libc `write`/`close`/`read`，所以函数体本身需要 `unsafe { }` 包裹（调用 `extern "C"` 的 libc 函数）。

---

## 4. std/ 库扩展范围（远期债）

### 4.1 待标注的 std/ C 库包装

按 [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.1 ABI 判定标准（按语义契约不按实现语言），以下 std/ 模块是 C 库包装，应标 `extern "C"`：

| 文件 | `extern function` 数 | 底层 C 库 | 优先级 |
|------|---------------------|----------|-------|
| `std/http/mod.x` | 249 | libcurl / http-parser | 🟡 中 |
| `std/socketio/mod.x` | 106 | libsocket / winsock | 🟡 中 |
| `std/async/mod.x` | 42 | libasync / pthreads | 🟡 中 |
| `std/json/mod.x` | 37 | cJSON / jansson | 🟢 低 |
| `std/math/mod.x` | 32 | libm | 🟢 低 |
| `std/db/sqlite/mod.x` | 32 | libsqlite3 | 🟢 低 |
| `std/atomic/mod.x` | 30 | stdatomic | 🟢 低 |
| `std/db/arrow/mod.x` | 29 | libarrow | 🟢 低 |
| 其他 std/ 文件 | ~32+ | 各种 | 🟢 低 |
| **合计** | **~557+** | — | — |

### 4.2 为什么自举前不强制标注

1. **P0a 语义降级保护**：`extern function`（X ABI 默认）当前生成 C ABI 调用，与 `extern "C"` 行为一致 → 不断链
2. **P1 激活前可顺延**：自举完成后才激活 X ABI 专用调用约定，自举前 std/ 标注不影响 bootstrap
3. **工作量巨大**：557+ 个机械替换，跨 ~10 个文件，应作为多波工程分批推进
4. **非阻塞自举**：自举的核心路径（compiler/src/）已无违规，std/ 是库扩展，不进 bootstrap 链

### 4.3 std/ 标注时机建议

**自举后 P1-P2 之间**：作为独立工程立项 `std-c-abi-annotation.md`，按文件分批推进。每波一个 std/ 模块（如先做最小的 `std/atomic/mod.x` 30 个作 PoC，验证 typeck 强制 unsafe 后无回归，再扩展）。

---

## 5. P0b 拆分策略（3 波收口）

### 5.1 波次划分

| 波 | 范围 | 工作量 | 触发 Windows 门禁 | 验证级别 |
|----|------|-------|------------------|---------|
| **波 1**：unsafe 包裹修复 | `main.x` 6 处 + `asm_libroot/std/fs/mod.x` 3 处 | 9 处包裹 + 双端验证 | 是（ABI 边界改动） | L4 双端真冷 |
| **波 2**：ABI 一致性修复 | `runtime_io_abi.x` 3 处定义改 `extern "C"` + 函数体 unsafe 包裹 | 3 处 + 双端验证 | 是 | L4 双端真冷 |
| **波 3**：std/ 扩展标注（远期） | std/ 下 ~557 个 C 库包装分文件标注 | 大债，多波 | 每波触发 | 每波 L4 |

### 5.2 波 1：unsafe 包裹修复（推荐立即执行）

**目标**：修复 9 处 `extern "C"` 调用点未包裹 unsafe 的 P0 契约违反。

**改动清单**：

#### `compiler/src/main.x` L671-690（6 处）

把 `driver_run_x_emit_c_set_path_and_run` 函数体内 6 处 `extern "C"` 调用包裹 unsafe。推荐用 thin unsafe wrap 模式（与 `driver/emit.x:178` 风格一致）：

```xlang
// 当前（违规）
let written: isize = fs_posix_write_c(fd, out.data, 262144);
fs_posix_close_c(fd);

// 修复后（thin unsafe wrap）
let written: isize = unsafe { fs_posix_write_c(fd, out.data, 262144) };
unsafe { fs_posix_close_c(fd); }
```

或者重构为函数级 unsafe wrap（如果 XLANG 支持 `unsafe fn` 语法糖）。

#### `compiler/asm_libroot/std/fs/mod.x` L22-39（3 处）

把 `open`/`read`/`write` 三个封装函数体内直接 `return` 改为 `unsafe { return ...; }`（与同文件 L18 `fs_mod_close` 风格一致）：

```xlang
// 当前（违规）
function open(path: *u8): i32 {
  return fs_open_read_c(path);
}

// 修复后（与 fs_mod_close 同模式）
function open(path: *u8): i32 {
  unsafe { return fs_open_read_c(path); }
}
```

**验证级别**：L4 双端真冷（mac arm64 + Ubuntu x86_64）。理由：`main.x` 是 compiler 入口，`asm_libroot/std/fs/mod.x` 是 SHARED fs 封装，均影响 bootstrap 链。

**触发 Windows 门禁**：是（ABI 边界 unsafe 包裹属于 [Windows兼容时序-删种子前后.md](Windows兼容时序-删种子前后.md) §5.1 「ABI / link 大改」类别）。

### 5.3 波 2：ABI 一致性修复（推荐波 1 后立即执行）

**目标**：修复 `runtime_io_abi.x` 3 处定义与声明 ABI 不匹配。

**改动清单**：

`compiler/src/runtime_io_abi.x` L164 / L176 / L188 三个函数定义改为 `export extern "C" function`，并把函数体内 libc 调用包裹 unsafe（如果尚未包裹）。

**验证级别**：L4 双端真冷。

**触发 Windows 门禁**：是。

### 5.4 波 3：std/ 扩展标注（远期，自举后）

**目标**：把 std/ 下 ~557 个 C 库包装从 `extern function`（X ABI 默认）改为 `extern "C"`。

**子波划分**（按文件大小递增，验证 typeck 强制 unsafe 后无回归再扩展）：
1. `std/atomic/mod.x`（30 个）— PoC，验证 typeck enforcement
2. `std/db/arrow/mod.x`（29 个）
3. `std/db/sqlite/mod.x`（32 个）
4. `std/math/mod.x`（32 个）
5. `std/json/mod.x`（37 个）
6. `std/async/mod.x`（42 个）
7. `std/socketio/mod.x`（106 个）
8. `std/http/mod.x`（249 个）— 最大，最后做

**前置条件**：P1 X ABI typeck 契约已稳定激活。

**每波触发 Windows 门禁**：是。

---

## 6. 风险评估

### 6.1 立即风险（自举前）

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| P1 激活 typeck 强制 unsafe 时 9 处违规断链 | 高（若不修复） | bootstrap 陷阱 | 波 1 修复 |
| P1 激活 X ABI 调用约定时 3 处 ABI 不匹配断链 | 高（若不修复） | 运行期 UB / 链接失败 | 波 2 修复 |
| std/ 557 个未标注在自举前断链 | 低 | 无（P0a 语义降级保护） | 顺延 P1 后 |

### 6.2 工程债积累风险

| 风险 | 当前状态 | 趋势 |
|------|---------|------|
| `extern function` vs `extern "C"` 语义混乱 | 中（2431 vs 3035） | 🟢 已有 X ABI 设计文档明确判定标准 |
| unsafe 包裹风格不统一 | 中（main.x 无 wrap / parser.x whole-body / emit.x thin wrap） | 🟡 应在波 1 统一为 thin unsafe wrap |
| std/ 库 C 库包装未标注 | 高（557 个） | 🟡 顺延自举后多波推进 |

### 6.3 时机决策

**立即执行（自举前必须）**：波 1 + 波 2（共 12 处改动，2 波收口）
**顺延执行（自举后 P1-P2）**：波 3 std/ 扩展标注

---

## 7. 验证清单

### 7.1 波 1 + 波 2 完成后验收

- [ ] `compiler/src/main.x` L671-690 全部 `extern "C"` 调用包裹 `unsafe { }`
- [ ] `compiler/asm_libroot/std/fs/mod.x` L22-39 全部 `extern "C"` 调用包裹 `unsafe { }`
- [ ] `compiler/src/runtime_io_abi.x` L164/176/188 改为 `export extern "C" function`
- [ ] `runtime_io_abi.x` 函数体内 libc 调用包裹 `unsafe { }`
- [ ] mac arm64 L4 真冷全测 `run-all-bstrict OK (125 scripts)` exit=0
- [ ] Ubuntu x86_64 L4 真冷全测 `run-all-bstrict OK (125 scripts)` exit=0
- [ ] Windows hybrid 门禁 `./tests/run-bootstrap-bstrict-windows-gate.sh` 通过
- [ ] lang-const 17/17 ✓
- [ ] 矩阵 rv=42 / opt / si / hello 全绿
- [ ] 全量 audit：`grep -rn 'extern "C" function' ... | wc -l` = 3038（3035 + 3 处定义改 extern "C"）

### 7.2 升钉决策

- **波 1 + 波 2** 属于 **ABI 边界改动**（unsafe 契约 + ABI 一致性）→ **必须升钉**（按 [自举进度.md](自举进度.md) §0 升钉口径）
- 新钉盘 = 波 2 commit SHA

---

## 8. 调查方法说明

### 8.1 静态扫描工具

- `grep -rn '^export extern "C" function\|^extern "C" function'` — 列出所有 `extern "C"` 声明
- `grep -rn '^export extern function\|^extern function'` — 列出所有 `extern function`（X ABI 默认）
- `grep -rn '^export extern "x" function\|^extern "x" function'` — 列出显式 X ABI（实测 0）
- 按文件分组统计：`awk -F: '{print $1}' | sort | uniq -c | sort -rn`

### 8.2 调用点 unsafe 包裹判定

- 对每个 `extern "C"` 声明的函数名 grep 调用点（排除声明行）
- 对每个调用点向上扫描 `unsafe {` 起始位置
- 若调用点在 `unsafe {` 与对应 `}` 之间 → ✅ 合规
- 若调用点在普通函数体内 → 🔴 违规

### 8.3 声明/定义 ABI 一致性判定

- 对每个 `extern "C"` 声明的函数名 grep 定义（`export function` 或 `function`）
- 比对声明 ABI 与定义 ABI
- 不一致 → 🔴 需修复

---

## 9. 相关文档

- [X-ABI-设计分析.md](X-ABI-设计分析.md) §3.2.2 P0b 范围 + §4.3 折中方案
- [自举进度.md](自举进度.md) §3 前排 #3 C6 X ABI P0b
- [当前进度.md](当前进度.md) §下一波前排 #1 C6 X ABI P0b
- [Windows兼容时序-删种子前后.md](Windows兼容时序-删种子前后.md) §5.1 ABI 改动触发门禁
- [AGENTS.md](../AGENTS.md) G.7 决策树 / G.8 平台边界 / G.9 .x 注释规范
