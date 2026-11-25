/* s177 DIG face: tip-faithful AS-over-foldable twin of
 * runtime_pipeline_abi_const_lit_fold_thin.x.
 *
 * Win DIG: replace build_asm/selfhost_pabi/const_lit_fold.o in-place
 * (same G05_OBJS slot as s176) — do NOT early-first-wins a second T
 * (that hung/AV'd check). Exports both tip symbols:
 *   asm_module_top_level_const_lit_i32
 *   pipeline_w211_fold_const_expr_i32
 *
 * UNIQUE: IO_FIXED_MAX = 8 as u32 (EXPR_AS#54) must fold to imm 8.
 * PLATFORM: WINDOWS DIG host-cc twin · SHARED tip fold semantics.
 */
#include <stdint.h>

extern int32_t pipe_load_i32_le(uint8_t *base, int32_t off);
extern void pipe_store_i32_le(uint8_t *base, int32_t off, int32_t v);
extern int32_t pipeline_module_top_level_let_name_len(void *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_name_byte_at(void *m, int32_t tl, int32_t k);
extern int32_t pipeline_module_top_level_let_init_ref(void *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_is_const(void *m, int32_t tl);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *a, int32_t expr_ref);

/**
 * Fold const init to i32 — tip .x w211 twin + EXPR_AS peel.
 * @return 1 folded; 0 miss
 * PLATFORM: SHARED tip semantics via WINDOWS host-cc DIG twin.
 */
int32_t pipeline_w211_fold_const_expr_i32(void *a, int32_t eref, int32_t *out_imm) {
  uint8_t cell[32];
  int32_t ek;
  if (!a || eref <= 0 || !out_imm)
    return 0;
  pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(a, eref));
  ek = pipe_load_i32_le(cell, 0);
  if (ek == 0 || ek == 2) {
    pipe_store_i32_le(cell, 4, pipeline_expr_int_val_at(a, eref));
    pipe_store_i32_le((uint8_t *)out_imm, 0, pipe_load_i32_le(cell, 4));
    return 1;
  }
  /* EXPR_AS = 54 — s177: peel `8 as u32`. */
  if (ek == 54) {
    pipe_store_i32_le(cell, 8, pipeline_expr_as_operand_ref_at(a, eref));
    if (pipe_load_i32_le(cell, 8) <= 0)
      return 0;
    return pipeline_w211_fold_const_expr_i32(a, pipe_load_i32_le(cell, 8), out_imm);
  }
  if (ek == 22) {
    pipe_store_i32_le(cell, 8, pipeline_expr_unary_operand_ref_at(a, eref));
    pipe_store_i32_le(cell, 12, pipeline_expr_kind_ord_at(a, pipe_load_i32_le(cell, 8)));
    if (pipe_load_i32_le(cell, 12) == 0 || pipe_load_i32_le(cell, 12) == 2) {
      pipe_store_i32_le(cell, 16, pipeline_expr_int_val_at(a, pipe_load_i32_le(cell, 8)));
      pipe_store_i32_le(cell, 28, 0 - pipe_load_i32_le(cell, 16));
      pipe_store_i32_le((uint8_t *)out_imm, 0, pipe_load_i32_le(cell, 28));
      return 1;
    }
    return 0;
  }
  if (ek == 5) {
    pipe_store_i32_le(cell, 8, pipeline_expr_binop_left_ref_at(a, eref));
    pipe_store_i32_le(cell, 12, pipeline_expr_binop_right_ref_at(a, eref));
    pipe_store_i32_le(cell, 16, pipeline_expr_kind_ord_at(a, pipe_load_i32_le(cell, 8)));
    pipe_store_i32_le(cell, 20, pipeline_expr_kind_ord_at(a, pipe_load_i32_le(cell, 12)));
    if ((pipe_load_i32_le(cell, 16) == 0 || pipe_load_i32_le(cell, 16) == 2) &&
        (pipe_load_i32_le(cell, 20) == 0 || pipe_load_i32_le(cell, 20) == 2)) {
      pipe_store_i32_le(cell, 24, pipeline_expr_int_val_at(a, pipe_load_i32_le(cell, 8)));
      pipe_store_i32_le(cell, 28, pipeline_expr_int_val_at(a, pipe_load_i32_le(cell, 12)));
      pipe_store_i32_le(cell, 4, pipe_load_i32_le(cell, 24) - pipe_load_i32_le(cell, 28));
      pipe_store_i32_le((uint8_t *)out_imm, 0, pipe_load_i32_le(cell, 4));
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * Tip .x asm_module_top_level_const_lit_i32 twin.
 * @return 1 hit; 0 miss
 * PLATFORM: WINDOWS DIG · SHARED tip semantics.
 */
int32_t asm_module_top_level_const_lit_i32(void *m, void *a, uint8_t *name, int32_t name_len,
                                          int32_t *out_imm) {
  uint8_t cell[32];
  int32_t tl;
  int32_t ntl;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  ntl = pipe_load_i32_le((uint8_t *)m, 12);
  tl = 0;
  while (tl < ntl) {
    pipe_store_i32_le(cell, 0, pipeline_module_top_level_let_name_len(m, tl));
    if (pipe_load_i32_le(cell, 0) == name_len && pipe_load_i32_le(cell, 0) > 0) {
      pipe_store_i32_le(cell, 4, 0);
      while (pipe_load_i32_le(cell, 4) < name_len) {
        pipe_store_i32_le(cell, 8, pipeline_module_top_level_let_name_byte_at(m, tl, pipe_load_i32_le(cell, 4)));
        pipe_store_i32_le(cell, 24, (int32_t)name[pipe_load_i32_le(cell, 4)]);
        if (pipe_load_i32_le(cell, 8) != pipe_load_i32_le(cell, 24))
          break;
        pipe_store_i32_le(cell, 4, pipe_load_i32_le(cell, 4) + 1);
      }
      if (pipe_load_i32_le(cell, 4) == name_len) {
        pipe_store_i32_le(cell, 16, pipeline_module_top_level_let_init_ref(m, tl));
        if (pipe_load_i32_le(cell, 16) > 0) {
          if (pipeline_w211_fold_const_expr_i32(a, pipe_load_i32_le(cell, 16), out_imm) != 0) {
            pipe_store_i32_le(cell, 12, pipeline_module_top_level_let_is_const(m, tl));
            if (pipe_load_i32_le(cell, 12) != 0)
              return 1;
          }
        }
        return 0;
      }
    }
    tl = tl + 1;
  }
  return 0;
}
