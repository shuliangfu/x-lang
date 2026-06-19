# STD-061：std.simd shuffle/select 生产级 bench v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-047 `std-simd-shuffle-select-v1.md`  
> 关联：`run-perf-simd-dot.sh`、SIMD-S4

---

## 1. 目标

在 STD-047 实装基础上，新增 **生产级 perf bench**：`tests/bench/simd_shuffle_select.sx` 热循环须 **≥1.0×** 标量桩基线 `simd_shuffle_select_stub.c`。

验收：`tests/run-std-simd-prod-gate.sh` 绿；`min_benches=3`。

---

## 2. Bench 矩阵

| bench_id | 文件 | 角色 |
|----------|------|------|
| `bench_shuffle_hot` | `simd_shuffle_select.sx` | import `std.simd` 生产路径 |
| `bench_stub_scalar` | `simd_shuffle_select_stub.c` | 纯标量 lane 桩基线 |
| `bench_hook` | `run-perf-simd-shuffle-select.sh` | stub/Shu ratio 门禁 |

热循环：**2M** 次 `vec4f_shuffle` + `vec4f_select` + `vec8i_shuffle` + `vec8i_select`。

---

## 3. Gate

```bash
./tests/run-std-simd-prod-gate.sh
```

```
shux: [SHUX_STD061_SIMD_PROD] status=ok bench_ok=1 bench_skip=0 skip=0 ratio=1.05
```

无 native `shux_asm` 时 manifest 仍须绿；perf runnable **SKIP**。

---

## 4. 联动

- manifest：`tests/baseline/std-simd-prod-wave.tsv`
- 父表：`std-simd-shuffle-select.tsv`；父 RFC `std-simd-shuffle-select-v1.md` §6
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- NEON/SVE 专用 intrinsic bench
- 与 OpenSSL/Intel IPP 对标
- 跨平台 ratio 硬门禁（Windows CI）
