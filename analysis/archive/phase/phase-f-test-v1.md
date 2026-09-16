# 阶段 F-test v1（std.test 去 C）

> **F-test v1**：删除 **`test.c`**；锚点 **`test.x`**；断言/runner/bench 在 **`test_glue.c`**（**F-ZC** 已删 glue）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `test.c`（196 行） | `test.x` + `test_glue.c` → **F-ZC 纯 `.x`** |
| `test.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TEST_V1_FAIL` retired. Delegates STD-145 test-runner hard. test-executable／bench-fuzz remain listed residual (ld UNDEF).

**2026-08-30 leftover XLANG fallthrough 已收**（f-test-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-test-runner 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-test-v1-gate.sh
./tests/run-std-test-runner-gate.sh
```

## 下一项

- **F-test v2** ✅ / **F-url v1** ✅ / **F-schema v1** ✅
