# STD-047：std.simd shuffle/select 矢量化实装 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：SIMD-S4、`compiler/pipeline_glue.c` 内联 + lane-scalar emit

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-simd-shuffle-select.tsv` |
| 3 | `./tests/run-std-simd-shuffle-select-gate.sh` |
| 4 | 烟测：`tests/simd/shuffle_select_roundtrip.sx` |

---

## 2. 双层实现

| 层 | 行为 |
|----|------|
| **编译器内联** | `vec4f_shuffle` / `vec8i_shuffle` → x86 `pshufd`/`vpshufd`；arm64 `ld1`/`ins`/`st1`；`vec*_select` → x86 `cmpgt*`/`and`/`or` 或 arm64 `cmgt`/`fcmgt`/`bit` |
| **.sx 回退** | `std/simd/mod.sx` lane-scalar：`v[mask[i]]`、三元 `mask[i]!=0 ? a[i]:b[i]` |

环境变量 `SHUX_SIMD_HW=0` 可强制走 lane-scalar emit（仍可由编译器内联 .sx 体）。

---

## 3. API 语义

| API | 说明 |
|-----|------|
| `vec4f_shuffle(v, mask)` | `mask: [4]i32` 编译期；`r[i]=v[mask[i]]` |
| `vec8i_shuffle(v, mask)` | `mask: [8]i32`；两半对称时可硬件 `vpshufd` |
| `vec4f_select(mask,a,b)` | `mask[i]!=0.0` → `a[i]`，否则 `b[i]` |
| `vec8i_select(mask,a,b)` | `mask[i]!=0` → `a[i]`，否则 `b[i]` |
| `simd_shuffle` / `simd_select` | 委托 `vec8i_*`（`@shuffle` / `@select` 目标） |

---

## 4. 门禁

```bash
./tests/run-std-simd-shuffle-select-gate.sh
```

```
shux: [SHUX_STD_SIMD_SHUFFLE_SELECT] status=ok shuffle=1 select=1 s4=1 skip=0
```

联动：`tests/run-simd-s4-gate.sh`（编译 + x86 objdump 探针）。

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.1 | 2026-06-18 | arm64 NEON：`simd_enc.c` 实装 shuffle（ins）与 select（cmgt/fcmgt+bit）；Vec8i 双 128-bit 半幅 |

---

## 6. STD-061 生产级 bench

详见 `analysis/std-simd-prod-v1.md`：`tests/bench/simd_shuffle_select.sx` vs `simd_shuffle_select_stub.c`，`run-perf-simd-shuffle-select.sh` ratio **≥1.0×**。
