// 记211: tip pure overlay — module const VAR has no stack home.
// Even if a dead/non-hoist slot was registered, foldable module consts
// must miss stack_off so emit/binop use asm_module_top_level_const_lit_i32.
// tipU: pipe cells. PRODUCT: _g05_pure_overlay first-wins.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function asm_module_top_level_const_lit_i32(m: *u8, a: *u8, name: *u8, nlen: i32, out: *i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;

/**
 * EXPR_VAR stack offset; -1 when unset OR foldable module const.
 * @return i32 — frame offset magnitude, or -1
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  unsafe {
    let cell: u8[32];
    let name: u8[256];
    let imm_cell: u8[8];
    let ko: i32;
    let off: i32;
    let vlen: i32;
    let mod: *u8;
    if (arena == 0 as *u8 || ctx == 0 as *u8 || var_expr_ref <= 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, var_expr_ref));
    if (pipe_load_i32_le(&cell[0], 0) != 3) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell[0], 4, glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref));
    off = pipe_load_i32_le(&cell[0], 4);
    if (off < 0) {
      return off;
    }
    /* Foldable module const → pretend no slot (emit imm). */
    pipe_store_i32_le(&cell[0], 8, pipeline_expr_var_name_len(arena, var_expr_ref));
    vlen = pipe_load_i32_le(&cell[0], 8);
    if (vlen <= 0 || vlen > 255) {
      return off;
    }
    pipeline_expr_var_name_into(arena, var_expr_ref, &name[0]);
    mod = pipeline_asm_emit_module_ref_c();
    if (mod == 0 as *u8) {
      return off;
    }
    pipe_store_i32_le(&cell[0], 12, asm_module_top_level_const_lit_i32(mod, arena, &name[0], vlen, &imm_cell[0] as *i32));
    if (pipe_load_i32_le(&cell[0], 12) != 0) {
      return 0 - 1;
    }
    return off;
  }
}
