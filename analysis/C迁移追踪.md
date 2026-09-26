# C → .X 迁移追踪

> 只勾已完成的。新完成项加一行 ✅。波次流水写在 [`自举进度.md`](自举进度.md)。
> 钉盘 `ecdb5cc1e` 不升。host-cc 还没到 0。

### 已完成

- ✅ `arch_arm64_enc_enc_prologue`
- ✅ `arch_arm64_enc_enc_epilogue`
- ✅ `arch_arm64_enc_enc_ret_imm32`
- ✅ `arch_x86_64_enc_enc_call`
- ✅ `arch_x86_64_enc_enc_label`
- ✅ `arch_arm64_enc_enc_label`
- ✅ `arch_arm64_enc_enc_lea_rbp_to_rax`
- ✅ `arch_arm64_enc_enc_lea_rbp_to_rbx`
- ✅ `arm64_enc_branch_patch`
- ✅ `x86_enc_jcc_rel32`
- ✅ `arch_x86_64_enc_enc_jmp`
- ✅ `backend_enc_mov_imm32_to_w0_arch`
- ✅ `x86_enc_movq_from_rbp_neg`
- ✅ `x86_enc_lea_from_rbp_neg`
- ✅ `x86_enc_movl_from_rbp_neg32`
- ✅ `x86_enc_store_rax_to_rbp_neg`
- ✅ `x86_enc_store_r64_to_rbp_neg`
- ✅ `x86_enc_alu_imm32_to_reg`
- ✅ `x86_enc_store_rdx_to_rbp_neg`
- ✅ `arch_x86_64_enc_enc_cmp_setcc_movzbl`
- ✅ `arch_arm64_enc_enc_cmp_setcc_movzbl`
- ✅ `arch_arm64_enc_enc_jmp`
- ✅ `arch_arm64_enc_enc_jz`
- ✅ `arch_arm64_enc_enc_jne`
- ✅ `arch_arm64_enc_enc_jnz`
- ✅ `arch_arm64_enc_enc_jeq`
- ✅ `arch_arm64_enc_enc_jge`
- ✅ `arch_x86_64_enc_enc_jz`
- ✅ `arch_x86_64_enc_enc_jeq`
- ✅ `arch_x86_64_enc_enc_jge`
- ✅ `arch_x86_64_enc_enc_jnz`
- ✅ `arch_x86_64_enc_enc_prologue`
- ✅ `arch_x86_64_enc_enc_epilogue`
- ✅ `x86_enc_u8`
- ✅ `x86_enc_u32_le`
- ✅ `x86_enc_bytes`
- ✅ `arch_arm64_enc_enc_add_imm_to_rax`
- ✅ `arch_arm64_enc_enc_add_imm_to_rbx`
- ✅ `arch_arm64_enc_enc_load_rbp_to_rax`
- ✅ `arch_arm64_enc_enc_load_rbp_to_rbx`
- ✅ `arch_arm64_enc_enc_load_rbp_to_x2`
- ✅ `arch_arm64_enc_enc_load_rbp_to_x3`
- ✅ `arch_arm64_enc_enc_store_x_reg_to_rbp`
- ✅ `arch_arm64_enc_enc_store_rax_to_rbp`
- ✅ `arch_arm64_enc_enc_store_rax_to_rbx_offset`
- ✅ `arch_x86_64_enc_enc_store_rax_to_rbp`
- ✅ `arch_x86_64_enc_enc_store_r64_to_rbp`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_rax`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_rbx`
- ✅ `arch_x86_64_enc_enc_lea_rbp_to_rax`
- ✅ `arch_x86_64_enc_enc_lea_rbp_to_rbx`
- ✅ `arch_x86_64_enc_enc_load_rbp_pos_to_rax`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_eax32`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_ebx32`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_ecx`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_edx`
- ✅ `arch_x86_64_enc_enc_add_imm_to_ecx`
- ✅ `arch_x86_64_enc_enc_sub_imm_from_ecx`
- ✅ `arch_x86_64_enc_enc_add_imm_to_ebx_index`
- ✅ `arch_x86_64_enc_enc_sub_imm_from_ebx_index`
- ✅ `arch_x86_64_enc_enc_imul_imm_to_ecx`
- ✅ `arch_x86_64_enc_enc_imul_imm_to_ebx`
- ✅ `arch_x86_64_enc_enc_store_rdx_to_rbp`
- ✅ `arch_x86_64_enc_enc_load_rbp_to_rdx`
- ✅ `arch_x86_64_enc_enc_mov_imm32_to_rbx`
- ✅ `arch_x86_64_enc_enc_ret_imm32`
- ✅ `arch_x86_64_enc_enc_mov_imm64_to_rax`
- ✅ `arch_x86_64_enc_enc_cmp_eax_imm32`
- ✅ `arch_x86_64_enc_enc_add_imm_to_rax`
- ✅ `arch_x86_64_enc_enc_add_imm_to_rbx`
- ✅ `arch_x86_64_enc_enc_add_rsp_imm`
- ✅ `arch_x86_64_enc_enc_store_rax_to_rbx_indirect`
- ✅ `arch_x86_64_enc_enc_store_rax_to_rbx_offset`
- ✅ `arch_x86_64_enc_enc_sub_rax_rbx`
- ✅ `arch_x86_64_enc_enc_load_qword_from_rbx_to_rax`
- ✅ `arch_x86_64_enc_enc_load_qword_rbx8_to_rdx`
- ✅ `arch_x86_64_enc_enc_mov_rdx_to_arg_reg`
- ✅ `arch_x86_64_enc_enc_add_rax_rbx`
- ✅ `arch_x86_64_enc_enc_and_rbx_rax`
- ✅ `arch_x86_64_enc_enc_or_rbx_rax`
- ✅ `arch_x86_64_enc_enc_xor_rbx_rax`
- ✅ `arch_x86_64_enc_enc_mov_rax_to_rbx`
- ✅ `arch_x86_64_enc_enc_mov_rbx_to_rax`
- ✅ `arch_x86_64_enc_enc_mov_rbx_to_ecx`
- ✅ `arch_x86_64_enc_enc_mov_edx_to_eax`
- ✅ `arch_x86_64_enc_enc_not_eax`
- ✅ `arch_x86_64_enc_enc_neg_eax`
- ✅ `arch_x86_64_enc_enc_test_eax_eax`
- ✅ `arch_x86_64_enc_enc_test_rbx_rbx`
- ✅ `arch_x86_64_enc_enc_test_edx_edx`
- ✅ `arch_x86_64_enc_enc_cmp_rbx_rax`
- ✅ `arch_x86_64_enc_enc_cmp_rax_rbx`
- ✅ `arch_x86_64_enc_enc_cltd`
- ✅ `arch_x86_64_enc_enc_idiv_rbx`
- ✅ `arch_x86_64_enc_enc_imul_rbx_rax`
- ✅ `arch_x86_64_enc_enc_push_rax`
- ✅ `arch_x86_64_enc_enc_push_rbx`
- ✅ `arch_x86_64_enc_enc_pop_rbx`
- ✅ `arch_x86_64_enc_enc_pop_rax`
- ✅ `arch_x86_64_enc_enc_shl_cl_eax`
- ✅ `arch_x86_64_enc_enc_shr_cl_eax`
- ✅ `arch_x86_64_enc_enc_sar_cl_eax`
- ✅ `arch_x86_64_enc_enc_shl_cl_rax`
- ✅ `arch_x86_64_enc_enc_shr_cl_rax`
- ✅ `arch_x86_64_enc_enc_sar_cl_rax`
- ✅ `arch_x86_64_enc_enc_xor_edx_edx`
- ✅ `arch_x86_64_enc_enc_div_rbx`
- ✅ `arch_x86_64_enc_enc_load_32_from_rax`
- ✅ `arch_x86_64_enc_enc_load_64_from_rax`
- ✅ `arch_x86_64_enc_enc_load_zext8_from_rax`
- ✅ `arch_x86_64_enc_enc_rax_plus_rbx_scale1`
- ✅ `arch_x86_64_enc_enc_rax_plus_rbx_scale4`
- ✅ `arch_x86_64_enc_enc_rax_plus_rbx_scale8`
- ✅ `arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1`
- ✅ `arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4`
- ✅ `arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8`
- ✅ `arch_x86_64_enc_enc_add_ecx_edx`
- ✅ `arch_x86_64_enc_enc_sub_ecx_edx`
- ✅ `arch_x86_64_enc_enc_add_ebx_edx`
- ✅ `arch_x86_64_enc_enc_sub_ebx_edx`
- ✅ `arch_x86_64_enc_enc_imul_ecx_edx`
- ✅ `arch_x86_64_enc_enc_imul_ebx_edx`
- ✅ `arch_x86_64_enc_enc_sub_rbx_rax_then_mov`
- ✅ `arch_x86_64_enc_enc_rsub_ecx_edx`
- ✅ `arch_x86_64_enc_enc_rsub_ebx_edx`
- ✅ `arch_x86_64_enc_enc_setz_movzbl_eax`
- ✅ `arch_x86_64_enc_enc_syscall`
- ✅ `arch_x86_64_enc_enc_movl_mem_rax_to_eax`
- ✅ `arch_x86_64_enc_enc_movl_mem_rcx_to_eax`
- ✅ `arch_x86_64_enc_enc_xchg_edx_mem_rax`
- ✅ `arch_x86_64_enc_enc_mov_rax_to_rcx`
- ✅ `arch_x86_64_enc_enc_movl_eax_to_mem_rcx`
- ✅ `arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rax`
- ✅ `arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rbx`
- ✅ `arch_x86_64_enc_enc_sete_al`
- ✅ `arch_x86_64_enc_enc_movzbl_al_eax`
- ✅ `arch_x86_64_enc_enc_mov_eax_to_edx`
- ✅ `arch_x86_64_enc_enc_movq_mem_rax_to_rax`
- ✅ `arch_x86_64_enc_enc_xchg_rdx_mem_rax`
- ✅ `arch_x86_64_enc_enc_mov_rax_to_rdx`
- ✅ `arch_x86_64_enc_enc_movq_mem_rcx_to_rax`
- ✅ `arch_x86_64_enc_enc_movq_rax_to_mem_rcx`
- ✅ `arch_x86_64_enc_enc_lock_cmpxchg_rdx_mem_rbx`
- ✅ `arch_x86_64_enc_enc_mfence`
- ✅ `arch_x86_64_enc_enc_lfence`
- ✅ `arch_x86_64_enc_enc_sfence`
- ✅ `arch_x86_64_enc_enc_movzwl_mem_rax_to_eax`
- ✅ `arch_x86_64_enc_enc_xchg_dx_mem_rax`
- ✅ `arch_x86_64_enc_enc_mov_ax_to_dx`
- ✅ `arch_x86_64_enc_enc_movzwl_mem_rcx_to_eax`
- ✅ `arch_x86_64_enc_enc_movw_ax_to_mem_rcx`
- ✅ `arch_x86_64_enc_enc_lock_cmpxchg_dx_mem_rbx`
- ✅ `arch_x86_64_enc_enc_mov_rax_to_r10`
- ✅ `arch_x86_64_enc_enc_mov_r10_to_rax`
- ✅ `arch_x86_64_enc_enc_mov_rax_to_r11`
- ✅ `arch_x86_64_enc_enc_mov_r11_to_rax`
- ✅ `arch_x86_64_enc_enc_pause`
- ✅ `arch_x86_64_enc_enc_int3`
- ✅ `arch_arm64_enc_enc_u32_le`
- ✅ `arch_arm64_enc_enc_mov_imm32_to_w0`
- ✅ `arch_arm64_enc_enc_mov_imm32_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_imm64_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rax_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_edx_to_eax`
- ✅ `arch_arm64_enc_enc_cltd`
- ✅ `arch_arm64_enc_enc_store_rax_to_rbx_indirect`
- ✅ `arch_arm64_enc_enc_mov_rax_to_arg_reg`
- ✅ `arch_arm64_enc_enc_mov_arg_reg_to_rax`
- ✅ `arch_arm64_enc_enc_load_32_from_rax`
- ✅ `arch_arm64_enc_enc_load_64_from_rax`
- ✅ `arch_arm64_enc_enc_load_zext8_from_rax`
- ✅ `arch_arm64_enc_enc_rax_plus_rbx_scale1`
- ✅ `arch_arm64_enc_enc_rax_plus_rbx_scale4`
- ✅ `arch_arm64_enc_enc_rax_plus_rbx_scale8`
- ✅ `arch_arm64_enc_enc_rbx_plus_x2_scale1`
- ✅ `arch_arm64_enc_enc_rbx_plus_x2_scale4`
- ✅ `arch_arm64_enc_enc_rbx_plus_x2_scale8`
- ✅ `arch_arm64_enc_enc_svc`
- ✅ `arch_arm64_enc_enc_dmb_ish`
- ✅ `arch_arm64_enc_enc_dmb_ishld`
- ✅ `arch_arm64_enc_enc_dmb_ishst`
- ✅ `arch_arm64_enc_enc_ldar_w0_x0`
- ✅ `arch_arm64_enc_enc_stlr_w1_x0`
- ✅ `arch_arm64_enc_enc_ldr_w0_x3`
- ✅ `arch_arm64_enc_enc_str_w0_x3`
- ✅ `arch_arm64_enc_enc_mov_w0_to_w4`
- ✅ `arch_arm64_enc_enc_casal_w0_w1_x2`
- ✅ `arch_arm64_enc_enc_cmp_w0_w4`
- ✅ `arch_arm64_enc_enc_cset_eq_w0`
- ✅ `arch_arm64_enc_enc_ldar_x0_x0`
- ✅ `arch_arm64_enc_enc_stlr_x1_x0`
- ✅ `arch_arm64_enc_enc_ldr_x0_x3`
- ✅ `arch_arm64_enc_enc_str_x0_x3`
- ✅ `arch_arm64_enc_enc_casal_x0_x1_x2`
- ✅ `arch_arm64_enc_enc_cmp_x0_x4`
- ✅ `arch_arm64_enc_enc_ldarh_w0_x0`
- ✅ `arch_arm64_enc_enc_stlrh_w1_x0`
- ✅ `arch_arm64_enc_enc_ldrh_w0_x3`
- ✅ `arch_arm64_enc_enc_strh_w0_x3`
- ✅ `arch_arm64_enc_enc_casalh_w0_w1_x2`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x2`
- ✅ `arch_arm64_enc_enc_mov_x2_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x2`
- ✅ `arch_arm64_enc_enc_mov_x2_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x9`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x8`
- ✅ `arch_arm64_enc_enc_mov_x8_to_rax`
- ✅ `arch_arm64_enc_enc_mov_x0_to_x1`
- ✅ `arch_arm64_enc_enc_mov_x0_to_x2`
- ✅ `arch_arm64_enc_enc_mov_x0_to_x3`
- ✅ `arch_arm64_enc_enc_mov_x0_to_x4`
- ✅ `arch_arm64_enc_enc_mov_x9_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x10`
- ✅ `arch_arm64_enc_enc_mov_x10_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x10`
- ✅ `arch_arm64_enc_enc_mov_x10_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x11`
- ✅ `arch_arm64_enc_enc_mov_x11_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x11`
- ✅ `arch_arm64_enc_enc_mov_x11_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x12`
- ✅ `arch_arm64_enc_enc_mov_x12_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x12`
- ✅ `arch_arm64_enc_enc_mov_x12_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x13`
- ✅ `arch_arm64_enc_enc_mov_x13_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x13`
- ✅ `arch_arm64_enc_enc_mov_x13_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x14`
- ✅ `arch_arm64_enc_enc_mov_x14_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x14`
- ✅ `arch_arm64_enc_enc_mov_x14_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rax_to_x15`
- ✅ `arch_arm64_enc_enc_mov_x15_to_rax`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_x15`
- ✅ `arch_arm64_enc_enc_mov_x15_to_rbx`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_rax`
- ✅ `arch_arm64_enc_enc_add_rax_rbx`
- ✅ `arch_arm64_enc_enc_sub_rax_rbx`
- ✅ `arch_arm64_enc_enc_sub_rbx_rax_then_mov`
- ✅ `arch_arm64_enc_enc_imul_rbx_rax`
- ✅ `arch_arm64_enc_enc_idiv_rbx`
- ✅ `arch_arm64_enc_enc_and_rbx_rax`
- ✅ `arch_arm64_enc_enc_or_rbx_rax`
- ✅ `arch_arm64_enc_enc_xor_rbx_rax`
- ✅ `arch_arm64_enc_enc_cmp_rbx_rax`
- ✅ `arch_arm64_enc_enc_cmp_rax_rbx`
- ✅ `arch_arm64_enc_enc_neg_eax`
- ✅ `arch_arm64_enc_enc_not_eax`
- ✅ `arch_arm64_enc_enc_test_eax_eax`
- ✅ `arch_arm64_enc_enc_test_rbx_rbx`
- ✅ `arch_arm64_enc_enc_push_rax`
- ✅ `arch_arm64_enc_enc_push_rbx`
- ✅ `arch_arm64_enc_enc_pop_rax`
- ✅ `arch_arm64_enc_enc_pop_rbx`
- ✅ `arch_arm64_enc_enc_mov_rbx_to_ecx`
- ✅ `arch_arm64_enc_enc_setz_movzbl_eax`
- ✅ `arch_arm64_enc_enc_shl_cl_eax`
- ✅ `arch_arm64_enc_enc_shr_cl_eax`
- ✅ `arch_arm64_enc_enc_sar_cl_eax`
- ✅ `arch_arm64_enc_enc_shl_cl_rax`
- ✅ `arch_arm64_enc_enc_shr_cl_rax`
- ✅ `arch_arm64_enc_enc_sar_cl_rax`
- ✅ `backend_enc_ldr_xreg_xreg_imm_arch`
- ✅ `backend_enc_store_arg_sp_offset_arch`
- ✅ `backend_enc_blr_arch`
- ✅ `backend_enc_ucomiss_rbx_rax_arch`
- ✅ `backend_enc_mov_rax_to_xmm_arg_reg_arch`
- ✅ `backend_enc_mov_xmm_arg_reg_to_rax_arch`
- ✅ `backend_enc_fp_cmp_setcc_movzbl_arch`
- ✅ `backend_enc_ucomisd_rbx_rax_arch`
- ✅ `backend_enc_divsd_rax_rbx_arch`
- ✅ `backend_enc_mulsd_rax_rbx_arch`
- ✅ `backend_enc_subsd_rax_rbx_arch`
- ✅ `backend_enc_subsd_rbx_rax_arch`
- ✅ `backend_enc_addsd_rax_rbx_arch`
- ✅ `backend_enc_x86_64_load_rax_rbx_disp32_c`
- ✅ `backend_enc_arm64_ldr_xreg_xreg_imm_c`
- ✅ `backend_enc_riscv64_ldr_xreg_xreg_imm_c`
- ✅ `backend_enc_x86_64_call_reg_c`
- ✅ `backend_enc_riscv64_jalr_reg_c`
- ✅ `backend_enc_arm64_blr_c`
- ✅ `backend_enc_append_u32_le_c_impl`
- ✅ `backend_enc_append_u8_c_impl`
- ✅ `arch_x86_64_enc_enc_cdqe_rax_impl`
- ✅ `arch_riscv64_enc_enc_ldr_xreg_xreg_imm`
- ✅ `arch_riscv64_enc_enc_jalr_reg`
- ✅ `arch_x86_64_enc_enc_load_rax_rbx_disp32`
- ✅ `arch_x86_64_enc_enc_call_reg`
- ✅ `arch_arm64_enc_enc_ldr_xreg_xreg_imm`
- ✅ `arch_arm64_enc_enc_blr`
- ✅ `pipeline_module_import_path_byte_at` 带签名转发
- ✅ `pipeline_asm_emit_dep_pipe_c` 带签名转发
- ✅ `pipeline_dep_ctx_module_at` 带签名转发
- ✅ `pipeline_dep_ctx_ndep` 带签名转发
- ✅ `pipeline_expr_field_access_name_into` 带签名转发
- ✅ `pipeline_expr_binop_right_ref_at` 带签名转发
- ✅ `pipeline_expr_binop_left_ref_at` 带签名转发
- ✅ `pipeline_expr_field_access_base_ref` 带签名转发
- ✅ `pipeline_expr_field_access_name_len` 带签名转发
- ✅ `glue_codegen_import_path_to_c_prefix_into` 带签名转发
- ✅ `glue_try_std_heap_redirect_sym_local` 带签名转发
- ✅ `glue_asm_build_import_binding_call_sym` 带签名转发
- ✅ `glue_asm_build_func_export_sym_c` 带签名转发
- ✅ `pipeline_type_kind_ord_at` 带签名转发
- ✅ 编码／preamble／parse／emit／arena 的 slice marker
- ✅ arch-emit 切片 marker
- ✅ 五份无人编译的 L2 thin C 种子已删除
- ✅ 编码薄层、诊断薄层、九个别名、`cfg_eval_host_lit`、arch-emit 壳、lsp sizes、18 个别名、精确诊断的 C 体已删除
- ✅ rt_emit_state／rt_arena_buf／rt_preamble 的已迁函数 C 体已删除
- ✅ type_ref、FN_BLOCK、skip_tl、seed_parse、stretch suite 退出产品链；死文件已清
- ✅ elf／typeck_orch／ast forwarders 与 pipeline_abi 冷孪生退出 POSIX 产品 rest

### 维护约定

1. 完成就加一行 ✅。不写残项长文，不写 SHA。
2. 阶段地图仍在下面。开项不在这里展开。

---

## 0. 仪表盘

| 轨道／债 | 状态 | 事实（短） |
|----------|------|------------|

| 库层 .X 化（阶段 1） | ✅ | 100% |
| Thin 退役（阶段 2） | ✅ | T 18/18 |
| Prove 注册（阶段 3） | ✅ | N 111/111 |
| Cap 能力解锁（阶段 4） | 🟡 | 3 leave-off ⬜ |
| R2 真迁（阶段 5） | 🟡 | ~120/128；余绑平台债 |
| Mega 拆分 M1–M3（阶段 6） | ✅ | 3/3 |
| Mega 去 pin M4（阶段 7） | 🟡 | leftover flatten 完；parser seed 物理删 ⬜；产品 `.inc` 仍 host-cc；P20b zeros 已纯 asm |
| Pinned gen 退役（阶段 8） | ✅ | 30/30 |
| 非 gen 产品 C／8.3 | 🟡 | wave309 壳物理退役（present 0）；产品 `.inc`／from_x／其它 host-cc seed 仍开；AP leftover 拼装＋AS／AT driver_abi Cap 剥已收 |
| Cap residual 消灭（阶段 9） | ✅ | 9.1–9.7 |
| Win PE egg pin | ✅ | egg＠`99b008cc1`；默认 asm **5/5**；FIELD／INDEX／DEREF／`struct_let_init`／`copy_large_struct`／SIMD／`asm_parser_*`／m8_tail／`collect_walk`／`pgo_emit_order_*` override **进 live**（Class S–AC leftover-safe LEGACY g05）；**三端 L2 硬闸已启用** |
| 语言能力 L2（阶段 10） | 🟡 | 主面 ✅；残 NT／MSVC／qemu／Win 实机 |
| xbuild／MG（阶段 11） | 🟡 | Makefile 物理删 ✅；终局／零 cc CI 仍开 |
| 冷启动零 cc（阶段 12） | 🟡 | LINK／`.s` 大半 ✅；全路径零 cc ⬜ |
| 终局 MG+BC+PC+v2==v3（阶段 13） | 🟡 | MG 文件层 ✅；BC／PC／v2==v3 未终 |
| 产品 L4 钉盘 | ✅ | **`ecdb5cc1e`**（升钉默认不做） |
| BC（编译层零 host-cc） | 🟡 | inventory present **0**（Class O）；余量＝map 外 from_x／seed／`.inc`／大户 leftover 真减；Darwin tip **可 prefer labi**（AU；L6／L8 仍 host-cc；AV Cap seed 已剥） |
| PC（产品默认 asm） | 🟡 | 门控已收；`labi_invoke_cc` 未删 |
| `pipeline_abi` mega pure-asm | 🟡 | 已绿 PREFER 面同上。**Class AP** leftover 拼装已收；**Class AV–AY** seed Cap 已剥；**Class AZ–BA** parser stretch suite 审计空桩＋产品 keep（thin_glue **1837656→343168**）。**Class BB–BD** Darwin leftover／labi／driver unwind＋Cap 压桩（pabi **1478272→1325868**）；**Class BE–BG** labi needle 表（labi **→406232**）；**Class BH–BI** leftover Cap PGO／WPO_MONO＋PGO-Lite 余桩（pabi **→1310504**）；**Class BJ** labi 26× od／fs needle（labi **→396392**）；**Class BK** call_dispatch Cap va／atomic／simd（call_dispatch **→140568**）；**Class BL** try_inline WPO_MONO Cap（try_inline **→39512**）；**Class BM** call_dispatch heap redirect 表化（call_dispatch **→133624**）；**Class BN** leftover Cap WPO reach／DCE（pabi **→1294672**）；**Class BO** leftover Cap-heavy safe（pabi **→1275064**）；**Class BP** leftover Cap-heavy skip／safe（pabi **→1253384**）；**Class BQ** tip compact_unwind 安全剥（slc／diagnostic／try_inline **−20360**）；**Class BR** Cap-skip＋ASM_DEBUG Cap 剥（pabi **→1246112**；call_dispatch **→127536**）；**Class BS** compact_unwind n_sect 修＋call／enc／diag 剥（合计 **−16440**）；**Class BT** tip compact_unwind 扩剥（合计 **−25280**）；**Class BU** tip compact_unwind G05 全扫（合计 **−80520**）；**Class BV** token／typekind 表化（pabi **→1232824**）。禁 FORCE；禁剥 thin_glue；禁 diag／vsnprintf Cap。真减 host-cc 续。HARD BAN／leftover-first／mega FORCE／`-E` 当修仍禁。 |
| nest 冻帽 | ✅ | **64** |
| check 闸门 | ⏸ | 自举期须点名才 dogfood |

**终局三义**：MG ✅ · BC 🟡 · PC 🟡。

---

## 阶段 0–3 · 已闭

- ✅ **阶段 0** 基建与方法论  
- ✅ **阶段 1** 库层 .X 化  
- ✅ **阶段 2** Thin 退役 T 18/18  
- ✅ **阶段 3** Prove 注册 N 111/111  

---

## 阶段 4 · Cap 能力解锁 🟡

### 已闭

- ✅ Cap dest／dyn／nest17–64／METHOD／STRUCT_LIT 等主面  

### 开项

- 🟡 **4.2.8** AST name 槽 128B→256B layout raise（content 127→255）  
- ⬜ **4.2.9** LANG-006 标量 bool→int — 有意保留 soft  
- ⬜ **4.2.16** `*T[N]` 解析序 — 有意保留 soft（`*[N]T`＝指针到数组）  

### 纪律

- nest **冻 64**；禁抬 nest 65；禁无界 assemble mega 当冷路径  

---

## 阶段 5 · R2 真迁 🟡

- ✅ 已真迁 ~120／128 prove 模块  

### 开项

- ⬜ **5.2.2** Darwin stage2 rv／strict multi-def  
- ⬜ **5.2.3** host `_impl` 后缀命名 — leave-off  
- ⬜ **5.2.4** Darwin `int64_t main` 硬要求 int  
- ⬜ **5.2.5** Windows MSYS2 hybrid 未重跑  
- ⬜ **5.2.6** mac CTFE 常 fold 假绿  
- ⬜ **5.2.7** mac `-dead_strip` 假绿当 Ubuntu 全链已过  

---

## 阶段 6 · Mega 拆分 M1–M3 ✅

- ✅ **6.1** runtime mega 拆分  
- ✅ **6.2** parser thin mega 拆分  
- ✅ **6.3** link_abi mega 拆分  

---

## 阶段 7 · Mega 去 pin（M4）🟡

### 已闭

- ✅ **7.1** runtime monofile 物理退役  
- ✅ **7.2.1a** 入口素材 70 件清零  
- ✅ **7.2.1b leftover flatten** unique 0／helpers 0；深链分批覆盖戏停  
- ✅ **7.2.1b Route C／B-minus** P1b–P1g · P2b–P2d · P3b–P3s · P4* · P5* · P6b–P6h · P7b–P7d · P9–P19 · P10–P18（细目见归档）  
- ✅ **7.2.3／7.3／7.4.1／7.4.2／7.4.3** 冷链／Stage2／prefer `.x`  
- ✅ **7.4.4** 双权威闸全家族  
- ✅ **7.4.5–7.4.10** typeck pin 孪生／leftover PE unique 0  

### 开项

- 🟡 **7.2.1b 残** 产品 `.inc` 切片仍 host-cc（glue_tail／冷 rest）；禁再深链分批 eq  
- 🟡 **7.2.2** parser_gen 去 pin — 产品默认 pin-first；`FROM_X=1` 仅显式 assemble  
- ⬜ **7.2.1** parser seed 物理删（依赖 7.2.1b／8.3）  

---

## 阶段 8 · Pinned gen 退役 ✅ · 8.3 非 gen 🟡

### 已闭

- ✅ **8.1** PRODUCT RETIRED 23／23  
- ✅ **8.2** NON_PRODUCT 7／7  
- ✅ **合计 30／30 FULLY CLOSED**  
- ✅ **8.3.4／8.3.5／8.3.7／8.3.9** leave／stubs／孤儿清理  
- ✅ glue 壳／typedefs／standalone deleted；bc-inventory present product C rows **0**  
- ✅ **8.3.6** 死件删除 114 件；三分表定稿（种子保留；`.inc` #else 冷质量待 L4 全 `.x` 冷引导）  

### 开项

- ✅ **8.3.1** `pipeline_glue`／fwd／standalone 壳物理退役（Class O；inventory present 0）  
- ✅ **8.3.2** `ast_pool`／typedefs 壳物理退役（Class O；inventory present 0）  
- 🟡 **8.3.3** field_access／soa — 叶 leave ✅；父项随冷孪生  
- 🟡 **8.3.8** `build_asm/gen_driver/*.c` — `pipeline_gen.c` 残留  
- ⬜ **8.3.10** `editors/tree-sitter-xlang/` 第三方 .c  
- ⬜ **BC 终局** 冷孪生整 TU 离 host-cc  

---

## 阶段 9 · Cap residual 边界消灭 ✅

- ✅ **9.1** OS 系统调用 9.1.1–9.1.12  
- ✅ **9.2** 第三方库勘正／standing（zlib／sqlite／libm／mbedtls／arrow／ed25519）  
- ✅ **9.3** 宏／host lit／atomic／SIMD 桥 standing  
- ✅ **9.4** C ABI／fnptr／argv／线程  
- ✅ **9.5** FILE／fprintf／va_list／fdprint／有界读  
- ✅ **9.6** 全局／static／modlet／字串池／RELA  
- ✅ **9.7** driver_abi 平台层 9.7.1–9.7.7  

> standing C＝系统库／语言极限（有意不迁）。细节见归档。

---

## 阶段 10 · 语言能力补齐 🟡

### 已闭

- ✅ **10.1.1／10.1.2** Linux x86_64／arm64 syscall 内建  
- ✅ **10.2.1** x86_64 inline asm slice0–16  
- ✅ **10.3.1–10.3.3** fnptr 类型／cast／间接 call／作参返回字段  
- ✅ **10.4.1／10.4.2** atomic＋内存屏障  
- ✅ **10.5.1／10.5.2** AVX／SSE／NEON／SVE  
- ✅ **10.6.1／10.6.3** Linux／Darwin 线程＋全平台 sync Cap  
- ✅ **10.7.1** va_list POSIX／host-C 单实例（MSVC 残）  
- ✅ **10.7.2** Cap vsnprintf slice0–21（纯 .x fmt／MSVC 残）  

### 开项

- ⬜ **10.1.3** Windows NT API 内建 — 暂缓  
- 🟡 **10.1.4** raw FFI — slice1–2 ✅；残 NT→10.1.3  
- 🟡 **10.2.2** arm64 inline asm — slice0–3 ✅；残 qemu  
- 🟡 **10.2.3** Windows inline asm — slice0–1 ✅；残 MSYS Win 运行时  
- 🟡 **10.6.2** Windows CreateThread — 源码＋gate ✅；残 MSYS／Win 实机  
- 🟡 **10.7.1 残** MSVC va  
- 🟡 **10.7.2 残** 纯 .x fmt · MSVC  

---

## 阶段 11 · xbuild + Makefile 退役（MG）🟡

### 已闭

- ✅ **11.2.2** `./xbuild l4`  
- ✅ **11.2.3／11.2.5／11.4.1／11.4.3／11.4.6** 编排入口  
- ✅ **11.3／11.3.1** Makefile 物理删除；catalog 单权威；bootstrap 0 make  

### 开项

- 🟡 **11.1.1–11.1.6** 依赖图／调度／平台／链接／`build.x`／吞并 g05 — 终局未完  
- ⬜ **11.2.1** stage1→2→3 编排 + 自动 v2==v3  
- ✅ **11.2.4** Windows／MSYS2：冷底座（g05＋crt0）✅；PE egg＋B-hybrid ✅；默认 asm **5/5**＠`89d99eb0c`；**三端 L2 硬闸已启用**＠`7edba47f4`（L4 真冷仍经理另派）  
- ⬜ **11.3.3** 其它 make 碎片（含 tree-sitter）  
- ⬜ **11.3.4** 「无 make + 无 cc」CI 闸门  
- 🟡 **11.4.5** docker 仍装 gcc／make  
- 🟡 **11.5.1–11.5.4** bench／tests 宿主 `.c` 策略（卸 cc→阶段 12）  
- ⬜ **11.6.1** `editors/tree-sitter-xlang/`  

---

## 阶段 12 · 冷启动零 cc 🟡

### 已闭

- ✅ LINK 全零 cc · `.s` COMPILE 零 cc · stub weak · `forbid_host_cc`  
- ✅ prefer 族／硬闸／ALLOW_TREE 地图  

### 开项

- 🟡 **12.0.5** asm backend 覆盖 — **`pipeline_abi` mega 仍硬禁**  
- ⬜ **12.1.1** 手写 asm seed（或极简二进制）  
- ⬜ **12.1.2** seed 产出 xlang_v1（无需 `-E`→cc）  
- ⬜ **12.1.3** 与 pin 退役衔接  
- 🟡 **12.2.1** 零 cc 验证 — ⬜ **全路径**零 `execve(cc)`  
- ⬜ **12.2.2** 双端冷启动验证（零 cc 闭环）  
- 🟡 **12.2.3** 产品默认后端 — `labi_invoke_cc` 未删  

---

## 阶段 13 · 终局 🟡

### 已闭

- ✅ **13.1.1** 前置闸门定义  
- ✅ **13.1.3** 阶段 9 residual 勘正收口  

### 开项

- ⬜ **13.1.2** 阶段 8 gen + 8.3／BC 完成（gen ✅；8.3／BC 未终）  
- ⬜ **13.1.4** v2 == v3 语义自举  
- ⬜ **13.1.5** D-03 bit-identical（可选）  
- ⬜ **13.2.1** 双端 L4 真冷 + 129 bstrict（**零 make · 零 host-cc**）  
- 🟡 **13.2.2** Makefile 物理删除验收 — 文件层 ✅；调用面／host-cc residual 🟡  
- ⬜ **13.2.3** 零 cc 三义验收（MG+BC+PC）  
- 🟡 **13.2.4** `labi_invoke_cc`／`-backend c` 退役或隔离  
- ⬜ **13.3.1** 物理删 seed 业务体  
- ⬜ **13.3.2** 宣布自举完成  

---

## 产品软残

| 项 | 状态 | 备注 |
|----|------|------|
| STD／CORE／gate soft SKIP 邻域 | 🟡 | 主池多空；余见归档 |
| `pipeline_abi` mega pure-asm | 🟡 | 已绿 PREFER：add_defs／param_ptr_slot／unused_hints／asm_expr helpers／`asm_wpo_thin`／`wpo_dump` helpers／`asm_locals`；Darwin COMMON lea／F7 data_len sidecar。**AP** Darwin leftover 拼装半刀已收。HARD BAN 面仍开。leftover-first 非主刀。mega FORCE 禁。禁 `-E` 当修。 |
| nest 冻 64 | ✅ | — |

---

## 附录

| 项 | 值 |
|----|-----|
| 产品 L4 放行钉盘 | **`ecdb5cc1e`** |
| bstrict | 129 |
| 升钉条件 | 用户点名 L4／谈自举；禁止微步升钉 |

### 推荐推进序

1. **主刀 M2**（[`自举效率方法-M2主链.md`](自举效率方法-M2主链.md)）：**Class F–AO** 已收。**Class DS** 把 `pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_module_import_path_byte_at`，这是 `u8` 三参，符号仍弱）；lexer 尾仍 host-cc。**Class DR** 把 `pipeline_asm_emit_dep_pipe_c_retu8_ptr` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_asm_emit_dep_pipe_c`，这是零参 `*u8`，符号仍弱）。**Class DQ** 把 `pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_dep_ctx_module_at`，这是 `*u8` 两参，符号仍弱）；lexer 尾与其余 `XLANG_WEAK` 别名仍 host-cc。**Class DP** 把 `pipeline_dep_ctx_ndep_u8_ptr_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_dep_ctx_ndep`，这是 i32 单参，符号仍弱）；lexer 尾与其余 `XLANG_WEAK` 别名仍 host-cc。**Class DO** 把 `pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_expr_field_access_name_into`，无后缀实现返回 void，符号仍弱）；lexer 尾与其余 `XLANG_WEAK` 别名仍 host-cc。**Class DN** 把 `pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_expr_binop_right_ref_at`，符号仍弱）；lexer 尾与其余 `XLANG_WEAK` 别名仍 host-cc。**Class DM** 把 `pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_expr_binop_left_ref_at`，符号仍弱）。**Class DL** 把 `pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_expr_field_access_base_ref`，符号仍弱）。**Class DK** 把 `pipeline_expr_field_access_name_len_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_expr_field_access_name_len`，符号仍弱）。**Class DJ** 把 `glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32` 收进 `x_frontend_link_alias.x`（仍转调 `glue_codegen_import_path_to_c_prefix_into`，无后缀实现返回 void，符号仍强）。**Class DI** 把 `glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `glue_try_std_heap_redirect_sym_local`，符号仍强）。**Class DH** 把 `glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `glue_asm_build_import_binding_call_sym`，符号仍强）。**Class DG** 把 `glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `glue_asm_build_func_export_sym_c`，符号仍强）。**Class DF** 把 `pipeline_type_kind_ord_at_u8_ptr_i32_reti32` 收进 `x_frontend_link_alias.x`（仍转调 `pipeline_type_kind_ord_at`，符号仍强）。**Class DE** 把 `backend_enc_dispatch_slice_marker` 收进 thin `.x`（仍返回 1）；f64／Cap 尾仍 host-cc。**Class CX** 删掉 `backend_enc_dispatch` 薄层公共函数的冷路径 C 体和无人引用的 thin 种子，权威在 thin `.x`。**Class CW** 删掉 `runtime_driver_diagnostic` 薄层公共函数的冷路径 C 体，权威在 `.x`；asm BSS 仍 host-cc。**Class CV** 删掉 `lsp_diag_pipeline_ctx` 九个薄别名的 C 体，权威在 `.x`；`_impl`／状态缓冲仍 host-cc。**Class DD** 把 `labi_rt_preamble_slice_marker` 收进 `.x`（仍返回 1）；字符串表仍 host-cc。**Class DC** 把 `labi_rt_parse_diag_slice_marker` 收进 `.x`（仍返回 1）；恢复诊断仍 host-cc。**Class DB** 把 `labi_rt_emit_state_slice_marker` 收进 `.x`（仍返回 1）；BSS／lib-name／入口前缀仍 host-cc。**Class DA** 把 `labi_rt_arena_buf_slice_marker` 收进 `.x`（仍返回 1）；128MiB／2MiB BSS 仍 host-cc。**Class CZ** 把 `backend_arch_emit_dispatch_slice_marker` 收进 `.x` 并删除种子，该对象不再 host-cc。**Class CT** 的 47 个分派壳仍在 `.x`。**Class CS** 整文件删掉 `lsp_diag_pipeline_sizes` 产品种子，三枚 sizeof 权威在 `.x`；非产品 weak 种子仍 host-cc。**Class CR** 删掉 `x_frontend_link_alias` 18 个别名的 C 体，权威在 `.x`；w863 又收进 `pipeline_type_kind_ord_at` 的带签名转发；w864 又收进 `glue_asm_build_func_export_sym_c` 的带签名转发；w865 又收进 `glue_asm_build_import_binding_call_sym` 的带签名转发；w866 又收进 `glue_try_std_heap_redirect_sym_local` 的带签名转发；w867 又收进 `glue_codegen_import_path_to_c_prefix_into` 的带签名转发；w868 又收进 `pipeline_expr_field_access_name_len` 的带签名转发，符号仍弱；w869 又收进 `pipeline_expr_field_access_base_ref` 的带签名转发，符号仍弱；w870 又收进 `pipeline_expr_binop_left_ref_at` 的带签名转发，符号仍弱；w871 又收进 `pipeline_expr_binop_right_ref_at` 的带签名转发，符号仍弱；w872 又收进 `pipeline_expr_field_access_name_into` 的带签名转发，无后缀实现返回 void，符号仍弱；w873 又收进 `pipeline_dep_ctx_ndep` 的带签名转发，这是 i32 单参，符号仍弱；w874 又收进 `pipeline_dep_ctx_module_at` 的带签名转发，这是 `*u8` 两参，符号仍弱；w875 又收进 `pipeline_asm_emit_dep_pipe_c` 的带签名转发，这是零参 `*u8`，符号仍弱；w876 又收进 `pipeline_module_import_path_byte_at` 的带签名转发，这是 `u8` 三参，符号仍弱；lexer 尾仍 host-cc。**Class CQ** 的恢复诊断仍 host-cc。**Class CP** 的 BSS／lib-name／入口前缀仍 host-cc。**Class CO** 的 128MiB／2MiB BSS 仍 host-cc。**Class CN** 字符串表仍 host-cc（marker 已见 Class DD）。asm BSS 八函数仍 host-cc。f64 尾仍 host-cc。活 FROM_X rest 的其余面仍 host-cc，剩下的 thin 面在 HARD BAN。HARD BAN 禁分类主刀。**三端 L2 硬闸仍启用**。下一刀＝另一份业务已在 `.x`、产品对象是独立 `.o`、C 体可以物理删除的 from_x。lexer 尾还没有 `.x` 体。不要优先 `.x` 整包重编 `runtime_driver_no_c.o`。禁 leftover-first；禁 `-E` 当修文件级 `let` 赋值或 `rt_stack` CG002；禁盲 FORCE mega；禁升钉；禁再搬已经 `#ifndef` 的冷孪生；禁剥 thin_glue。
2. 🟡 **7.2.1b 残**＋**8.3 冷孪生** — 产品 `.inc` 仍 host-cc；禁再深链分批 eq  
3. ⬜ **7.2.1／7.2.2** parser seed 物理删／去 pin  
4. 🟡 **阶段 10** 残（NT／MSVC／qemu／Win 实机）  
5. ⬜ **阶段 12–13** 最小 seed · 全路径零 cc · v2==v3 · 公告  

> 完成一步只改对应 `⬜`→`🟡`→`✅`。不要在本文写 tip／wave／日志路径。

- 2026-09-26 Darwin arm64 `runtime_panic.o` 的产品体在 `src/asm/runtime_panic_arm64.x`，冷路径先纯 asm。Linux aarch64 与纯 asm 失败时的备份仍是 `seeds/runtime_panic_arm64.from_x.c`。
- 2026-09-26 Darwin arm64 `runtime_link_abi_user_env.o` 的产品体在 `src/asm/runtime_link_abi_user_env.x`，两个 getenv 符号在编出后削弱。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_link_abi_user_env.from_x.c`。
- 2026-09-26 Darwin arm64 `runtime_random_fill.o` 的产品体在 `src/asm/runtime_random_fill.x`，按 256 字节调用 libSystem getentropy。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_random_fill.from_x.c`。
- 2026-09-26 Darwin arm64 `runtime_time_os.o` 的产品体在 `src/asm/runtime_time_os_darwin.x`，时钟、睡眠、RFC3339 和本地偏移走 libSystem。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_time_os.from_x.c`。共享薄封装 `runtime_time_os.x` 仍只转调 C `_impl`。
- 2026-09-26 Darwin arm64 `runtime_kv_mmap_glue.o` 的产品体在 `src/asm/runtime_kv_mmap_glue_darwin.x`，创建、加长、映射和同步走 libSystem。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_kv_mmap_glue.from_x.c`。共享锚点 `runtime_kv_mmap_glue.x` 仍无业务。
- 2026-09-26 Darwin arm64 `runtime_string_fast` 的产品体在 `src/asm/runtime_string_fast.x`，`xlang_compile_std_string_o.sh` 冷路径先纯 asm。Linux、Windows 与纯 asm 失败时的备份仍是 `seeds/runtime_string_fast.from_x.c`。`std/string/mod.x` 仍是另一份单元。
- 2026-09-26 Darwin arm64 `std/path/path.o` 的产品体在 `src/asm/runtime_path_fast.x`，冷路径先纯 asm。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_path_fast.from_x.c`。
- 2026-09-26 Darwin arm64 `runtime_sync_os.o` 的产品体在 `src/asm/runtime_sync_os_darwin.x`，互斥锁、读写锁和条件变量走 libSystem pthread。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_sync_os.from_x.c`。共享薄封装 `runtime_sync_os.x` 仍只转调 C `_impl`。
- 2026-09-26 Darwin arm64 `runtime_dynlib_os.o` 的产品体是 `src/asm/runtime_dynlib_os_darwin_text.x` 与 `src/asm/runtime_dynlib_os_darwin.x`，纯 asm 后 ld -r 合成。循环和 dlopen 不能放进同一份翻译单元，现行编译器会退出 139。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_dynlib_os.from_x.c`。共享薄封装 `runtime_dynlib_os.x` 仍只转调 C `_impl`。
- 2026-09-26 Darwin arm64 `runtime_net_workers.o` 的产品体是 `src/asm/runtime_net_workers_darwin.x`。接受循环在 .x 里，入口用 dlsym 取地址，因为函数名当指针时现行编译器退出 139。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_workers.from_x.c`。共享薄封装 `runtime_net_workers.x` 仍只转调 C `_impl`。
- 2026-09-26 Darwin arm64 `runtime_process_argv.o` 的产品体是 `src/asm/runtime_process_argv_darwin.x`。文件级存储在现行编译器上写不出 Mach-O，getter 在全局仍空时直接读 `_NSGetArgc` 与 `_NSGetArgv`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_process_argv.from_x.c`。共享薄封装 `runtime_process_argv.x` 仍只转调 C `_impl`。
- 2026-09-27 Darwin arm64 `runtime_queue_contention.o` 的产品体是 `src/asm/runtime_queue_contention.x` 与 `src/asm/runtime_queue_contention_darwin.x`，纯 asm 后 ld -r 合成。互斥锁和两个工人走 libSystem pthread，入口用 dlsym。指针字段下标存储改走 `queue_smoke_store_i32`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_queue_contention.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_env_os.o` 的产品体是 `src/asm/runtime_env_os.x` 与 `src/asm/runtime_env_os_darwin.x`，纯 asm 后 ld -r 合成。读取走 `link_abi_getenv`。setenv 改 Darwin 环境块，不调用 libc setenv。文件级槽用 memcpy 写入。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_env_os.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_log_os.o` 的产品体是 `src/asm/runtime_log_os.x` 与 `src/asm/runtime_log_os_darwin.x`，纯 asm 后 ld -r 合成。文件级槽用 memcpy 写入。打开文件走 `___open`，标志与 `xlang_io_cap.h` 的 Darwin 值一致。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_log_os.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_compress_zlib_glue.o` 的产品体是 `src/asm/runtime_compress_zlib_glue.x` 与 `src/asm/runtime_compress_zlib_glue_darwin.x`，纯 asm 后 ld -r 合成。桥把 `ZLIB_VERSION` `1.2.12` 和 `sizeof(z_stream)` 112 传给 `deflateInit2_` / `inflateInit2_`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_compress_zlib_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_crypto_inc_glue.o` 的产品体是 `src/asm/runtime_crypto_inc_glue.x` 与 `src/asm/runtime_crypto_inc_glue_darwin.x`，纯 asm 后 ld -r 合成。S-box 与 K 表是十六进制文本。调度和 HMAC 缓冲在堆上。SHA-512 仍调用 `ed25519_ref10_sha512`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_crypto_inc_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_process_os_glue.o` 的产品体是 `src/asm/runtime_process_os_glue.x` 与 `src/asm/runtime_process_os_darwin.x`，纯 asm 后 ld -r 合成。进程调用走 libSystem。setenv 与 unsetenv 调用 `env_setenv_c` / `env_unsetenv_c`。getenv 调用 `link_abi_getenv`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_process_os_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_sync_lock_diag_tls.o` 的产品体是 `src/asm/runtime_sync_lock_diag_tls.x` 与 `src/asm/runtime_sync_lock_diag_tls_darwin.x`，纯 asm 后 ld -r 合成。持有栈是 pthread_key 上的堆缓冲，元数据表也在堆上。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_sync_lock_diag_tls.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_tls_mbedtls_bio.o` 的产品体是 `src/asm/runtime_tls_mbedtls_bio.x` 与 `src/asm/runtime_tls_mbedtls_bio_darwin.x`，纯 asm 后 ld -r 合成。send 与 recv 走 libSystem。bind 用 dlsym 取回调再交给 `mbedtls_ssl_set_bio`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_tls_mbedtls_bio.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_net_udp_batch.o` 的产品体是 `src/asm/runtime_net_udp_batch.x` 与 `src/asm/runtime_net_udp_batch_darwin.x`，纯 asm 后 ld -r 合成。sendto、recvfrom 与 poll 走 libSystem，与 Darwin Cap 的循环同结果。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_udp_batch.from_x.c`。
- 2026-09-27 Darwin arm64 `std/net/net_addr_fast.o` 的产品体是 `src/asm/runtime_net_addr_fast.x` 与 `src/asm/runtime_net_addr_fast_darwin.x`，纯 asm 后 ld -r 合成，再并进 `std/net/net.o`。getsockname 与 getpeername 走 libSystem。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_addr_fast.from_x.c`。
- 2026-09-27 Darwin arm64 `std/net/net_sock_fast.o` 的产品体是 `src/asm/runtime_net_sock_fast.x` 与 `src/asm/runtime_net_sock_fast_darwin.x`，纯 asm 后 ld -r 合成，再并进 `std/net/net.o`。socket、bind、listen、accept、sendto、recvfrom、poll、close 走 libSystem。非阻塞走 `___fcntl`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_sock_fast.from_x.c`。
- 2026-09-27 Darwin arm64 `std/net/net_ipv6_fast.o` 的产品体是 `src/asm/runtime_net_ipv6_fast.x` 与 `src/asm/runtime_net_ipv6_fast_darwin.x`，纯 asm 后 ld -r 合成，再并进 `std/net/net.o`。socket、bind、listen、connect、poll、close 与 setsockopt 走 libSystem。非阻塞走 `___fcntl`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_ipv6_fast.from_x.c`。
- 2026-09-27 Darwin arm64 `std/net/net_io_batch_fast.o` 的产品体是 `src/asm/runtime_net_io_batch_fast.x` 与 `src/asm/runtime_net_io_batch_fast_darwin.x`，纯 asm 后 ld -r 合成，再并进 `std/net/net.o`。Darwin 上两个 UDP 桥返回 -1。三个 `io_*` 默认实现保持弱符号。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_net_io_batch_fast.from_x.c`。
- 2026-09-27 Darwin arm64 `std/runtime/runtime.o` 的产品体是 `src/asm/runtime_std_runtime_fast.x`，纯 asm。六个包装转发到 `xlang_panic_` 与 `xlang_crash_evidence_collect_c`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_std_runtime_fast.from_x.c`。
- 2026-09-27 Darwin arm64 `core/slice/slice.o` 的产品体是 `src/asm/runtime_slice_glue.x`，纯 asm。返回值是 16 字节的 data 与 length。起点越过末尾时保留原指针且长度为 0。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_slice_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_sqlite_glue_stub.o` 的产品体是 `src/asm/runtime_sqlite_glue_stub_darwin.x`，纯 asm。不调用 sqlite3。`xlang_db_use_sqlite3_c` 返回 0，打开与执行返回 -9。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_sqlite_glue.from_x.c` 的 `#else` 分支。
- 2026-09-27 Darwin arm64 `runtime_sqlite_glue.o` 的产品体是 `src/asm/runtime_sqlite_glue_darwin.x`，纯 asm，转发到 libsqlite3。`SQLITE_TRANSIENT` 以指针值 -1 传入。行计数回调经 dlsym 取 `xlang_sqlite3_count_cb`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_sqlite_glue.from_x.c` 的 `XLANG_DB_USE_SQLITE3` 分支。
- 2026-09-27 Darwin arm64 `runtime_atomic_glue.o` 的产品体是 `src/asm/runtime_atomic_glue_darwin.x`，纯 asm。调用 libSystem 的 `___atomic_load_4` 一族（2、4、8 字节）。比较交换 weak 为 0，内存序为 5。栅栏是 `OSMemoryBarrier`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_atomic_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_dir_cap.o` 的产品体是 `src/asm/runtime_dir_cap_darwin.x`，纯 asm。调用 libSystem 的 `___open` 与 `___getdirentries64`。`O_DIRECTORY` 为 1048576。流 1096 字节，`d_name` 在偏移 21。补缓冲与解析分函数。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_dir_cap.from_x.c`。
- 2026-09-27 Darwin arm64 `runtime_process_import_alias.o` 的产品体是 `src/asm/runtime_process_import_alias_darwin.x`，纯 asm。`std_process_*` 转发到已有的 `process_*_c`。退出调用 libSystem `___exit`，不跑 atexit。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_process_import_alias.from_x.c`。
- 2026-09-27 Darwin arm64 `std/debug/debug.o` 的产品体是 `src/asm/std_debug_formal_darwin.x`，纯 asm。stderr 调用 libSystem `write`。换行是字节 10。`assert` 假值返回 -1。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `std/debug/formal_surface.c`。
- 2026-09-27 Darwin arm64 `std/async/async.o` 的产品体是 `src/asm/std_async_formal_darwin.x`，纯 asm。`placeholder` 返回 0。drain、reset、net/fs smoke 转发到调度 glue。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `std/async/formal_surface.c`。
- 2026-09-27 Darwin arm64 `std/io/io.o` 的产品体是 `src/asm/std_io_formal_darwin.x`，纯 asm。上下文句柄是一个 i64。取消 -1，过期 -2，其余按毫秒转发到 `std_io_read` 和 `std_io_write`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `std/io/formal_surface.c`。
- 2026-09-27 Darwin arm64 `std/io/driver.o` 的产品体是 `src/asm/std_io_driver_formal_darwin.x`，纯 asm。24 字节 Buffer 以指针传入，每个入口返回 0。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `std/io/driver_formal_surface.c`。
- 2026-09-27 Darwin arm64 `std/compress/compress.o` 的产品体是 `src/asm/std_compress_formal_darwin.x`，纯 asm。门面转发到 gzip、brotli、zstd 子模块。流记录 24 字节。brotli-lib 长外部名由 llvm-objcopy 改回。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `std/compress/formal_surface.c`。
- 2026-09-27 Darwin arm64 `src/lexer/lexer.o` 的产品体是 `src/asm/runtime_lexer_glue_darwin.x`，纯 asm。块 536 字节，line 与 col 从 1 开始，end 为源加 strlen。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/runtime_lexer_glue.from_x.c`。
- 2026-09-27 Darwin arm64 `build_tool_libc_bridge.o` 的产品体是 `src/asm/build_tool_libc_bridge_darwin.x`，纯 asm。空命令返回 -1，构建脚本名固定。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/build_tool_libc_bridge.from_x.c`。
- 2026-09-27 Darwin arm64 `asm_xlang_lsp_diag_stub.o` 的产品体是 `src/asm/asm_xlang_lsp_diag_stub_darwin.x`，纯 asm。空数组是两个方括号，失效转发到已有诊断对象。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/asm_xlang_lsp_diag_stub.from_x.c`。
- 2026-09-27 Darwin arm64 `src/lsp/lsp_diag_pipeline_sizes.o` 的产品体是 `src/asm/lsp_diag_pipeline_sizes_weak_darwin.x`，纯 asm。arena 16，module 40，依赖上下文 1560，分配返回 0。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/lsp_diag_pipeline_sizes_weak.from_x.c`。
- 2026-09-27 Darwin arm64 `ast_asm_bare_link_alias.o` 的产品体是已有的 `ast_asm_bare_link_alias.x`，纯 asm。十七个裸名只转发到 `ast_ast_*`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/ast_asm_bare_link_alias.from_x.c`。
- 2026-09-27 Darwin arm64 `backend_asm_bare_link_alias.o` 的产品体是已有的 `backend_asm_bare_link_alias.x`，纯 asm。四个 `backend_*` 只转发到裸名。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/backend_asm_bare_link_alias.from_x.c`。
- 2026-09-27 Darwin arm64 `backend_asm_strict_fallback_alias.o` 的产品体是已有的 `backend_asm_strict_fallback_alias.x`，纯 asm。两个 `backend_*` 只转发到 `pipeline_backend_*_c`。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/backend_asm_strict_fallback_alias.from_x.c`。
- 2026-09-27 Darwin arm64 `src/asm/parser_asm_parse_expr_link.o` 的产品体是 `src/asm/parser_asm_parse_expr_link_darwin.x`，纯 asm。调试门闩关闭，parse_expr_into 转发到 `parser_parse_expr_into`，弱 parse 桩不导出。Linux、Windows 与纯 asm 失败且对象缺失时的备份仍是 `seeds/parser_asm_parse_expr_link.from_x.c`。
- 2026-09-27 Darwin arm64 `driver_compile_asm_link_alias.o` 的产品体是已有的 `src/driver_compile_asm_link_alias.x`，纯 asm。四个 `driver_*` 只转发到裸名。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `src/asm/pipeline_run_x_link_alias.o` 的产品体是已有的 `src/pipeline_run_x_link_alias.x`，纯 asm。四个 `run_x_pipeline_*` 只转发到 `pipeline_run_x_pipeline_*`。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_wpo_strict_link_alias.o` 的产品体是已有的 `src/pipeline_wpo_strict_link_alias.x`，纯 asm。入口转发到 `run_x_pipeline_impl`，typecheck emit 转发到 `run_x_pipeline_typecheck_entry_emit_c`。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_wpo_typecheck_emit_bridge.o` 的产品体是已有的 `src/pipeline_wpo_typecheck_emit_bridge.x`，纯 asm。typecheck emit 转发到 `run_x_pipeline_typecheck_entry_emit_c`，路径解析转发到 `pipeline_resolve_path_try_one_lib_root`。对象不定义 `pipeline_run_x_pipeline_impl`。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_asm_run_all_alias.o` 的产品体是已有的 `src/pipeline_asm_run_all_alias.x`，纯 asm。解析或类型检查失败立刻返回，跳过代码生成时返回 0。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_asm_typecheck_alias.o` 的产品体是已有的 `src/pipeline_asm_typecheck_alias.x`，纯 asm。大入口或 asm 构建跳过返回 0，没有主函数走库路径，force_c 走 for_ctx，失败先记诊断。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_glue_link.o` 的产品体是已有的 `src/pipeline_glue_link.x`，纯 asm。`pipeline_run_x_pipeline` 只转发到 `pipeline_run_x_pipeline_impl`。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `typeck_lsp_io_stub.o` 的产品体是已有的 `src/typeck_lsp_io_stub.x`，纯 asm。读消息返回 -1，分配返回空，空指针判断空为 1。Linux 构建仍走 `-x -E` 再交给 host cc。strict 链仍编 `seeds/typeck_lsp_io_stub.from_x.c`。纯 asm 失败且对象缺失时退回 `-x -E`。
- 2026-09-27 Darwin arm64 `build_tool_main.o` 的产品体是已有的 `src/build_tool_main.x`，纯 asm。`main` 把 argc 和 argv 原样转给 `entry`。Linux 与 Windows 仍走 `-x -E` 再交给 host cc。纯 asm 失败且对象缺失时走同一条备份。
- 2026-09-27 Darwin arm64 `pipeline_run_impl_alias.o` 的产品体是 `src/pipeline_run_impl_alias.x`，纯 asm。六个参数原样转发，8 字节解析结果 ok 为 7、main_idx 为 9，`parse_into_init` 交换两个指针。Linux 与 Windows 仍编 `seeds/pipeline_run_impl_alias.from_x.c`。纯 asm 失败且对象缺失时走同一份种子。
- 2026-09-27 Darwin arm64 `pipeline_run_bootstrap_trampoline.o` 的产品体是 `src/pipeline_run_bootstrap_trampoline.x`，纯 asm。`pipeline_run_x_pipeline_impl` 把六个参数原样转给 `pipeline_impl_run_all`。Linux 与 Windows 仍编 `seeds/pipeline_run_bootstrap_trampoline.from_x.c`。纯 asm 失败且对象缺失时走同一份种子。
- 2026-09-27 Darwin arm64 `pipeline_phase_parse_only_alias.o` 的产品体是 `src/pipeline_phase_parse_only_alias.x`，纯 asm。解析结果 ok 为 3 时返回 -6，加载返回 21。Linux 与 Windows 仍编 `seeds/pipeline_phase_parse_only_alias.from_x.c`。纯 asm 失败且对象缺失时走同一份种子。
- 2026-09-27 Darwin arm64 `cfg_eval_link_alias.o` 的产品体是 `src/lexer/cfg_eval_link_alias.x`，纯 asm。四个名字转发到 `lexer_cfg_*`，宿主字符串是 `macos` 和 `aarch64`。Linux 与 Windows 仍编 `seeds/cfg_eval_link_alias.from_x.c`。纯 asm 失败且对象缺失时走同一份种子。
- 2026-09-27 Darwin arm64 `runtime_asm_build.o` 的产品体是 `src/asm/runtime_asm_build.x` 与 `src/asm/runtime_asm_build_main.x` 的纯 asm 合并。含 `main` 的翻译单元只发出 `main`。`skip` 读回 5，`main` 读回 17。Linux 与 Windows 仍编 `seeds/runtime_asm_build.from_x.c`。纯 asm 失败且对象缺失时走同一份种子。
- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。f64／Cap 尾仍 host-cc。没有整份冷种子回退，也不再尝试 full `.x`。
- 2026-09-23 driver_diagnostic：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。asm BSS 家族仍 host-cc。没有整份冷种子回退。
- 2026-09-23 slot_bytes：Linux tip 坏帧的两枚符号由权威 `.x` thin 经 host cc 复现并跳进 tip ELF（`overlay_tip_slot_bytes_gcc.sh`，g05 仅对坏帧）。不再依赖本机 warm blob。残：tip asm 帧未治本，这两枚在 Linux tip 仍 host-cc。Win reloc BSS 新链已绿。
- 2026-09-23 pipeline_abi：纯 `#ifndef FROM_X` 冷孪生出 seeds（文件约 2.78MB→1.51MB）。产品 rest 预处理不变，仍 host-cc。
- 2026-09-23 ast_forwarders：POSIX 产品 rest 在 `XLANG_PABI_AST_FORWARDERS_ASM` 下不再编这 186 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 typeck_orch：POSIX 产品 rest 在 `XLANG_PABI_TYPECK_ORCH_ASM` 下不再编这 7 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 elf_codegen_forwarders：POSIX 产品 rest 在 `XLANG_PABI_ELF_CODEGEN_FORWARDERS_ASM` 下不再编这 19 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 x_frontend_link_alias：POSIX 产品在 `XLANG_XFLA_ASM` 下不再编这 18 个别名 C 体，改由纯 asm `.x` 提供（5 个保持 weak）。lexer 尾与带修饰别名仍 host-cc。Windows／冷种子仍编 C 体。
- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，见文首 Class CX。f64／Cap 尾仍 host-cc。
