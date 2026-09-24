# C → .X 迁移追踪

> 只勾已完成的。新完成项加一行 ✅。波次流水写在 [`自举进度.md`](自举进度.md)。
> 钉盘 `ecdb5cc1e` 不升。host-cc 还没到 0。

### 已完成

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

- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。f64／Cap 尾仍 host-cc。没有整份冷种子回退，也不再尝试 full `.x`。
- 2026-09-23 driver_diagnostic：薄层公共函数的冷路径 C 体已删除，权威在 thin `.x`。asm BSS 家族仍 host-cc。没有整份冷种子回退。
- 2026-09-23 slot_bytes：Linux tip 坏帧的两枚符号由权威 `.x` thin 经 host cc 复现并跳进 tip ELF（`overlay_tip_slot_bytes_gcc.sh`，g05 仅对坏帧）。不再依赖本机 warm blob。残：tip asm 帧未治本，这两枚在 Linux tip 仍 host-cc。Win reloc BSS 新链已绿。
- 2026-09-23 pipeline_abi：纯 `#ifndef FROM_X` 冷孪生出 seeds（文件约 2.78MB→1.51MB）。产品 rest 预处理不变，仍 host-cc。
- 2026-09-23 ast_forwarders：POSIX 产品 rest 在 `XLANG_PABI_AST_FORWARDERS_ASM` 下不再编这 186 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 typeck_orch：POSIX 产品 rest 在 `XLANG_PABI_TYPECK_ORCH_ASM` 下不再编这 7 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 elf_codegen_forwarders：POSIX 产品 rest 在 `XLANG_PABI_ELF_CODEGEN_FORWARDERS_ASM` 下不再编这 19 个 C 体，改由纯 asm thin 提供。Windows／冷种子仍编 C 体。
- 2026-09-23 x_frontend_link_alias：POSIX 产品在 `XLANG_XFLA_ASM` 下不再编这 18 个别名 C 体，改由纯 asm `.x` 提供（5 个保持 weak）。lexer 尾与带修饰别名仍 host-cc。Windows／冷种子仍编 C 体。
- 2026-09-23 backend_enc_dispatch：薄层公共函数的冷路径 C 体已删除，见文首 Class CX。f64／Cap 尾仍 host-cc。
