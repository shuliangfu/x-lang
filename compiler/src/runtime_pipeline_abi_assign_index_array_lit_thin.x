// Thin pure: INDEX TYPE_ARRAY lit-VAR frame dest (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, arr_ty: i32, depth: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * Lit index + VAR base TYPE_ARRAY INDEX assign via lea+dest-in-rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled; -4 handled-skip (hit set, skip rbx)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_lit_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32 {
  unsafe {
    let ltk: i32 = 0;
    let base_kind: i32 = 0;
    let cmp_lit: i32 = 0;
    let lit_slot: i32[1] = [];
    let lit_imm: i32 = 0;
    let base_off: i32 = 0;
    let nbytes: i32 = 0;
    let elem_home: i32 = 0;
    let rc: i32 = 0;
    let arr_st: i32 = 0;
    ltk = pipeline_type_kind_ord_at(arena, ltr);
    if (ltk != 10) {
      return 0 - 3;
    }
    base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
    if (base_kind != 3) {
      return 0 - 3;
    }
    cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
    if (cmp_lit == 0) {
      return 0 - 3;
    }
    lit_imm = lit_slot[0];
    base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
    nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
    if (nbytes < 8) {
      nbytes = esz;
    }
    if (base_off < 0) {
      return 0 - 3;
    }
    if (nbytes <= 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      elem_home = base_off + lit_imm * nbytes;
    } else {
      elem_home = base_off - lit_imm * nbytes;
    }
    if (elem_home < 0) {
      return 0 - 3;
    }
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, elem_home, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
    if (arr_st == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (arr_st == 0 - 1) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // lit path took lea but let-init fell through (-2): skip rbx twin (hit=1).
    return 0 - 4;
  }
}
