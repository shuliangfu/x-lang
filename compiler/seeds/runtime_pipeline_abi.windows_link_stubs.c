/* AUTO: strong Win link stubs for PE-egg phase1.
 * Merge LAST with ld -r --allow-multiple-definition so real bodies win.
 * PE/COFF weak attrs do not satisfy final EXE undefs.
 */
#include <stdint.h>
#include <stddef.h>

const char *asm_backend_m8_tail_thin_delegate_c_name(void) { return ""; }
const char *asm_driver_m8_tail_thin_delegate_c_name(void) { return ""; }
int32_t asm_parser_emit_heavy_safe_helper() { return -1; }
int32_t asm_parser_func_is_thin_delegate() { return -1; }
const char *asm_parser_m8_tail_thin_delegate_c_name(void) { return ""; }
const char *asm_pipeline_m8_tail_thin_delegate_c_name(void) { return ""; }
const char *asm_typeck_m8_tail_thin_delegate_c_name(void) { return ""; }
void asm_wpo_collect_walk(void *a, void *b) { (void)a; (void)b; }
/* glue_copy_large_struct_from_rax_ptr_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_index_eff_addr_scaled_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_struct_type_let_init_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_vector_type_let_init_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_try_index_var_or_field_base_to_rax_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_try_index_var_or_field_base_to_rbx_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* int32_t pipe_modlet_bake_scalar_imm_to_data() { return -1; } — real body in windows_e extras; stubs merge last */
/* int32_t pipeline_asm_emit_assign_elf_c() { return -1; } — real body in windows_e extras; stubs merge last */
/* pipeline_asm_emit_struct_let_init_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* pipeline_asm_emit_struct_lit_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32 — real body in FROM_X/windows_e; stubs merge last */
/* pipeline_asm_simd_try_inline_splat_call_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* Win PE: identity emit-order (was return -1 → mega loop 0× → CG002 empty).
 * Real asm_wpo.from_x may be clobbered by PE ld -r stub merge; these must work. */
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
void pipeline_asm_wpo_pgo_emit_order_prepare(void *m) { (void)m; }
int32_t pipeline_asm_wpo_pgo_emit_order_count(void *m) {
  int32_t nf, fi, n = 0;
  if (!m) return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0)
      n++;
  }
  return n;
}
int32_t pipeline_asm_wpo_pgo_emit_order_at(void *m, int32_t order_index) {
  int32_t nf, fi, n = 0;
  if (!m || order_index < 0) return -1;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0) continue;
    if (n == order_index) return fi;
    n++;
  }
  return -1;
}
/* add_sym/add_label/ensure_label/add_common_sym: NOT stubbed.
 * Stubs merge last and were clobbering elf_ctx.windows_e real bodies
 * → num_syms stayed 0 → COFF .o had .text but no main (WinMain ld fail). */
/* glue_emit_assign_field_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_assign_index_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_assign_var_elf_c — real body in FROM_X/windows_e; stubs merge last */
/* glue_emit_assign_deref_elf_c — real body in FROM_X/windows_e; stubs merge last */
