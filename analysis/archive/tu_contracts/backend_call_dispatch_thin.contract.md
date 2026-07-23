# TU Contract: backend_call_dispatch_thin

## 1. 当前权威源
- x 源：`src/asm/backend_call_dispatch_thin.x`
- seed 源：`seeds/backend_call_dispatch.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/backend_call_dispatch_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：44
- seed/rest 当前导出数：80
- thin/.x 独有导出：0
- seed/rest 残余导出：36

### 3.1 必须由 thin/.x 提供
- `glue_asm_append_export_c_suffix`
- `glue_asm_build_call_export_sym_c`
- `glue_asm_build_dep_export_sym_c`
- `glue_asm_build_func_export_sym_c`
- `glue_asm_build_import_binding_call_sym`
- `glue_asm_c_prefix_redundant_with_name`
- `glue_asm_call_reg_max`
- `glue_asm_call_stack_cleanup_bytes`
- `glue_asm_emit_call_with_cleanup`
- `glue_asm_emit_jmp_skip_string_then_lea`
- `glue_asm_emit_string_lit_ptr_rax_elf_c`
- `glue_asm_enc_call_redirected`
- `glue_asm_fill_c_prefix_from_module_import`
- `glue_asm_import_binding_name_equal`
- `glue_asm_import_path_segment_count`
- `glue_asm_import_path_slice_equal`
- `glue_asm_import_segment_at`
- `glue_asm_prefix_is_fmt_or_debug`
- `glue_asm_std_c_wrapper_fname_needs_export_c_suffix`
- `glue_asm_string_lit_into`
- `glue_asm_string_lit_len`
- `glue_asm_try_emit_fmt_string_lit_import_call_elf_c`
- `glue_call_param_is_f32_c`
- `glue_call_param_type_ref_at`
- `glue_codegen_import_path_to_c_prefix_into`
- `glue_emit_call_args_elf_sysv_f32_xmm_c`
- `glue_emit_one_call_arg_elf_c`
- `glue_f32_xmm_flag_get_body`
- `glue_module_func_overload_count_c`
- `glue_spill_struct16_call_arg_to_lea_elf_c`
- `glue_sysv_x86_call_arg_slot_c`
- `glue_sysv_x86_call_n_stack_c`
- `glue_try_std_encoding_redirect_sym_local`
- `glue_try_std_heap_redirect_sym_local`
- `glue_try_std_string_xlang_redirect_sym_local`
- `glue_type_kind_to_suffix_c`
- `pipeline_asm_abi_f32_xmm_enabled_c`
- `pipeline_asm_emit_call_args_elf_c`
- `pipeline_asm_emit_call_args_text_c`
- `pipeline_asm_emit_call_elf_c`
- `pipeline_asm_emit_get_call_f32_xmm_c`
- `pipeline_asm_emit_method_call_elf_c`
- `pipeline_asm_emit_set_call_f32_xmm`
- `pipeline_asm_resolve_whole_import_qualified_symbol_c`

### 3.2 当前仍由 seed/rest 提供
- `glue_asm_build_call_export_sym_c_impl`
- `glue_asm_build_dep_export_sym_c_impl`
- `glue_asm_build_func_export_sym_c_impl`
- `glue_asm_build_import_binding_call_sym_impl`
- `glue_asm_emit_call_with_cleanup_impl`
- `glue_asm_emit_jmp_skip_string_then_lea_impl`
- `glue_asm_emit_string_lit_ptr_rax_elf_c_impl`
- `glue_asm_enc_call_redirected_impl`
- `glue_asm_fill_c_prefix_from_module_import_impl`
- `glue_asm_import_binding_name_equal_impl`
- `glue_asm_import_path_segment_count_impl`
- `glue_asm_import_path_slice_equal_impl`
- `glue_asm_import_segment_at_impl`
- `glue_asm_prefix_is_fmt_or_debug_impl`
- `glue_asm_std_c_wrapper_fname_needs_export_c_suffix_impl`
- `glue_asm_string_lit_into_impl`
- `glue_asm_try_emit_fmt_string_lit_import_call_elf_c_impl`
- `glue_codegen_import_path_to_c_prefix_into_impl`
- `glue_emit_call_args_elf_sysv_f32_xmm_c_impl`
- `glue_emit_one_call_arg_elf_c_impl`
- `glue_f32_xmm_flag_get_body_impl`
- `glue_module_func_overload_count_c_impl`
- `glue_spill_struct16_call_arg_to_lea_elf_c_impl`
- `glue_sysv_x86_call_arg_slot_c_impl`
- `glue_sysv_x86_call_n_stack_c_impl`
- `glue_try_std_encoding_redirect_sym_local_impl`
- `glue_try_std_heap_redirect_sym_local_impl`
- `glue_try_std_string_xlang_redirect_sym_local_impl`
- `glue_type_kind_to_suffix_c_impl`
- `pipeline_asm_abi_f32_xmm_enabled_c_impl`
- `pipeline_asm_emit_call_args_elf_c_impl`
- `pipeline_asm_emit_call_args_text_c_impl`
- `pipeline_asm_emit_call_elf_c_impl`
- `pipeline_asm_emit_method_call_elf_c_impl`
- `pipeline_asm_emit_set_call_f32_xmm_impl`
- `pipeline_asm_resolve_whole_import_qualified_symbol_c_impl`

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
