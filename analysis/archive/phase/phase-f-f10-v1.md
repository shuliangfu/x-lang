# 阶段 F-10 v1（test_x + portable 子集门禁）

> **F-10 v1**：在 **当前 std 混合构建**（glue + .x）下，`./xbuild test_x` 与 **Stage2 portable 子集**（D-04）可复现；无 native xlang 时 **SKIP 不 FAIL**。

## v1 范围

| 项 | 说明 |
|----|------|
| `./xbuild test_x` | → `compiler/scripts/run_compiler_tests.sh x`（G.7；`Makefile` 已删） |
| portable 子集 | 委托 `run-d04-stage2-portable-diff-gate.sh` |
| 终局 | std C=0 后全量 `run-portable-suite.sh` 硬绿（F-10 v2） |

## Gate

Honesty gate (2026-08-26): hard-fail archive DOC + xbuild `test_x`
route + d04. No soft `die→exit 0`. Soft `XLANG_F10_TEST_X_PORTABLE_FAIL`
retired. Full `./xbuild test_x` dogfood opt-in via
`XLANG_F10_RUN_TEST_X=1`. Report `doc=` / `wiring=` / `d04=` / `skip=`.

**2026-08-30 leftover native_xlang 已收**（f10-test-x-portable：leftover `stdlib_cm_native_xlang` 收敛 `dod_native_exe`；G.7 补全既有 `resolve_shu`；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested d04 portable／leftover nested test_x opt-in 不重写）。

**2026-08-30 leftover unused compiler-make SOURCE 已收**（f10-test-x-portable：unused `compiler-make.sh` sourced unused（no `xlang_compiler_make`）retired；G.7 补全既有 `resolve_shu`；显式坏 XLANG 先硬 die；leftover nested d04 portable／leftover nested test_x opt-in 不重写）。Keep `## Gate`。

```bash
./tests/run-f10-test-x-portable-gate.sh
XLANG_F10_RUN_TEST_X=1 ./tests/run-f10-test-x-portable-gate.sh
```
