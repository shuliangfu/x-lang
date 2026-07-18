# TU Contract: async_cps_codegen

## 1. 当前权威源
- x 源：`src/async/async_cps_codegen.x`（G-02f-18 文档锚点 + G-02f-105/111/120/132 门闩与真迁）
- seed 源：`seeds/async_cps_codegen.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 IMPL wrapper + 3 个 DIRECT 函数 + 1 doc_anchor + 1 辅助函数，seed/rest 提供 3 个 `_impl` + 18 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：8（doc_anchor + helper + 3 IMPL wrapper + 3 DIRECT）
- seed/rest 导出：21（3 `_impl` + 18 个 async_cps_* 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `async_cps_codegen_x_doc_anchor`（only_x）
- `async_cps_load_func_name`（辅助函数，从 ASTFunc* 读取 name 字段偏移 8 的 char*，供 DIRECT 函数调用）
- `emit_hoisted_lets`（IMPL，调用 `emit_hoisted_lets_impl`）
- `expr_references_run_async`（IMPL，调用 `expr_references_run_async_impl`）
- `block_has_run_async_ref`（IMPL，调用 `block_has_run_async_ref_impl`）
- `async_cps_callee_is_io`（DIRECT，G-02f-132 真迁 .x 完整实现）
- `async_cps_callee_is_future_wait_by_name`（DIRECT，G-02f-120 真迁 .x 完整实现）
- `async_cps_callee_is_future_wait`（DIRECT，G-02f-132 真迁 .x 完整实现，调用 `async_cps_callee_is_future_wait_by_name`）

### 3.2 当前仍由 seed/rest 提供
- `expr_references_run_async_impl`（递归扫描表达式，调用 `expr_references_run_async` + `block_has_run_async_ref`）
- `block_has_run_async_ref_impl`（递归扫描块，调用 `expr_references_run_async` + `block_has_run_async_ref`）
- `emit_hoisted_lets_impl`（emit let 静态变量，调用 `async_liveness_type_to_c_buf`）
- 模块级扫描：`async_cps_module_references_run_async`（调用 `block_has_run_async_ref`）
- 协程门闩：`async_cps_func_uses_void_entry`（调用 `async_liveness_func_needs_cps_frame`）/ `async_cps_codegen_emit_param_statics`（调用 `async_liveness_type_to_c_buf`）
- CPS 状态机 emit：`async_cps_codegen_begin`（调用 `emit_hoisted_lets`）/ `async_cps_codegen_end`
- await 边界判定：`async_cps_expr_is_io_await`（调用 `async_cps_callee_is_io`）/ `async_cps_expr_is_await_read` / `async_cps_expr_is_await_read_fd` / `async_cps_expr_is_await_write_fd` / `async_cps_expr_is_await_write` / `async_cps_expr_is_await_future_wait`（调用 `async_cps_callee_is_future_wait_by_name` + `async_cps_callee_is_future_wait`）
- await 边界 emit：`async_cps_codegen_after_await` / `async_cps_codegen_after_await_io` / `async_cps_codegen_emit_phase_reset`
- 调度 wrapper emit：`async_cps_codegen_emit_sched_wrapper` / `async_cps_is_sched_wrapper_name` / `async_cps_resolve_sched_target` / `async_cps_module_has_sched_extern`

## 4. ABI Manifest
- _impl 残余列表：`expr_references_run_async_impl`、`block_has_run_async_ref_impl`、`emit_hoisted_lets_impl`
- DIRECT 符号列表：`async_cps_callee_is_io`、`async_cps_callee_is_future_wait_by_name`、`async_cps_callee_is_future_wait`
- thin+rest 宏边界：`SHUX_ASYNC_CPS_CODEGEN_FROM_X`
- 前向声明：6 个 thin 函数（`block_has_run_async_ref` 已有 L18 + 5 个新增 L20-25：`emit_hoisted_lets` / `expr_references_run_async` / `async_cps_callee_is_io` / `async_cps_callee_is_future_wait_by_name` / `async_cps_callee_is_future_wait`），rest 模式下供 rest 函数调用
- 内部调用更新：
  - `expr_references_run_async_impl` 调用 `expr_references_run_async` + `block_has_run_async_ref`（IMPL thin wrapper）
  - `block_has_run_async_ref_impl` 调用 `expr_references_run_async` + `block_has_run_async_ref`（IMPL thin wrapper）
  - `async_cps_module_references_run_async` 调用 `block_has_run_async_ref`（IMPL thin wrapper）
  - `async_cps_codegen_begin` 调用 `emit_hoisted_lets`（IMPL thin wrapper）
  - `async_cps_expr_is_io_await` 调用 `async_cps_callee_is_io`（DIRECT thin wrapper）
  - `async_cps_expr_is_await_future_wait` 调用 `async_cps_callee_is_future_wait_by_name` + `async_cps_callee_is_future_wait`（DIRECT thin wrapper）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 8 x_symbols + 3 _impl + rest + 外部 TU U；Ubuntu merged 29 T/W，U 仅 libc + async_liveness_* 外部 TU 依赖）
- smoke/probe：pending

## 6. 备注
- 混合 IMPL+DIRECT 模式：3 个 IMPL wrapper（emit_hoisted_lets / expr_references_run_async / block_has_run_async_ref）+ 3 个 DIRECT（async_cps_callee_is_io / async_cps_callee_is_future_wait_by_name / async_cps_callee_is_future_wait，真迁 .x 完整实现）
- 类型擦除：.x 侧 IMPL wrapper 参数为 `*u8`（`const struct ASTFunc *` / `const struct ASTExpr *` / `const struct ASTBlock *` / `FILE *` 在 .x 无法表达）；seed 前向声明用实际 C 类型与调用处一致，thin.o 实际签名 `uint8_t *`，C 链接器不看类型，ABI 兼容
- `async_cps_load_func_name` 无 #no_mangle：作为 thin.o 内部辅助函数，供 DIRECT 函数 `async_cps_callee_is_io` / `async_cps_callee_is_future_wait` 调用（从 ASTFunc* 偏移 8 读取 name 字段）
- 递归调用链：`expr_references_run_async_impl` ↔ `block_has_run_async_ref_impl` 相互递归调用 thin wrapper，wrapper 再调回 _impl，形成完整递归
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：外部 TU `async_liveness_func_has_await` / `async_liveness_func_needs_cps_frame` / `async_liveness_type_to_c_buf`（async_liveness TU）+ libc（fprintf / fwrite / snprintf / strcmp / strncmp / strstr / __stack_chk_fail）
