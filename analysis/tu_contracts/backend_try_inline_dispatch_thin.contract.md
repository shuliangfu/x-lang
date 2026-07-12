# TU Contract: backend_try_inline_dispatch_thin

## 1. 当前权威源
- x 源：`src/asm/backend_try_inline_dispatch_thin.x`
- seed 源：`seeds/backend_try_inline_dispatch.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/backend_try_inline_dispatch_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：50
- seed/rest 当前导出数：86
- thin/.x 独有导出：0
- seed/rest 残余导出：36

### 3.1 必须由 thin/.x 提供
- `asm_array_lit_elem_byte_sz`
- `asm_array_lit_reserve_stack_bytes`
- `asm_index_elem_byte_sz`
- `asm_local_var_slot_holds_indirect_ptr`
- `asm_struct_lit_reserve_stack_bytes`
- `glue_align_up8_c`
- `glue_arch_emit_local_slot_ptr_or_addr_text`
- `glue_asm_ctx_module_ref_c`
- `glue_call_is_zero_arg_default_alloc`
- `glue_call_lookup_callee_mod_fi_arena`
- `glue_const_scalar_binop_eval_i32`
- `glue_const_struct_lit_field_can_inline`
- `glue_dep_module_field_offset_by_name`
- `glue_emit_default_alloc_to_rbx_offset`
- `glue_enc_local_slot_ptr_or_addr`
- `glue_expr_is_func_param_at`
- `glue_fold_func_return_operand_ref_module`
- `glue_fold_func_returns_const_struct_lit`
- `glue_fold_func_returns_param01_scalar_binop`
- `glue_fold_func_returns_param01_vector_binop`
- `glue_fold_func_returns_param0_index_const`
- `glue_fold_func_returns_param_struct_lit`
- `glue_inline_var_field_access_offset`
- `glue_inner_call_arg_for_field_access`
- `glue_is_vector_lane_scalar_binop_ko`
- `glue_local_var_slot_holds_indirect_ptr`
- `glue_module_func_index_by_name`
- `glue_module_named_type_has_struct_layout`
- `glue_struct_lit_field_index_by_name`
- `glue_struct_lit_field_init_param_index`
- `glue_try_array_lit_lane_const_i32`
- `glue_try_expr_const_i32`
- `glue_try_fold_func_return_operand_ref`
- `glue_try_inline_local_slot_off`
- `glue_type_ref_is_named_struct_layout`
- `pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c`
- `pipeline_asm_array_lit_elem_byte_sz_c`
- `pipeline_asm_array_lit_reserve_stack_bytes_c`
- `pipeline_asm_enc_local_slot_ptr_or_addr_elf_c`
- `pipeline_asm_struct_lit_reserve_stack_bytes_c`
- `try_call_wpo_mono_symbol_elf`
- `try_call_wpo_mono_vector_lane_of_binop_call_elf`
- `try_inline_const_struct_lit_return_call_to_slot_elf`
- `try_inline_param0_field_sum_call_elf`
- `try_inline_param0_single_field_call_elf`
- `try_inline_struct_lit_return_call_to_slot_elf`
- `try_inline_var_field_sum_binop_elf`
- `try_inline_wpo_const_scalar_binop_call_elf`
- `try_inline_wpo_const_vector_lane_of_binop_call_elf`
- `try_inline_x_plus_k_call_elf`

### 3.2 当前仍由 seed/rest 提供
- `asm_array_lit_elem_byte_sz_impl`
- `asm_array_lit_reserve_stack_bytes_impl`
- `asm_local_var_slot_holds_indirect_ptr_impl`
- `glue_arch_emit_local_slot_ptr_or_addr_text_impl`
- `glue_call_is_zero_arg_default_alloc_impl`
- `glue_call_lookup_callee_mod_fi_arena_impl`
- `glue_const_struct_lit_field_can_inline_impl`
- `glue_dep_module_field_offset_by_name_impl`
- `glue_emit_default_alloc_to_rbx_offset_impl`
- `glue_enc_local_slot_ptr_or_addr_impl`
- `glue_expr_is_func_param_at_impl`
- `glue_fold_func_return_operand_ref_module_impl`
- `glue_fold_func_returns_const_struct_lit_impl`
- `glue_fold_func_returns_param01_scalar_binop_impl`
- `glue_fold_func_returns_param01_vector_binop_impl`
- `glue_fold_func_returns_param0_index_const_impl`
- `glue_fold_func_returns_param_struct_lit_impl`
- `glue_inline_var_field_access_offset_impl`
- `glue_inner_call_arg_for_field_access_impl`
- `glue_module_func_index_by_name_impl`
- `glue_module_named_type_has_struct_layout_impl`
- `glue_struct_lit_field_index_by_name_impl`
- `glue_struct_lit_field_init_param_index_impl`
- `glue_try_array_lit_lane_const_i32_impl`
- `glue_try_expr_const_i32_impl`
- `glue_type_ref_is_named_struct_layout_impl`
- `try_call_wpo_mono_symbol_elf_impl`
- `try_call_wpo_mono_vector_lane_of_binop_call_elf_impl`
- `try_inline_const_struct_lit_return_call_to_slot_elf_impl`
- `try_inline_param0_field_sum_call_elf_impl`
- `try_inline_param0_single_field_call_elf_impl`
- `try_inline_struct_lit_return_call_to_slot_elf_impl`
- `try_inline_var_field_sum_binop_elf_impl`
- `try_inline_wpo_const_scalar_binop_call_elf_impl`
- `try_inline_wpo_const_vector_lane_of_binop_call_elf_impl`
- `try_inline_x_plus_k_call_elf_impl`

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
