# STD-SIMD-INTRINSIC：std.simd mul/sub/dot intrinsic

## 1. 阅读路径（15min）

- `std/simd/mod.x` — overload `mul`/`sub`/`dot`/`hsum`/`fma`/`madd`（历史 `vec4f_mul` 非第二导出）
- `compiler/pipeline_glue.c` — `pipeline_asm_simd_try_inline_fma3_call_elf_c`
- `tests/run-simd-s3-gate.sh` — 硬件 mulps/pmulld 烟测

## 2. binop intrinsic 语义

| API | 说明 |
|-----|------|
| `mul` / `sub` | 逐 lane f32 / i32；let 初始化可内联 mulps/subps / pmulld |
| `hsum` | 四 lane 水平求和 |
| `dot` | 点积 sum(a[i]*b[i]) |
| `fma` / `madd` | 融合乘加 a+b*c（vfmadd231ps / mulps+addps） |

硬件 emit：`fma(a,b,c)` 三参 local VAR 内联为 x86 `vfmadd231ps`（FMA3）或 `mulps+addps`。

## 3. Gate

```bash
./tests/run-std-simd-intrinsic-gate.sh
```

```
xlang: [XLANG_STD_SIMD_INTRINSIC] status=ok check=0|1 x=1 skip=0
```

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 观测（自举期暂停闸门 2026-08-05）
- `tests/simd/intrinsic_binop_dot.x` exit 0 硬失败（无 soft SKIP）

**Honesty (2026-08-29 leftover wrap dead source)**：leftover `bootstrap-link-xlang.sh` sourced unused（no `RUN_XLANG`）+ unused `compiler-make.sh` retired from `tests/run-std-simd-intrinsic-gate.sh`. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `intrinsic_binop_dot.x` hard；check＝obs；report `run=`／`obs=`／`skip=`。Keep `## 3. Gate`。 Leave wrap body / ensure_std family.

## 4. Evolution

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06 | binop / FMA 初版 |
| honesty | 2026-08-26 | soft→硬绿：`## 3. Gate`；prefer asm；check 观测；runnable hard；报告 `check=`／`x=`／`skip=` |
| honesty-2 | 2026-08-29 | leftover wrap 死 source：删 unused wrap source + unused `compiler-make.sh`；Keep `## 3. Gate` |
