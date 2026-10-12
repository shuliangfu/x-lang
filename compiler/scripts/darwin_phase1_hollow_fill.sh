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
	.globl _backend_emit_block_body_sync_elf
	.weak_definition _backend_emit_block_body_sync_elf
_backend_emit_block_body_sync_elf:
	mov	w0, #0
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
	.weak_definition _pipeline_asm_emit_block_body_sync_elf
_pipeline_asm_emit_block_body_sync_elf:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_expr_elf_fast
	.weak_definition _pipeline_asm_emit_expr_elf_fast
_pipeline_asm_emit_expr_elf_fast:
	mov	w0, #0
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
	.globl _pipeline_asm_emit_return_elf_impl
	.weak_definition _pipeline_asm_emit_return_elf_impl
_pipeline_asm_emit_return_elf_impl:
	mov	w0, #0
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
	.globl _pipeline_asm_wpo_pgo_emit_order_at
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_at
_pipeline_asm_wpo_pgo_emit_order_at:
	mov	w0, #0
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_count
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_count
_pipeline_asm_wpo_pgo_emit_order_count:
	mov	w0, #0
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare
	.weak_definition _pipeline_asm_wpo_pgo_emit_order_prepare
_pipeline_asm_wpo_pgo_emit_order_prepare:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_common_sym
	.weak_definition _pipeline_elf_ctx_add_common_sym
_pipeline_elf_ctx_add_common_sym:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_label
	.weak_definition _pipeline_elf_ctx_add_label
_pipeline_elf_ctx_add_label:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_sym
	.weak_definition _pipeline_elf_ctx_add_sym
_pipeline_elf_ctx_add_sym:
	mov	w0, #0
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
	// x0=data *u8, w1=len i32. Sticky: ignore null/poison (<4096).
	mov	x2, #0x1000
	cmp	x0, x2
	b.ls	1f
	adrp	x2, _g_lex_src_data@PAGE
	str	x0, [x2, _g_lex_src_data@PAGEOFF]
	adrp	x2, _g_lex_src_len@PAGE
	sxtw	x1, w1
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
  done < <(nm -gU "$OUT/m8_reloc_stubs.o" 2>/dev/null | awk '/ T /{print $NF}' | grep -Ev 'lexer_src_|parser_asm_copy_slice_to_name64_buf_c|g_lex_src_')
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
