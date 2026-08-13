# STD-061：std.simd shuffle/select 生产级 bench v1

> 更新时间：2026-08-13
> 状态：**活文档**（产品 bench 权威 = `bench/r04_simd_shuffle_select.x`；闸门 `run-std-simd-prod-gate.sh`）
> 前置：STD-047 `std-simd-shuffle-select-v1.md`
> 关联：`run-perf-simd-dot.sh`、SIMD-S4、STD-SIMD-INTRINSIC
> PLATFORM: SHARED — Ubuntu gold for link/run; Darwin L2 same fixture names

---

## 1. 目标

在 STD-047 实装基础上，新增 **生产级 perf bench**：`bench/r04_simd_shuffle_select.x` 热循环须 **≥1.0×** 标量桩基线 `bench/r04_simd_shuffle_select_stub.c`。

验收：`tests/run-std-simd-prod-gate.sh` 绿；`min_benches=3`。

产品路径是 **`r04_simd_shuffle_select*`**（wave1191 rename）。
**没有** `bench/simd_shuffle_select.x` 第二套 fixture（G.7：一功能一权威）。

129 白名单里的 `run-perf-simd-xlangffle-select.sh` 是 `run-perf-simd-shuffle-select.sh` 的薄 `exec`，不是第二套 bench 体。
历史 `r04_simd_xlangffle_select*` 双关副本已删；本 RFC 不把它当 STD-061 权威。

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
xlang: [XLANG_STD061_SIMD_PROD] status=ok bench_ok=1 bench_skip=0 skip=0 ratio=1.05
```

无 native `xlang_asm` 时 manifest 仍须绿；perf runnable **SKIP**。
自举期 check 闸门暂停（2026-08-05）：产品验收以 `-L . -o` 真链 + run 为准。

2026-08-13：peel 已跨 while 外层 comptime mask，热循环 `shuffle` 走 `pshufd`。
2026-08-13：`try_inline_select` 补 fold `select(splat(k),a,b)`＋嵌套 splat 物化；同族 `try_inline_splat`。Ubuntu L2 r04 UNDEF **NONE** · ratio **2.42**（stub 0.029s／Xlang 0.012s）硬过 1.0 · `bench_ok=1`。**不**改门槛。
2026-08-13：129 `run-perf-simd-xlangffle-select.sh` 改薄 `exec` 权威 `run-perf-simd-shuffle-select.sh`；删除无引用 `r04_simd_xlangffle_select*`／dual smoke。Ubuntu L2 xffle／ss 同走权威 r04 · ratio **2.3／2.08**。

---

## 4. 联动

- manifest：`tests/baseline/std-simd-prod-wave.tsv`
- 父表：`std-simd-shuffle-select.tsv`；父 RFC `std-simd-shuffle-select-v1.md`
- 产品 ID 锚：`std/simd/README.md`（`STD-061`）
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- NEON/SVE 专用 intrinsic bench
- 与 OpenSSL/Intel IPP 对标
- 跨平台 ratio 硬门禁（Windows CI）
- 把 129 的 `xlangffle-select` 薄包装当 STD-061 第二权威
- 第二套 `bench/simd_shuffle_select.x`／`r04_simd_xlangffle_select*` 旧路径
