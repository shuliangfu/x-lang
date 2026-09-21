/*
 * wave745 leftover-gcc sidecar: const_lit only hits `const`, and
 * load_operand VAR-without-slot falls back to emit_expr_elf_fast.
 *
 * G.1 (thin WPO CG002 code_len=0):
 *   Producer: leftover gcc glue_try_binop_load_operand_elf_c, when
 *     glue_var_expr_stack_off_elf_c returns -1, calls
 *     asm_module_top_level_const_lit_i32 and emits mov-imm of the
 *     initializer. That helper did not test is_const, so mutable
 *     `let g: i32 = 0` became `mov w0, #0` in `x >= g`.
 *   Store: file-level let is COMMON/DATA; prepare stores g_aw_pgo_emit_n
 *     correctly (adrp+str). count returns via ldr. at() compared against
 *     the folded init 0 → always -1 → emit_one empty success.
 *   Consumer: mega_loop emit_order_at. Small-file `return g` after store
 *     is green (emit_expr VAR path); `if (x >= g)` is red (binop load).
 *
 * This TU is a strong T first-wins of leftover gcc weak const_lit and
 * load_operand. It does not gcc -E .x, does not PREFER peel_thin,
 * does not ld -r into pabi, does not redefine leftover T (w647).
 * PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS co-path.
 */
#include <stdint.h>

extern int32_t pipeline_module_top_level_let_name_len(void *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_name_byte_at(void *m, int32_t tl, int32_t k);
extern int32_t pipeline_module_top_level_let_init_ref(void *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_is_const(void *m, int32_t tl);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *arena, int32_t expr_ref);

extern int32_t glue_expr_block_transparent_value_ref_at(void *arena, int32_t expr_ref);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern void glue_asm73_evict_cache_if_live_pressure_elf_c(int32_t ta, void *elf_ctx);
extern int32_t glue_binop_var_slot_cache_hit_rbx(void *ctx, int32_t off);
extern int32_t glue_binop_try_reload_spill_off_elf_c(void *elf_ctx, void *ctx, int32_t off,
                                                    int32_t ta, int32_t to_rbx);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t glue_load_f32_var_slot_to_rbx_elf_c(void *elf_ctx, void *arena, void *ctx,
                                                  int32_t expr_ref, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t glue_asm73_var_prefers_stack_spill(int32_t off);
extern int32_t glue_binop_stack_spill_push_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t which);
extern void glue_binop_var_slot_cache_set_ctx_key(void *ctx);
extern void glue_binop_var_slot_cache_set_rbx(void *ctx, int32_t off);
extern int32_t glue_binop_var_slot_cache_hit_rax(void *ctx, int32_t off);
extern int32_t glue_load_f32_var_slot_to_rax_elf_c(void *elf_ctx, void *arena, void *ctx,
                                                  int32_t expr_ref, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern void glue_binop_var_slot_cache_set_rax(void *ctx, int32_t off);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern void glue_binop_var_slot_cache_clear(void);
extern int32_t pipeline_asm_emit_expr_elf_fast(void *arena, void *elf_ctx, int32_t expr_ref,
                                              void *ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_emit_field_access_elf_fast_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                        void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                            int32_t ta);
extern int32_t pipeline_asm_emit_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                            int32_t ta);
extern int32_t glue_expr_is_await_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t glue_expr_is_x_as_cast_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t glue_binop_as_needs_full_emit_elf_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_as_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                            int32_t ta);

/**
 * If module top-level *const* name is an int-lit init, write *out_imm.
 * Mutable `let` with the same init must miss so load_operand can lea+load
 * the global (wave745). Name match on a mutable binding returns 0 without
 * scanning further names (bindings are unique).
 * @param m Module*
 * @param a ASTArena*
 * @param name name bytes
 * @param name_len name length
 * @param out_imm output immediate
 * @return 1 found const, 0 miss
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t asm_module_top_level_const_lit_i32(void *m, void *a, uint8_t *name, int32_t name_len,
                                          int32_t *out_imm) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t init_ref;
  int32_t ntl;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  /* LP64: Module.num_top_level_lets @ offset 12 (leftover twin). */
  ntl = *(int32_t *)((char *)m + 12);
  for (tl = 0; tl < ntl; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k != name_len)
      continue;
    /* wave745: only `const` may fold to an immediate. */
    if (pipeline_module_top_level_let_is_const(m, tl) == 0)
      return 0;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0)
      continue;
    k = pipeline_expr_kind_ord_at(a, init_ref);
    if (k == 0 || k == 2) {
      *out_imm = pipeline_expr_int_val_at(a, init_ref);
      return 1;
    }
  }
  return 0;
}

/**
 * Load one binop operand into rax (to_rbx=0) or rbx (to_rbx=1).
 * VAR without a stack slot: const-lit imm only for `const`; mutable
 * file-level let uses emit_expr_elf_fast (lea+load) then optional
 * rax→rbx. Twin of leftover from_x wave149 + wave745 fallback.
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t glue_try_binop_load_operand_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                         int32_t ta, int32_t to_rbx) {
  int32_t ko;
  int32_t off;
  int32_t vr;
  int32_t base_ref;
  int32_t blk_inner;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -2;
  blk_inner = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
  if (blk_inner > 0)
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, blk_inner, ctx, ta, to_rbx);
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    if (off < 0) {
      uint8_t vname[256];
      int32_t vlen;
      int32_t mod_imm;
      void *mod;
      vlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (vlen <= 0)
        return -2;
      pipeline_expr_var_name_into(arena, expr_ref, vname);
      mod = pipeline_asm_emit_module_ref_c();
      if (mod && asm_module_top_level_const_lit_i32(mod, arena, vname, vlen, &mod_imm) != 0) {
        if (to_rbx != 0) {
          if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, mod_imm, ta) != 0)
            return -1;
        } else {
          if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, mod_imm, ta) != 0)
            return -1;
        }
        return 0;
      }
      /* wave745: mutable file-level let — load the global, do not -2. */
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == -99)
        return -2;
      if (vr != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    glue_asm73_evict_cache_if_live_pressure_elf_c(ta, elf_ctx);
    if (to_rbx != 0) {
      if ((glue_binop_var_slot_cache_hit_rbx(ctx, off) != 0))
        return 0;
      vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 1);
      if (vr < 0)
        return -1;
      if (vr != 0)
        return 0;
      {
        int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
        if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
          if (glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
            return -1;
        } else if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off, ta) != 0) {
          return -1;
        }
      }
      if (glue_asm73_var_prefers_stack_spill(off) != 0) {
        if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 1) != 0)
          return -1;
        glue_binop_var_slot_cache_set_ctx_key(ctx);
        return 0;
      }
      glue_binop_var_slot_cache_set_rbx(ctx, off);
      return 0;
    }
    if ((glue_binop_var_slot_cache_hit_rax(ctx, off) != 0))
      return 0;
    vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 0);
    if (vr < 0)
      return -1;
    if (vr != 0)
      return 0;
    {
      int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
        if (glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
          return -1;
      } else if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0) {
        return -1;
      }
    }
    if (glue_asm73_var_prefers_stack_spill(off) != 0) {
      if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 0) != 0)
        return -1;
      glue_binop_var_slot_cache_set_ctx_key(ctx);
      return 0;
    }
    glue_binop_var_slot_cache_set_rax(ctx, off);
    return 0;
  }
  if (ko == 44) {
    if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
      return -2;
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == -99)
        return -2;
      if (vr != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3)
      return -2;
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr == -99)
      return -2;
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 47) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -2;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 52) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    int32_t await_op;
    await_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (await_op <= 0)
      return -2;
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, await_op, ctx, ta, to_rbx);
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    int32_t op_ref;
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0)
      return -2;
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
      glue_binop_var_slot_cache_clear();
      if (pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, op_ref, ctx, ta, to_rbx);
  }
  return -2;
}
