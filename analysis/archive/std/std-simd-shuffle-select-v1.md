# STD-047：std.simd shuffle/select 矢量化实装 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）+ honesty**  
> 关联：SIMD-S4、`compiler/pipeline_glue.c` 内联 + lane-scalar emit

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-simd-shuffle-select.tsv` |
| 3 | `./tests/run-std-simd-shuffle-select-gate.sh` |
| 4 | 烟测：`tests/simd/shuffle_select_roundtrip.x` |

---

## 2. 双层实现

| 层 | 行为 |
|----|------|
| **编译器内联** | `shuffle` / `select` → x86 `pshufd`/`vpshufd` / `cmpgt*`/`and`/`or` 或 arm64 `ins` / `cmgt`/`fcmgt`/`bit` |
| **.x 回退** | `std/simd/mod.x` lane-scalar：`v[mask[i]]`、三元 `mask[i]!=0 ? a[i]:b[i]` |

环境变量 `XLANG_SIMD_HW=0` 可强制走 lane-scalar emit（仍可由编译器内联 .x 体）。

---

## 3. API 语义

| API | 说明 |
|-----|------|
| `shuffle(v, mask)` | overload Vec4f / Vec8i；`mask: i32[N]`；`r[i]=v[mask[i]]` |
| `select(mask,a,b)` | overload；`mask[i]!=0` → `a[i]`，否则 `b[i]` |
| `select_lane(mask, a, b)` | lane helper（产品短名；非 `vec8i_select_lane`） |
| lane-scalar | `.x` 回退路径；`v[mask[0]]` 等 |

---

## 4. Gate

```bash
./tests/run-std-simd-shuffle-select-gate.sh
```

```
xlang: [XLANG_STD_SIMD_SHUFFLE_SELECT] status=ok check=0|1 shuffle=1 select=1 s4=0|1 skip=0
```

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 观测（自举期暂停闸门 2026-08-05）
- `tests/simd/shuffle_select_roundtrip.x` exit 0 硬失败（无 soft SKIP）
- `tests/run-simd-s4-gate.sh`：x86_64 硬；其它平台观测

联动：`tests/run-simd-s4-gate.sh`（编译 + x86 objdump 探针）。

---

## 5. Evolution

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.1 | 2026-06-18 | arm64 NEON：`simd_enc.c` 实装 shuffle（ins）与 select（cmgt/fcmgt+bit）；Vec8i 双 128-bit 半幅 |
| honesty | 2026-08-26 | soft→硬绿：`## 4. Gate`；DOC 补 `select_lane`；prefer asm；check 观测；roundtrip hard；报告 `check=`／`shuffle=`／`select=`／`s4=`／`skip=` |

---

## 6. STD-061 生产级 bench

详见 `analysis/archive/std/std-simd-prod-v1.md`：`bench/r04_simd_shuffle_select.x` vs stub，`run-perf-simd-shuffle-select.sh` ratio **≥1.0×**（perf soft 另项；本波不啃）。
