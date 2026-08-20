# STD-SIMD-INTRINSIC：std.simd mul/sub/dot/fma

> 更新时间：2026-08-13
> 状态：**活文档**（产品面权威 = `mod.x` overload 名 `mul`／`sub`／`dot`／`hsum`／`fma`／`madd`；formal c_face 孪生）
> 关联：STD-047 shuffle/select、STD-061 prod bench、STD-153 `recommend_path`
> PLATFORM: SHARED — Ubuntu gold for link/run; Darwin L2 same names

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | 打开 `tests/baseline/std-simd-intrinsic.tsv` |
| 3 | `./tests/run-std-simd-intrinsic-gate.sh`（自举期 **不**把 `xlang check` 当产品闸门） |
| 4 | 金样：`tests/simd/intrinsic_binop_dot.x` |

产品 export 是 **`mul`／`sub`／`dot`／`hsum`／`fma`／`madd`**（Vec4f／Vec8i overload；mangle `std_simd_mul_f32x4_f32x4` 等）。
**没有** `vec4f_mul`／`vec8i_mul`／`simd_mul` 第二套 export（G.7：一功能一权威）。
历史类型限定名只作文档说明，不进 `mod.x`。

`import std.simd` 产品车是 formal c_face（不能 host-cc `.x` monofile）。

---

## 2. binop intrinsic 语义

| 产品 API | 说明 |
|----------|------|
| `mul`／`sub` | 逐 lane；Vec4f = f32（mulps／subps），Vec8i = i32（pmulld／vpsubd） |
| `hsum` | Vec4f 四 lane 水平求和 |
| `dot` | Vec4f 点积 `sum(a[i]*b[i])` |
| `fma`／`madd` | 融合乘加 `a+b*c`（`vfmadd231ps` dest=a；或 mulps+addps） |

`madd` 是 `fma` 的同语义别名（同一组 formal 体），不是第三条算法。

硬件 emit：`simd.fma(a,b,c)` 三参 local VAR 可内联为 x86 `vfmadd231ps`（FMA3）或 `mulps+addps`。

---

## 3. 验证与门禁

```bash
./tests/run-std-simd-intrinsic-gate.sh
```

产品验收以 `-L . -o` 真链 + `intrinsic_binop_dot.x` run=0 为准。
自举期 check 闸门暂停（2026-08-05）。

回归：`run-simd-s3-gate.sh`（硬件 mulps／pmulld）、`run-std-simd-prod-gate.sh`。

---

## 4. 非目标（v1）

- 第二套 `vec4f_mul`／`simd_mul` export（会改 mangle，打坏 g18／formal mid）
- SVE／AVX-512 动态分派
- 把 `xlang check` 当本 gate 产品闸门
