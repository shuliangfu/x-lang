# TU Contract: runtime_driver_diagnostic_thin

## 1. 当前权威源
- x 源：`src/runtime_driver_diagnostic_thin.x`
- seed 源：`seeds/runtime_driver_diagnostic.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_driver_diagnostic_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin/.x provider`
  - `seed/rest provider`

## 3. 导出符号合同
- thin/.x 当前导出数：79
- seed/rest 当前导出数：84
- thin/.x 独有导出：3
- seed/rest 残余导出：8

### 3.1 必须由 thin/.x 提供
- `driver_debug_log`
- `driver_diag_append_cstr`
- `driver_diag_append_i32`
- `driver_diag_append_name`
- `driver_diag_build_expected_found`
- `driver_diag_copy_bytes`
- `driver_diag_env_debug_pipe`
- `driver_diag_fill_expr_part`
- `driver_diag_note`
- `driver_diag_pipe_note`
- `driver_diag_report_prefixed`
- `driver_diagnostic_after_dep_codegen`
- `driver_diagnostic_after_entry_parse`
- `driver_diagnostic_after_entry_parse_module`
- `driver_diagnostic_asm_current_func_maybe_trace`
- `driver_diagnostic_asm_current_func_store`
- `driver_diagnostic_asm_elf_unresolved_patch`
- `driver_diagnostic_asm_fail_at`
- `driver_diagnostic_asm_last_expr_kind_set`
- `driver_diagnostic_asm_macho_empty_reloc`
- `driver_diagnostic_asm_macho_missing_und_reloc`
- `driver_diagnostic_asm_print_current_func`
- `driver_diagnostic_asm_set_current_func`
- `driver_diagnostic_asm_set_last_expr_kind`
- `driver_diagnostic_asm_unsupported_expr`
- `driver_diagnostic_asm_var_not_found`
- `driver_diagnostic_before_codegen`
- `driver_diagnostic_codegen_emit_func_fail`
- `driver_diagnostic_codegen_fail`
- `driver_diagnostic_entry_already`
- `driver_diagnostic_hint_unused_binding`
- `driver_diagnostic_parse_commit_fail`
- `driver_diagnostic_parse_commit_shape`
- `driver_diagnostic_parse_fail`
- `driver_diagnostic_parse_func_generic`
- `driver_diagnostic_parse_skip_function`
- `driver_diagnostic_parser_onefunc_param_ref`
- `driver_diagnostic_pipe_marker`
- `driver_diagnostic_source_len`
- `driver_diagnostic_typeck_assign_mismatch`
- `driver_diagnostic_typeck_binop_operands`
- `driver_diagnostic_typeck_block_enter`
- `driver_diagnostic_typeck_break_continue_outside`
- `driver_diagnostic_typeck_call_not_generic`
- `driver_diagnostic_typeck_call_requires_type_args`
- `driver_diagnostic_typeck_call_wrong_num_type_args`
- `driver_diagnostic_typeck_deref_outside_unsafe`
- `driver_diagnostic_typeck_enum_no_variant`
- `driver_diagnostic_typeck_extern_call_outside_unsafe`
- `driver_diagnostic_typeck_fail`
- `driver_diagnostic_typeck_fn_enter`
- `driver_diagnostic_typeck_for_condition_not_bool`
- `driver_diagnostic_typeck_func_fail`
- `driver_diagnostic_typeck_if_condition_not_bool`
- `driver_diagnostic_typeck_import_const_must_be_qualified`
- `driver_diagnostic_typeck_linear_addr_of`
- `driver_diagnostic_typeck_ptr_field`
- `driver_diagnostic_typeck_ret_fail`
- `driver_diagnostic_typeck_return_mismatch`
- `driver_diagnostic_typeck_return_subexpr`
- `driver_diagnostic_typeck_return_unresolved`
- `driver_diagnostic_typeck_struct_field_bad_size`
- `driver_diagnostic_typeck_struct_padding_before`
- `driver_diagnostic_typeck_struct_padding_trailing`
- `driver_diagnostic_typeck_subscript_base`
- `driver_diagnostic_typeck_try_propagate_bad_enclosing`
- `driver_diagnostic_typeck_var_resolution`
- `driver_diagnostic_typeck_while_condition_not_bool`
- `driver_diagnostic_warn_hot_reorder_field`
- `driver_diagnostic_warn_pad_fields_same_cache_line`
- `driver_parse_strict_enabled`
- `driver_typeck_diag_scratch_expect`
- `driver_typeck_diag_scratch_found`
- `lsp_diag_get_enabled`
- `parser_diag_ident_len`
- `parser_diag_scan_fail`
- `parser_diag_tok_kind`
- `parser_diagnostic_parse_commit_shape`
- `parser_is_ident_allow`

### 3.2 当前仍由 seed/rest 提供
- `driver_diag_env_debug_pipe_impl`
- `driver_diag_pipe_note_impl`
- `driver_diag_report_x_pipeline_code`
- `driver_diag_report_x_pipeline_code_impl`
- `driver_diagnostic_asm_current_func_maybe_trace_impl`
- `driver_diagnostic_asm_current_func_store_impl`
- `driver_diagnostic_asm_last_expr_kind_set_impl`
- `lsp_diag_get_enabled_impl`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `driver_diag_append_cstr`
- `driver_diag_append_i32`
- `driver_diag_append_name`

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表
  - thin+rest 宏边界：N/A
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot
  - critical_field_offsets

## 5. 验证状态
- prove_x_o.sh：已跑通最小 L1/L2
- 已完成：
  - bootstrap-safe lint
  - .x -> -E
  - cc -c
  - nm
  - seed 符号对照
  - ld -r thin+rest 合并：pending
- 待补：
  - smoke / probe：pending
  - canonical snapshot compare：pending

## 6. 删除 seed 的门槛
- 当前阶段：**不允许删 seed**
- 必须补齐：
  - provider 边界稳定
  - ld -r 闭环
  - smoke / probe 一致
  - 连续构建不回退 seed

## 7. 备注
- 本文件由 compiler/scripts/gen_tu_contract.sh 生成
- 当前只作为试点 TU 的最小合同，不代表最终 ABI 审计已完成
