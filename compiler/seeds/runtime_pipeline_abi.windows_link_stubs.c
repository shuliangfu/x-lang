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
/* Prior stub returned -1 → Option STRUCT_LIT (`none_i32` etc) CG002 code_len=12.
 * G.7 twin of leftover_emit_struct_lit_into_parked_rbx + array_lit stack home.
 * PE stubs merge last (last-wins) — real body must live here. PLATFORM: WINDOWS leftover-PE. */
extern void *glue_emit_module_from_ctx(void *ctx);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_expr_struct_lit_value_bytes(void *a, void *m, int32_t expr_ref);
extern int32_t glue_struct_lit_field_store_sz(void *a, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_asm_emit_expr_elf_rec(void *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t pipe_load_i32_le(void *base, int32_t off);
extern void pipe_store_i32_le(void *base, int32_t off, int32_t v);
extern int32_t pipe_asm_ctx_off_next_offset(void);

static int32_t win_emit_struct_lit_fields_into_parked_rbx(void *arena, void *elf_ctx, int32_t lit_ref,
                                                          void *ctx, int32_t ta, int32_t base_off) {
  int32_t nf, fi, iref, foff, fsz, store_off, iko;
  void *mod;
  if (!arena || !elf_ctx || lit_ref <= 0)
    return -1;
  if (base_off < 0 || base_off > 4096)
    return -1;
  mod = glue_emit_module_from_ctx(ctx);
  if (!mod)
    mod = pipeline_asm_emit_module_ref_c();
  nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  if (nf < 0)
    nf = 0;
  if (nf > 64)
    return -1;
  for (fi = 0; fi < nf; fi++) {
    iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi);
    if (iref <= 0)
      return -1;
    foff = 0;
    if (mod)
      foff = pipeline_expr_struct_lit_field_offset_at(arena, mod, lit_ref, fi);
    if (foff < 0)
      foff = 0;
    store_off = foff + base_off;
    if (store_off > 4096)
      return -1;
    iko = pipeline_expr_kind_ord_at(arena, iref);
    if (iko == 45) {
      if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, iref, ctx, ta, store_off) != 0)
        return -1;
      continue;
    }
    fsz = glue_struct_lit_field_store_sz(arena, lit_ref, fi);
    if (fsz <= 0)
      continue;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, iref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (fsz > 8)
      fsz = 8;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, fsz, ta) != 0)
      return -1;
  }
  return 0;
}

int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                 void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t dest_in_rbx;
  int32_t home;
  int32_t nbytes;
  int32_t reserve;
  void *mod;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 45)
    return -1;
  dest_in_rbx = (stack_slot_off == -3) ? 1 : 0;
  home = stack_slot_off;
  mod = glue_emit_module_from_ctx(ctx);
  if (!mod)
    mod = pipeline_asm_emit_module_ref_c();
  nbytes = 0;
  if (mod)
    nbytes = pipeline_expr_struct_lit_value_bytes(arena, mod, expr_ref);
  if (nbytes <= 0)
    nbytes = 8;
  if (nbytes > 4096)
    return -1;
  if (!dest_in_rbx) {
    if (home < 0) {
      reserve = (nbytes + 7) & -8;
      if (reserve < 8)
        reserve = 8;
      home = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
      if ((home % 8) != 0)
        home = ((home + 7) / 8) * 8;
      if (ta == 1) {
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + reserve);
      } else {
        home = home + reserve;
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home);
      }
    }
    if (home < 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, expr_ref, ctx, ta, 0) != 0) {
    (void)backend_enc_pop_rbx_arch(elf_ctx, ta);
    return -1;
  }
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (!dest_in_rbx) {
    /* ≤16B rvalue/return: materialize VALUE into GP regs (not lea pointer).
     * Prior lea left stack addr in rax; Option_i32 is_some read low byte of
     * pointer → none looked like some → tests/option run=-2.
     * Win64 ≤8B aggregate returns in RAX; 9–16B dual-GP matches store_retval
     * pair path used by POSIX/Win fallthrough. >16B keep lea (sret dest ptr).
     * PLATFORM: WINDOWS leftover-PE. */
    if (nbytes <= 8) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
    } else if (nbytes <= 16) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rdx_arch(elf_ctx, home + 8, ta) != 0)
        return -1;
    } else {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_struct_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                          int32_t ta) {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, -1);
}
int32_t glue_emit_assign_var_elf_c() { return -1; }
int32_t glue_emit_assign_field_elf_c() { return -1; }
int32_t glue_emit_assign_index_elf_c() { return -1; }
int32_t glue_emit_assign_deref_elf_c() { return -1; }
/* Cap residual glue_emit_index_eff_addr_scaled is #ifndef FROM_X; windows_e
 * emit_index calls these. Prior stubs returned -1 → option `bp[0]` CG002 after
 * ARRAY_LIT fix. Minimal Win body: eff_addr_base + lit add / scaled rbx.
 * try_* return -2 (not-handled) so Cap/windows_e fallthroughs keep working.
 * PLATFORM: WINDOWS leftover-PE. */
extern int32_t glue_emit_index_eff_addr_base_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                   void *ctx, int32_t ta);
extern int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(void *elf_ctx, int32_t esz, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                     void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)base_ref; (void)ctx; (void)ta;
  return -2;
}
int32_t glue_try_index_var_or_field_base_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                     void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)base_ref; (void)ctx; (void)ta;
  return -2;
}
int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                             int32_t base_ref, int32_t idx_ref, void *ctx,
                                             int32_t ta, int32_t esz) {
  int32_t iko;
  int32_t lit;
  if (!arena || !elf_ctx || !ctx || ix_ref <= 0 || base_ref <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_elf_c(arena, elf_ctx, ix_ref, ctx, ta) != 0)
    return -1;
  iko = pipeline_expr_kind_ord_at(arena, idx_ref);
  if (iko == 0) {
    lit = pipeline_expr_int_val_at(arena, idx_ref);
    if (lit != 0 && esz != 0) {
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, lit * esz, ta) != 0)
        return -1;
    }
    return 0;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}
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
