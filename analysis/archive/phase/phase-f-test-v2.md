# 阶段 F-test v2（std.test 逻辑 .x 下沉）

> **F-test v2 / F-ZC**：**expect / runner / bench_run / fuzz** 主逻辑在 **`test.x`**；**`test_glue.c` 已删除**；fn-ptr invoke 在 **`runtime_test_fn_invoke.c`**（compiler runtime）。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| expect / fuzz_next / runner 计数 | `test_glue.c` | **`test.x`** |
| bench_run / fuzz_run 循环 | `test_glue.c` | **`test.x`**（经 `test_call_i32_void_c`） |
| stderr 格式化 / clock / getenv | `test_glue.c` | **`test.x`** |
| fn-ptr invoke | `test_glue.c` | **`runtime_test_fn_invoke.c`** |
| `test.o` | ld -r glue + .x | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TEST_V2_FAIL` retired. STD-145 test-runner hard-delegate. test-executable／bench-fuzz remain listed residual (ld UNDEF) — not invoked.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-test-v2-gate.sh
./tests/run-std-test-runner-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（其它模块）
