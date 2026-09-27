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
- 2026-09-27 Darwin arm64 独立 `rt_stack.o` 的产品体是 `src/runtime/rt_stack.x`，纯 asm。空参数返回空，源 11 长度 4 写回 21，大栈读回 7，留下 -99 时读回 3。切片标记留在大包 C。Linux 与 Windows 仍编 `seeds/rt_stack.from_x.c`。纯 asm 对象若带上切片标记则不收口。
- 2026-09-27 lib root 三函数的产品体是 `src/runtime/rt_lib_root.x`，纯 asm。文件里只留一个 `while`。空指针和空串不可用，`XLANG_LIB` 为 `lib` 时读回 `lib`，两行时第一行 `abc`、第二行 `.`。切片标记留在大包 C。Linux 与 Windows 走同一份 `.x`。纯 asm 失败才退回 `-E` 或整份种子。
- 2026-09-27 追加 let 一个符号改由 `.x` 纯 asm 编出。八次抽样里六次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。字面量初值八次都过，仍走原来的八次尝试。函数块其余十六份仍走原来的八次尝试。库形状包装有九个整数参数，栈上参数压在帧边上，仍走原来的八次尝试。结构名存在、结构名下标、占位结构下标、packed 修饰、soa 修饰、具名类型、结构体布局和追加常量仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 追加常量一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。字面量初值八次都过，仍走原来的八次尝试。函数块其余十七份仍走原来的八次尝试。库形状包装有九个整数参数，栈上参数压在帧边上，仍走原来的八次尝试。结构名存在、结构名下标、占位结构下标、packed 修饰、soa 修饰、具名类型和结构体布局仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 结构体布局一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余十八份仍走原来的八次尝试。库形状包装有九个整数参数，栈上参数压在帧边上，仍走原来的八次尝试。结构名存在、结构名下标、占位结构下标、packed 修饰、soa 修饰和具名类型仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 具名类型一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余十九份仍走原来的八次尝试。结构名存在、结构名下标、占位结构下标、packed 修饰和 soa 修饰仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 soa 修饰一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。soa 记号写出 1。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余二十份仍走原来的八次尝试。结构名存在、结构名下标、占位结构下标和 packed 修饰仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 packed 修饰一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。打包记号写出 1。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余二十一份仍走原来的八次尝试。结构名存在、结构名下标和占位结构下标仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 占位结构下标一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余二十二份仍走原来的八次尝试。结构名存在和结构名下标仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 结构名下标一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余二十三份仍走原来的八次尝试。结构名存在仍走十二次重试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 结构名存在一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。函数块其余二十四份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装、匹配变量包装和匹配字段包装仍走十二次重试。
- 2026-09-27 匹配字段包装一个符号改由 `.x` 纯 asm 编出。八次抽样里七次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十四份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签、块表达式包装和匹配变量包装仍走十二次重试。
- 2026-09-27 匹配变量包装一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十五份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检、枚举标签和块表达式包装仍走十二次重试。
- 2026-09-27 块表达式包装一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十六份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号、关键字预检和枚举标签仍走十二次重试。
- 2026-09-27 枚举标签一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十七份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写、关键字记号和关键字预检仍走十二次重试。
- 2026-09-27 关键字预检一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。窗口不够返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十八份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度、关键字拼写和关键字记号仍走十二次重试。
- 2026-09-27 关键字记号一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。未知序号返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余十九份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后、关键字长度和关键字拼写仍走十二次重试。
- 2026-09-27 关键字拼写一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。拼写不符返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号、if 语句之后和关键字长度仍走十二次重试。
- 2026-09-27 关键字长度一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。未知序号返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十一份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过、条件左花括号和 if 语句之后仍走十二次重试。
- 2026-09-27 if 语句之后一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 5。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十二份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字、注释跳过和条件左花括号仍走十二次重试。
- 2026-09-27 条件左花括号一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。没有花括号时返回 3。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十三份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字、else 关键字和注释跳过仍走十二次重试。
- 2026-09-27 注释跳过一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。普通字节返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十四份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置、if 关键字和 else 关键字仍走十二次重试。
- 2026-09-27 else 关键字一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十五份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过、关键字位置和 if 关键字仍走十二次重试。
- 2026-09-27 if 关键字一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十六份仍走原来的八次尝试。标识续字节、字节相等、花括号跳过和关键字位置仍走十二次重试。
- 2026-09-27 关键字位置一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十七份仍走原来的八次尝试。标识续字节、字节相等和花括号跳过仍走十二次重试。
- 2026-09-27 花括号跳过一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 3。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十八份仍走原来的八次尝试。标识续字节和字节相等仍走十二次重试。
- 2026-09-27 字节相等一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余二十九份仍走原来的八次尝试。标识续字节仍走十二次重试。
- 2026-09-27 标识续字节一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。小写 a 写出 1。盘上 `parser_asm_thin_glue.o` 没有重编。控制流其余三十份仍走原来的八次尝试。类型引用那十二份仍走十二次重试。
- 2026-09-27 被指向类型一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余十八份也仍走原来的八次尝试。
- 2026-09-27 向量拼写一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余十九份也仍走原来的八次尝试。
- 2026-09-27 泛型参数一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十份也仍走原来的八次尝试。
- 2026-09-27 后缀数组一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 7。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十一份也仍走原来的八次尝试。
- 2026-09-27 后缀切片一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十二份也仍走原来的八次尝试。
- 2026-09-27 已登记特征一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 7。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十三份也仍走原来的八次尝试。
- 2026-09-27 动态类型分配一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 7。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十四份也仍走原来的八次尝试。
- 2026-09-27 限定名一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十五份也仍走原来的八次尝试。
- 2026-09-27 尖括号收口一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。类型实例拼接仍走原来的八次尝试。这一车道其余二十六份也仍走原来的八次尝试。
- 2026-09-27 类型后缀一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。这一车道其余二十八份仍走原来的八次尝试。
- 2026-09-27 向量类型打包一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。这一车道其余二十九份仍走原来的八次尝试。
- 2026-09-27 类型引用跨度一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。这一车道其余三十份仍走原来的八次尝试。
- 2026-09-27 标识符跨度一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余二十七份仍走原来的八次尝试。
- 2026-09-27 空花括号一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。其余二十八份仍走原来的八次尝试。
- 2026-09-27 操作数解析一个符号改由 `.x` 纯 asm 编出。八次抽样里六次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余二十九份仍走原来的八次尝试。
- 2026-09-27 寄存器打包一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十份仍走原来的八次尝试。
- 2026-09-27 模板解码一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十一份仍走原来的八次尝试。
- 2026-09-27 十六进制半字节一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。字母 a 写成 10。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十二份仍走原来的八次尝试。
- 2026-09-27 类型名结构体收尾一个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十三份仍走原来的八次尝试。
- 2026-09-27 结构体字段一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十四份仍走原来的八次尝试。
- 2026-09-27 字符串解码一个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空指针返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十五份仍走原来的八次尝试。
- 2026-09-27 主表达式选项位一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空数据返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。其余三十六份仍走原来的八次尝试。
- 2026-09-27 IPv6 面十六个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空地址不写。盘上 `std/net/net_ipv6_fast.o` 没有重编。薄封装仍走原来的八次尝试。
- 2026-09-27 套接字面二十四个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。负长度接收返回 -1。盘上 `std/net/net_sock_fast.o` 没有重编。薄封装仍走原来的八次尝试。
- 2026-09-27 网络地址面十四个符号改由 `.x` 纯 asm 编出。两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空缓冲区不写。盘上 `std/net/net_addr_fast.o` 没有重编。薄封装仍走原来的八次尝试。
- 2026-09-27 路径复制面一个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。整份帧已经关着。符号保持强。空路径返回 0。盘上 `runtime_driver_no_c.o` 没有重编。打开调用那一半仍走原来的八次尝试。
- 2026-09-27 ELF 查找面一个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。没有标签时返回 -1。盘上 `runtime_driver_no_c.o` 没有重编。种类和注释那两份仍走原来的八次尝试。
- 2026-09-27 ELF 诊断面八个符号改由 `.x` 纯 asm 编出。四次会段错误，再试才发出对象。整份帧已经关着。符号保持强。偏移 4 处读出 2。盘上 `runtime_driver_no_c.o` 没有重编。查找、种类和注释那三份仍走原来的八次尝试。
- 2026-09-27 TLS 系统面六个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。整份帧已经关着。符号保持强。空 errno 返回 0。盘上 `runtime_tls_mbedtls_bio.o` 没有重编。共享包装那一半仍走原来的八次尝试。
- 2026-09-27 锁诊断系统面五十四个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。活垫把两处槽收进帧里。符号保持强。准备返回 0。盘上 `runtime_sync_lock_diag_tls.o` 没有重编。薄面仍走上一波的十二次重试。
- 2026-09-27 锁诊断薄面六个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。整份帧已经关着。符号保持强。锚点返回 0。盘上 `runtime_sync_lock_diag_tls.o` 没有重编。表和线程局部那一半仍走原来的八次尝试。
- 2026-09-27 进程系统面三十七个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。活垫把读字那一槽收进帧里。符号保持强。偏移 4 处读出 2。盘上 `runtime_process_os_glue.o` 没有重编。共享包装那一半仍走原来的八次尝试。
- 2026-09-27 加密系统面三十五个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。活垫把四处槽收进帧里。符号保持强。高字节是 1。盘上 `runtime_crypto_inc_glue.o` 没有重编。共享包装那一半仍走原来的八次尝试。
- 2026-09-27 日志系统面三十四个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。活垫把两处槽收进帧里。符号保持强。偏移 4 处读出 2。盘上 `runtime_log_os.o` 没有重编。薄面仍走上一波的十二次重试。
- 2026-09-27 日志薄面十八个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。整份帧已经关着。符号保持强。锚点返回 0。盘上 `runtime_log_os.o` 没有重编。系统调用那一半仍走原来的八次尝试。
- 2026-09-27 环境系统面二十八个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。活垫把长度槽收进帧里。符号保持强。空名字返回 0。盘上 `runtime_env_os.o` 没有重编。薄面仍走上一波的十二次重试。
- 2026-09-27 环境薄面十一个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。锚点返回 0。盘上 `runtime_env_os.o` 没有重编。系统调用那一半仍走原来的八次尝试。
- 2026-09-27 动态库文本面六个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。符号保持强。锚点返回 0。盘上 `runtime_dynlib_os.o` 没有重编。装入一半仍走原来的八次尝试。
- 2026-09-27 栈逃逸两个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。符号保持强。空线程入口返回空指针。盘上 `rt_stack.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 诊断错误码十三个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。__error 改成 ___error。当前错误码返回 7。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 解析阶段两个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。解析成功返回 -2。盘上 `pipeline_phase_parse_only_alias.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 压缩正式面四十一个符号改由 `.x` 纯 asm 编出。前三次会段错误，第四次才发出对象。brotli 长名字改回子模块名。符号保持强。gzip 格式返回 0。盘上 `std/compress/compress.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 词法胶合六个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。符号保持强。空指针释放不做事。盘上 `src/lexer/lexer.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 构建桥十一个符号改由 `.x` 纯 asm 编出。前六次会段错误，第七次才发出对象。符号保持强。空命令返回 -1。盘上 `build_tool_libc_bridge.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 诊断桩五个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。空缓冲返回 -1。盘上 `asm_xlang_lsp_diag_stub.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 诊断尺寸六个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。两个占位保持弱。竞技场尺寸返回 16。盘上 `lsp_diag_pipeline_sizes.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 表达式链接十个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。调试开关返回 0。盘上 `parser_asm_parse_expr_link.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 网络工作线程十个符号改由 `.x` 纯 asm 编出。前四次会段错误，第五次才发出对象。装入槽用活填充拉回帧内。亲和性保持弱。空参数循环返回 0。盘上 `runtime_net_workers.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 切片胶合八个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。六个返回槽用活填充拉回帧内。符号保持强。起点越界长度返回 0。盘上 `core/slice/slice.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 驱动正式面九个符号改由 `.x` 纯 asm 编出。前两次会段错误，第三次才发出对象。符号保持强。空缓冲登记返回 0。盘上 `std/io/driver.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 输入输出正式面十五个符号改由 `.x` 纯 asm 编出。八次抽样里七次会段错误，再试才发出对象。符号保持强。零纳秒超时返回 0。盘上 `std/io/io.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 调试正式面六个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。断言真返回 0。盘上 `std/debug/debug.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 目录容量十七个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。空名字打开返回 0。盘上 `runtime_dir_cap.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 原子胶合三十一个符号改由 `.x` 纯 asm 编出。前三次会段错误，第四次才发出对象。十四处各留 64 字节活缓冲。符号保持强。载入得到 7。盘上 `runtime_atomic_glue.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 数据库胶合二十三个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。符号保持强。使用开关返回 1。盘上 `runtime_sqlite_glue.o` 没有重编。纯 asm 失败才退回原来的八次尝试。
- 2026-09-27 进程参数七个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。参数个数和参数取值保持弱。负下标返回 0。盘上 `runtime_process_argv.o` 没有重编。纯 asm 失败才退回原来的三次尝试。
- 2026-09-27 路径函数二十个符号改由 `.x` 纯 asm 编出。前三次会段错误，第四次才发出对象。目录名留了 64 字节活缓冲。符号保持强。分隔符是 47。盘上 `std/path/path.o` 没有重编。纯 asm 失败才退回原来的三次尝试。
- 2026-09-27 字符串快路径九个符号改由 `.x` 纯 asm 编出。第一次会段错误，第二次才发出对象。符号保持强。针长 0 返回 0。盘上 `std/string/string.o` 没有重编。纯 asm 失败才退回原来的三次尝试。
- 2026-09-27 时间胶合二十一个符号改由 `.x` 纯 asm 编出。前两次会段错误，第三次才发出对象。读时钟、睡眠和年月日各留 64 字节活缓冲。符号保持强。睡眠 0 立即返回。盘上 `runtime_time_os.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 键值映射七个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。文件长度和映射各留 64 字节活缓冲。符号保持强。长度 42 写入 42。盘上 `runtime_kv_mmap_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 随机填充三个符号改由 `.x` 纯 asm 编出。八次抽样里六次会段错误，再试才发出对象。符号保持强。长度 0 返回 0。盘上 `runtime_random_fill.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 测试函数调用两个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。符号保持强。空函数地址返回 -1。盘上 `runtime_test_fn_invoke.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 线程胶合二十五个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。符号保持强。锚点返回 0。空名字返回 -1。盘上 `runtime_thread_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 调用薄层四十四个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。清栈字节留 64 字节活缓冲。符号保持强。目标 0 的寄存器上限是 6。盘上 `backend_call_dispatch.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 编码薄层七十七个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。插入指令留 64 字节活缓冲。符号保持强。车道 0 和 1 写成 1846027265。盘上 `simd_enc.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 循环薄层二十二个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。符号保持强。槽偏移 4 写成 -4。盘上 `simd_loop.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 内联分发薄层四十九个符号改由 `.x` 纯 asm 编出。八次抽样里三次会段错误，再试才发出对象。符号保持强。长度 9 对齐到 16。20 加 22 写成 42。盘上 `backend_try_inline_dispatch.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 诊断薄层八十八个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。消息缓冲改到堆上。符号保持强。数字 42 写成 4 和 2。盘上 `runtime_driver_diagnostic.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 格式检查六十六个符号改由 `.x` 纯 asm 编出。前两次会段错误，第三次才发出对象。汇总行缓冲改到堆上。全体符号改为弱。数字 42 写成 4 和 2。盘上 `driver/fmt_check_cmd_driver.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 LSP 胶水五十六个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。八字节指针改成两次读取加左移。全体符号改为弱。锚点返回 0。盘上 `lsp/lsp_diag.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 异步池十三个符号改由 `.x` 纯 asm 编出。八次抽样里两次会段错误，再试才发出对象。名字缓冲改到堆上。锚点返回 0。盘上 `async/async_asm_pool.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 异步活性五十六个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。八字节指针拆成两次四字节读取。锚点返回 0。盘上 `async/async_liveness.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 异步续体四十七个符号改由 `.x` 纯 asm 编出。前一次会段错误，第二次才发出对象。八字节指针拆成两次四字节读取。锚点返回 0。盘上 `async/async_cps_codegen.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 解析后编译六十九个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。路径槽是 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 架构发射分发四十九个符号改由 `.x` 纯 asm 编出。八次抽样里五次会段错误，再试才发出对象。锚点返回 0。盘上 `asm/backend_arch_emit_dispatch.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 种子链接兼容十九个符号改由 `.x` 纯 asm 编出。前两次会段错误，第三次才发出对象。诊断桩返回 -1。七个桥保持弱。盘上 `seed_link_compat.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 兼容桩四个符号改由 `.x` 纯 asm 编出。前三次会段错误，第四次才发出对象。小端追加的帧边存储垫进帧内。锚点返回 0。盘上 `asm/asm_backend_compat_stubs.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 发射状态十四个符号改由 `.x` 纯 asm 编出。八次抽样里第八次会段错误，前七次发出对象。最大库根返回 16。盘上 `runtime/rt_emit_state.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 严格薄胶十一个符号改由 `.x` 纯 asm 编出。八次抽样里四次会段错误，再试才发出对象。空指针读返回 0。盘上 `runtime_driver_strict_glue_stubs.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 参数记号十五个符号改由 `.x` 纯 asm 编出。前三次会段错误，第四次才发出对象。长度 0 的减号 o 返回 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 单文件格式化三个符号改由 `.x` 纯 asm 编出。八次里四次会段错误，再试才发出对象。空路径复制返回 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 编译参数三十二个符号改由 `.x` 纯 asm 编出。抽样前两次会段错误，第三次才发出对象。空比较返回 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 解析诊断两个符号改由 `.x` 纯 asm 编出。前七次会段错误，第八次才发出对象。标记返回 1。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 库根十个符号改由 `.x` 纯 asm 编出。六次里三次会段错误，再试才发出对象。空指针可用性返回 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 发射标志六个符号改由 `.x` 纯 asm 编出。抽样第一次会段错误，再试才发出对象。空指针的减号 E 返回 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 x 发射五十七个符号改由 `.x` 纯 asm 编出。前两次会段错误，再试才发出对象。路径槽是 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 汇编后端七十五个符号改由 `.x` 纯 asm 编出。前两次会段错误，第三次才发出对象。路径槽是 0。盘上 `runtime_driver_no_c.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 let 别名四个符号改由 `.x` 纯 asm 编出。八次里四次会段错误。方括号起点 11 时位置写成 11。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 if 跳过四个符号改由 `.x` 纯 asm 编出。有一轮连续四次会段错误。文件结束恢复位置 11。空名字登记返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 基础层两个符号改由 `.x` 纯 asm 编出。清零函数加了 192 字节垫块，帧是 1504。加垫前连续五次会段错误。位置 16909060 的第 0 字节是 4。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 二元运算四个符号改由 `.x` 纯 asm 编出。前几次会段错误，再试才发出对象。星号映射 6。种类 0 映射 -1。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 一元前缀三个符号改由 `.x` 纯 asm 编出。前几次会段错误，再试才发出对象。减号映射 22。种类 0 映射 -1。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 allow 填充三个符号改由 `.x` 纯 asm 编出。前几次会段错误，再试才发出对象。空词法返回 0。种类不是标识符时核心返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 函数体顶层十三个符号改由 `.x` 纯 asm 编出。第一次会段错误，再试才发出对象。标量 i32 返回 1，种类 0 返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 Class CB 回退的四份薄对象仍走已有的 `.x` 分段。顶层跳过六十三，词法跳过十九，函数块二十五，类型引用三十一。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的一次尝试。
- 2026-09-27 拉伸审计的产品体仍是 `src/asm/pthin_stretch_audit.x`。一份翻译单元纯 asm 退出 139，Darwin 按一千九百七十八个函数拆开再链。空词法的 if 头返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 顶层跳过的产品体仍是 `src/asm/pthin_skip_tl.x`。一份翻译单元纯 asm 退出 139，Darwin 按六十三个函数拆开再链。self 返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 主表达式的产品体仍是 `src/asm/pthin_expr_primary.x`。一份翻译单元纯 asm 退出 139，Darwin 按三十七个函数拆开再链。unsafx 返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 类型引用的产品体仍是 `src/asm/pthin_type_ref.x`。一份翻译单元纯 asm 退出 139，Darwin 按三十一个函数拆开再链。i32x4 返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 控制流的产品体仍是 `src/asm/pthin_ctrl.x`。一份翻译单元纯 asm 退出 139，Darwin 按三十一个函数拆开再链。ix 不相等返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 函数块的产品体仍是 `src/asm/pthin_fn_block.x`。一份翻译单元纯 asm 退出 139，Darwin 按二十五个函数拆开再链。名字 ac 存在返回 0。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 词法跳过的产品体仍是 `src/asm/pthin_lex_skip.x`。一份翻译单元纯 asm 退出 139，Darwin 按十九个函数拆开再链。一对尖括号步进 2 次。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 拉伸表的产品体仍是 `src/asm/pthin_stretch.x`。一份翻译单元纯 asm 退出 139，Darwin 按十五个函数拆开再链。种类 12 的长度是 8。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 辅助函数的产品体仍是 `src/asm/pthin_helpers.x`。一份翻译单元纯 asm 退出 139，Darwin 按十三个函数拆开再链。标识符段长度 4。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 import 收集的产品体仍是 `src/asm/pthin_imports.x`。一份翻译单元纯 asm 退出 139，Darwin 按七个函数拆开再链。成功收集路径长度 4。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 库函数扫描的产品体仍是 `src/asm/pthin_library.x`。一份翻译单元纯 asm 退出 139，Darwin 按五个函数拆开再链。spawn 名字长度 5。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 诊断后段的产品体仍是 `src/asm/pthin_diag_late.x`。一份翻译单元纯 asm 退出 139，Darwin 按四个函数拆开再链。空参数整数函数体返回 -1。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 as 后缀的产品体仍是 `src/asm/pthin_expr_as_suffix.x`。一份翻译单元纯 asm 退出 139，Darwin 按四个函数拆开再链。问号包装种类 58。as 包装种类 54。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 simd 的产品体仍是 `src/asm/pthin_simd.x`。一份翻译单元纯 asm 退出 139，Darwin 拆成五片再链，标识符辅助函数留在 pack 同一片。shuffle 读出 258。select 读出 3。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 三元表达式的产品体仍是 `src/asm/pthin_expr_ternary.x`。一份翻译单元纯 asm 退出 139，Darwin 按四个函数拆开再链。包装种类 27。问号加冒号包装引用是 11。盘上 `parser_asm_thin_glue.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 诊断薄层的产品体仍是 `src/diag_thin.x`。一份翻译单元纯 asm 退出 139，Darwin 拆成八份再链。行号 100 是 3 位。小端 `78 56 34 12` 读出 305419896。宿主实现留在 `seeds/diag.from_x.c`。盘上 `src/diag.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 整份 CPU 业务的产品体是 `src/driver/target_cpu_pure.x` 的纯 asm。`tcp_eq_at` 收字节指针。SSE2 读出 1。neon 读出 256。rvv 读出 65536。两边留空白的 neon 解析成 256。i32x4 是 4 路，i32x8 是 8 路，i32x16 是 16 路。宿主探测、打印和切片标记留在 `seeds/target_cpu_pure.from_x.c`。盘上 `target_cpu.o` 没有重编。纯 asm 失败才退回五个助手那条路径。
- 2026-09-27 CPU 特性五个助手的产品体是 `src/driver/target_cpu_flags.x` 的纯 asm。特性字经指针槽写入。写入 17 读回 17。`Hello` 对上 `hello`。宿主探测留在 `seeds/target_cpu_pure.from_x.c`。盘上 `target_cpu.o` 没有重编。纯 asm 失败才退回原来的优先路径。
- 2026-09-27 ELF 诊断的产品体是 `src/runtime/rt_pipeline_elf_diag.x`、`rt_pipeline_elf_diag_find.x`、`rt_pipeline_elf_diag_kind.x`、`rt_pipeline_elf_diag_note.x` 四份纯 asm 的合并。字节 `78 56 34 12` 读回 305419896。补丁名 `hi`、标签偏移 99 时第三条笔记命中。切片标记留在大包 C。纯 asm 失败才退回整份 `seeds/rt_pipeline_elf_diag.from_x.c`。
- 2026-09-27 诊断 errno 的产品体是 `src/runtime/rt_diag_errno.x` 的纯 asm。文件级诊断码经指针槽写入。空种类读回 BLD001。io error 读回 IO001。打开消息是 open failed: File exists。切片标记留在大包 C。裸 `__error` 改成 libc 的 `___error`。纯 asm 失败才退回整份 `seeds/rt_diag_errno.from_x.c`。
- 2026-09-27 路径打开的产品体是 `src/runtime/rt_fs_open.x` 与 `src/runtime/rt_fs_open_call.x` 的纯 asm 合并。拷贝循环和 512 字节栈缓冲分开。字节 `ab` 读回 `ab`。只读打开读回 7。写入打开标志 1537、模式 420、读回 9。切片标记留在大包 C。Linux 创建和截断标志是 64 和 512。纯 asm 失败才退回整份 `seeds/rt_fs_open.from_x.c`。
- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。f64／Cap 尾仍 host-cc。没有整份冷种子回退，也不再尝试 full `.x`。
- 2026-09-23 driver_diagnostic：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。asm BSS 家族仍 host-cc。没有整份冷种子回退。
- 2026-09-23 slot_bytes：Linux tip 坏帧的两枚符号由权威 `.x` thin 经 host cc 复现并跳进 tip ELF（`overlay_tip_slot_bytes_gcc.sh`，g05 仅对坏帧）。不再依赖本机 warm blob。残：tip asm 帧未治本，这两枚在 Linux tip 仍 host-cc。Win reloc BSS 新链已绿。
- 2026-09-23 pipeline_abi：纯 `#ifndef FROM_X` 冷孪生出 seeds（文件约 2.78MB→1.51MB）。产品 rest 预处理不变，仍 host-cc。
- 2026-09-23 ast_forwarders：POSIX 产品 rest 在 `XLANG_PABI_AST_FORWARDERS_ASM` 下不再编这 186 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 typeck_orch：POSIX 产品 rest 在 `XLANG_PABI_TYPECK_ORCH_ASM` 下不再编这 7 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 elf_codegen_forwarders：POSIX 产品 rest 在 `XLANG_PABI_ELF_CODEGEN_FORWARDERS_ASM` 下不再编这 19 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 x_frontend_link_alias：POSIX 产品在 `XLANG_XFLA_ASM` 下不再编这 18 个别名 C 体，改由纯 asm `.x` 提供（5 个保持 weak）。lexer 尾与带修饰别名仍 host-cc。Windows／冷种子仍编 C 体。
- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，见文首 Class CX。f64／Cap 尾仍 host-cc。
