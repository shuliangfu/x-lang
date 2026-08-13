# STD-047 std.simd shuffle/select 矢量化实装

> 更新时间：2026-08-13
> 状态：**活文档**（产品面权威 = `mod.x` overload 名 `shuffle`／`select`／`select_lane`；formal c_face 孪生）
> 关联：STD-SIMD-INTRINSIC mul/dot/fma、STD-061 prod bench、STD-153 `recommend_path`
> PLATFORM: SHARED — Ubuntu gold for link/run; Darwin L2 same names

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | 打开 `tests/baseline/std-simd-shuffle-select.tsv` |
| 3 | `./tests/run-std-simd-shuffle-select-gate.sh`（自举期 **不**把 `xlang check` 当产品闸门） |
| 4 | 金样：`tests/simd/shuffle_select_roundtrip.x` |

产品 export 是 **`shuffle`／`select`／`select_lane`**（Vec4f／Vec8i overload；mangle `std_simd_shuffle_f32x4_a4` 等）。
**没有** `vec4f_shuffle`／`vec8i_select`／`vec8i_select_lane` 第二套 export（G.7：一功能一权威）。
历史类型限定名只作文档说明，不进 `mod.x`。

`import std.simd` 产品车是 formal c_face（不能 host-cc `.x` monofile）。
g18 针表现含 `select_lane` i32／f32 mid（count **23**）；仅调 `simd.select_lane` 也能 ensure `std/simd/simd.o`。
129 白名单里的 `run-std-simd-xlangffle-select-gate.sh` 是本闸门的薄包装，不是第二套 gate 体。
129 白名单里的 `run-perf-simd-xlangffle-select.sh` 是 `run-perf-simd-shuffle-select.sh` 的薄包装，不是第二套 bench 体。

---

## 2. 双层实现

每个 SIMD 操作提供两条路径：
- lane-scalar：逐 lane 标量循环（`v[mask[0]]`, `v[mask[1]]`, …），不依赖硬件 SIMD
- HW path：当 `XLANG_SIMD_HW` 可用时走原生 SIMD 指令（x86 `pshufd`／`pcmpgtd` 或等价）

`select_lane` 是单 lane 辅助：mask 非 0 取 a，否则取 b。`select` 对每个 lane 调用它。

---

## 3. API 语义

| 产品 API | 说明 |
|----------|------|
| `shuffle` | Vec4f：4-lane f32 permute，mask 为 `i32[4]`；Vec8i：8-lane i32 permute，mask 为 `i32[8]` |
| `select` | Vec4f／Vec8i blend：按 mask 逐 lane 选择 a／b |
| `select_lane` | 单 lane select（i32 与 f32 overload） |

硬件 emit：`simd.shuffle(v, m)`／`simd.select(mask, a, b)` 的 METHOD + 同块 ARRAY_LIT mask 可内联为 x86 `pshufd`／`pcmpgtd`/`cmpnleps`。

---

## 4. 门禁

```bash
./tests/run-std-simd-shuffle-select-gate.sh
# 129 alias (zero-logic wrapper):
./tests/run-std-simd-xlangffle-select-gate.sh
# 129 alias (zero-logic wrapper → shuffle-select perf):
./tests/run-perf-simd-xlangffle-select.sh
```

gate 验证 `mod.x` 含 lane-scalar 实装（`v[mask[0]]`）与产品 `select_lane` helper。
产品验收以 `-L . -o` 真链 + `shuffle_select_roundtrip.x` run=0 为准。
s2 烟测断言 Vec8i／Vec4f splat/add 与 `select_lane`；**不再**把 `placeholder()` 当退出码。
`splat(1.0)[0]` emit：try_inline_splat 对 dest esz==4 走 ARRAY_LIT `force_esz==4` 的 f64→f32 pack（未标 FLOAT_LIT 的 f64 低 32 位曾是 0.0f）。
自举期 check 闸门暂停（2026-08-05）。

回归：`run-simd-s4-gate.sh`（硬件 pshufd／select）、`run-std-simd-prod-gate.sh`。

---

## 5. 非目标（v1）

- 第二套 `vec4f_shuffle`／`vec8i_select`／`vec8i_select_lane` export（会改 mangle，打坏 g18／formal mid）
- 把 129 的 `xlangffle-select` 副本当 STD-047 第二权威
- 把 `xlang check` 当本 gate 产品闸门
- 重调 STD-061 热循环阈值（perf 仍软 SKIP，另刀）
