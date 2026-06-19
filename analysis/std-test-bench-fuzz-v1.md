# STD-054：std.test bench / fuzz 占位 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：既有 `expect` / `test_run`、`tests/bench/*`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-test-bench-fuzz.tsv` |
| 3 | `./tests/run-std-test-bench-fuzz-gate.sh` |

---

## 2. bench 占位 API

| API | 说明 |
|-----|------|
| `bench_run(fn, iters): i64` | 调用无参 `fn` 共 `iters` 次，返回纳秒耗时 |
| `bench_report(name, len, ns): i32` | 写 `shux: [SHUX_BENCH] name=… ns=…` 到 stderr |

v1 **不**集成采样统计 / CSV；后续可接 `tests/run-perf-*.sh`。

---

## 3. fuzz 占位 API

| API | 说明 |
|-----|------|
| `fuzz_seed(): u32` | `SHUX_FUZZ_SEED` 环境变量或默认 `0xABCDEF01` |
| `fuzz_next(state: *u32): u32` | LCG 单步 |
| `fuzz_run(fn, iters): i32` | 每轮推进 PRNG 后调用 `fn` |

v1 **不**做覆盖率反馈；仅提供可复现种子与 runner 钩子。

---

## 4. 金样

| ID | 验证 |
|----|------|
| `bench_report_line` | stderr 含 `shux: [SHUX_BENCH] name=smoke` |
| `fuzz_next_nz` | `fuzz_next` 非零 |
| `expect_regress` | 既有 `tests/stdtest/main.sx` 仍通过 |

---

## 5. 门禁

```bash
./tests/run-std-test-bench-fuzz-gate.sh
```

```
shux: [SHUX_STD_TEST_BENCH_FUZZ] status=ok c_smoke=1 bench_su=1 fuzz_su=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | bench / fuzz 占位 API + 烟测 |
