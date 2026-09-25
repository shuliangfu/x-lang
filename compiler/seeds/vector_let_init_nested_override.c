/**
 * PLATFORM: SHARED tip — nested ARRAY_LIT local let-init.
 *
 * w1023: Cap residual mangled vector_let_init rejects nested ARRAY_LIT
 * elems (kind 46) with -1 → Darwin local `[2][2]T = [[…],[…]]` CG002
 * (code_len=16). Ubuntu short WEAK cold body already routes nested to
 * pipeline_asm_emit_array_lit_flat_elf_c. Twin of cold_L20500 nested
 * arm + Cap residual scalar loop. Exports short + mangled names so
 * Darwin leftover store (calls mangled / stubdead→mangled) and thin
 * callers (short) first-wins the same body.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t expr_ref, int32_t ai);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_array_lit_leaf_elem_byte_sz_c(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_array_lit_flat_elf_c(void *a, void *elf, int32_t init,
                                                     void *ctx, int32_t ta, int32_t off,
                                                     int32_t leaf_esz, int32_t *flat_i);
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

/**
 * ARRAY_LIT → stack slot. Nested rows flatten via array_lit_flat.
 * @return 0 ok; -1 hard fail / not ARRAY_LIT.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · WINDOWS.
 */
static int32_t vector_let_init_nested_body(void *arena, void *elf_ctx, int32_t init_ref,
                                           void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t n_arr;
  int32_t esz;
  int32_t store_sz;
  int32_t ai;
  int32_t elem_ref;
  int32_t may_clobber;
  int32_t has_nested;
  int32_t flat_i;

  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr <= 0 || n_arr > 1024)
    return -1;

  has_nested = 0;
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref > 0 && pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
      has_nested = 1;
      break;
    }
  }
  if (has_nested != 0) {
    /* Twin of cold_L20500 nested arm. PLATFORM: SHARED. */
    esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, init_ref);
    if (esz <= 0)
      esz = 4;
    flat_i = 0;
    return pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                 stack_slot_off, esz, &flat_i);
  }

  /* Cap residual scalar loop (windows_link_stubs twin). */
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

/** Short name — thin / Ubuntu leftover callers. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_vector_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                void *ctx, int32_t ta, int32_t stack_slot_off) {
  return vector_let_init_nested_body(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

/**
 * Mangled Cap residual face — Darwin/Win leftover store calls this
 * (or stubdead → this). PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off) {
  return vector_let_init_nested_body(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

/**
 * Darwin leftover store bl's stubdead (same-TU b→mangled). Tip must
 * own stubdead too or the local branch stays Cap residual -1.
 * PLATFORM: MACOS|DARWIN.
 */
int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32_pabi_stubdead(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off) {
  return vector_let_init_nested_body(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
