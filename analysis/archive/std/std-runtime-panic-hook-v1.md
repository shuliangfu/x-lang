# STD-028 std.runtime panic 钩子 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`STD-028`、EXC-002、`std/runtime/mod.x`、`compiler/seeds/runtime_panic.from_x.c`

---

## 1. 目标

在 `panic()` / `abort()` 终止前，允许收集崩溃证据（backtrace、消息码等）。用户与测试通过 `panic_hook_collect` 登记参数；底层经弱符号 `xlang_crash_evidence_collect_c` 转发，强符号由 `std/backtrace` 或运行时 TU 覆盖。

| API | 说明 |
|-----|------|
| `panic_hook_collect(has_msg, msg_val)` | STD-028 公开钩子；panic 前登记证据 |
| `runtime_crash_evidence_collect_c` | `std/runtime/runtime.c` 门面 |
| `xlang_crash_evidence_collect_c` | C/asm 弱符号；`XLANG_WEAK`（`xlang_weak.h`）默认实现；Windows 强符号 |

交叉引用：`analysis/archive/exc/exc-panic-abort-v1-rfc.md`（EXC-002 终止语义；`exc-panic-abort-v1-rfc.md`）。

---

## 2. 终止链

```
用户 panic() / abort()
  → runtime_panic / runtime_abort (std/runtime/runtime.c)
  → xlang_panic_(has_msg, msg_val)  [runtime_panic.c / runtime_panic_x86_64.s / runtime_panic_arm64.c]
  → xlang_crash_evidence_collect_c (weak → backtrace 强符号)
  → abort() / _exit(1)
```

- **门面**：`std/runtime/runtime.c` 导出 `runtime_panic` / `runtime_abort`，并转发 `runtime_crash_evidence_collect_c`。
- **弱钩子**：`compiler/seeds/runtime_panic.from_x.c` 内 `XLANG_WEAK xlang_crash_evidence_collect_c`（POSIX）；Windows/Cygwin 为强符号默认实现。
- **汇编路径**：Linux x86_64 可用 `runtime_panic_x86_64.s` 提供 `xlang_panic_`（freestanding）。

---

## 3. 三平台终止矩阵

| 平台 | xlang_panic_ 实现 | 证据收集 | 最终终止 |
|------|------------------|----------|----------|
| **Linux x86_64** | `runtime_panic.c` 或 `runtime_panic_x86_64.s` | weak → backtrace.o | `abort()` |
| **macOS arm64/x64** | `runtime_panic.c` / `runtime_panic_arm64.c` | weak → backtrace.o | `abort()` / `_exit(1)` 备选 |
| **Windows MSYS** | `runtime_panic.c` | weak → backtrace.o | `abort()` |

---

## 4. 验收

- Manifest：`tests/baseline/std-runtime-panic-hook.tsv`
- 烟测：`tests/exc/panic_hook_align.x`、`tests/exc/runtime_ready.x`
- 联动：`tests/run-exc-panic-abort-gate.sh`（EXC-002；闸内 observational）
- Gate：`tests/run-std-runtime-panic-hook-gate.sh`
- 报告：`xlang: [XLANG_STD_RUNTIME_PANIC] status=ok`

---

## 5. 演进

- 与 SAFE-007 崩溃证据目录、`std/backtrace` 强符号收集对齐。
- v2：可注册用户钩子链（Rust `set_hook` 风格）。

---

## 6. Gate

```bash
./tests/run-std-runtime-panic-hook-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `panic_hook_align.x` + `runtime_ready.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- EXC-002 委托 **观测**（报告 `exc=`；禁止 soft-SKIP 整闸却报 OK）
- EXC RFC 活路径：`analysis/archive/exc/exc-panic-abort-v1-rfc.md`（禁 top-level 复活）
- 报告行：`check=`／`hook=`／`ready=`／`exc=`／`skip=`（硬绿信号＝`hook=`／`ready=`）

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/std/std-runtime-panic-hook-v1.md` |
| EXC-002 RFC | `analysis/archive/exc/exc-panic-abort-v1-rfc.md` |
| manifest | `tests/baseline/std-runtime-panic-hook.tsv` |
| 库 | `tests/lib/std-runtime-panic-hook.sh` |
| 门禁 | `tests/run-std-runtime-panic-hook-gate.sh` |
| 烟测 | `tests/exc/panic_hook_align.x`、`tests/exc/runtime_ready.x` |
| README | `std/runtime/README.md` |

旧闸偏 `xlang-c`／无 native 则 soft SKIP 却报 OK／钉死已归档 top-level EXC RFC／缺 `## 6. Gate`＝portable 假红；产品 asm 烟测本绿（runnable）。

**STD-028 状态：定版 ✅ · Gate honesty soft→硬绿**

### Changelog

| Ver | Date | Note |
|-----|------|------|
| v1.0 | 2026-06-19 | 定版：终止链 + 三平台矩阵 + 弱钩子 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；`## 6. Gate`；hook/ready exit0 硬；EXC 观测；报告 `check=`／`hook=`／`ready=`／`exc=`／`skip=` |
