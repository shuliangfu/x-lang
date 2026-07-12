# TU Contract: backend_enc_dispatch_thin

## 1. 当前权威源
- x 源：`src/asm/backend_enc_dispatch_thin.x`
- seed 源：`seeds/backend_enc_dispatch.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/backend_enc_dispatch_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：120
- seed/rest 当前导出数：125
- thin/.x 独有导出：0
- seed/rest 残余导出：5

### 3.1 必须由 thin/.x 提供
- `arch_arm64_enc_enc_add_sp_imm12`
- `arch_arm64_enc_enc_call`
- `arch_arm64_enc_enc_str_x0_sp_offset`
- `arch_arm64_enc_enc_sub_sp_imm12`
- `arch_riscv64_enc_enc_call`
- `arch_riscv64_enc_enc_mov_rax_to_arg_reg`
- `arch_x86_64_enc_enc_cdqe_rax`
- `arm64_enc_load_w0_from_rbp_c`
- `arm64_enc_store_w0_to_rbp_c`
- `backend_enc_add_imm_to_index_scratch_arch`
- `backend_enc_add_imm_to_rax_arch`
- `backend_enc_add_imm_to_rbx_arch`
- `backend_enc_add_imm_to_rbx_index_arch`
- `backend_enc_add_rax_rbx_arch`
- `backend_enc_addss_rax_rbx_arch`
- `backend_enc_and_rbx_rax_arch`
- `backend_enc_append_u32_le_c`
- `backend_enc_append_u8_c`
- `backend_enc_arm64_add_sp_imm12_c`
- `backend_enc_arm64_call_c`
- `backend_enc_arm64_str_x0_sp_offset_c`
- `backend_enc_arm64_sub_sp_imm12_c`
- `backend_enc_call_arch`
- `backend_enc_call_stack_cleanup_arch`
- `backend_enc_call_stack_reserve_arch`
- `backend_enc_cltd_arch`
- `backend_enc_cmp_rax_rbx_arch`
- `backend_enc_cmp_rbx_rax_arch`
- `backend_enc_cmp_setcc_movzbl_arch`
- `backend_enc_cvtsd2ss_eax_from_f64_bits_arch`
- `backend_enc_cvtsi2ss_eax_from_i32_arch`
- `backend_enc_cvttss2si_eax_from_f32_bits_arch`
- `backend_enc_div_rbx_arch`
- `backend_enc_epilogue_arch`
- `backend_enc_idiv_rbx_arch`
- `backend_enc_imul_rbx_rax_arch`
- `backend_enc_index_scratch_add_secondary_arch`
- `backend_enc_index_scratch_mul_secondary_arch`
- `backend_enc_index_scratch_rsub_secondary_arch`
- `backend_enc_index_scratch_sub_secondary_arch`
- `backend_enc_jeq_arch`
- `backend_enc_jge_arch`
- `backend_enc_jl_arch`
- `backend_enc_jle_arch`
- `backend_enc_jmp_arch`
- `backend_enc_jne_arch`
- `backend_enc_jnz_arch`
- `backend_enc_jz_arch`
- `backend_enc_label_arch`
- `backend_enc_lea_rbp_to_rax_arch`
- `backend_enc_lea_rbp_to_rbx_arch`
- `backend_enc_load_32_from_rax_arch`
- `backend_enc_load_64_from_rax_arch`
- `backend_enc_load_i32_indirect_to_rax_arch`
- `backend_enc_load_qword_from_rbx_to_rax_arch`
- `backend_enc_load_qword_rbx8_to_rdx_arch`
- `backend_enc_load_rbp_index_scratch_arch`
- `backend_enc_load_rbp_index_secondary_scratch_arch`
- `backend_enc_load_rbp_lane_to_rax_arch`
- `backend_enc_load_rbp_lane_to_rbx_arch`
- `backend_enc_load_rbp_pos_to_rax_arch`
- `backend_enc_load_rbp_to_rax_arch`
- `backend_enc_load_rbp_to_rbx_arch`
- `backend_enc_load_rbp_to_rdx_arch`
- `backend_enc_load_x29_pos_to_rax_arch`
- `backend_enc_load_zext8_from_rax_arch`
- `backend_enc_mov_arg_reg_to_rax_arch`
- `backend_enc_mov_eax_to_xmm_arg_reg_arch`
- `backend_enc_mov_edx_to_eax_arch`
- `backend_enc_mov_imm32_to_rbx_arch`
- `backend_enc_mov_imm64_to_rax_arch`
- `backend_enc_mov_rax_to_arg_reg_arch`
- `backend_enc_mov_rax_to_rbx_arch`
- `backend_enc_mov_rbx_to_ecx_arch`
- `backend_enc_mov_rbx_to_rax_arch`
- `backend_enc_mov_rdx_to_arg_reg_arch`
- `backend_enc_mov_xmm_arg_reg_to_eax_arch`
- `backend_enc_mul_imm_to_index_scratch_arch`
- `backend_enc_mul_imm_to_rbx_arch`
- `backend_enc_neg_eax_arch`
- `backend_enc_not_eax_arch`
- `backend_enc_or_rbx_rax_arch`
- `backend_enc_pop_rax_arch`
- `backend_enc_pop_rbx_arch`
- `backend_enc_prologue_arch`
- `backend_enc_push_rax_arch`
- `backend_enc_push_rbx_arch`
- `backend_enc_rax_plus_rbx_scale1_arch`
- `backend_enc_rax_plus_rbx_scale4_arch`
- `backend_enc_rax_plus_rbx_scale8_arch`
- `backend_enc_rbx_index_add_secondary_arch`
- `backend_enc_rbx_index_mul_secondary_arch`
- `backend_enc_rbx_index_rsub_secondary_arch`
- `backend_enc_rbx_index_sub_secondary_arch`
- `backend_enc_rbx_plus_index_scratch_scaled_arch`
- `backend_enc_rem_mod_arch`
- `backend_enc_rem_mod_unsigned_arch`
- `backend_enc_ret_imm32_arch`
- `backend_enc_sar_cl_eax_arch`
- `backend_enc_sar_cl_rax_arch`
- `backend_enc_setz_movzbl_eax_arch`
- `backend_enc_shl_cl_eax_arch`
- `backend_enc_shl_cl_rax_arch`
- `backend_enc_shr_cl_eax_arch`
- `backend_enc_shr_cl_rax_arch`
- `backend_enc_store_eax_to_rbp_arch`
- `backend_enc_store_rax_to_rbp_arch`
- `backend_enc_store_rax_to_rbx_indirect_arch`
- `backend_enc_store_rax_to_rbx_offset_arch`
- `backend_enc_store_rdx_to_rbp_arch`
- `backend_enc_store_x0_sp_offset_arch`
- `backend_enc_store_x_reg_to_rbp_arch`
- `backend_enc_sub_imm_from_index_scratch_arch`
- `backend_enc_sub_imm_from_rbx_index_arch`
- `backend_enc_sub_rax_rbx_arch`
- `backend_enc_sub_rbx_rax_then_mov_arch`
- `backend_enc_test_eax_eax_arch`
- `backend_enc_test_rbx_rbx_arch`
- `backend_enc_x86_jcc_rel32_c`
- `backend_enc_xor_rbx_rax_arch`

### 3.2 当前仍由 seed/rest 提供
- `arch_x86_64_enc_enc_cdqe_rax_impl`
- `backend_enc_append_u32_le_c_impl`
- `backend_enc_append_u8_c_impl`
- `backend_enc_arm64_call_c_impl`
- `backend_enc_x86_jcc_rel32_c_impl`

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
