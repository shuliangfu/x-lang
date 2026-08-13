# std.simd

SIMD-S2：`Vec4f`（4×f32 / 128-bit）与 `Vec8i`（8×i32 / 256-bit）标准向量类型。

- 编译器将 `Vec4f` / `Vec8i` / `f32x4` 识别为 `TYPE_VECTOR` 栈槽（16B / 32B 对齐）
- 底层映射：x86 AVX2（Vec8i）、NEON/SSE（Vec4f）；完整 intrinsic 分派见 SIMD-S3+
- 探测宿主特性：`xlang --print-target-cpu`（SIMD-S1）
- STD-153 策略：`hw_available()` / `recommend_path()`（0=scalar，1=hw；见 `XLANG_SIMD_HW` / `XLANG_SIMD_AUTovec`）
- STD-047 shuffle/select：产品 overload `shuffle` / `select` / `select_lane`（comptime mask → x86 pshufd/vpshufd 或 NEON）
- **STD-SIMD-INTRINSIC**：产品 overload `mul`／`sub`／`dot`／`hsum`／`fma`／`madd`（binop 内联 mulps/psubd/pmulld；fma 内联 vfmadd231ps）。**无** `vec4f_mul` 第二套 export
- **STD-061**：生产级 shuffle/select bench = `bench/r04_simd_shuffle_select.x`（**无** `bench/simd_shuffle_select.x` 旧路径）
- CI 严格：`XLANG_SIMD_HW_STRICT=1` 时 gate 要求 objdump 见硬件指令（`tests/run-simd-s4-gate.sh`）

## API（binop / 归约）

| API | 说明 |
|-----|------|
| `add`／`sub`／`mul` | 逐 lane；Vec4f = f32，Vec8i = i32（overload） |
| `fma`／`madd` | `a+b*c`（vfmadd231ps HW 内联）；`madd` 是 `fma` 别名 |
| `hsum`／`dot` | Vec4f 水平求和 / 点积 |
| `shuffle`／`select`／`select_lane` | STD-047 lane permute / blend |

## Gate

```bash
./tests/run-std-simd-shuffle-select-gate.sh
./tests/run-std-simd-intrinsic-gate.sh
./tests/run-std-simd-prod-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
```
