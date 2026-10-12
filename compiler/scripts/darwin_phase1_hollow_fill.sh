#!/bin/bash
# knife256 / 10.2: Darwin L4 true-cold phase1 hollow-fill after 9.1 seed hollow.
#
# Wipe leaves pipeline/glue/m8/driver-emit faces U; tip overlays need ./xlang.
# Return-0 text stubs + emit-state BSS so phase1 pure-ld can produce
# xlang-seed-phase1. g05 tip overlays restore real faces for the product.
# Also pairs with weak io stubs in ensure_runtime_asm_io_stubs_pure.
#
# Zero make / zero host-cc: `as` only.
# PLATFORM: MACOS arm64. Other hosts no-op.
set -euo pipefail
cd "$(dirname "$0")/.."

case "$(uname -s)" in
  Darwin*) ;;
  *) echo "darwin_phase1_hollow_fill: skip $(uname -s)"; exit 0 ;;
esac

OUT=build_asm/selfhost_pabi
mkdir -p "$OUT"

cat > "$OUT/m8_reloc_stubs.s" <<'STUB'
/* knife256 / 10.2 Darwin phase1 hollow-fill stubs + emit-state BSS.
 * PLATFORM: MACOS arm64 · as only · zero host-cc.
 */
	.text
	.align 2

	.globl _asm_backend_m8_tail_thin_delegate_c_name
	.weak_definition _asm_backend_m8_tail_thin_delegate_c_name
_asm_backend_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_driver_m8_tail_thin_delegate_c_name
	.weak_definition _asm_driver_m8_tail_thin_delegate_c_name
_asm_driver_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_parser_bootstrap_mega_emit_allowed
	.weak_definition _asm_parser_bootstrap_mega_emit_allowed
_asm_parser_bootstrap_mega_emit_allowed:
	mov	w0, #0
	ret
	.globl _asm_parser_emit_heavy_force_stub
	.weak_definition _asm_parser_emit_heavy_force_stub
_asm_parser_emit_heavy_force_stub:
	mov	w0, #0
	ret
	.globl _asm_parser_emit_heavy_safe_helper
	.weak_definition _asm_parser_emit_heavy_safe_helper
_asm_parser_emit_heavy_safe_helper:
	mov	w0, #0
	ret
	.globl _asm_parser_func_is_thin_delegate
	.weak_definition _asm_parser_func_is_thin_delegate
_asm_parser_func_is_thin_delegate:
	mov	w0, #0
	ret
	.globl _asm_parser_m8_tail_thin_delegate_c_name
	.weak_definition _asm_parser_m8_tail_thin_delegate_c_name
_asm_parser_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_pipeline_m8_tail_thin_delegate_c_name
	.weak_definition _asm_pipeline_m8_tail_thin_delegate_c_name
_asm_pipeline_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_typeck_m8_tail_thin_delegate_c_name
	.weak_definition _asm_typeck_m8_tail_thin_delegate_c_name
_asm_typeck_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_wpo_collect_walk
	.weak_definition _asm_wpo_collect_walk
_asm_wpo_collect_walk:
	mov	w0, #0
	ret
	/* knife256/10.2: body_sync k==2 → emit_expr (covers return). Strong. */
	.globl _backend_emit_block_body_sync_elf
_backend_emit_block_body_sync_elf:
	cbz	x0, Lsync_fail
	cbz	x1, Lsync_fail
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	str	x25, [sp, #0x40]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	x22, x3
	mov	w23, w4
	mov	x0, x19
	mov	w1, w21
	bl	_ast_ast_block_num_stmt_order
	mov	w24, w0
	mov	w25, #0
Lsync_loop:
	cmp	w25, w24
	b.ge	Lsync_ok
	mov	x0, x19
	mov	w1, w21
	mov	w2, w25
	bl	_ast_ast_block_stmt_order_kind
	cmp	w0, #2
	b.ne	Lsync_next
	mov	x0, x19
	mov	w1, w21
	mov	w2, w25
	bl	_ast_ast_block_stmt_order_idx
	mov	w2, w0
	mov	x0, x19
	mov	w1, w21
	bl	_ast_pipeline_block_expr_stmt_ref
	cmp	w0, #0
	b.le	Lsync_next
	mov	w2, w0
	mov	x0, x19
	mov	x1, x20
	mov	x3, x22
	mov	w4, w23
	bl	_pipeline_asm_emit_expr_elf_c
	cbnz	w0, Lsync_fail_fr
Lsync_next:
	add	w25, w25, #1
	b	Lsync_loop
Lsync_ok:
	mov	w0, #0
	b	Lsync_ret
Lsync_fail_fr:
	mov	w0, #-1
Lsync_ret:
	ldr	x25, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret
Lsync_fail:
	mov	w0, #-1
	ret

	.globl _glue_copy_large_struct_from_rax_ptr_elf_c
	.weak_definition _glue_copy_large_struct_from_rax_ptr_elf_c
_glue_copy_large_struct_from_rax_ptr_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_index_eff_addr_scaled_elf_c
	.weak_definition _glue_emit_index_eff_addr_scaled_elf_c
_glue_emit_index_eff_addr_scaled_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_struct_type_let_init_elf_c
	.weak_definition _glue_emit_struct_type_let_init_elf_c
_glue_emit_struct_type_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_vector_type_let_init_elf_c
	.weak_definition _glue_emit_vector_type_let_init_elf_c
_glue_emit_vector_type_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _glue_enc_local_slot_ptr_or_addr_elf_c
	.weak_definition _glue_enc_local_slot_ptr_or_addr_elf_c
_glue_enc_local_slot_ptr_or_addr_elf_c:
	mov	w0, #0
	ret
	.globl _glue_try_index_var_or_field_base_to_rax_elf_c
	.weak_definition _glue_try_index_var_or_field_base_to_rax_elf_c
_glue_try_index_var_or_field_base_to_rax_elf_c:
	mov	w0, #0
	ret
	.globl _glue_try_index_var_or_field_base_to_rbx_elf_c
	.weak_definition _glue_try_index_var_or_field_base_to_rbx_elf_c
_glue_try_index_var_or_field_base_to_rbx_elf_c:
	mov	w0, #0
	ret
	.globl _pipe_elf_macho_undef_cap
	.weak_definition _pipe_elf_macho_undef_cap
_pipe_elf_macho_undef_cap:
	mov	w0, #0
	ret
	.globl _pipe_modlet_bake_scalar_imm_to_data
	.weak_definition _pipe_modlet_bake_scalar_imm_to_data
_pipe_modlet_bake_scalar_imm_to_data:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_assign_elf_c
	.weak_definition _pipeline_asm_emit_assign_elf_c
_pipeline_asm_emit_assign_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_block_body_sync_elf
_pipeline_asm_emit_block_body_sync_elf:
	b	_backend_emit_block_body_sync_elf
	/* knife256/10.2: INT_LIT/BOOL → enc_mov_imm32; else -99 (RETURN→impl).
	 * tip backend_emit_expr_elf is no-op; slow path cannot save hello. Strong. */
	.globl _pipeline_asm_emit_expr_elf_fast
_pipeline_asm_emit_expr_elf_fast:
	cbz	x0, Lfast_unh
	cbz	x1, Lfast_unh
	cmp	w2, #0
	b.le	Lfast_unh
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	w22, w4
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_expr_kind_ord_at
	cmp	w0, #0
	b.eq	Lfast_lit
	cmp	w0, #2
	b.eq	Lfast_lit
	mov	w0, #-99
	b	Lfast_ret
Lfast_lit:
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_expr_int_val_at
	mov	w1, w0
	mov	x0, x20
	mov	w2, w22
	bl	_backend_enc_mov_imm32_to_w0_arch
Lfast_ret:
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
Lfast_unh:
	mov	w0, #-99
	ret
	.globl _pipeline_asm_emit_expr_elf_for_call_args
	.weak_definition _pipeline_asm_emit_expr_elf_for_call_args
_pipeline_asm_emit_expr_elf_for_call_args:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_lvalue_eff_addr_elf_c
	.weak_definition _pipeline_asm_emit_lvalue_eff_addr_elf_c
_pipeline_asm_emit_lvalue_eff_addr_elf_c:
	mov	w0, #0
	ret
	/* knife256/10.2: return_elf_impl emits operand via emit_expr_elf_c.
	 * Hollow mov#0 left main without mov w0. Strong. PLATFORM: MACOS. */
	.globl _pipeline_asm_emit_return_elf_impl
_pipeline_asm_emit_return_elf_impl:
	/* x0=arena x1=elf_ctx w2=expr_ref x3=ctx w4=ta */
	cbz	x0, Lret_fail
	cbz	x1, Lret_fail
	cbz	x3, Lret_fail
	cmp	w2, #0
	b.le	Lret_fail
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	str	x23, [sp, #0x30]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	x22, x3
	mov	w23, w4
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_expr_unary_operand_ref_at
	cbz	w0, Lret_ok
	mov	w2, w0
	mov	x0, x19
	mov	x1, x20
	mov	x3, x22
	mov	w4, w23
	bl	_pipeline_asm_emit_expr_elf_c
	cbnz	w0, Lret_fail_frame
Lret_ok:
	mov	w0, #0
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret
Lret_fail_frame:
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
Lret_fail:
	mov	w0, #-1
	ret

	.globl _pipeline_asm_emit_struct_let_init_elf_c
	.weak_definition _pipeline_asm_emit_struct_let_init_elf_c
_pipeline_asm_emit_struct_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_struct_lit_elf_c
	.weak_definition _pipeline_asm_emit_struct_lit_elf_c
_pipeline_asm_emit_struct_lit_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_struct_lit_fields_elf_c
	.weak_definition _pipeline_asm_emit_struct_lit_fields_elf_c
_pipeline_asm_emit_struct_lit_fields_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
	.weak_definition _pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
_pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32:
	mov	w0, #0
	ret
	.globl _pipeline_asm_index_elem_byte_sz_c
	.weak_definition _pipeline_asm_index_elem_byte_sz_c
_pipeline_asm_index_elem_byte_sz_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_simd_try_inline_splat_call_elf_c
	.weak_definition _pipeline_asm_simd_try_inline_splat_call_elf_c
_pipeline_asm_simd_try_inline_splat_call_elf_c:
	mov	w0, #0
	ret
	/* knife256/10.2: identity emit-order (Win wpo_pgo_emit_thin twin).
	 * Zero stubs made emit_n=0 → code_len=0 → reject_empty → CG002 despite
	 * num_funcs≥1. count→pipeline_module_num_funcs; at(i)=i; prepare no-op.
	 * mega_emit_one skips extern. PLATFORM: MACOS phase1 hollow. */
	.globl _pipeline_asm_wpo_pgo_emit_order_at
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_at
_pipeline_asm_wpo_pgo_emit_order_at:
	mov	w0, w1
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_count
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_count
_pipeline_asm_wpo_pgo_emit_order_count:
	b	_pipeline_module_num_funcs
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_prepare
_pipeline_asm_wpo_pgo_emit_order_prepare:
	ret
	/* knife256/10.2: strong Mach-O writer (pabi_strong_writer twin).
	 * asm_full_link_stubs + weak pabi both return -1 / weak; Darwin ld
	 * first-weak-won the -1 stub → macho_write=-1 out_len=0 after emit_order
	 * identity fixed code_len>0. Forward to pipeline_macho_write_o_to_buf_c
	 * (real body in pabi). Keep STRONG — excluded from weaken below.
	 * PLATFORM: MACOS phase1 hollow. */
	.globl _platform_macho_write_macho_o_to_buf
_platform_macho_write_macho_o_to_buf:
	cbz	x0, 1f
	cbz	x1, 1f
	b	_pipeline_macho_write_o_to_buf_c
1:
	mov	w0, #-1
	ret
	.globl _pipeline_elf_ctx_add_common_sym
	.weak_definition _pipeline_elf_ctx_add_common_sym
_pipeline_elf_ctx_add_common_sym:
	mov	w0, #0
	ret
	/* knife256/10.2: real add_label/add_sym (hollow zero stubs → nsyms=0).
	 * Strong — excluded from weaken. Call live egg helpers. Append-only
	 * (no rename search) is enough for phase1 hello; duplicate name updates
	 * offset like elf_ctx_thin. PLATFORM: MACOS phase1. */
	.globl _pipeline_elf_ctx_add_label
_pipeline_elf_ctx_add_label:
	cbz	x0, 9f
	cbz	x1, 9f
	tbnz	w2, #31, 9f
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	str	x25, [sp, #0x40]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	w22, w3
	bl	_pipe_elf_current_shndx
	mov	w23, w0
	mov	x0, x19
	bl	_pipe_elf_off_num_labels
	mov	w24, w0
	mov	x0, x19
	mov	w1, w24
	bl	_pipe_load_i32_le
	mov	w25, w0
	mov	x0, x19
	bl	_pipe_elf_label_cap
	cmp	w25, w0
	b.ge	8f
	mov	x0, x19
	mov	w1, w25
	bl	_pipe_elf_label_at
	mov	x1, x0
	/* name at lab+0; len at +256; offset at +260 */
	cmp	w21, #255
	csel	w2, w21, wzr, le
	mov	w3, #255
	cmp	w21, #255
	csel	w2, w3, w21, gt
	cmp	w2, #0
	b.le	1f
	mov	x0, x1
	mov	x3, x20
	mov	w4, w2
0:
	ldrb	w5, [x3], #1
	strb	w5, [x0], #1
	subs	w4, w4, #1
	b.ne	0b
1:
	mov	w0, #256
	str	w2, [x1, w0, sxtw]
	mov	w0, #260
	str	w22, [x1, w0, sxtw]
	mov	x0, x19
	mov	w1, w25
	mov	w2, w23
	bl	_pipe_elf_label_shndx_set
	add	w2, w25, #1
	mov	x0, x19
	mov	w1, w24
	bl	_pipe_store_i32_le
	mov	w0, #0
	b	7f
8:
	mov	w0, #-1
7:
	ldr	x25, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret
9:
	mov	w0, #-1
	ret

	.globl _pipeline_elf_ctx_add_sym
_pipeline_elf_ctx_add_sym:
	/* name-pool add_sym (elf_ctx_thin twin). No sym_shndx_set — store off_shndx. */
	cbz	x0, Lsym_fail
	cbz	x1, Lsym_fail
	tbnz	w2, #31, Lsym_fail
	stp	x29, x30, [sp, #-0x60]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	stp	x25, x26, [sp, #0x40]
	str	x27, [sp, #0x50]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	w22, w3
	mov	x0, x19
	bl	_pipe_elf_off_num_syms
	mov	w23, w0
	mov	x0, x19
	mov	w1, w23
	bl	_pipe_load_i32_le
	mov	w24, w0
	mov	x0, x19
	bl	_pipe_elf_table_cap
	cmp	w24, w0
	b.ge	Lsym_full
	mov	w25, w21
	cmp	w25, #256
	b.le	1f
	mov	w25, #256
1:
	mov	x0, x19
	bl	_pipe_elf_off_sym_name_len
	mov	w26, w0
	mov	x0, x19
	mov	w1, w26
	bl	_pipe_load_i32_le
	mov	w27, w0
	add	w0, w27, w25
	mov	w1, #131072
	cmp	w0, w1
	b.gt	Lsym_full
	mov	x0, x19
	bl	_pipe_elf_off_sym_name_data
	add	x1, x19, w0, sxtw
	add	x1, x1, w27, sxtw
	cmp	w25, #0
	b.le	2f
	mov	x0, x1
	mov	x3, x20
	mov	w4, w25
0:
	ldrb	w5, [x3], #1
	strb	w5, [x0], #1
	subs	w4, w4, #1
	b.ne	0b
2:
	add	w2, w27, w25
	mov	x0, x19
	mov	w1, w26
	bl	_pipe_store_i32_le
	mov	x0, x19
	mov	w1, w24
	bl	_pipe_elf_sym_at
	mov	x27, x0
	mov	x0, x19
	bl	_pipe_elf_sym_off_name_len
	str	w25, [x27, w0, sxtw]
	mov	x0, x19
	bl	_pipe_elf_sym_off_offset
	str	w22, [x27, w0, sxtw]
	bl	_pipe_elf_shnx_text
	mov	w22, w0
	mov	x0, x19
	bl	_pipe_elf_sym_off_shndx
	str	w22, [x27, w0, sxtw]
	add	w2, w24, #1
	mov	x0, x19
	mov	w1, w23
	bl	_pipe_store_i32_le
	mov	w0, #0
	b	Lsym_ret
Lsym_full:
	mov	w0, #-1
Lsym_ret:
	ldr	x27, [sp, #0x50]
	ldp	x25, x26, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x60
	ret
Lsym_fail:
	mov	w0, #-1
	ret

	.globl _pipeline_elf_ctx_append_data_zeros
	.weak_definition _pipeline_elf_ctx_append_data_zeros
_pipeline_elf_ctx_append_data_zeros:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_data_poke_u8
	.weak_definition _pipeline_elf_ctx_data_poke_u8
_pipeline_elf_ctx_data_poke_u8:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_emit_data_len
	.weak_definition _pipeline_elf_ctx_emit_data_len
_pipeline_elf_ctx_emit_data_len:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_ensure_label
	.weak_definition _pipeline_elf_ctx_ensure_label
_pipeline_elf_ctx_ensure_label:
	mov	w0, #0
	ret
	.globl _w499_mega_try_tail_jmp
	.weak_definition _w499_mega_try_tail_jmp
_w499_mega_try_tail_jmp:
	mov	w0, #0
	ret
	.globl _cfg_sync_compile_target_from_state_c
	.weak_definition _cfg_sync_compile_target_from_state_c
_cfg_sync_compile_target_from_state_c:
	mov	w0, #0
	ret
	.globl _driver_arena_buf
	.weak_definition _driver_arena_buf
_driver_arena_buf:
	mov	w0, #0
	ret
	.globl _driver_argv0_basename_is
	.weak_definition _driver_argv0_basename_is
_driver_argv0_basename_is:
	mov	w0, #0
	ret
	.globl _driver_build_build_x
	.weak_definition _driver_build_build_x
_driver_build_build_x:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_backend_next_c
	.weak_definition _driver_compile_argv_apply_backend_next_c
_driver_compile_argv_apply_backend_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_minus_L_next_c
	.weak_definition _driver_compile_argv_apply_minus_L_next_c
_driver_compile_argv_apply_minus_L_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_minus_O_next_c
	.weak_definition _driver_compile_argv_apply_minus_O_next_c
_driver_compile_argv_apply_minus_O_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_minus_o_next_c
	.weak_definition _driver_compile_argv_apply_minus_o_next_c
_driver_compile_argv_apply_minus_o_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_target_cpu_next_c
	.weak_definition _driver_compile_argv_apply_target_cpu_next_c
_driver_compile_argv_apply_target_cpu_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_apply_target_next_c
	.weak_definition _driver_compile_argv_apply_target_next_c
_driver_compile_argv_apply_target_next_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_copy_path_c
	.weak_definition _driver_compile_argv_copy_path_c
_driver_compile_argv_copy_path_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_is_help_c
	.weak_definition _driver_compile_argv_is_help_c
_driver_compile_argv_is_help_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_next_is_value_c
	.weak_definition _driver_compile_argv_next_is_value_c
_driver_compile_argv_next_is_value_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_set_legacy_f32_abi_c
	.weak_definition _driver_compile_argv_set_legacy_f32_abi_c
_driver_compile_argv_set_legacy_f32_abi_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_set_print_target_cpu_c
	.weak_definition _driver_compile_argv_set_print_target_cpu_c
_driver_compile_argv_set_print_target_cpu_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_set_sanitize_address_c
	.weak_definition _driver_compile_argv_set_sanitize_address_c
_driver_compile_argv_set_sanitize_address_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_set_use_freestanding_c
	.weak_definition _driver_compile_argv_set_use_freestanding_c
_driver_compile_argv_set_use_freestanding_c:
	mov	w0, #0
	ret
	.globl _driver_compile_argv_set_use_lto_c
	.weak_definition _driver_compile_argv_set_use_lto_c
_driver_compile_argv_set_use_lto_c:
	mov	w0, #0
	ret
	.globl _driver_compile_ensure_default_lib_c
	.weak_definition _driver_compile_ensure_default_lib_c
_driver_compile_ensure_default_lib_c:
	mov	w0, #0
	ret
	.globl _driver_compile_parse_argv_init_c
	.weak_definition _driver_compile_parse_argv_init_c
_driver_compile_parse_argv_init_c:
	mov	w0, #0
	ret
	.globl _driver_compile_resolve_target_cpu_c
	.weak_definition _driver_compile_resolve_target_cpu_c
_driver_compile_resolve_target_cpu_c:
	mov	w0, #0
	ret
	.globl _driver_compile_state_alloc_c
	.weak_definition _driver_compile_state_alloc_c
_driver_compile_state_alloc_c:
	mov	w0, #0
	ret
	.globl _driver_compile_state_free_c
	.weak_definition _driver_compile_state_free_c
_driver_compile_state_free_c:
	mov	w0, #0
	ret
	.globl _driver_deps_are_std_core_closure_only
	.weak_definition _driver_deps_are_std_core_closure_only
_driver_deps_are_std_core_closure_only:
	mov	w0, #0
	ret
	.globl _driver_exec_compiled
	.weak_definition _driver_exec_compiled
_driver_exec_compiled:
	mov	w0, #0
	ret
	.globl _driver_exec_path_is_non_exe
	.weak_definition _driver_exec_path_is_non_exe
_driver_exec_path_is_non_exe:
	mov	w0, #0
	ret
	.globl _driver_exec_scan_out_path
	.weak_definition _driver_exec_scan_out_path
_driver_exec_scan_out_path:
	mov	w0, #0
	ret
	.globl _driver_fmt_one_file
	.weak_definition _driver_fmt_one_file
_driver_fmt_one_file:
	mov	w0, #0
	ret
	.globl _driver_fs_open_write
	.weak_definition _driver_fs_open_write
_driver_fs_open_write:
	mov	w0, #0
	ret
	.globl _driver_lib_roots_from_key
	.weak_definition _driver_lib_roots_from_key
_driver_lib_roots_from_key:
	mov	w0, #0
	ret
	.globl _driver_module_buf
	.weak_definition _driver_module_buf
_driver_module_buf:
	mov	w0, #0
	ret
	.globl _driver_print_target_cpu_features_c
	.weak_definition _driver_print_target_cpu_features_c
_driver_print_target_cpu_features_c:
	mov	w0, #0
	ret
	.globl _driver_run_asm_backend_impl_c
	.weak_definition _driver_run_asm_backend_impl_c
_driver_run_asm_backend_impl_c:
	mov	w0, #0
	ret
	.globl _driver_run_compiler_full_x_impl_c
	.weak_definition _driver_run_compiler_full_x_impl_c
_driver_run_compiler_full_x_impl_c:
	mov	w0, #0
	ret
	.globl _driver_run_compiler_parsed
	.weak_definition _driver_run_compiler_parsed
_driver_run_compiler_parsed:
	mov	w0, #0
	ret
	.globl _driver_run_emit_c_path_impl_c
	.weak_definition _driver_run_emit_c_path_impl_c
_driver_run_emit_c_path_impl_c:
	mov	w0, #0
	ret
	.globl _driver_run_test
	.weak_definition _driver_run_test
_driver_run_test:
	mov	w0, #0
	ret
	.globl _driver_run_x_emit_c
	.weak_definition _driver_run_x_emit_c
_driver_run_x_emit_c:
	mov	w0, #0
	ret
	.globl _driver_unlink_failed_output
	.weak_definition _driver_unlink_failed_output
_driver_unlink_failed_output:
	mov	w0, #0
	ret
	.globl _runtime_diag_errno_path
	.weak_definition _runtime_diag_errno_path
_runtime_diag_errno_path:
	mov	w0, #0
	ret
	.globl _runtime_diag_errno_path_pair
	.weak_definition _runtime_diag_errno_path_pair
_runtime_diag_errno_path_pair:
	mov	w0, #0
	ret
	.globl _runtime_pipeline_elf_ctx_diag_note
	.weak_definition _runtime_pipeline_elf_ctx_diag_note
_runtime_pipeline_elf_ctx_diag_note:
	mov	w0, #0
	ret

	.bss
	.align 3

	.globl _g_pipeline_elf_reloc_r_pcrel
	.weak_definition _g_pipeline_elf_reloc_r_pcrel
_g_pipeline_elf_reloc_r_pcrel:
	.quad 0
	.globl _g_pipeline_elf_reloc_r_type
	.weak_definition _g_pipeline_elf_reloc_r_type
_g_pipeline_elf_reloc_r_type:
	.quad 0
	.globl _g_pipeline_elf_reloc_sidecar_owner
	.weak_definition _g_pipeline_elf_reloc_sidecar_owner
_g_pipeline_elf_reloc_sidecar_owner:
	.quad 0
	.globl _driver_x_emit_c_path
	.weak_definition _driver_x_emit_c_path
	.align 3
_driver_x_emit_c_path:
	.space 8
	.globl _driver_x_emit_lib_roots
	.weak_definition _driver_x_emit_lib_roots
	.align 3
_driver_x_emit_lib_roots:
	.space 128
	.globl _driver_x_emit_n_lib_roots
	.weak_definition _driver_x_emit_n_lib_roots
	.align 3
_driver_x_emit_n_lib_roots:
	.space 4
	.globl _driver_x_emit_path_buf
	.weak_definition _driver_x_emit_path_buf
	.align 3
_driver_x_emit_path_buf:
	.space 512
	.globl _driver_x_emit_lib_bufs
	.weak_definition _driver_x_emit_lib_bufs
	.align 3
_driver_x_emit_lib_bufs:
	.space 4096
	.globl _driver_x_emit_c_want_extern
	.weak_definition _driver_x_emit_c_want_extern
	.align 3
_driver_x_emit_c_want_extern:
	.space 4
	.globl _driver_x_emit_scan_ab
	.weak_definition _driver_x_emit_scan_ab
	.align 3
_driver_x_emit_scan_ab:
	.space 512
	.globl _driver_x_emit_scan_nx
	.weak_definition _driver_x_emit_scan_nx
	.align 3
_driver_x_emit_scan_nx:
	.space 512
	.globl _driver_x_emit_lib_name_buf
	.weak_definition _driver_x_emit_lib_name_buf
	.align 3
_driver_x_emit_lib_name_buf:
	.space 64
	.globl _driver_x_emit_lib_name_len
	.weak_definition _driver_x_emit_lib_name_len
	.align 3
_driver_x_emit_lib_name_len:
	.space 4

	/* knife256 / 10.2: dual F7 data homes for data_len sidecar / tip cold.
	 * CAP=65536 matches W744_PIPE_ELF_DATA_CAP. Weak so tip/pabi strong wins.
	 * PLATFORM: MACOS arm64 · as only · g05 via m8_reloc_stubs.o.
	 */
	.globl _g_pipeline_elf_data_len
	.weak_definition _g_pipeline_elf_data_len
	.align 3
_g_pipeline_elf_data_len:
	.space 4
	.globl _g_pipeline_elf_data_buf
	.weak_definition _g_pipeline_elf_data_buf
	.align 3
_g_pipeline_elf_data_buf:
	.space 65536
STUB
# knife256 / 10.2: real BSS for tip lexer skip park (tip .x emits no __DATA).
# PLATFORM: MACOS arm64 · as only.
cat >> "$OUT/m8_reloc_stubs.s" <<'LEXPARK'
	.bss
	.align 3
	.globl _g_lex_src_data
_g_lex_src_data:
	.quad 0
	.globl _g_lex_src_len
_g_lex_src_len:
	.quad 0
	.text
	.align 2
	.globl _lexer_src_park
_lexer_src_park:
	// x0=data *u8, w1=len i32.
	// Poison: Darwin PAGEZERO is 4GiB — reject ptrs with bit32 clear (tip smash
	// 0x102a etc.). Also ignore tip u8[] return deep-copy (len==1024) when a
	// longer full-file park already exists — that truncate clobbered */ past 1024.
	// PLATFORM: MACOS arm64.
	tbz	x0, #32, 1f
	sxtw	x1, w1
	cmp	x1, #1024
	b.ne	0f
	adrp	x2, _g_lex_src_len@PAGE
	ldr	x2, [x2, _g_lex_src_len@PAGEOFF]
	cmp	x2, #1024
	b.gt	1f
0:
	adrp	x2, _g_lex_src_data@PAGE
	str	x0, [x2, _g_lex_src_data@PAGEOFF]
	adrp	x2, _g_lex_src_len@PAGE
	str	x1, [x2, _g_lex_src_len@PAGEOFF]
1:
	ret
	.globl _lexer_src_data_store
_lexer_src_data_store:
	// x0 = *u8*  (out: store parked data pointer)
	adrp	x1, _g_lex_src_data@PAGE
	ldr	x1, [x1, _g_lex_src_data@PAGEOFF]
	str	x1, [x0]
	ret
	.globl _lexer_src_len_store
_lexer_src_len_store:
	// x0 = *i64*  (out: store parked len as i64/usize)
	adrp	x1, _g_lex_src_len@PAGE
	ldr	x1, [x1, _g_lex_src_len@PAGEOFF]
	str	x1, [x0]
	ret
	// knife256 / 10.2: strong override — tip may pass source=0x3a.
	// Prefer parked BSS when source is null/poison (<4096). PLATFORM: MACOS.
	.globl _parser_asm_copy_slice_to_name64_buf_c
_parser_asm_copy_slice_to_name64_buf_c:
	// x0=source, w1=source_len, x2=start, w3=nlen, x4=out
	// Always prefer parked lexer BSS when set (tip source smash).
	cbz	x4, 9f
	cmp	w3, #0
	b.le	9f
	adrp	x5, _g_lex_src_data@PAGE
	ldr	x5, [x5, _g_lex_src_data@PAGEOFF]
	adrp	x6, _g_lex_src_len@PAGE
	ldr	x6, [x6, _g_lex_src_len@PAGEOFF]
	cbnz	x5, 2f
	mov	x5, x0
	sxtw	x6, w1
2:
	cbz	x5, 9f
	mov	w8, #0			// i = 0
3:
	cmp	w8, w3
	b.ge	9f
	sxtw	x9, w8
	add	x9, x2, x9		// off = start + i
	cmp	x9, x6
	b.hs	4f
	ldrb	w10, [x5, x9]
	sxtw	x11, w8
	strb	w10, [x4, x11]
4:
	add	w8, w8, #1
	b	3b
9:
	ret
LEXPARK



# knife256/10.2: WEAK aliases for cold archive pabi (missing ast_pipeline_* /
# tip-thin bodies). Strong tip/MH_OBJECT pabi wins when present.
# PLATFORM: MACOS.
cat >> "$OUT/m8_reloc_stubs.s" <<'ALIASES'
	.globl _ast_pipeline_block_append_labeled
	.weak_definition _ast_pipeline_block_append_labeled
_ast_pipeline_block_append_labeled:
	b	_pipeline_block_append_labeled
	.globl _ast_pipeline_block_const_init_ref
	.weak_definition _ast_pipeline_block_const_init_ref
_ast_pipeline_block_const_init_ref:
	b	_ast_ast_block_const_init_ref
	.globl _ast_pipeline_block_const_name_copy64
	.weak_definition _ast_pipeline_block_const_name_copy64
_ast_pipeline_block_const_name_copy64:
	b	_pipeline_block_const_name_copy64
	.globl _ast_pipeline_block_const_name_len
	.weak_definition _ast_pipeline_block_const_name_len
_ast_pipeline_block_const_name_len:
	b	_pipeline_block_const_name_len
	.globl _ast_pipeline_block_expr_stmt_ref
	.weak_definition _ast_pipeline_block_expr_stmt_ref
_ast_pipeline_block_expr_stmt_ref:
	b	_ast_ast_block_expr_stmt_ref
	.globl _ast_pipeline_block_if_cond_ref
	.weak_definition _ast_pipeline_block_if_cond_ref
_ast_pipeline_block_if_cond_ref:
	b	_ast_ast_block_if_cond_ref
	.globl _ast_pipeline_block_if_else_body_ref
	.weak_definition _ast_pipeline_block_if_else_body_ref
_ast_pipeline_block_if_else_body_ref:
	b	_ast_ast_block_if_else_body_ref
	.globl _ast_pipeline_block_if_then_body_ref
	.weak_definition _ast_pipeline_block_if_then_body_ref
_ast_pipeline_block_if_then_body_ref:
	b	_ast_ast_block_if_then_body_ref
	.globl _ast_pipeline_block_let_init_ref
	.weak_definition _ast_pipeline_block_let_init_ref
_ast_pipeline_block_let_init_ref:
	b	_ast_ast_block_let_init_ref
	.globl _ast_pipeline_block_let_name_copy64
	.weak_definition _ast_pipeline_block_let_name_copy64
_ast_pipeline_block_let_name_copy64:
	b	_pipeline_block_let_name_copy64
	.globl _ast_pipeline_block_let_name_len
	.weak_definition _ast_pipeline_block_let_name_len
_ast_pipeline_block_let_name_len:
	b	_pipeline_block_let_name_len
	.globl _ast_pipeline_dep_ctx_module_at
	.weak_definition _ast_pipeline_dep_ctx_module_at
_ast_pipeline_dep_ctx_module_at:
	b	_pipeline_dep_ctx_module_at
	.globl _ast_pipeline_dep_ctx_ndep
	.weak_definition _ast_pipeline_dep_ctx_ndep
_ast_pipeline_dep_ctx_ndep:
	b	_pipeline_dep_ctx_ndep
	.globl _pipeline_sizeof_elf_ctx
	.weak_definition _pipeline_sizeof_elf_ctx
_pipeline_sizeof_elf_ctx:
	movz	x0, #0x30
	movk	x0, #0x330, lsl #16
	ret
	.globl _pipeline_copy_lib_root_to_buf256
	.weak_definition _pipeline_copy_lib_root_to_buf256
_pipeline_copy_lib_root_to_buf256:
	cbz	x2, 1f
	mov	x3, x2
	mov	w4, #256
0:	strb	wzr, [x3], #1
	subs	w4, w4, #1
	b.ne	0b
1:	mov	w0, #0
	ret
	.globl _glue_local_var_slot_needs_ptr_load_elf_c
	.weak_definition _glue_local_var_slot_needs_ptr_load_elf_c
_glue_local_var_slot_needs_ptr_load_elf_c:
	mov	w0, #0
	ret
	.globl _typeck_x_type_align_from_layout_glue
	.weak_definition _typeck_x_type_align_from_layout_glue
_typeck_x_type_align_from_layout_glue:
	mov	w0, #8
	ret
	.globl _typeck_x_type_size_from_layout_glue
	.weak_definition _typeck_x_type_size_from_layout_glue
_typeck_x_type_size_from_layout_glue:
	mov	w0, #8
	ret
ALIASES

as -o "$OUT/m8_reloc_stubs.o" "$OUT/m8_reloc_stubs.s"
[ -s "$OUT/m8_reloc_stubs.o" ] || { echo "darwin_phase1_hollow_fill: as failed" >&2; exit 1; }

# knife256: weaken every text stub so real bodies in runtime_driver_no_c
# (rt_entry pure-asm / hybrid) win at phase1 pure-ld. Strong stubs dups
# driver_build_build_x / driver_exec_* when no_c carries tip faces.
# PLATFORM: MACOS arm64.
_oc=$(command -v llvm-objcopy 2>/dev/null || command -v objcopy 2>/dev/null || true)
if [ -z "$_oc" ] && [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
  _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
fi
if [ -z "$_oc" ] && [ -x /usr/bin/xcrun ]; then
  _oc=$(xcrun -f llvm-objcopy 2>/dev/null || true)
fi
if [ -n "$_oc" ]; then
  _weak_args=()
  while read -r _sym; do
    [ -n "$_sym" ] || continue
    _weak_args+=(--weaken-symbol "$_sym")
  done < <(nm -gU "$OUT/m8_reloc_stubs.o" 2>/dev/null | awk '/ T /{print $NF}' | grep -Ev 'lexer_src_|parser_asm_copy_slice_to_name64_buf_c|g_lex_src_|platform_macho_write_macho_o_to_buf|pipeline_elf_ctx_add_label|pipeline_elf_ctx_add_sym|pipeline_asm_emit_return_elf_impl|backend_emit_block_body_sync_elf|pipeline_asm_emit_block_body_sync_elf|pipeline_asm_emit_expr_elf_fast')
  if [ "${#_weak_args[@]}" -gt 0 ]; then
    "$_oc" "${_weak_args[@]}" "$OUT/m8_reloc_stubs.o" \
      || { echo "darwin_phase1_hollow_fill: weaken stubs failed" >&2; exit 1; }
    echo "darwin_phase1_hollow_fill: weakened ${#_weak_args[@]} text stubs"
  fi
else
  echo "darwin_phase1_hollow_fill: WARN no objcopy; stubs stay strong (dup risk)" >&2
fi

echo "$OUT/m8_reloc_stubs.o" >"$OUT/phase1_hollow_fill_objs.txt"
echo "darwin_phase1_hollow_fill: OK stubs+bss manifest=$OUT/phase1_hollow_fill_objs.txt"
exit 0
