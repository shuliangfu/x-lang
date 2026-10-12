#!/bin/bash
# knife256 / 10.2: Darwin L4 true-cold phase1 hollow-fill after 9.1 seed hollow.
#
# After wipe, pabi leaves pipeline/glue/m8 faces U; tip overlays need ./xlang which
# does not exist yet. Ship return-0 asm stubs for the phase1 UNDEF set so pure-ld
# can produce xlang-seed-phase1; build_seed_asm_host may fall back to the phase1
# stub path; g05 tip overlays restore real faces for the product.
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
/* knife256 / 10.2 Darwin phase1 hollow-fill: return-0 stubs for 9.1-hollow U faces.
 * PLATFORM: MACOS arm64 · as only · zero host-cc.
 */
	.text
	.align 2

	.globl _asm_backend_m8_tail_thin_delegate_c_name
_asm_backend_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_driver_m8_tail_thin_delegate_c_name
_asm_driver_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_parser_bootstrap_mega_emit_allowed
_asm_parser_bootstrap_mega_emit_allowed:
	mov	w0, #0
	ret
	.globl _asm_parser_emit_heavy_force_stub
_asm_parser_emit_heavy_force_stub:
	mov	w0, #0
	ret
	.globl _asm_parser_emit_heavy_safe_helper
_asm_parser_emit_heavy_safe_helper:
	mov	w0, #0
	ret
	.globl _asm_parser_func_is_thin_delegate
_asm_parser_func_is_thin_delegate:
	mov	w0, #0
	ret
	.globl _asm_parser_m8_tail_thin_delegate_c_name
_asm_parser_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_pipeline_m8_tail_thin_delegate_c_name
_asm_pipeline_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_typeck_m8_tail_thin_delegate_c_name
_asm_typeck_m8_tail_thin_delegate_c_name:
	mov	w0, #0
	ret
	.globl _asm_wpo_collect_walk
_asm_wpo_collect_walk:
	mov	w0, #0
	ret
	.globl _backend_emit_block_body_sync_elf
_backend_emit_block_body_sync_elf:
	mov	w0, #0
	ret
	.globl _glue_copy_large_struct_from_rax_ptr_elf_c
_glue_copy_large_struct_from_rax_ptr_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_index_eff_addr_scaled_elf_c
_glue_emit_index_eff_addr_scaled_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_struct_type_let_init_elf_c
_glue_emit_struct_type_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _glue_emit_vector_type_let_init_elf_c
_glue_emit_vector_type_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _glue_enc_local_slot_ptr_or_addr_elf_c
_glue_enc_local_slot_ptr_or_addr_elf_c:
	mov	w0, #0
	ret
	.globl _glue_try_index_var_or_field_base_to_rax_elf_c
_glue_try_index_var_or_field_base_to_rax_elf_c:
	mov	w0, #0
	ret
	.globl _glue_try_index_var_or_field_base_to_rbx_elf_c
_glue_try_index_var_or_field_base_to_rbx_elf_c:
	mov	w0, #0
	ret
	.globl _pipe_elf_macho_undef_cap
_pipe_elf_macho_undef_cap:
	mov	w0, #0
	ret
	.globl _pipe_modlet_bake_scalar_imm_to_data
_pipe_modlet_bake_scalar_imm_to_data:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_assign_elf_c
_pipeline_asm_emit_assign_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_block_body_sync_elf
_pipeline_asm_emit_block_body_sync_elf:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_expr_elf_fast
_pipeline_asm_emit_expr_elf_fast:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_expr_elf_for_call_args
_pipeline_asm_emit_expr_elf_for_call_args:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_lvalue_eff_addr_elf_c
_pipeline_asm_emit_lvalue_eff_addr_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_return_elf_impl
_pipeline_asm_emit_return_elf_impl:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_struct_let_init_elf_c
_pipeline_asm_emit_struct_let_init_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_struct_lit_elf_c
_pipeline_asm_emit_struct_lit_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_struct_lit_fields_elf_c
_pipeline_asm_emit_struct_lit_fields_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
_pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32:
	mov	w0, #0
	ret
	.globl _pipeline_asm_index_elem_byte_sz_c
_pipeline_asm_index_elem_byte_sz_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_simd_try_inline_splat_call_elf_c
_pipeline_asm_simd_try_inline_splat_call_elf_c:
	mov	w0, #0
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_at
_pipeline_asm_wpo_pgo_emit_order_at:
	mov	w0, #0
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_count
_pipeline_asm_wpo_pgo_emit_order_count:
	mov	w0, #0
	ret
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare
_pipeline_asm_wpo_pgo_emit_order_prepare:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_common_sym
_pipeline_elf_ctx_add_common_sym:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_label
_pipeline_elf_ctx_add_label:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_add_sym
_pipeline_elf_ctx_add_sym:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_append_data_zeros
_pipeline_elf_ctx_append_data_zeros:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_data_poke_u8
_pipeline_elf_ctx_data_poke_u8:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_emit_data_len
_pipeline_elf_ctx_emit_data_len:
	mov	w0, #0
	ret
	.globl _pipeline_elf_ctx_ensure_label
_pipeline_elf_ctx_ensure_label:
	mov	w0, #0
	ret
	.globl _w499_mega_try_tail_jmp
_w499_mega_try_tail_jmp:
	mov	w0, #0
	ret

	.bss
	.align 3

	.globl _g_pipeline_elf_reloc_r_pcrel
_g_pipeline_elf_reloc_r_pcrel:
	.quad 0
	.globl _g_pipeline_elf_reloc_r_type
_g_pipeline_elf_reloc_r_type:
	.quad 0
	.globl _g_pipeline_elf_reloc_sidecar_owner
_g_pipeline_elf_reloc_sidecar_owner:
	.quad 0
STUB
as -o "$OUT/m8_reloc_stubs.o" "$OUT/m8_reloc_stubs.s"
[ -s "$OUT/m8_reloc_stubs.o" ] || { echo "darwin_phase1_hollow_fill: as failed" >&2; exit 1; }

echo "$OUT/m8_reloc_stubs.o" >"$OUT/phase1_hollow_fill_objs.txt"
echo "darwin_phase1_hollow_fill: OK stubs-only manifest=$OUT/phase1_hollow_fill_objs.txt"
exit 0
