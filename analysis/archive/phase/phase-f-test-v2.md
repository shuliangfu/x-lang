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

## 门禁

```bash
SHUX_F_TEST_V2_FAIL=1 ./tests/run-f-test-v2-gate.sh
./tests/run-std-test-bench-fuzz-gate.sh
./tests/run-std-test-executable-gate.sh
./tests/run-std-test-runner-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-cache v2** / **F-url v2**（LRU / URL 解析逻辑下沉）
