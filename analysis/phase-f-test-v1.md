# 阶段 F-test v1（std.test 去 C）

> **F-test v1**：删除 **`test.c`**；锚点 **`test.x`**；断言/runner/bench 在 **`test_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `test.c`（196 行） | `test.x` + `test_glue.c` |
| `test.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_TEST_V1_FAIL=1 ./tests/run-f-test-v1-gate.sh
./tests/run-std-test-bench-fuzz-gate.sh
./tests/run-std-test-executable-gate.sh
./tests/run-std-test-runner-gate.sh
```

## 下一项

- **F-test v2** ✅ / **F-url v1** ✅ / **F-schema v1** ✅
