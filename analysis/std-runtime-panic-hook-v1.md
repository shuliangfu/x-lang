# STD-028 std.runtime panic 钩子跨平台一致 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-028、`EXC-002`、`SAFE-007`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-028 | `std.runtime` panic 终止链与证据钩子三平台一致文档 + 门面 API |

与 `analysis/exc-panic-abort-v1-rfc.md`（EXC-002）示例联动。

---

## 2. 终止链（统一模型）

```
panic() / panic(expr) / assert / UB
        ↓
std.runtime.runtime_panic()  （用户显式 panic/abort）
        ↓
shux_panic_(has_msg, msg_val)   ← runtime_panic.o / codegen 内联
        ↓
shux_crash_evidence_collect_c   ← 弱符号；backtrace.o 强符号（SAFE-007）
        ↓
平台终止（abort / _exit / syscall exit）
```

| 入口 | 模块 |
|------|------|
| `panic_hook_collect` | `std.runtime` 手动钩子（STD-028） |
| `collect_crash_evidence` | `std.backtrace` 同 C 符号 |

---

## 3. 三平台终止矩阵

| 平台 / 产物 | `shux_panic_` 实现 | 终止方式 | 钩子 |
|-------------|----------------------|----------|------|
| **Linux x86_64**（`.s` 存在） | `runtime_panic_x86_64.s` | `syscall exit(134)` | 无 collect（freestanding） |
| **Linux / Windows / macOS**（`.c`） | `runtime_panic.c` | `abort()` | weak `shux_crash_evidence_collect_c` |
| **macOS ARM64 备选** | `runtime_panic_arm64.c` | `_exit(1)` | 同上 weak collect |

**v1 铁律**：无论终止码如何实现，`panic()` 均 **不可恢复**（EXC-002 §2）。

---

## 4. std.runtime API

| 函数 | 说明 |
|------|------|
| `panic()` / `abort()` | noreturn；经 `runtime_panic` → `shux_panic_` |
| `runtime_ready()` | 初始化占位；返回 0 |
| `panic_hook_collect(has_msg, msg_val)` | 委托 `shux_crash_evidence_collect_c` |

环境变量（经 backtrace 强符号）：`SHUX_CRASH_EVIDENCE=1`、`SHUX_CRASH_EVIDENCE_DIR`（见 SAFE-007）。

---

## 5. EXC-002 联动示例

| 示例 | 路径 | STD-028 验证点 |
|------|------|----------------|
| runtime 门面 | `tests/exc/runtime_ready.sx` | `runtime_ready` 不 panic |
| 钩子 typeck | `tests/exc/panic_hook_align.sx` | `panic_hook_collect` |
| Layer A 可恢复 | `tests/exc/recoverable_result.sx` | 不走 panic 链 |
| panic 语法 | `tests/panic/main.sx` | `run-panic.sh` 非零退出 |
| EXC-002 门禁 | `tests/run-exc-panic-abort-gate.sh` | 7 case 矩阵 |

---

## 6. 验收

- manifest：`tests/baseline/std-runtime-panic-hook.tsv`
- 烟测：`tests/exc/panic_hook_align.sx`
- 报告：`shux: [SHUX_STD_RUNTIME_PANIC] status=ok`

---

## 7. 演进

- 用户可注册 `panic_hook_set`（Rust 风格）；Windows SEH 与 stderr 统一格式。
