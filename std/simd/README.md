# std.simd

SIMD-S2：`Vec4f`（4×f32 / 128-bit）与 `Vec8i`（8×i32 / 256-bit）标准向量类型。

- 编译器将 `Vec4f` / `Vec8i` / `f32x4` 识别为 `TYPE_VECTOR` 栈槽（16B / 32B 对齐）
- 底层映射：x86 AVX2（Vec8i）、NEON/SSE（Vec4f）；完整 intrinsic 分派见 SIMD-S3+
- 探测宿主特性：`shu --print-target-cpu`（SIMD-S1）
- STD-153 策略：`hw_available()` / `recommend_simd_path()`（0=scalar，1=hw；见 `SHU_SIMD_AUTovec`）
