# STD-028 std.runtime panic 钩子 v1

> 更新时间：2026-06-19  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-028、EXC-002、`std/runtime/mod.x`、`compiler/src/asm/runtime_panic.c`

---

## 1. 目标

在 `panic()` / `abort()` 终止前，允许收集崩溃证据（backtrace、消息码等）。用户与测试通过 `panic_hook_collect` 登记参数；底层经弱符号 `shux_crash_evidence_collect_c` 转发，强符号由 `std/backtrace` 或运行时 TU 覆盖。

| API | 说明 |
|-----|------|
| `panic_hook_collect(has_msg, msg_val)` | STD-028 公开钩子；panic 前登记证据 |
| `runtime_crash_evidence_collect_c` | `std/runtime/runtime.c` 门面 |
| `shux_crash_evidence_collect_c` | C/asm 弱符号；`__attribute__((weak))` 默认 no-op |

交叉引用：`exc-panic-abort-v1-rfc.md`（EXC-002 终止语义）。

---

## 2. 终止链

```
用户 panic() / abort()
  → runtime_panic / runtime_abort (std/runtime/runtime.c)
  → shux_panic_(has_msg, msg_val)  [runtime_panic.c / runtime_panic_x86_64.s / runtime_panic_arm64.c]
  → shux_crash_evidence_collect_c (weak → backtrace 强符号)
  → abort() / _exit(1)
```

- **门面**：`std/runtime/runtime.c` 导出 `runtime_panic` / `runtime_abort`，并转发 `runtime_crash_evidence_collect_c`。
- **弱钩子**：`compiler/src/asm/runtime_panic.c` 内 `__attribute__((weak)) shux_crash_evidence_collect_c`；无 backtrace.o 时为 no-op。
- **汇编路径**：Linux x86_64 可用 `runtime_panic_x86_64.s` 提供 `shux_panic_`（freestanding）。

---

## 3. 三平台终止矩阵

| 平台 | shux_panic_ 实现 | 证据收集 | 最终终止 |
|------|------------------|----------|----------|
| **Linux x86_64** | `runtime_panic.c` 或 `runtime_panic_x86_64.s` | weak → backtrace.o | `abort()` |
| **macOS arm64/x64** | `runtime_panic.c` / `runtime_panic_arm64.c` | weak → backtrace.o | `abort()` / `_exit(1)` 备选 |
| **Windows MSYS** | `runtime_panic.c` | weak → backtrace.o | `abort()` |

---

## 4. 验收

- Manifest：`tests/baseline/std-runtime-panic-hook.tsv`
- 烟测：`tests/exc/panic_hook_align.x`、`tests/exc/runtime_ready.x`
- 联动：`tests/run-exc-panic-abort-gate.sh`（EXC-002）
- Gate：`tests/run-std-runtime-panic-hook-gate.sh`
- 报告：`shux: [SHUX_STD_RUNTIME_PANIC] status=ok`

---

## 5. 演进

- 与 SAFE-007 崩溃证据目录、`std/backtrace` 强符号收集对齐。
- v2：可注册用户钩子链（Rust `set_hook` 风格）。
