# STD-143：std.test 可执行 bench/fuzz v1

> 状态：**定版（v1）**  
> 关联：`STD-054` 占位 API、`tests/run-std-test-bench-fuzz-gate.sh`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-143 | `.x` 侧可调用 `bench_run_noop` / `fuzz_run_noop`（无需函数指针）+ 端到端烟测 |

---

## 2. 可执行 API

| API | 说明 |
|-----|------|
| `bench_run_noop(iters): i64` | 对 C 内置 noop 跑 `bench_run`，返回纳秒 |
| `fuzz_run_noop(iters): i32` | 对 C 内置 noop 跑 `fuzz_run`，推进 PRNG |

底层仍用 `test_bench_run_c` / `test_fuzz_run_c`；v1 不向 .x 暴露函数指针 cast。

---

## 3. 烟测

`tests/std-test/bench_fuzz_exec.x`：

1. `fuzz_seed` + `fuzz_next` 序列可复现  
2. `bench_run_noop` 返回 `ns >= 0`  
3. `bench_report` 输出 `shux: [SHUX_BENCH]`  
4. `fuzz_run_noop` 返回 0  

---

## 4. Gate

```bash
./tests/run-std-test-executable-gate.sh
```

报告：`shux: [SHUX_STD143_TEST_EXECUTABLE]`
