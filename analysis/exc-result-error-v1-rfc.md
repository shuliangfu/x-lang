# Result/Error 语义 v1 设计定版（EXC-001）

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 统一 `core.result`、`std.error` 与标准库既有返回约定  
> 关联：`EXC-002`（panic/abort 边界）、`EXC-003`（错误码分层）、`analysis/Result寄存器化.md`

---

## 1. 目标与定位

| 目标 | 说明 |
|------|------|
| **风格统一** | 标准库与用户代码对「成功/失败」有唯一、可文档化的语义 |
| **零成本优先** | 热路径保留 `i32`/寄存器返回；结构化错误用 `Result_i32` 双槽 ABI |
| **可互操作** | 错误码为 `i32`，与 C errno / 平台 API 可桥接 |
| **可演进** | v1 定 concrete 类型；泛型 `Result<T,E>` 待语言实参就绪（EXC-003 扩展码表） |

验收标准（NEXT EXC-001）：**标准库错误返回风格在本文档中定版，且 core/std 现有 API 与约定一致**。

---

## 2. 三层模型（v1）

```
┌─────────────────────────────────────────────────────────────┐
│  Layer A：core.result.Result_i32   │  值 + 错误（双寄存器）   │
├────────────────────────────────────┼──────────────────────────┤
│  Layer B：std.error.Error          │  纯错误载体（code: i32） │
├────────────────────────────────────┼──────────────────────────┤
│  Layer C：Legacy 标量返回          │  热路径 / C FFI 薄包装   │
│  （i32/i64/*T + 侧车 errno）       │                          │
└─────────────────────────────────────────────────────────────┘
```

| 层 | 模块 | 适用场景 |
|----|------|----------|
| **A** | `core.result` | 新 API：成功返回 **值** + 明确错误码；需组合 `or`/`and` |
| **B** | `std.error` | 仅表达成败/错误码；无成功 payload 或 payload 已由其他方式返回 |
| **C** | `std.io` / `std.fs` 等 |  syscall 级热路径、C 互操作、已有 `-1`/`0` 约定 |

**v1 原则**：不强制一次性把 Layer C 全部迁到 Layer A；但**新公开 API**须按 §4 选型，并在文档注释中标明层级。

---

## 3. Layer A：`Result_i32`（core.result）

### 3.1 布局与 ABI

见 `analysis/Result寄存器化.md`：

```su
allow(padding) struct Result_i32 {
  value: i32;   // 成功值
  _pad1: i32;
  err: i32;     // 0 = Ok，非 0 = Err
  _pad2: i32;
}
```

- 总大小 **16 字节** → x86-64 SysV **RAX/RDX 双寄存器返回**，错误检查无额外内存读。
- **成功判定**：`err == 0`（`is_ok_i32` / `is_err_i32`）。
- **构造**：`ok_i32(x)` / `err_i32(code)`。

### 3.2 标准操作（v1 已实现）

| 函数 | 语义 |
|------|------|
| `unwrap_or_i32(r, default)` | Ok → value；Err → default |
| `expect_i32(r, default)` | 同 `unwrap_or_i32` |
| `expect_i32_or_panic(r)` | Ok → value；Err → `panic()` |
| `or_i32(r, other)` | 第一个 Ok 或 fallback |
| `and_i32(r, other)` | 第一个 Err 或继续 |

### 3.3 错误码字段

- `Result_i32.err` 使用 **与 `std.error` 相同的 i32 码表**（§5）。
- `value` 在 Err 时为 **未定义**（应置 0；调用方不得读取）。

---

## 4. Layer B：`std.error.Error`

### 4.1 类型

```su
struct Error {
  code: i32;   // 0 = 无错误
}
```

- `error_ok()` → `0`
- `error_from_code(c)` / `error_code(e)` / `error_is_ok` / `error_is_err`

### 4.2 与 Result_i32 关系

| 概念 | Result_i32 | Error |
|------|------------|-------|
| 成功标志 | `err == 0` | `code == 0` |
| 错误码 | `err` | `code` |
| 成功 payload | `value` | 无 |

**转换约定（v1 手写，无语言 ? 操作符）**：

```su
// Err → Result
let r: Result_i32 = err_i32(error_code(e));

// Result → 是否失败
if (is_err_i32(r)) { let c: i32 = r.err; ... }
```

---

## 5. 错误码约定（v1 全局）

### 5.1 基本规则

| 规则 | 说明 |
|------|------|
| **0** | 成功 / 无错误 |
| **非 0** | 错误；具体含义由模块或全局码表定义 |
| **符号** | std 库 **逻辑错误** 推荐 **负数**（与 POSIX errno 正数区分） |
| **平台 errno** | **不**嵌入返回值；通过 `fs_last_error()` 等侧车查询 |

### 5.2 全局保留码（std.error）

| 码 | 常量 | 含义 |
|----|------|------|
| `0` | `error_ok()` | 成功 |
| `-1` | `error_code_alloc_fail()` | 分配失败 |
| `-2` | `error_code_invalid()` | 无效参数 / 越界 |
| `-3` | `error_code_not_found()` | 未找到 |

模块专用码从 **-1000** 起分段（细节见 **EXC-003** `analysis/exc-error-code-layer-v1.md`）；v1 仅要求 **不得占用 0** 且 **与上表冲突时优先用全局码**。

---

## 6. Layer C：Legacy 标量约定（v1 允许，须文档化）

下列模式在 **std.io / std.fs / std.net** 热路径保留，与 Layer A **并存**：

### 6.1 i32 状态码

| 模式 | 示例 | 语义 |
|------|------|------|
| `0` / `-1` | `fs_open`, `register` | `0` 成功，`-1` 失败 → 可调 `fs_last_error()` |
| `≥0` / `-1` | `submit_read` | `≥0` 字节数或状态，`-1` 错误 |
| 计数 | `vec_push` 等 | 非负成功，负值错误（对齐各模块注释） |

### 6.2 i64 读写

| 返回值 | 语义 |
|--------|------|
| `>0` | 读写字节数 |
| `0` | EOF（读） |
| `-1` | 错误 |

### 6.3 指针

| 返回值 | 语义 |
|--------|------|
| 非 null | 成功 |
| `0` / null | 失败（如 `fs_mmap_ro`） |

### 6.4 侧车 errno

- `fs_last_error()`：上次 `fs_*` 失败的平台码（errno / GetLastError）。
- **不与** `Result_i32.err` 混用：Layer C API 失败时调用方查侧车；Layer A API 直接读 `r.err`。

---

## 7. 标准库返回风格（v1 选型表）

| 模块 / API 类 | v1 风格 | 备注 |
|---------------|---------|------|
| **core.result** | Layer A | 基准实现与测试 |
| **std.error** | Layer B | 码表与 helper |
| **std.io 同步读写** | Layer C | `-1` + 字节数；热路径 |
| **std.io read_ptr** | Layer C + slice 域 | 指针/slice；错误见 timeout/负值 |
| **std.fs** | Layer C | `-1` + `fs_last_error()` |
| **std.heap/vec/map** | Layer C | 负错误码（alloc -1 等） |
| **新 core/std 组合 API** | **优先 Layer A** | 当返回值可放入 `i32` 第一槽 |
| **async IO_Result** | 占位 enum | 见 §8；EXC-002 后对齐 Result |

**禁止**：同一函数名 overload 混用 Layer A 与 Layer C 且无文档说明。

---

## 8. 异步与 IO_Result（占位）

`std.io.driver.IO_Result`（`Ok | Err | Timeout | Cancelled`）为 **async 驱动占位**：

- v1 **不**替代 `Result_i32`；
- 完成回调/状态机稳定后，映射为：
  - `Ok` → `ok_i32(payload)` 或 void success
  - `Err` → `err_i32(code)`
  - `Timeout` / `Cancelled` → 模块分段错误码（EXC-003）

---

## 9. 与 panic 的边界（概要；详 **EXC-002** `analysis/exc-panic-abort-v1-rfc.md`）

| 机制 | 用途 |
|------|------|
| `Result_i32` + 显式分支 | **默认**：可恢复错误 |
| `expect_i32_or_panic` | 程序员断言「必成功」 |
| `core.debug.assert` / `unreachable` | 逻辑不变量违反 |
| `std.runtime.panic` / `abort` | 不可恢复终止 |

**v1 规则**：库函数 **不得** 对可预期 IO 错误直接 panic；须返回 Layer A/B/C。仅 `*_or_panic` / debug API 可 panic。

---

## 10. 验收与 CI

| 脚本 | 覆盖 |
|------|------|
| `tests/run-result.sh` | `ok_i32` / `err_i32` / `unwrap_or` / `or` / `and` / panic 路径 |
| `tests/run-error.sh` | `std.error` 基础 |
| `tests/run-all-bstrict.sh` | 含上述两者 |

**审阅通过条件**：

- 本文档定版 ✅  
- `core/result/mod.sx`、`std/error/mod.sx` 与 §3–§7 一致  
- 标准库模块注释遵循 §7 选型表  

---

## 11. v2 预留（EXC-003 / EXC-004）

| 项 | 说明 |
|----|------|
| 泛型 `Result<T,E>` | T/E 为寄存器可容纳类型时复用双槽 ABI |
| `?` / `try` 语法 | 错误传播糖 |
| 错误链 / context | EXC-004 ✅ `analysis/exc-error-chain-v1.md` |
| IO/fs 逐步 Result 化 | 性能对比后分批迁移 |
| `map` / `and_then` | 需函数类型支持 |

---

## 12. 文档索引

| 资源 | 路径 |
|------|------|
| Result ABI | `analysis/Result寄存器化.md` |
| core.result | `core/result/mod.sx` |
| std.error | `std/error/mod.sx` |
| panic 运行时 | `std/runtime/mod.sx` |
| 测试 | `tests/result/main.sx`、`tests/error/main.sx` |
| 路线图 | `NEXT.md` EXC-001 / EXC-002 |

**EXC-001 状态：定版 ✅**（Layer C 热路径保留为 documented exception；新 API 优先 Layer A。）
