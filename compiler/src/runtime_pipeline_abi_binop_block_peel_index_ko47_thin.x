// Thin pure: peel INDEX ko47 rbx-clobber helper (wave435).
// G.7: twin of glue_binop_operand_index_addr_clobbers_rbx_elf_c INDEX arm.
// PRODUCT: LINUX PREFER with index_addr main; co-file walker → Ubuntu XT001.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_index_base_is_slice_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;

/**
 * INDEX (ko==47) rbx-clobber decision.
 * @param arena *u8 — ASTArena*
 * @param expr_ref i32 — INDEX expr
 * @return i32 — 1 if INDEX emit parks rbx; 0 if base+imm*esz path
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_ko47_clobbers_rbx(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let lit_imm: i32 = 0;
    let idx_ref: i32 = 0;
    let base_ref: i32 = 0;
    let base_ty: i32 = 0;
    let base_ko: i32 = 0;
    let fa_base: i32 = 0;
    let fa_ko: i32 = 0;
    if (pipeline_expr_index_base_is_slice_at(arena, expr_ref) != 0) {
      return 1;
    }
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    if (base_ref > 0) {
      base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == 11) {
        return 1;
      }
      base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
      if (base_ko == 46 || base_ko == 45 || base_ko == 48 || base_ko == 49) {
        return 1;
      }
      if (base_ko == 47) {
        return 1;
      }
      if (base_ko == 44) {
        fa_base = pipeline_expr_field_access_base_ref(arena, base_ref);
        if (fa_base > 0) {
          fa_ko = pipeline_expr_kind_ord_at(arena, fa_base);
          if (fa_ko == 46 || fa_ko == 45 || fa_ko == 48 || fa_ko == 49 || fa_ko == 47) {
            return 1;
          }
        }
      }
    }
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    if (idx_ref > 0 && (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_imm) != 0)) {
      return 0;
    }
    return 1;
  }
}
