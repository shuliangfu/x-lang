# STD-061：std.simd shuffle/select 生产级 bench v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）+ honesty**  
> 前置：STD-047 `std-simd-shuffle-select-v1.md`  
> 关联：`run-perf-simd-dot.sh`、SIMD-S4、STD-SIMD-INTRINSIC  
> PLATFORM: SHARED — Ubuntu gold for link/run; Darwin L2 same fixture names

---

## 1. 目标

在 STD-047 实装基础上，新增 **生产级 perf bench**：`bench/r04_simd_shuffle_select.x` 热循环须 **≥1.0×** 标量桩基线 `bench/r04_simd_shuffle_select_stub.c`。

验收：`tests/run-std-simd-prod-gate.sh` 绿；`min_benches=3`。

产品路径是 **`r04_simd_shuffle_select*`**（wave1191 rename）。
**没有** `bench/simd_shuffle_select.x` 第二套 fixture（G.7：一功能一权威）。

---

## 2. Bench 矩阵

| bench_id | 文件 | 角色 |
|----------|------|------|
| `bench_shuffle_hot` | `bench/r04_simd_shuffle_select.x` | import `std.simd` 生产路径 |
| `bench_stub_scalar` | `bench/r04_simd_shuffle_select_stub.c` | 纯标量 lane 桩基线 |
| `bench_hook` | `tests/run-perf-simd-shuffle-select.sh` | stub/Xlang ratio 门禁 |

热循环：**2M** 次 `shuffle` + `select`（Vec4f／Vec8i overload）。

---

## 3. Gate

```bash
./tests/run-std-simd-prod-gate.sh
```

```
xlang: [XLANG_STD061_SIMD_PROD] status=ok check=0|1 bench=0|1 skip=0|1 ratio=…
```

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 观测（自举期暂停闸门 2026-08-05）
- Manifest（DOC／TSV／r04 fixture／README `STD-061`）硬失败
- Perf ratio soft SKIP（perf soft residual；不因 ratio／host-cc 缺席假红）

无 native `xlang_asm` 时闸门硬失败（不再 soft SKIP→OK）。

---

## 4. 联动

- manifest：`tests/baseline/std-simd-prod-wave.tsv`
- 父表：`std-simd-shuffle-select.tsv`；父 RFC `std-simd-shuffle-select-v1.md`
- 产品 ID 锚：`std/simd/README.md`（`STD-061`）
- CI：`tests/run-portable-suite.sh`

---

## 5. Evolution

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | 初版 prod bench 矩阵 |
| honesty | 2026-08-26 | soft→硬绿：`## 3. Gate`；DOC 对齐 `stub/Xlang`＋`r04_simd_shuffle_select`；prefer asm；check 观测；manifest hard；perf soft；报告 `check=`／`bench=`／`skip=`／`ratio=` |

---

## 6. 非目标（v2）

- NEON/SVE 专用 intrinsic bench
- 与 OpenSSL/Intel IPP 对标
- 跨平台 ratio 硬门禁（Windows CI）
- 第二套 `bench/simd_shuffle_select.x`／`r04_simd_xlangffle_select*` 旧路径
