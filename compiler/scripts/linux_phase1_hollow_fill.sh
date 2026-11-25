#!/usr/bin/env bash
# knife256 / 10.2 note734: Linux L4 tip-cold phase1 hollow-fill.
#
# Mirror Darwin darwin_phase1_hollow_fill.sh for ELF x86_64: after L4 wipe,
# phase1 pure-ld needs return-0 / park stubs so xlang-seed-phase1 can link.
# g05 tip overlays restore real faces for the product.
#
# Zero make / zero host-cc / no FORCE_CC: `as` only.
# PLATFORM: LINUX x86_64. Other hosts no-op.
set -euo pipefail
cd "$(dirname "$0")/.."

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) ;;
  *) echo "linux_phase1_hollow_fill: skip $(uname -s)-$(uname -m)"; exit 0 ;;
esac

OUT=build_asm/selfhost_pabi
mkdir -p "$OUT"
S="$OUT/linux_phase1_hollow_stubs.s"
O="$OUT/linux_phase1_hollow_stubs.o"

cat > "$S" <<'STUB'
/* knife256 / 10.2 Linux phase1 hollow-fill stubs.
 * PLATFORM: LINUX x86_64 · as only · zero host-cc.
 */
        .text
        .globl asm_backend_m8_tail_thin_delegate_c_name
        .weak asm_backend_m8_tail_thin_delegate_c_name
asm_backend_m8_tail_thin_delegate_c_name:
        xorl    %eax, %eax
        ret
        .globl asm_driver_m8_tail_thin_delegate_c_name
        .weak asm_driver_m8_tail_thin_delegate_c_name
asm_driver_m8_tail_thin_delegate_c_name:
        xorl    %eax, %eax
        ret
        .globl asm_parser_bootstrap_mega_emit_allowed
        .weak asm_parser_bootstrap_mega_emit_allowed
asm_parser_bootstrap_mega_emit_allowed:
        xorl    %eax, %eax
        ret
        .globl asm_parser_emit_heavy_force_stub
        .weak asm_parser_emit_heavy_force_stub
asm_parser_emit_heavy_force_stub:
        xorl    %eax, %eax
        ret
        .globl asm_parser_emit_heavy_safe_helper
        .weak asm_parser_emit_heavy_safe_helper
asm_parser_emit_heavy_safe_helper:
        xorl    %eax, %eax
        ret
        .globl asm_parser_func_is_thin_delegate
        .weak asm_parser_func_is_thin_delegate
asm_parser_func_is_thin_delegate:
        xorl    %eax, %eax
        ret
        .globl asm_parser_m8_tail_thin_delegate_c_name
        .weak asm_parser_m8_tail_thin_delegate_c_name
asm_parser_m8_tail_thin_delegate_c_name:
        xorl    %eax, %eax
        ret
        .globl asm_pipeline_m8_tail_thin_delegate_c_name
        .weak asm_pipeline_m8_tail_thin_delegate_c_name
asm_pipeline_m8_tail_thin_delegate_c_name:
        xorl    %eax, %eax
        ret
        .globl asm_typeck_m8_tail_thin_delegate_c_name
        .weak asm_typeck_m8_tail_thin_delegate_c_name
asm_typeck_m8_tail_thin_delegate_c_name:
        xorl    %eax, %eax
        ret
        .globl asm_wpo_collect_walk
        .weak asm_wpo_collect_walk
asm_wpo_collect_walk:
        xorl    %eax, %eax
        ret
        .globl bootstrap_init_environ
        .weak bootstrap_init_environ
bootstrap_init_environ:
        xorl    %eax, %eax
        ret
        .globl bootstrap_init_static_tls
        .weak bootstrap_init_static_tls
bootstrap_init_static_tls:
        xorl    %eax, %eax
        ret
        .globl codegen_emit_slice_let_reent_finish
        .weak codegen_emit_slice_let_reent_finish
codegen_emit_slice_let_reent_finish:
        xorl    %eax, %eax
        ret
        .globl codegen_get_host_call_arg_param_ty
        .weak codegen_get_host_call_arg_param_ty
codegen_get_host_call_arg_param_ty:
        xorl    %eax, %eax
        ret
        .globl codegen_next_host_call_array_tmp_id
        .weak codegen_next_host_call_array_tmp_id
codegen_next_host_call_array_tmp_id:
        xorl    %eax, %eax
        ret
        .globl codegen_set_host_call_arg_param_ty
        .weak codegen_set_host_call_arg_param_ty
codegen_set_host_call_arg_param_ty:
        xorl    %eax, %eax
        ret
        .globl driver_arena_buf
        .weak driver_arena_buf
driver_arena_buf:
        xorl    %eax, %eax
        ret
        .globl driver_argv0_basename_is
        .weak driver_argv0_basename_is
driver_argv0_basename_is:
        xorl    %eax, %eax
        ret
        .globl driver_exec_compiled
        .weak driver_exec_compiled
driver_exec_compiled:
        xorl    %eax, %eax
        ret
        .globl driver_exec_path_is_non_exe
        .weak driver_exec_path_is_non_exe
driver_exec_path_is_non_exe:
        xorl    %eax, %eax
        ret
        .globl driver_exec_scan_out_path
        .weak driver_exec_scan_out_path
driver_exec_scan_out_path:
        xorl    %eax, %eax
        ret
        .globl driver_fmt_one_file
        .weak driver_fmt_one_file
driver_fmt_one_file:
        xorl    %eax, %eax
        ret
        .globl driver_fs_open_write
        .weak driver_fs_open_write
driver_fs_open_write:
        xorl    %eax, %eax
        ret
        .globl driver_lib_roots_from_key
        .weak driver_lib_roots_from_key
driver_lib_roots_from_key:
        xorl    %eax, %eax
        ret
        .globl driver_module_buf
        .weak driver_module_buf
driver_module_buf:
        xorl    %eax, %eax
        ret
        .globl driver_print_target_cpu_features_c
        .weak driver_print_target_cpu_features_c
driver_print_target_cpu_features_c:
        xorl    %eax, %eax
        ret
        .globl driver_run_test
        .weak driver_run_test
driver_run_test:
        xorl    %eax, %eax
        ret
        .globl driver_run_x_emit_c
        .weak driver_run_x_emit_c
driver_run_x_emit_c:
        xorl    %eax, %eax
        ret
        .globl driver_unlink_failed_output
        .weak driver_unlink_failed_output
driver_unlink_failed_output:
        xorl    %eax, %eax
        ret
        /* note743e: these are DATA cells (want_extern_slot lea+store).
         * Code stubs land in .text → tip -E SEGV. Weak BSS until prefer
         * / cold BSS supplies strong. Sizes match rt_emit_state_bss_cold. */
        .bss
        .align 8
        .globl driver_x_emit_c_path
        .weak driver_x_emit_c_path
driver_x_emit_c_path:
        .zero 8
        .globl driver_x_emit_c_want_extern
        .weak driver_x_emit_c_want_extern
        .align 4
driver_x_emit_c_want_extern:
        .zero 4
        .globl driver_x_emit_lib_bufs
        .weak driver_x_emit_lib_bufs
        .align 8
driver_x_emit_lib_bufs:
        .zero 4096
        .globl driver_x_emit_lib_roots
        .weak driver_x_emit_lib_roots
        .align 8
driver_x_emit_lib_roots:
        .zero 128
        .globl driver_x_emit_n_lib_roots
        .weak driver_x_emit_n_lib_roots
        .align 4
driver_x_emit_n_lib_roots:
        .zero 4
        .globl driver_x_emit_path_buf
        .weak driver_x_emit_path_buf
        .align 8
driver_x_emit_path_buf:
        .zero 512
        .globl driver_x_emit_scan_ab
        .weak driver_x_emit_scan_ab
        .align 8
driver_x_emit_scan_ab:
        .zero 512
        .globl driver_x_emit_scan_nx
        .weak driver_x_emit_scan_nx
        .align 8
driver_x_emit_scan_nx:
        .zero 512
        .globl driver_x_emit_lib_name_buf
        .weak driver_x_emit_lib_name_buf
        .align 8
driver_x_emit_lib_name_buf:
        .zero 64
        .globl driver_x_emit_lib_name_len
        .weak driver_x_emit_lib_name_len
        .align 4
driver_x_emit_lib_name_len:
        .zero 4
        .text
        .globl glue_copy_large_struct_from_rax_ptr_elf_c
        .weak glue_copy_large_struct_from_rax_ptr_elf_c
glue_copy_large_struct_from_rax_ptr_elf_c:
        xorl    %eax, %eax
        ret
        .globl glue_emit_index_eff_addr_scaled_elf_c
        .weak glue_emit_index_eff_addr_scaled_elf_c
glue_emit_index_eff_addr_scaled_elf_c:
        xorl    %eax, %eax
        ret
        .globl glue_emit_struct_type_let_init_elf_c
        .weak glue_emit_struct_type_let_init_elf_c
glue_emit_struct_type_let_init_elf_c:
        xorl    %eax, %eax
        ret
        .globl glue_try_index_var_or_field_base_to_rax_elf_c
        .weak glue_try_index_var_or_field_base_to_rax_elf_c
glue_try_index_var_or_field_base_to_rax_elf_c:
        xorl    %eax, %eax
        ret
        .globl glue_try_index_var_or_field_base_to_rbx_elf_c
        .weak glue_try_index_var_or_field_base_to_rbx_elf_c
glue_try_index_var_or_field_base_to_rbx_elf_c:
        xorl    %eax, %eax
        ret
        .globl pipe_elf_macho_undef_cap
        .weak pipe_elf_macho_undef_cap
pipe_elf_macho_undef_cap:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_assign_elf_c
        .weak pipeline_asm_emit_assign_elf_c
pipeline_asm_emit_assign_elf_c:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_expr_elf_fast
        .weak pipeline_asm_emit_expr_elf_fast
pipeline_asm_emit_expr_elf_fast:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_expr_elf_for_call_args
        .weak pipeline_asm_emit_expr_elf_for_call_args
pipeline_asm_emit_expr_elf_for_call_args:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_lvalue_eff_addr_elf_c
        .weak pipeline_asm_emit_lvalue_eff_addr_elf_c
pipeline_asm_emit_lvalue_eff_addr_elf_c:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_return_elf_impl
        .weak pipeline_asm_emit_return_elf_impl
pipeline_asm_emit_return_elf_impl:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
        .weak pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_index_elem_byte_sz_c
        .weak pipeline_asm_index_elem_byte_sz_c
pipeline_asm_index_elem_byte_sz_c:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_simd_try_inline_splat_call_elf_c
        .weak pipeline_asm_simd_try_inline_splat_call_elf_c
pipeline_asm_simd_try_inline_splat_call_elf_c:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_wpo_pgo_emit_order_at
        .weak pipeline_asm_wpo_pgo_emit_order_at
pipeline_asm_wpo_pgo_emit_order_at:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_wpo_pgo_emit_order_count
        .weak pipeline_asm_wpo_pgo_emit_order_count
pipeline_asm_wpo_pgo_emit_order_count:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_wpo_pgo_emit_order_prepare
        .weak pipeline_asm_wpo_pgo_emit_order_prepare
pipeline_asm_wpo_pgo_emit_order_prepare:
        xorl    %eax, %eax
        ret
        .globl pipeline_elf_ctx_add_common_sym
        .weak pipeline_elf_ctx_add_common_sym
pipeline_elf_ctx_add_common_sym:
        xorl    %eax, %eax
        ret
        .globl pipeline_elf_ctx_add_label
        .weak pipeline_elf_ctx_add_label
pipeline_elf_ctx_add_label:
        xorl    %eax, %eax
        ret
        .globl pipeline_elf_ctx_add_sym
        .weak pipeline_elf_ctx_add_sym
pipeline_elf_ctx_add_sym:
        xorl    %eax, %eax
        ret
        .globl pipeline_elf_ctx_emit_data_len
        .weak pipeline_elf_ctx_emit_data_len
pipeline_elf_ctx_emit_data_len:
        xorl    %eax, %eax
        ret
        .globl pipeline_elf_ctx_ensure_label
        .weak pipeline_elf_ctx_ensure_label
pipeline_elf_ctx_ensure_label:
        xorl    %eax, %eax
        ret
        .globl pipeline_loop_should_continue_lib_root_c
        .weak pipeline_loop_should_continue_lib_root_c
pipeline_loop_should_continue_lib_root_c:
        xorl    %eax, %eax
        ret
        .globl pipe_modlet_bake_scalar_imm_to_data
        .weak pipe_modlet_bake_scalar_imm_to_data
pipe_modlet_bake_scalar_imm_to_data:
        xorl    %eax, %eax
        ret
        .globl runtime_diag_errno_path
        .weak runtime_diag_errno_path
runtime_diag_errno_path:
        xorl    %eax, %eax
        ret
        .globl runtime_diag_errno_path_pair
        .weak runtime_diag_errno_path_pair
runtime_diag_errno_path_pair:
        xorl    %eax, %eax
        ret
        .globl runtime_pipeline_elf_ctx_diag_note
        .weak runtime_pipeline_elf_ctx_diag_note
runtime_pipeline_elf_ctx_diag_note:
        xorl    %eax, %eax
        ret
        .globl w499_mega_try_tail_jmp
        .weak w499_mega_try_tail_jmp
w499_mega_try_tail_jmp:
        xorl    %eax, %eax
        ret

        .globl pipeline_scratch_buf64
        .weak pipeline_scratch_buf64
pipeline_scratch_buf64:
        leaq    pipeline_scratch_buf64_bss(%rip), %rax
        ret
        .globl pipeline_scratch_buf64_slot
        .weak pipeline_scratch_buf64_slot
pipeline_scratch_buf64_slot:
        leaq    pipeline_scratch_buf64_bss(%rip), %rax
        ret

/* lexer park BSS + faces (SysV: rdi/rsi). Strong so tip poison paths work. */
        .globl g_lex_src_data
        .bss
        .align 8
g_lex_src_data:
        .zero 8
        .globl g_lex_src_len
g_lex_src_len:
        .zero 8
        .globl pipeline_scratch_buf64_bss
        .align 16
pipeline_scratch_buf64_bss:
        .zero 64

        .text
        .globl lexer_src_park
lexer_src_park:
        /* rdi=data, rsi=len — park if data non-null and >4096-ish, else clear */
        testq   %rdi, %rdi
        jz      1f
        cmpq    $4096, %rdi
        jb      1f
        movq    %rdi, g_lex_src_data(%rip)
        movq    %rsi, g_lex_src_len(%rip)
        ret
1:
        movq    $0, g_lex_src_data(%rip)
        movq    $0, g_lex_src_len(%rip)
        ret
        .globl lexer_src_data_store
lexer_src_data_store:
        /* rdi = *u8* out */
        movq    g_lex_src_data(%rip), %rax
        movq    %rax, (%rdi)
        ret
        .globl lexer_src_len_store
lexer_src_len_store:
        /* rdi = *i64* out */
        movq    g_lex_src_len(%rip), %rax
        movq    %rax, (%rdi)
        ret
STUB

as --64 -o "$O" "$S"
[ -s "$O" ] || { echo "linux_phase1_hollow_fill: as failed" >&2; exit 1; }

: >"$OUT/phase1_hollow_fill_objs.txt"
echo "$O" >>"$OUT/phase1_hollow_fill_objs.txt"
echo "linux_phase1_hollow_fill: OK $(nm "$O" | awk '$2=="T"||$2=="t"' | wc -l | tr -d " ") text faces → $O"
