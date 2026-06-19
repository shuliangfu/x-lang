# STD-SIMD-INTRINSIC：std.simd mul/sub/dot intrinsic

## 1. 阅读路径（15min）

- `std/simd/mod.sx` — `vec4f_mul/sub/dot`、`vec8i_mul/sub`
- `compiler/pipeline_glue.c` — `pipeline_asm_simd_try_inline_fma3_call_elf_c`
- `tests/run-simd-s3-gate.sh` — 硬件 mulps/pmulld 烟测

## 2. binop intrinsic 语义

| API | 说明 |
|-----|------|
| `vec4f_mul/sub` | 逐 lane f32；let 初始化可内联 mulps/subps |
| `vec4f_hsum` | 四 lane 水平求和 |
| `vec4f_dot` | 点积 sum(a[i]*b[i]) |
| `vec4f_fma/madd` | 融合乘加 a+b*c（vfmadd231ps / mulps+addps） |
| `vec8i_mul/sub` | 逐 lane i32；pmulld/vpsubd |
| `simd_mul/sub/dot/fma` | Vec4f 语法糖分派 |

硬件 emit：`vec4f_fma(a,b,c)` 三参 local VAR 内联为 x86 `vfmadd231ps`（FMA3）或 `mulps+addps`。

## 3. 验证与门禁

```bash
./tests/run-std-simd-intrinsic-gate.sh
```
