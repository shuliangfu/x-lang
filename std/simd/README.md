# std.simd

SIMD-S2：`Vec4f`（4×f32 / 128-bit）与 `Vec8i`（8×i32 / 256-bit）标准向量类型。

- 编译器将 `Vec4f` / `Vec8i` / `f32x4` 识别为 `TYPE_VECTOR` 栈槽（16B / 32B 对齐）
- 底层映射：x86 AVX2（Vec8i）、NEON/SSE（Vec4f）；完整 intrinsic 分派见 SIMD-S3+
- 探测宿主特性：`shux --print-target-cpu`（SIMD-S1）
- STD-153 策略：`hw_available()` / `recommend_simd_path()`（0=scalar，1=hw；见 `SHUX_SIMD_AUTovec`）
- STD-047 shuffle/select：`vec4f_shuffle` / `vec8i_select` 等（comptime mask → x86 pshufd/vpshufd 或 NEON）
- **STD-SIMD-INTRINSIC**：`vec4f_mul/sub/dot/fma`、`vec8i_mul/sub`（binop 内联 mulps/psubd/pmulld；fma 内联 vfmadd231ps）
- CI 严格：`SHUX_SIMD_HW_STRICT=1` 时 gate 要求 objdump 见硬件指令（`tests/run-simd-s4-gate.sh`）

## API（binop / 归约）

| API | 说明 |
|-----|------|
| `vec4f_add/sub/mul/fma` | 逐 lane f32 运算（fma = a+b*c） |
| `vec4f_madd` | `vec4f_fma` 别名（vfmadd231ps HW 内联） |
| `vec4f_hsum` / `vec4f_dot` | 水平求和 / 点积 |
| `vec8i_add/sub/mul` | 逐 lane i32 运算 |
| `simd_mul/sub/dot/fma` | Vec4f 语法糖分派 |

## Gate

```bash
./tests/run-std-simd-shuffle-select-gate.sh
./tests/run-std-simd-intrinsic-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
```
