# 性能基线：Shux asm vs C -O2 vs Zig -O2

> **PERF-001 定版**：版本/参数/机器见 [`perf-zig-baseline-v1.md`](perf-zig-baseline-v1.md) 与 `tests/baseline/zig-perf.tsv`。

## 跑法

```bash
make -C compiler bootstrap-driver-seed   # 或已有 ./compiler/shux
./tests/run-perf-baseline.sh --bench
```

可选 B-strict 列：先 `make -C compiler bootstrap-driver-bstrict`，脚本会自动尝试 `./compiler/shux_asm`。

## P0 用例（`tests/bench/`）

| 用例 | 说明 | `.x` | `.c` | `.zig` |
|------|------|-------|------|--------|
| `loop_i32` | 10⁹ 次计数循环 | ✅ | ✅ | ✅ |
| `mem_copy` | 4KiB fill + sum 两遍扫描 | ✅ | ✅ | ✅ |
| `struct_param` | 10⁸ 次按值传递 `Pair{a,b}` 并字段求和 | ✅ | ✅ | ✅ |
| `call_boundary` | 2×10⁸ 次 5 层 `f0..f4` 调用链 | ✅ | ✅ | ✅ |

## 记录表（本地填写 median real 秒）

| 用例 | Shu (default asm) | Shu (-backend c) | shux_asm | C -O2 | Zig -O2 |
|------|-------------------|------------------|---------|-------|---------|
| loop_i32 | | | | | |
| mem_copy | | | | | |
| struct_param | | | | | |
| call_boundary | | | | | |

## 门禁目标（P2）

- 逐项：**Shu default asm median ≤ Zig -O2**（先追平 C -O2，再追 Zig）。
- CI 可选：`SHUX_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench`。

## P3：编译器 compile dogfood

固定模块 **`-o` 编译**与 **`check` 重模块**耗时中位数，对比 `tests/baseline/compile-dogfood.tsv` 上限（防编译路径回退）：

```bash
./tests/run-perf-compile-dogfood.sh
SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh
SHUX=./compiler/shux_asm ./tests/run-perf-compile-dogfood.sh
SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh   # 有意优化后刷新基线
```

| case | 说明 |
|------|------|
| `loop_i32` … `call_boundary` | P0 bench `-o` |
| `perf_main` | `tests/perf-baseline/main.x -o` |
| `check_backend` / `check_parser` | 编译器 asm/parser 前端 dogfood |

## 备注

- 仅优化**用户默认** `-backend asm -o` 路径；改 backend/typeck 自举桩不计入用户 perf。
- `while` 计数循环折叠见 `backend.x` `try_fold_count_up_while`（主要惠及 `loop_i32`）。
- `add_pair(p)` 运行时内联见 `try_inline_param0_field_sum_call_elf`（`tests/boundary/struct_add_pair_inline.x`）。
- **Linux CI**（`.github/workflows/ci.yml`）在 runner 有 `zig` 时跑 `SHUX_PERF_FAIL_ON_ZIG=1` / `SHUX_PERF_FAIL_ON_IO_ZIG=1`；无 zig 时跳过 Zig 列（与 P2 同模式）。本地 median 填入上表。
