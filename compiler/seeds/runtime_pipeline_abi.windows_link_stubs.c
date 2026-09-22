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
/* int32_t pipe_modlet_bake_scalar_imm_to_data() { return -1; } — real body in windows_e extras; stubs merge last */
/* int32_t pipeline_asm_emit_assign_elf_c() { return -1; } — real body in windows_e extras; stubs merge last */
int32_t glue_emit_struct_type_let_init_elf_c() { return -2; } /* -2 not-handled: scalar let falls through */
int32_t glue_emit_vector_type_let_init_elf_c() { return -2; } /* -2 not-handled: scalar let falls through */
int32_t pipeline_asm_emit_struct_let_init_elf_c() { return -1; }
int32_t pipeline_asm_emit_struct_lit_elf_c() { return -1; }
int32_t glue_emit_assign_var_elf_c() { return -1; }
int32_t glue_emit_assign_field_elf_c() { return -1; }
int32_t glue_emit_assign_index_elf_c() { return -1; }
int32_t glue_emit_assign_deref_elf_c() { return -1; }
int32_t glue_emit_index_eff_addr_scaled_elf_c() { return -1; }
int32_t glue_try_index_var_or_field_base_to_rax_elf_c() { return -1; }
int32_t glue_try_index_var_or_field_base_to_rbx_elf_c() { return -1; }
int32_t glue_copy_large_struct_from_rax_ptr_elf_c() { return -1; }
/* Win PE egg calls Cap-mangled name; Cap residual body is #ifndef FROM_X.
 * Prior stub returned -1 → fixed-array let init fail → option CG002 after unwrap_or
 * (`let buf: u8[4] = [1,2,3,4]`). Real scalar ARRAY_LIT → stack slot (G.7 twin of
 * pipeline_asm_emit_vector_let_init_elf_c Cap residual). PLATFORM: WINDOWS leftover-PE. */
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t expr_ref, int32_t ai);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(void *a, int32_t expr_ref);
extern int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(void *a, void *elf, int32_t lit,
                                                            int32_t elem, void *ctx, int32_t ta,
                                                            int32_t esz);
extern int32_t glue_expr_emit_may_clobber_rbx_elf_c(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz,
                                                        int32_t ta);
int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t n_arr;
  int32_t esz;
  int32_t store_sz;
  int32_t ai;
  int32_t elem_ref;
  int32_t may_clobber;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr <= 0 || n_arr > 1024)
    return -1;
  /* Nested ARRAY_LIT: leave unhandled (-1) until a product probe needs it. */
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref > 0 && pipeline_expr_kind_ord_at(arena, elem_ref) == 46)
      return -1;
  }
  esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
  if (esz <= 0)
    esz = 4;
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
    store_sz = 4;
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref == 0)
      continue;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
    if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, init_ref, elem_ref, ctx, ta,
                                                    esz) != 0)
      return -1;
    if (may_clobber != 0) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta) != 0)
      return -1;
  }
  return 0;
}
int32_t pipeline_asm_simd_try_inline_splat_call_elf_c() { return -1; }
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
