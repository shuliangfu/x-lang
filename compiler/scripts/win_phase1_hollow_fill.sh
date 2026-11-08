#!/usr/bin/env bash
# Win L4 tip-cold phase1 hollow-fill.
#
# Mirror linux_phase1_hollow_fill.sh for PE x86_64 (w64devkit as): after L4
# wipe, bootstrap_driver_seed_link phase1 CC residual needs return-0 stubs so
# xlang-seed-phase1 can link. g05 tip overlays restore real faces for the
# product. Manifest is prepended by bootstrap_driver_seed_link.sh (same as
# Darwin/Linux hollow).
#
# Zero make / zero host-cc: `as` only.
# PLATFORM: WINDOWS (Windows_NT / MINGW / MSYS / CYGWIN). Other hosts no-op.
set -euo pipefail
cd "$(dirname "$0")/.."

_os=$(uname -s 2>/dev/null || echo unknown)
case "$_os" in
  Windows_NT*|MINGW*|MSYS*|CYGWIN*) ;;
  *)
    # Git Bash sometimes reports the same; also accept OSTYPE.
    case "${OSTYPE:-}" in
      msys*|cygwin*) ;;
      *) echo "win_phase1_hollow_fill: skip $_os"; exit 0 ;;
    esac
    ;;
esac

OUT=build_asm/selfhost_pabi
mkdir -p "$OUT"
S="$OUT/win_phase1_hollow_stubs.s"
O="$OUT/win_phase1_hollow_stubs.o"

# FAIL＠96be11450 / add6c2a7d residual UNDEF batch (stretch/lexer_src_store
# cleared by thin_glue T≥764; xlang_sys_* prefer MAIN_LINK io stubs — still
# stub here as belt-and-suspenders when MAIN_LINK lag).
cat > "$S" <<'STUB'
/* Win phase1 hollow-fill stubs.
 * PLATFORM: WINDOWS PE x86_64 · as only · zero host-cc.
 * PE/COFF gas: .weak makes weak-UNDEF (not defs). Use strong .globl only;
 * first-win under --allow-multiple-definition; g05 restores real faces.
 */
        .text
        .globl vlet_lane_cmp_ko
vlet_lane_cmp_ko:
        xorl    %eax, %eax
        ret
        .globl backend_emit_block_body_sync_elf
backend_emit_block_body_sync_elf:
        xorl    %eax, %eax
        ret
        .globl pipeline_asm_emit_block_body_sync_elf
pipeline_asm_emit_block_body_sync_elf:
        xorl    %eax, %eax
        ret
        .globl pipe_modlet_bake_struct_lit_to_data
pipe_modlet_bake_struct_lit_to_data:
        xorl    %eax, %eax
        ret
        .globl pipe_modlet_array_lit_elem_const_val
pipe_modlet_array_lit_elem_const_val:
        xorl    %eax, %eax
        ret
        .globl w499_mega_try_tail_jmp
w499_mega_try_tail_jmp:
        xorl    %eax, %eax
        ret
        .globl driver_arena_buf
driver_arena_buf:
        xorl    %eax, %eax
        ret
        .globl driver_module_buf
driver_module_buf:
        xorl    %eax, %eax
        ret
        .globl driver_fs_open_write
driver_fs_open_write:
        xorl    %eax, %eax
        ret
        .globl driver_exec_compiled
driver_exec_compiled:
        xorl    %eax, %eax
        ret
        .globl driver_exec_path_is_non_exe
driver_exec_path_is_non_exe:
        xorl    %eax, %eax
        ret
        .globl driver_exec_scan_out_path
driver_exec_scan_out_path:
        xorl    %eax, %eax
        ret
        .globl driver_print_target_cpu_features_c
driver_print_target_cpu_features_c:
        xorl    %eax, %eax
        ret
        .globl driver_run_test
driver_run_test:
        xorl    %eax, %eax
        ret
        .globl driver_run_x_emit_c
driver_run_x_emit_c:
        xorl    %eax, %eax
        ret
        .globl driver_argv0_basename_is
driver_argv0_basename_is:
        xorl    %eax, %eax
        ret
        .globl driver_unlink_failed_output
driver_unlink_failed_output:
        xorl    %eax, %eax
        ret
        .globl driver_lib_roots_from_key
driver_lib_roots_from_key:
        xorl    %eax, %eax
        ret
        .globl runtime_diag_errno_path
runtime_diag_errno_path:
        xorl    %eax, %eax
        ret
        .globl runtime_diag_errno_path_pair
runtime_diag_errno_path_pair:
        xorl    %eax, %eax
        ret
        .globl runtime_pipeline_elf_ctx_diag_note
runtime_pipeline_elf_ctx_diag_note:
        xorl    %eax, %eax
        ret
        .globl lexer_src_park
lexer_src_park:
        ret
        .globl xlang_sys_read
xlang_sys_read:
        xorl    %eax, %eax
        ret
        .globl xlang_sys_write
xlang_sys_write:
        xorl    %eax, %eax
        ret
        .globl xlang_sys_writev
xlang_sys_writev:
        xorl    %eax, %eax
        ret
        .globl glue_asm_resolve_call_target_module_c_u8_ptr_i32_u8_ptr_i32_ptr_i32_ptr_reti32
glue_asm_resolve_call_target_module_c_u8_ptr_i32_u8_ptr_i32_ptr_i32_ptr_reti32:
        xorl    %eax, %eax
        ret
        .globl glue_asm_mangle_import_binding_call_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_u8_ptr_i32_u8_ptr_i32_i32_u8_ptr_reti32
glue_asm_mangle_import_binding_call_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_u8_ptr_i32_u8_ptr_i32_i32_u8_ptr_reti32:
        xorl    %eax, %eax
        ret
        .globl driver_diagnostic_parse_skip_function
driver_diagnostic_parse_skip_function:
        ret
        .globl codegen_find_impl_method_for_type_u8_ptr_u8_ptr_u8_ptr_i32_i32_reti32
codegen_find_impl_method_for_type_u8_ptr_u8_ptr_u8_ptr_i32_i32_reti32:
        xorl    %eax, %eax
        ret
STUB

AS=as
if command -v x86_64-w64-mingw32-as >/dev/null 2>&1; then
  AS=x86_64-w64-mingw32-as
fi
"$AS" -o "$O" "$S"
[ -s "$O" ] || { echo "win_phase1_hollow_fill: as failed" >&2; exit 1; }

: >"$OUT/phase1_hollow_fill_objs.txt"
echo "$O" >>"$OUT/phase1_hollow_fill_objs.txt"
_nt=$(nm "$O" 2>/dev/null | awk '$2=="T"||$2=="t"' | wc -l | tr -d ' ')
echo "win_phase1_hollow_fill: OK ${_nt} text faces → $O"
