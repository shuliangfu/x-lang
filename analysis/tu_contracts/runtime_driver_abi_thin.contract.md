# TU Contract: runtime_driver_abi_thin

## 1. 当前权威源
- x 源：`src/runtime_driver_abi_thin.x`
- seed 源：`seeds/runtime_driver_abi.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_driver_abi_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：71
- seed/rest 当前导出数：113
- thin/.x 独有导出：0
- seed/rest 残余导出：42

### 3.1 必须由 thin/.x 提供
- `compile_phase_now_sec`
- `compile_phase_timing_enabled`
- `driver_argv_collect_defines`
- `driver_ascii_toupper`
- `driver_asm_build_skip_typeck`
- `driver_asm_entry_emit_heavy`
- `driver_asm_entry_module_only_from_env`
- `driver_asm_parse_metric_only_from_env`
- `driver_bump_stack_limit`
- `driver_check_diag_emitted_flag_slot`
- `driver_check_diag_emitted_get`
- `driver_check_diag_emitted_note`
- `driver_check_diag_emitted_reset`
- `driver_check_only_flag_slot`
- `driver_check_only_get`
- `driver_check_only_set`
- `driver_check_quiet_ok_get`
- `driver_compile_phase_index_ok`
- `driver_compile_phase_timing_begin`
- `driver_compile_phase_timing_enabled`
- `driver_compile_phase_timing_end`
- `driver_compile_phase_timing_flush`
- `driver_current_dep_path_load`
- `driver_current_dep_path_store`
- `driver_defines_set_at`
- `driver_fmt_check_only_flag_slot`
- `driver_fmt_check_only_get`
- `driver_fmt_check_only_set`
- `driver_freestanding_flag_slot`
- `driver_freestanding_get`
- `driver_freestanding_set`
- `driver_get_current_dep_path_for_codegen`
- `driver_is_large_stack_thread`
- `driver_large_stack_thread_flag_slot`
- `driver_large_stack_thread_mark`
- `driver_os_define_lit`
- `driver_path_last_preprocess_len`
- `driver_path_read_preprocess_malloc`
- `driver_peek_source_file`
- `driver_pipeline_entry_source_len`
- `driver_pipeline_entry_source_len_i32`
- `driver_pipeline_entry_source_len_load_and_maybe_debug`
- `driver_pipeline_entry_source_len_store`
- `driver_pipeline_fail_code`
- `driver_pipeline_no_large_stack_env`
- `driver_print_check_ok`
- `driver_print_x_smoke_summary`
- `driver_run_fn_on_current_large_stack`
- `driver_run_on_large_stack_pthread`
- `driver_run_thread_on_large_stack`
- `driver_sanitize_address_flag_slot`
- `driver_sanitize_address_get`
- `driver_sanitize_address_set`
- `driver_set_current_dep_path_for_codegen`
- `driver_set_pipeline_entry_source_len`
- `driver_skip_codegen_dep_0_flag_slot`
- `driver_skip_codegen_dep_0_get`
- `driver_skip_codegen_dep_0_set`
- `driver_source_has_top_level_import`
- `driver_source_has_top_level_import_path`
- `driver_source_scan_top_level_import`
- `driver_stack_limit_want_bytes`
- `driver_target_arg_os_kind`
- `driver_typeck_force_c_enabled`
- `driver_typeck_skip_large_entry`
- `driver_x_pipeline_skip_codegen_flag_slot`
- `driver_x_pipeline_skip_codegen_get`
- `driver_x_pipeline_skip_codegen_set`
- `driver_x_pipeline_skip_typeck_flag_slot`
- `driver_x_pipeline_skip_typeck_get`
- `driver_x_pipeline_skip_typeck_set`

### 3.2 当前仍由 seed/rest 提供
- `compile_phase_timing_enabled_impl`
- `driver_argv_collect_append_uname_impl`
- `driver_argv_collect_defines_impl`
- `driver_asm_build_skip_typeck_impl`
- `driver_asm_entry_emit_heavy_impl`
- `driver_asm_entry_module_only_from_env_impl`
- `driver_asm_parse_metric_only_from_env_impl`
- `driver_bump_stack_limit_to_impl`
- `driver_call_fn_void_arg_impl`
- `driver_compile_phase_timing_begin_impl`
- `driver_compile_phase_timing_end_impl`
- `driver_compile_phase_timing_flush_impl`
- `driver_current_dep_path_load_impl`
- `driver_current_dep_path_store_impl`
- `driver_defines_set_at_impl`
- `driver_get_current_dep_path_for_codegen_impl`
- `driver_large_stack_thread_trampoline`
- `driver_os_define_lit_impl`
- `driver_path_last_preprocess_len_impl`
- `driver_peek_source_file_impl`
- `driver_pipeline_entry_source_len_i32_impl`
- `driver_pipeline_entry_source_len_impl`
- `driver_pipeline_entry_source_len_load_and_maybe_debug_impl`
- `driver_pipeline_entry_source_len_store_impl`
- `driver_pipeline_fail_code_impl`
- `driver_pipeline_fail_code_path_impl`
- `driver_pipeline_fail_code_rc_impl`
- `driver_pipeline_no_large_stack_env_impl`
- `driver_print_check_ok_impl`
- `driver_print_x_smoke_parse_empty_impl`
- `driver_print_x_smoke_parse_ok_impl`
- `driver_print_x_smoke_summary_impl`
- `driver_print_x_smoke_typeck_ok_impl`
- `driver_run_on_large_stack_pthread_impl`
- `driver_run_thread_on_large_stack_impl`
- `driver_run_thread_on_large_stack_pthread_impl`
- `driver_source_has_top_level_import_impl`
- `driver_source_has_top_level_import_path_impl`
- `driver_source_scan_top_level_import_impl`
- `driver_stack_limit_want_bytes_impl`
- `driver_target_arg_os_kind_impl`
- `driver_typeck_force_c_enabled_impl`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- （空）

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
