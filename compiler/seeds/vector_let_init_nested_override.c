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
 *
 * w1513 (终局待办 10.42/10.51): the scalar loop stored every element with
 * store_sz 4 when esz was not 1/2/4/8, so local `[3]P3 = [P3 {..}, ..]`
 * (12 B) and `[2]E = [E {..}, ..]` (16 B) kept only the first 4 bytes of
 * each element, on all three targets. Elements whose size is not a single
 * store now go straight to the element's frame home (x86 home =
 * off - ai*esz, arm64 home = off + ai*esz, same as
 * pipeline_asm_emit_array_lit_flat_elf_c): STRUCT_LIT through
 * pipeline_asm_emit_struct_lit_fields_elf_c, other kinds through the struct
 * let-init; VAR/FIELD/INDEX elements that the let-init declines copy esz
 * bytes from their address into the element.
 * The Win pabi twin in runtime_pipeline_abi.windows_link_stubs.c is not
 * rebuilt (pabi ban); this file links first on all targets (10.26 merge).
 *
 * w2067: Windows and Linux build the short name from
 * src/pabi_vector_let_init_nested_one.x. The mangled name and stubdead
 * forward from their own objects. Do not gcc this file on those paths.
 * Darwin still compiles this C into one object. Do not put the three
 * strong names in one product object (same-.o dual T smashes i32).
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
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf, int32_t imm, int32_t ta);
extern int32_t pipeline_asm_array_lit_elem_type_ref(void *a, int32_t array_lit_expr_ref);
extern int32_t glue_emit_struct_type_let_init_elf_c(void *a, void *elf, int32_t init_ref, void *ctx,
                                                    int32_t ta, int32_t let_ty_ref,
                                                    int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *a, void *elf, int32_t expr_ref,
                                                       void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *a, void *elf, int32_t expr_ref,
                                                       void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf, int32_t slot_off, int32_t sz,
                                                         int32_t ta);

/**
 * w1513: store one element whose size is not 1/2/4/8 bytes.
 * @return 0 stored; 1 not handled here (caller keeps the old path); -1 error.
 * PLATFORM: SHARED — x86 home off-ai*esz, arm64 home off+ai*esz.
 */
static int32_t vector_let_init_wide_elem(void *arena, void *elf_ctx, int32_t elem_ref, void *ctx,
                                         int32_t ta, int32_t stack_slot_off, int32_t esz,
                                         int32_t ai, int32_t elem_ty) {
  int32_t home;
  int32_t ek;
  int32_t st;

  if (ta != 0 && ta != 1)
    return 1;
  if (ta == 1)
    home = stack_slot_off + ai * esz;
  else
    home = stack_slot_off - ai * esz;
  if (home < 0)
    return 1;
  ek = pipeline_expr_kind_ord_at(arena, elem_ref);
  if (ek == 45) {
    /* STRUCT_LIT: fields straight into the element home (emit_expr would
     * build a temp and hand back only rax/x0). */
    return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, elem_ref, ctx, ta, home) != 0
               ? -1
               : 0;
  }
  st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, elem_ty, home);
  if (st == 0)
    return 0;
  if (st == -1)
    return -1;
  if (ek != 3 && ek != 44 && ek != 47)
    return 1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, elem_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  if (ai > 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, -3, esz, ta) != 0 ? -1 : 0;
}

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
  int32_t elem_ty;
  int32_t wide;

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
  elem_ty = 0;
  if (store_sz != esz)
    elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref == 0)
      continue;
    if (store_sz != esz) {
      /* w1513: 12/16/24 B elements (10.42/10.51). PLATFORM: SHARED. */
      wide = vector_let_init_wide_elem(arena, elf_ctx, elem_ref, ctx, ta, stack_slot_off, esz,
                                       ai, elem_ty);
      if (wide == 0)
        continue;
      if (wide < 0)
        return -1;
    }
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
