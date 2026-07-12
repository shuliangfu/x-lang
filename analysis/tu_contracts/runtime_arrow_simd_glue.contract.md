# TU Contract: runtime_arrow_simd_glue

## 1. 当前权威源
- x 源：`src/asm/runtime_arrow_simd_glue.x`
- seed 源：`seeds/runtime_arrow_simd_glue.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 4 个 IMPL wrapper，seed/rest 提供 4 个 `_impl` + 1 个 SSE2 helper + 4 个 column 胶层函数

## 3. 导出符号合同
- thin/.x 导出：5（doc_anchor + 4 wrapper）
- seed/rest 导出：8 macOS / 9 Ubuntu（4 `_impl` + 4 column 胶层函数 + arrow_hsum_ps [SSE2 only]）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_arrow_simd_glue_x_doc_anchor`
- `arrow_f32_sum_kernel`（IMPL，调用 `_impl`）
- `arrow_f32_dot_kernel`（IMPL，调用 `_impl`）
- `arrow_i32_sum_valid_kernel`（IMPL，调用 `_impl`）
- `arrow_f32_sum_valid_kernel`（IMPL，调用 `_impl`）

### 3.2 当前仍由 seed/rest 提供
- `arrow_hsum_ps`（SSE2 水平求和 helper，仅 __SSE2__ 平台编译）
- `arrow_f32_sum_kernel_impl`（f32 列求和 SIMD 内核）
- `arrow_f32_dot_kernel_impl`（f32 两列点积 SIMD 内核）
- `arrow_i32_sum_valid_kernel_impl`（i32 列有效元素累加 SIMD 内核）
- `arrow_f32_sum_valid_kernel_impl`（f32 列有效元素求和 SIMD 内核）
- `arrow_column_i32_sum_valid_c`（i32 列有效元素累加胶层，调用 thin wrapper）
- `arrow_column_f32_sum_c`（f32 列求和胶层，调用 thin wrapper）
- `arrow_column_f32_sum_valid_c`（f32 列有效元素求和胶层，调用 thin wrapper）
- `arrow_column_f32_dot_c`（f32 两列点积胶层，调用 thin wrapper）

## 4. ABI Manifest
- _impl 残余列表：`arrow_f32_sum_kernel_impl`、`arrow_f32_dot_kernel_impl`、`arrow_i32_sum_valid_kernel_impl`、`arrow_f32_sum_valid_kernel_impl`
- thin+rest 宏边界：`SHUX_RUNTIME_ARROW_SIMD_GLUE_FROM_X`
- 前向声明：4 个 thin wrapper（`arrow_f32_sum_kernel` / `arrow_f32_dot_kernel` / `arrow_i32_sum_valid_kernel` / `arrow_f32_sum_valid_kernel`），rest 模式下供 4 个 column 胶层函数调用，符号由 thin.o 提供
- 内部调用更新：无（column 胶层函数调用 thin wrapper 符号，rest 模式下为 U 由 thin.o 解析）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程）
- ld -r：ok（macOS merged 13 T 0 U + Ubuntu merged 12 T + 2 W，U 仅 __stack_chk_fail [libc]）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：4 个 thin wrapper 调用对应 `_impl`
- 4 个 column 胶层函数调用 4 个 thin wrapper，rest 模式下 thin wrapper 为 U 符号由 thin.o 提供
- 平台条件：`arrow_hsum_ps` 仅在 `#if defined(ARROW_HAVE_SSE2)` 块内定义（macOS arm64 无 SSE2 → 不编译；Ubuntu x86_64 有 SSE2 → 编译为 T 符号）。3 个 f32 kernel `_impl` 在 SSE2 分支调用 `arrow_hsum_ps`，NEON 分支用 `vgetq_lane_f32` 直接求和
- 已知预存行为：`arrow_i32_sum_valid_kernel` 和 `runtime_arrow_simd_glue_x_doc_anchor` 在 Linux 上为 W（weak）符号——shux-c 编译器对 `#[no_mangle]` 属性处理不完整（`arrow_i32_sum_valid_kernel` 有 `#[no_mangle]` 但 gen.c 仍标记 weak；`doc_anchor` 无 `#[no_mangle]` 故 weak 正确）。macOS Mach-O 不支持 weak，均为 T 符号。非本次切割引入
- 依赖：SSE2（emmintrin.h）/ NEON（arm_neon.h）；无外部库依赖
