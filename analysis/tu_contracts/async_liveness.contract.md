# TU Contract: async_liveness

## 1. 当前权威源
- x 源：`src/async/async_liveness.x`（G-02f-161~171 真迁 .x）
- seed 源：`seeds/async_liveness.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 18 个 DIRECT 函数 + 16 个辅助函数，seed/rest 提供 14 个公开 API 函数（含 frame_build_tag）

## 3. 导出符号合同
- thin/.x 导出：35（18 DIRECT + 16 thin 独有辅助 + 1 doc_anchor）
- seed/rest 导出：14（rest 函数）
- only_x：16（thin 独有辅助函数）

### 3.1 必须由 thin/.x 提供
- DIRECT（18）：`expr_has_await`、`expr_count_await`、`block_has_await`、`block_count_await`、`async_liveness_callee_is_io_read`、`async_liveness_callee_is_io_write`、`expr_has_io_read_await`、`expr_has_io_write_await`、`block_has_io_read_await`、`block_has_io_write_await`、`expr_refs_var`、`block_refs_var`、`block_rest_refs_var`、`frame_live_add`、`frame_live_at_await`、`analyze_block_linear`、`live_name_cmp`、`frame_mangle_ident`
- thin 独有辅助（16）：`async_live_*` / `frame_live_*` 系列（.x 内部用，seed 无对应定义）

### 3.2 当前仍由 seed/rest 提供
- `frame_build_tag`（字符串字面量限制：.x 编译器静默跳过使用 `"fn"` / `"__shux_async_frame_"` 的函数）
- `async_liveness_lookup_var_type`、`async_liveness_type_to_c_buf`、`async_liveness_type_size_bytes_module`
- `async_liveness_func_has_await`、`async_liveness_func_needs_cps_frame`、`async_liveness_expr_has_await`
- `async_liveness_layout_func`、`async_liveness_layout_func_module`、`async_liveness_module_struct_in_frame`
- `async_liveness_analyze_func`、`async_liveness_emit_codegen_comment`、`async_liveness_emit_frame_local`、`async_liveness_emit_frame_typedef`

## 4. ABI Manifest
- _impl 残余列表：无
- DIRECT 符号列表：18 个（见 3.1）
- thin+rest 宏边界：`SHUX_ASYNC_LIVENESS_FROM_X`
- 前向声明：12 个（`expr_has_await`、`block_has_await`、`block_has_io_read_await`、`block_has_io_write_await`、`expr_count_await`、`block_count_await`、`expr_refs_var`、`block_refs_var`、`analyze_block_linear`、`frame_build_tag`、`frame_mangle_ident`、`live_name_cmp`）

## 5. 验证状态
- prove_x_o：ok（需 `SHUX_PROVE_SKIP_LINT=1` 跳过预存 lint 问题：嵌套 if 和 &&/|| 操作符）
- ld -r：ok（macOS merged 49 T；Ubuntu merged 49 T/W，U=0）
- smoke/probe：pending

## 6. 备注
- DIRECT 模式切割：18 个函数由 .x 提供，seed 在 rest 模式下 `#ifndef SHUX_ASYNC_LIVENESS_FROM_X` 跳过
- frame_build_tag 为 rest 函数：.x 编译器静默跳过使用字符串字面量的函数（`"fn"` 和 `"__shux_async_frame_"`），故始终由 seed 提供。frame_mangle_ident 不使用字符串字面量（用字节字面量 `out[0]=102` 表达 `'f'`），.x 能正常生成，保持 DIRECT
- 前向声明：rest 函数 frame_build_tag 调用 thin 函数 frame_mangle_ident，需前向声明；其余前向声明供 rest 函数间相互调用
- 验证命令：`SHUX_PROVE_SKIP_LINT=1 bash scripts/prove_x_o.sh src/async/async_liveness.x seeds/async_liveness.from_x.c`
