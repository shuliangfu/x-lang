# TU Contract: runtime_math_libm

## 1. 当前权威源
- x 源：`src/asm/runtime_math_libm.x`（G-02f-19 文档锚点 + G-02f-100 门闩 + G-02f-119 真迁）
- seed 源：`seeds/runtime_math_libm.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 IMPL wrapper + 1 个 DIRECT 函数 + 1 doc_anchor，seed/rest 提供 3 个 `_impl` + 31 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：5（doc_anchor + 3 IMPL wrapper + 1 DIRECT）
- seed/rest 导出：34（3 `_impl` + 31 个 math_*_c 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_math_libm_x_doc_anchor`（only_x）
- `math_fenv_mask_to_fe`（IMPL，调用 `_impl`，fenv only）
- `math_fenv_fe_to_mask`（IMPL，调用 `_impl`，fenv only）
- `math_fenv_emit_cap_report`（IMPL，调用 `_impl`，跨平台）
- `math_special_near`（DIRECT，G-02f-119 真迁 .x，完整实现）

### 3.2 当前仍由 seed/rest 提供
- `math_fenv_mask_to_fe_impl`（mask→FE_* 位转换，fenv only）
- `math_fenv_fe_to_mask_impl`（FE_* 位→mask 转换，fenv only）
- `math_fenv_emit_cap_report_impl`（输出能力报告到 stderr，跨平台）
- libm 转发：`math_floor_c` / `math_ceil_c` / `math_trunc_c` / `math_round_c` / `math_sin_c` / `math_cos_c` / `math_tan_c` / `math_asin_c` / `math_acos_c` / `math_atan_c` / `math_atan2_c` / `math_sqrt_c` / `math_cbrt_c` / `math_pow_c` / `math_exp_c` / `math_log_c` / `math_fabs_c` / `math_fmin_c` / `math_fmax_c` / `math_erf_c` / `math_erfc_c` / `math_log1p_c` / `math_expm1_c`
- signum：`math_signum_c`
- 烟测：`math_special_smoke_c`（调用 `math_special_near`）
- fenv API：`math_fenv_available_c`（调用 `math_fenv_emit_cap_report`）/ `math_fenv_test_c`（调用 `math_fenv_mask_to_fe` + `math_fenv_fe_to_mask`）/ `math_fenv_clear_c`（调用 `math_fenv_mask_to_fe`）/ `math_fenv_raise_c`（调用 `math_fenv_mask_to_fe`）/ `math_fenv_smoke_c` / `math_fenv_capability_smoke_c`

## 4. ABI Manifest
- _impl 残余列表：`math_fenv_mask_to_fe_impl`、`math_fenv_fe_to_mask_impl`、`math_fenv_emit_cap_report_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_MATH_LIBM_FROM_X`
- 前向声明：4 个 thin 函数（`math_special_near` / `math_fenv_mask_to_fe` / `math_fenv_fe_to_mask` / `math_fenv_emit_cap_report`），rest 模式下供 rest 函数调用
- 内部调用更新：
  - `math_special_smoke_c` 调用 `math_special_near`（DIRECT thin wrapper）
  - `math_fenv_test_c` 调用 `math_fenv_mask_to_fe` + `math_fenv_fe_to_mask`（IMPL thin wrapper）
  - `math_fenv_clear_c` / `math_fenv_raise_c` 调用 `math_fenv_mask_to_fe`（IMPL thin wrapper）
  - `math_fenv_available_c` 调用 `math_fenv_emit_cap_report`（IMPL thin wrapper）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 完整符号集；Ubuntu merged 40 T/W，U 仅 libc/libm/fenv 符号）
- smoke/probe：pending

## 6. 备注
- 混合 IMPL+DIRECT 模式：3 个 IMPL wrapper（fenv 系列）+ 1 个 DIRECT（math_special_near，G-02f-119 真迁 .x 完整实现）
- 平台条件：`math_fenv_mask_to_fe` / `math_fenv_fe_to_mask` 及其 `_impl` 在 `#if XLANG_MATH_HAVE_FENV` 块内（macOS/Linux only）；`math_fenv_emit_cap_report` 及其 `_impl` 在 fenv `#endif` 之后（跨平台）
- `math_special_near` 为 DIRECT 模式：rest 模式下 seed 中 #ifndef 保护不定义，由 thin/.x 完整提供
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：libm（floor/ceil/trunc/round/sin/cos/tan/asin/acos/atan/atan2/sqrt/cbrt/pow/exp/log/fabs/fmin/fmax/erf/erfc/log1p/expm1）+ fenv（feclearexcept/feraiseexcept/fetestexcept）+ diag_reportf（weak stub）
