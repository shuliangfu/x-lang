/* AUTO: strong Win link stubs for PE-egg phase1.
 * Merge LAST with ld -r --allow-multiple-definition so real bodies win.
 * PE/COFF weak attrs do not satisfy final EXE undefs.
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

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
/* Real CALL/METHOD/STRUCT_LIT let-init (stub was return -2 → bare store_rax
 * dropped Option_ptr rdx half → tests/option -16). PLATFORM: WINDOWS leftover-PE. */
extern int32_t glue_call_return_byte_size_c(void *arena, int32_t call_expr_ref);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t v);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf, int32_t k, int32_t ta);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                              int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref,
                                                                    void *ctx, int32_t ta, int32_t stack_slot_off);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);

int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                             int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  int32_t inl;
  int32_t emit_rc;
  int32_t call_ret_sz;
  int32_t let_sz;
  int32_t named_sz;
  int32_t best;
  int32_t dest_in_rbx;
  void *modp;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  dest_in_rbx = (stack_slot_off == -3) ? 1 : 0;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 45) {
    /* STRUCT_LIT: leave to existing twin / fallthrough (pipeline_asm_emit_struct_let_init Class U real) */
    return -2;
  }
  if (ko == 48 || ko == 49) {
    if (!dest_in_rbx) {
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
    }
    pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref > 0 ? let_ty_ref : 0);
    call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
    if (call_ret_sz <= 16 && let_ty_ref > 0) {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, let_ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
      best = let_sz;
      if (named_sz > best)
        best = named_sz;
      if (best > call_ret_sz)
        call_ret_sz = best;
    }
    if (call_ret_sz > 16 && ta == 0 && !dest_in_rbx) {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return emit_rc != 0 ? -1 : 0;
    }
    emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    if (dest_in_rbx)
      return -2;
    modp = glue_emit_module_from_ctx(ctx);
    if (glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx) != 0)
      return -1;
    return 0;
  }
  return -2;
}
/* wave773 Class X: was empty stub return -2. Twin of FROM_X glue_emit_vector_type_let_init
 * (ARRAY_LIT→mangled vector_let_init; VAR/binop/splat/binop2). select/shuffle/fma3 absent
 * on Win PE leftover — leave -2. PLATFORM: WINDOWS leftover-PE. */
extern int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_vector_var_copy_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                       void *ctx, int32_t ta, int32_t stack_slot_off,
                                                       int32_t type_ref);
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
extern int32_t pipeline_asm_emit_vector_binop_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                            void *ctx, int32_t ta, int32_t stack_slot_off,
                                                            int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                             int32_t ta, int32_t stack_slot_off, int32_t type_ref) {
  int32_t ko;
  int32_t inl;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || !asm_type_is_simd_vector_spelling(arena, type_ref))
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 46)
    return pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 3)
    return pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off,
                                                   type_ref);
  if (glue_is_vector_lane_scalar_binop_ko(ko))
    return pipeline_asm_emit_vector_binop_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
  /* CALL=48 / METHOD_CALL=49 — Class Y: wire select/shuffle/fma3 */
  if (ko == 48 || ko == 49) {
    inl = pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_select_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_shuffle_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_fma3_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                       stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_binop2_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
  }
  return -2;
}
/* Class U: pipeline_asm_emit_struct_let_init_elf_c defined after struct_lit_fields below. */
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
    /* value_bytes can under-report (Option_ptr: 8 while fields land at +8).
     * Raise nbytes from field ends so 16B returns load RAX+RDX. */
    {
      int32_t nf2, fi2, foff2, fsz2, end2;
      nf2 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      if (nf2 < 0)
        nf2 = 0;
      for (fi2 = 0; fi2 < nf2 && fi2 < 64; fi2++) {
        foff2 = 0;
        if (mod)
          foff2 = pipeline_expr_struct_lit_field_offset_at(arena, mod, expr_ref, fi2);
        if (foff2 < 0)
          foff2 = 0;
        fsz2 = glue_struct_lit_field_store_sz(arena, expr_ref, fi2);
        if (fsz2 <= 0)
          continue;
        if (fsz2 > 8)
          fsz2 = 8;
        end2 = foff2 + fsz2;
        if (end2 > nbytes)
          nbytes = end2;
      }
    }
    /* ≤16B rvalue/return: materialize VALUE into GP regs (not lea pointer).
     * Win64 ≤8B in RAX; 9–16B dual-GP. >16B keep lea (sret).
     * PLATFORM: WINDOWS leftover-PE. */
    if (nbytes <= 8) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
    } else if (nbytes <= 16) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta) != 0)
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

/* wave770 Class U: STRUCT_LIT let-init was return -1; forward to fields body.
 * Twin of FROM_X thin wrapper. PLATFORM: WINDOWS leftover-PE. */
int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                               void *ctx, int32_t ta, int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

/* VAR assign: real leftover body (was return -1 → si/if-assign CG002).
 * FIELD/INDEX/DEREF still stub until their windows_e peers land; si uses VAR dest.
 * PLATFORM: WINDOWS leftover-PE. Full twin: seeds/win_assign_var_override.c */
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);

int32_t glue_emit_assign_var_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                  int32_t right_ref, void *ctx, int32_t ta) {
  int32_t off;
  int32_t ltr;
  int32_t ltk;
  int32_t ako;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  if (off < 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ako != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
  if (ltk == 11) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
      return -1;
  } else if (ltr > 0 && ltk == 14) {
    if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
  } else if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta,
                                                right_ref, ctx) != 0) {
    return -1;
  }
  return 0;
}
/* wave767 Class R: FIELD assign real scalar path (was return -1).
 * Twin of LINUX assign_field_scalar_thin: RHS→rax, push, lvalue→rbx, pop,
 * store indirect by field load_sz. Class T: INDEX/DEREF scalar too.
 * PLATFORM: WINDOWS leftover-PE. */
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                       void *ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t pipeline_expr_field_access_load_byte_sz(void *arena, void *mod, int32_t expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);

int32_t glue_emit_assign_field_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  sz = pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref);
  if (sz <= 0)
    sz = 8;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
/* wave768 Class T: INDEX/DEREF assign real scalar (was return -1).
 * Twin of FIELD scalar: RHS→rax, push, lvalue→rbx, pop, store indirect.
 * INDEX esz via pipeline_asm_index_elem_byte_sz_c; DEREF via type width.
 * PLATFORM: WINDOWS leftover-PE. */
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr);

int32_t glue_emit_assign_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  sz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
  if (sz <= 0)
    sz = 8;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}

int32_t glue_emit_assign_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  int32_t tr;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, left_ref);
  sz = (tr > 0) ? glue_index_elem_byte_sz_from_type_ref_c(arena, tr) : 0;
  if (sz <= 0)
    sz = 4;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
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
/* wave771 Class V: was return -1. Seed twin of FROM_X glue_copy_large_struct
 * (memcpy via arg_reg 0/1/2 — Win64 enc maps rcx/rdx/r8). PLATFORM: WINDOWS leftover-PE. */
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *sym, int32_t sym_len, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t glue_arm64_mov_x19_to_x0_elf_c(void *elf_ctx);

int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off, int32_t sz, int32_t ta) {
  uint8_t memcpy_sym[8];
  memcpy_sym[0] = 109;
  memcpy_sym[1] = 101;
  memcpy_sym[2] = 109;
  memcpy_sym[3] = 99;
  memcpy_sym[4] = 112;
  memcpy_sym[5] = 121;
  memcpy_sym[6] = 0;
  if (!elf_ctx || (ta != 0 && ta != 1) || sz < 8)
    return -1;
  if (sz <= 16 && slot_off != -3)
    return -1;
  if (slot_off == -3) {
    if (ta == 1) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
        return -1;
      if (glue_arm64_mov_x19_to_x0_elf_c(elf_ctx) != 0)
        return -1;
      return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (ta == 1) {
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
}
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
/* wave772 Class W: was return -1 (false error). Twin of FROM_X try_inline splat.
 * Returns 1 inlined / 0 no-match / -1 err. PLATFORM: WINDOWS leftover-PE. */
static int32_t win_glue_simd_callee_is_splat_c(const uint8_t *cname, int32_t clen) {
  if (!cname || clen <= 0)
    return 0;
  if (clen == 5 && memcmp(cname, "splat", 5) == 0)
    return 1;
  if (clen == 10 && memcmp(cname, "simd_splat", 10) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec8i_splat", 11) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec4f_splat", 11) == 0)
    return 1;
  return 0;
}
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref);
extern int32_t glue_call_callee_func_name_into_c(void *a, int32_t callee_ref, uint8_t *out, int32_t cap);
extern int32_t glue_vector_type_lanes_esz_c(void *a, int32_t type_ref, int32_t *out_lanes, int32_t *out_esz);
extern int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t glue_simd_emit_imm_fill_slot_c(void *elf, int32_t slot, int32_t lanes, int32_t esz, int32_t ta, int32_t imm);
extern int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi);
extern int32_t pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref);
extern int32_t glue_emit_float_lit_to_rax_elf_c(void *a, void *elf, int32_t expr_ref, int32_t ta, int32_t a4, int32_t a5);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);

int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref, clen, arg0, lanes, esz, ko, nargs, is_method, imm, store_sz, li;
  uint8_t cname[256];
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  nargs = is_method ? pipeline_expr_method_call_num_args_at(arena, call_ref)
                    : pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 1)
    return 0;
  if (is_method) {
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  if (!win_glue_simd_callee_is_splat_c(cname, clen))
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  arg0 = is_method ? pipeline_expr_method_call_arg_ref(arena, call_ref, 0)
                   : pipeline_expr_call_arg_ref(arena, call_ref, 0);
  if (arg0 <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arg0);
  if (ko == 0 || ko == 2) {
    imm = pipeline_expr_int_val_at(arena, arg0);
    if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
      return -1;
    return 1;
  }
  if (ko == 1) {
    if (esz == 4) {
      imm = glue_ieee_f64_bits_to_f32_bits(pipeline_expr_float_bits_lo_at(arena, arg0),
                                          pipeline_expr_float_bits_hi_at(arena, arg0));
      if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
        return -1;
      return 1;
    }
    if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, arg0, ta, 0, 0) != 0)
      return -1;
    store_sz = esz;
    if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
      store_sz = 4;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    for (li = 0; li < lanes; li++) {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * store_sz, store_sz, ta) != 0)
        return -1;
    }
    return 1;
  }
  return 0;
}
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

/* Class Y deps for select/shuffle/fma3 twins in this TU */
extern char *link_abi_getenv(const char *name);
extern int32_t glue_peel_comptime_array_lit_mask_c(void *arena, void *ctx, int32_t mask_ref);
extern int32_t glue_asm_local_var_stack_off_scoped(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_shuffle_pshufd_imm8_from_mask_c(void *arena, int32_t mask_ref, int32_t lanes, int32_t *out_imm8);
extern uint32_t glue_simd_emit_cpu_features_c(void);
extern uint32_t xlang_target_cpu_detect_host(void);
extern int32_t simd_enc_try_pshufd_rbp(void *elf, int32_t src, int32_t dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_shuffle_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t src_ref, int32_t mask_lit,
                                                          int32_t dst_off, int32_t type_ref, void *ctx, int32_t ta);
extern int32_t glue_simd_expr_splat_int_imm_c(void *arena, int32_t expr_ref, int32_t *out_imm);
extern int32_t glue_simd_select_arg_stack_off_c(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t arg_ref,
                                                int32_t type_ref);
extern int32_t glue_vector_elem_is_f32_c(void *arena, int32_t type_ref);
extern int32_t simd_enc_try_hw_vector_select_rbp(void *elf, int32_t m, int32_t a, int32_t b, int32_t d, int32_t lanes,
                                                  int32_t is_f32, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_select_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t mask_ref, int32_t a_ref,
                                                         int32_t b_ref, int32_t dst_off, int32_t type_ref, void *ctx,
                                                         int32_t ta);
extern int32_t glue_callee_is_vec4f_fma3_c(uint8_t *cname, int32_t clen);
extern int32_t simd_enc_try_hw_vector_fma_rbp(void *elf, int32_t a, int32_t b, int32_t c, int32_t d, int32_t lanes,
                                               int32_t esz, int32_t ta, uint32_t feats);

int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena,
                                                       void *elf_ctx, int32_t call_ref,
                                                       void *ctx, int32_t ta,
                                                       int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg0;
  int32_t arg1;
  int32_t mask_lit;
  int32_t lanes;
  int32_t esz;
  int32_t src_off;
  int32_t imm8;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.shuffle is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 2)
    return 0;
  if (is_method) {
    /* Method name lives on METHOD_CALL node (not FIELD callee). */
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  expect_lanes = 0;
  if (clen == 13 && memcmp(cname, "vec4f_shuffle", 13) == 0)
    expect_lanes = 4;
  else if (clen == 13 && memcmp(cname, "vec8i_shuffle", 13) == 0)
    expect_lanes = 8;
  else if (clen == 12 && memcmp(cname, "simd_shuffle", 12) == 0)
    expect_lanes = 0;
  else if (clen == 7 && memcmp(cname, "shuffle", 7) == 0)
    /* import METHOD bare name: simd.shuffle → "shuffle". */
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
  }
  if (arg0 <= 0 || arg1 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3)
    return 0;
  mask_lit = glue_peel_comptime_array_lit_mask_c(arena, ctx, arg1);
  if (mask_lit <= 0)
    return 0;
  src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  if (src_off < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    if (glue_shuffle_pshufd_imm8_from_mask_c(arena, mask_lit, lanes, &imm8) == 0) {
      feats = glue_simd_emit_cpu_features_c();
      if (feats == 0)
        feats = xlang_target_cpu_detect_host();
      if (simd_enc_try_pshufd_rbp(elf_ctx, src_off, stack_slot_off, imm8, lanes, ta, feats) == 0)
        return 1;
    }
  }
  if (glue_emit_vector_shuffle_lane_scalar_elf_c(arena, elf_ctx, arg0, mask_lit, stack_slot_off, type_ref, ctx, ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena,
                                                      void *elf_ctx, int32_t call_ref,
                                                      void *ctx, int32_t ta,
                                                      int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg_m;
  int32_t arg_a;
  int32_t arg_b;
  int32_t lanes;
  int32_t esz;
  int32_t off_m;
  int32_t off_a;
  int32_t off_b;
  int32_t is_f32;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 3)
    return 0;
  if (is_method) {
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  expect_lanes = 0;
  if (clen == 12 && memcmp(cname, "vec4f_select", 12) == 0)
    expect_lanes = 4;
  else if (clen == 12 && memcmp(cname, "vec8i_select", 12) == 0)
    expect_lanes = 8;
  else if (clen == 11 && memcmp(cname, "simd_select", 11) == 0)
    expect_lanes = 0;
  else if (clen == 6 && memcmp(cname, "select", 6) == 0)
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg_m = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg_m = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg_m <= 0 || arg_a <= 0 || arg_b <= 0)
    return -1;
  /* Comptime-uniform mask: select(splat(k), a, b) → a if k!=0 else b.
   * Product select_lane is mask!=0 ? a : b. Avoids two splat sret + select.
   * PLATFORM: SHARED — fold before any temp emit. */
  {
    int32_t mask_imm;
    int32_t pick;
    int32_t pko;
    if (glue_simd_expr_splat_int_imm_c(arena, arg_m, &mask_imm)) {
      pick = (mask_imm != 0) ? arg_a : arg_b;
      pko = pipeline_expr_kind_ord_at(arena, pick);
      if (pko == 3) {
        if (pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                    type_ref) != 0)
          return -1;
        return 1;
      }
      if (pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                        type_ref) == 1)
        return 1;
      return 0;
    }
  }
  off_m = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_m, type_ref);
  off_a = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_a, type_ref);
  off_b = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_b, type_ref);
  if (off_m < 0 || off_a < 0 || off_b < 0)
    return 0;
  is_f32 = glue_vector_elem_is_f32_c(arena, type_ref);
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    feats = glue_simd_emit_cpu_features_c();
    if (feats == 0)
      feats = xlang_target_cpu_detect_host();
    if (simd_enc_try_hw_vector_select_rbp(elf_ctx, off_m, off_a, off_b, stack_slot_off, lanes, is_f32, ta, feats) == 0)
      return 1;
  }
  /* Lane-scalar fallback still requires IDENT args (expr refs, not temps). */
  if (pipeline_expr_kind_ord_at(arena, arg_m) != 3 || pipeline_expr_kind_ord_at(arena, arg_a) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg_b) != 3)
    return 0;
  if (glue_emit_vector_select_lane_scalar_elf_c(arena, elf_ctx, arg_m, arg_a, arg_b, stack_slot_off, type_ref, ctx,
                                                ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena,
                                                     void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t arg0;
  int32_t arg1;
  int32_t arg2;
  int32_t lanes;
  int32_t esz;
  int32_t off_a;
  int32_t off_b;
  int32_t off_c;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.fma is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49);
  if (is_method) {
    if (pipeline_expr_method_call_num_args_at(arena, call_ref) != 3)
      return 0;
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 3)
      return 0;
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
  }
  if (clen <= 0 || glue_callee_is_vec4f_fma3_c(cname, clen) == 0)
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (lanes != 4 || esz != 4 || glue_vector_elem_is_f32_c(arena, type_ref) == 0)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg0 <= 0 || arg1 <= 0 || arg2 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3 || pipeline_expr_kind_ord_at(arena, arg1) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg2) != 3)
    return 0;
  off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, arg1);
  off_c = glue_asm_local_var_stack_off_scoped(arena, ctx, arg2);
  if (off_a < 0 || off_b < 0 || off_c < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (hw_env && hw_env[0] == '0')
    return 0;
  feats = glue_simd_emit_cpu_features_c();
  if (feats == 0)
    feats = xlang_target_cpu_detect_host();
  if (simd_enc_try_hw_vector_fma_rbp(elf_ctx, off_a, off_b, off_c, stack_slot_off, lanes, esz, ta, feats) == 0)
    return 1;
  return 0;
}
