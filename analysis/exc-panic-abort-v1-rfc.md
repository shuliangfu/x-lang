# panic / abort / 可恢复错误边界 v1（EXC-002）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`EXC-001`（Result/Error 三层模型）、`std/runtime`、`core/debug`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **边界清晰** | 何时用 Result/Error（可恢复）vs panic/abort（不可恢复） |
| **库行为** | 标准库不对可预期 IO/资源错误直接 panic |
| **示例可跑** | `tests/exc/*.sx` + 既有 `run-result` / `run-panic` |
| **与 EXC-001 衔接** | 扩展 §9 为可执行规范 |

验收标准（NEXT EXC-002）：**边界文档 + 示例完成** + CI 烟测。

---

## 2. 决策树（v1）

```
错误是否可预期且调用方可处理？
├─ 是 → Layer A/B/C 返回（Result_i32 / Error / -1+侧车）
└─ 否 → 程序员断言 / 逻辑不变量
         ├─ 调试/测试：core.debug.assert*
         ├─ 不可达：core.builtin.unreachable
         └─ 终止：panic() / abort() / expect_*_or_panic（仅「必成功」）
```

**v1 无 `recover()`**：Go 式 recover 不在范围；panic = 进程终止。

---

## 3. 机制对照表

| 机制 | 模块 | 可恢复？ | 典型场景 |
|------|------|----------|----------|
| `Result_i32` + 分支 | `core.result` | ✅ | 新 API、组合逻辑 |
| `Error` / 错误码 | `std.error` | ✅ | 纯错误载体 |
| `i32 -1` + `fs_last_error` | `std.fs` 等 | ✅ | IO 热路径 |
| `unwrap_or_i32` / `expect_i32` | `core.result` | ✅ | 默认值 / 降级 |
| `expect_i32_or_panic` | `core.result` | ❌ | 程序员断言必 Ok |
| `assert` / `assert_eq_*` | `core.debug` | ❌ | 不变量 |
| `unreachable` / `abort` | `core.builtin` | ❌ | 不可达 / 硬终止 |
| `panic()` / `panic(expr)` | 语言 + `std.runtime` | ❌ | 不可恢复 |
| `std.runtime.abort` | `std.runtime` | ❌ | 同 panic（C abort 路径） |

---

## 4. panic / abort 实现（v1）

| 入口 | 行为 |
|------|------|
| `panic()` | 调用 `runtime_panic()` → `shux_panic_` → **abort** |
| `panic(expr)` | `fprintf(stderr, "%d\n", expr)` 后 abort（i32 消息） |
| `abort()` | `core.builtin` / `std.runtime` 均终止进程 |
| 除零 / bounds（M-6） | codegen → `shux_panic_`（见 `tests/ub/`） |

链接：`runtime_panic.o` 按需链入（与 freestanding 烟测一致）。

---

## 5. 库函数规则（v1 强制）

| 规则 | 说明 |
|------|------|
| **R1** | `std.io` / `std.fs` / `std.net` 同步 API：**不得**对 ENOENT 等可预期失败 panic |
| **R2** | 失败返回 Layer C 约定（`-1` / `0`）+ 文档化侧车 |
| **R3** | 仅 `*_or_panic`、`assert*`、`unreachable` 可终止 |
| **R4** | 新组合 API 优先 `Result_i32`（EXC-001 §7） |

---

## 6. 示例索引

| 示例 | 路径 | 说明 |
|------|------|------|
| Layer A 可恢复 | `tests/exc/recoverable_result.sx` | `unwrap_or` on Err |
| Layer C 可恢复 | `tests/exc/layer_c_recoverable.sx` | `fs_open` 失败 + `fs_last_error` |
| expect 必成功 | `tests/exc/expect_or_panic_ok.sx` | Ok 路径 `expect_i32_or_panic` |
| runtime 门面 | `tests/exc/runtime_ready.sx` | `runtime_ready()` |
| Result 全量 | `tests/result/main.sx` | `run-result.sh` |
| panic 语法 | `tests/panic/main.sx` | 非零退出 |
| panic 带消息 | `tests/panic/with_msg.sx` | `panic(42)` |

---

## 7. 门禁

```bash
./tests/run-exc-panic-abort-gate.sh
```

矩阵：`tests/baseline/exc-panic-abort.tsv`（7 case）

| case | 验证 |
|------|------|
| `recoverable_result` 等 4× `.sx` | exit 0 |
| `result_suite` / `error_suite` | hook 脚本 OK |
| `panic_abort` | 编译通过 + 运行非零 |

---

## 8. 与 EXC-003 关系

| 项 | EXC-002 | EXC-003 |
|----|---------|---------|
| panic 边界 | ✅ v1 | — |
| 错误码分段 | 引用 EXC-001 §5 | 模块码表细化 |
| IO_Result 映射 | 占位 | 稳定后 → `err_i32` |

---

## 9. 索引

| 资源 | 路径 |
|------|------|
| Result/Error | `analysis/exc-result-error-v1-rfc.md` |
| std.runtime | `std/runtime/mod.sx` |
| 门禁 | `tests/run-exc-panic-abort-gate.sh` |

**EXC-002 状态：定版 ✅**
