# TU Contract: simd_enc_thin

## 1. 当前权威源
- x 源：`src/asm/simd_enc_thin.x`
- seed 源：`seeds/simd_enc.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/simd_enc_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：74
- seed/rest 当前导出数：145
- thin/.x 独有导出：0
- seed/rest 残余导出：71

### 3.1 必须由 thin/.x 提供
- `simd_append`
- `simd_append_disp32`
- `simd_append_u32_le`
- `simd_arm64_ins_v1_from_v0_s`
- `simd_arm64_pshufd_imm8_128_rbp`
- `simd_arm64_rbp_lea_off_128half`
- `simd_arm64_select_128_rbp`
- `simd_enc_emit_f32_select_xmm_seq`
- `simd_enc_emit_f32_select_ymm_seq`
- `simd_enc_emit_i32_select_xmm_seq`
- `simd_enc_emit_i32_select_ymm_seq`
- `simd_enc_f32_soa_col_movups_xmm1_at_idx`
- `simd_enc_try_hw_vector_binop_rbp_at_idx`
- `simd_enc_try_hw_vector_fadd_rbp`
- `simd_enc_try_hw_vector_fma_rbp`
- `simd_enc_try_hw_vector_fmul_rbp`
- `simd_enc_try_hw_vector_iadd_isub_rbp`
- `simd_enc_try_hw_vector_iadd_rbp`
- `simd_enc_try_hw_vector_imul_rbp`
- `simd_enc_try_hw_vector_isub_rbp`
- `simd_enc_try_hw_vector_select_rbp`
- `simd_enc_try_pshufd_rbp`
- `simd_enc_x86_addps_xmm0_xmm1`
- `simd_enc_x86_horizontal_addps_xmm0`
- `simd_enc_x86_movss_xmm0_rbp_disp`
- `simd_enc_x86_movups_xmm1_rbp_disp`
- `simd_enc_x86_xorps_xmm0_zero`
- `simd_rbp_disp32`
- `simd_x86_addps_xmm0_xmm1`
- `simd_x86_andnps_xmm2_xmm1`
- `simd_x86_andps_xmm0_xmm2`
- `simd_x86_cmpgtps_xmm2_xmm3`
- `simd_x86_movups_xmm0_from_rbp`
- `simd_x86_movups_xmm0_from_rbx_rax4`
- `simd_x86_movups_xmm0_to_rbp`
- `simd_x86_movups_xmm0_to_rbx_rax4`
- `simd_x86_movups_xmm1_from_rbp`
- `simd_x86_movups_xmm1_from_rbx_rax4`
- `simd_x86_movups_xmm2_from_rbp`
- `simd_x86_mulps_xmm0_xmm1`
- `simd_x86_orps_xmm0_xmm2`
- `simd_x86_paddd_xmm0_xmm1`
- `simd_x86_pand_xmm0_xmm2`
- `simd_x86_pandn_xmm2_xmm1`
- `simd_x86_pcmpgtd_xmm2_xmm3`
- `simd_x86_pmulld_xmm0_xmm1`
- `simd_x86_por_xmm0_xmm2`
- `simd_x86_pshufd_xmm0_imm8`
- `simd_x86_pshufd_xmm1_xmm0`
- `simd_x86_psubd_xmm0_xmm1`
- `simd_x86_pxor_xmm3_xmm3`
- `simd_x86_vandnps_ymm2_ymm1`
- `simd_x86_vandps_ymm0_ymm2`
- `simd_x86_vcmpgtps_ymm2_ymm3`
- `simd_x86_vfmadd231ps_xmm0_xmm1_xmm2`
- `simd_x86_vmovups_ymm0_from_rbp`
- `simd_x86_vmovups_ymm0_from_rbx_rax4`
- `simd_x86_vmovups_ymm0_to_rbp`
- `simd_x86_vmovups_ymm0_to_rbx_rax4`
- `simd_x86_vmovups_ymm1_from_rbp`
- `simd_x86_vmovups_ymm1_from_rbx_rax4`
- `simd_x86_vmovups_ymm2_from_rbp`
- `simd_x86_vorps_ymm0_ymm2`
- `simd_x86_vpaddd_ymm0_ymm1`
- `simd_x86_vpand_ymm0_ymm2`
- `simd_x86_vpandn_ymm2_ymm1`
- `simd_x86_vpcmpgtd_ymm2_ymm3`
- `simd_x86_vpmulld_ymm0_ymm1`
- `simd_x86_vpor_ymm0_ymm2`
- `simd_x86_vpshufd_ymm0_imm8`
- `simd_x86_vpsubd_ymm0_ymm1`
- `simd_x86_vpxor_ymm3_ymm3`
- `simd_x86_vxorps_ymm3_ymm3`
- `simd_x86_xorps_xmm3_xmm3`

### 3.2 当前仍由 seed/rest 提供
- `simd_append_disp32_impl`
- `simd_append_impl`
- `simd_append_u32_le_impl`
- `simd_arm64_pshufd_imm8_128_rbp_impl`
- `simd_arm64_select_128_rbp_impl`
- `simd_enc_emit_f32_select_xmm_seq_impl`
- `simd_enc_emit_f32_select_ymm_seq_impl`
- `simd_enc_emit_i32_select_xmm_seq_impl`
- `simd_enc_emit_i32_select_ymm_seq_impl`
- `simd_enc_f32_soa_col_movups_xmm1_at_idx_impl`
- `simd_enc_try_hw_vector_binop_rbp_at_idx_impl`
- `simd_enc_try_hw_vector_fadd_rbp_impl`
- `simd_enc_try_hw_vector_fma_rbp_impl`
- `simd_enc_try_hw_vector_fmul_rbp_impl`
- `simd_enc_try_hw_vector_iadd_isub_rbp_impl`
- `simd_enc_try_hw_vector_iadd_rbp_impl`
- `simd_enc_try_hw_vector_imul_rbp_impl`
- `simd_enc_try_hw_vector_isub_rbp_impl`
- `simd_enc_try_hw_vector_select_rbp_impl`
- `simd_enc_try_pshufd_rbp_impl`
- `simd_enc_x86_addps_xmm0_xmm1_impl`
- `simd_enc_x86_horizontal_addps_xmm0_impl`
- `simd_enc_x86_movss_xmm0_rbp_disp_impl`
- `simd_enc_x86_movups_xmm1_rbp_disp_impl`
- `simd_enc_x86_xorps_xmm0_zero_impl`
- `simd_x86_addps_xmm0_xmm1_impl`
- `simd_x86_andnps_xmm2_xmm1_impl`
- `simd_x86_andps_xmm0_xmm2_impl`
- `simd_x86_cmpgtps_xmm2_xmm3_impl`
- `simd_x86_movups_xmm0_from_rbp_impl`
- `simd_x86_movups_xmm0_from_rbx_rax4_impl`
- `simd_x86_movups_xmm0_to_rbp_impl`
- `simd_x86_movups_xmm0_to_rbx_rax4_impl`
- `simd_x86_movups_xmm1_from_rbp_impl`
- `simd_x86_movups_xmm1_from_rbx_rax4_impl`
- `simd_x86_movups_xmm2_from_rbp_impl`
- `simd_x86_mulps_xmm0_xmm1_impl`
- `simd_x86_orps_xmm0_xmm2_impl`
- `simd_x86_paddd_xmm0_xmm1_impl`
- `simd_x86_pand_xmm0_xmm2_impl`
- `simd_x86_pandn_xmm2_xmm1_impl`
- `simd_x86_pcmpgtd_xmm2_xmm3_impl`
- `simd_x86_pmulld_xmm0_xmm1_impl`
- `simd_x86_por_xmm0_xmm2_impl`
- `simd_x86_pshufd_xmm0_imm8_impl`
- `simd_x86_pshufd_xmm1_xmm0_impl`
- `simd_x86_psubd_xmm0_xmm1_impl`
- `simd_x86_pxor_xmm3_xmm3_impl`
- `simd_x86_vandnps_ymm2_ymm1_impl`
- `simd_x86_vandps_ymm0_ymm2_impl`
- `simd_x86_vcmpgtps_ymm2_ymm3_impl`
- `simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl`
- `simd_x86_vmovups_ymm0_from_rbp_impl`
- `simd_x86_vmovups_ymm0_from_rbx_rax4_impl`
- `simd_x86_vmovups_ymm0_to_rbp_impl`
- `simd_x86_vmovups_ymm0_to_rbx_rax4_impl`
- `simd_x86_vmovups_ymm1_from_rbp_impl`
- `simd_x86_vmovups_ymm1_from_rbx_rax4_impl`
- `simd_x86_vmovups_ymm2_from_rbp_impl`
- `simd_x86_vorps_ymm0_ymm2_impl`
- `simd_x86_vpaddd_ymm0_ymm1_impl`
- `simd_x86_vpand_ymm0_ymm2_impl`
- `simd_x86_vpandn_ymm2_ymm1_impl`
- `simd_x86_vpcmpgtd_ymm2_ymm3_impl`
- `simd_x86_vpmulld_ymm0_ymm1_impl`
- `simd_x86_vpor_ymm0_ymm2_impl`
- `simd_x86_vpshufd_ymm0_imm8_impl`
- `simd_x86_vpsubd_ymm0_ymm1_impl`
- `simd_x86_vpxor_ymm3_ymm3_impl`
- `simd_x86_vxorps_ymm3_ymm3_impl`
- `simd_x86_xorps_xmm3_xmm3_impl`

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
