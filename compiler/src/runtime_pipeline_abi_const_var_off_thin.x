// 记211: tip pure overlay — module const VAR has no stack home.
// Force stack_off=-1 when the name is a module *const* (is_const), so
// emit/binop take asm_module_top_level_const_lit_i32 / modlet even if a
// dead non-hoist slot was registered. tipU pipe cells.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_module_top_level_let_name_len(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(m: *u8, tl: i32, k: i32): i32;
export extern function pipeline_module_top_level_let_is_const(m: *u8, tl: i32): i32;

/**
 * EXPR_VAR stack offset; -1 when unset OR module const name.
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  unsafe {
    let cell: u8[32];
    let name: u8[256];
    let mod: *u8;
    let off: i32;
    let vlen: i32;
    let tl: i32;
    let ntl: i32;
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
    ntl = pipe_load_i32_le(mod, 12);
    tl = 0;
    while (tl < ntl) {
      pipe_store_i32_le(&cell[0], 12, pipeline_module_top_level_let_name_len(mod, tl));
      if (pipe_load_i32_le(&cell[0], 12) == vlen) {
        pipe_store_i32_le(&cell[0], 16, 0);
        while (pipe_load_i32_le(&cell[0], 16) < vlen) {
          pipe_store_i32_le(&cell[0], 20, pipeline_module_top_level_let_name_byte_at(mod, tl, pipe_load_i32_le(&cell[0], 16)));
          if (pipe_load_i32_le(&cell[0], 20) != (name[pipe_load_i32_le(&cell[0], 16)] as i32)) {
            break;
          }
          pipe_store_i32_le(&cell[0], 16, pipe_load_i32_le(&cell[0], 16) + 1);
        }
        if (pipe_load_i32_le(&cell[0], 16) == vlen) {
          pipe_store_i32_le(&cell[0], 24, pipeline_module_top_level_let_is_const(mod, tl));
          if (pipe_load_i32_le(&cell[0], 24) != 0) {
            return 0 - 1;
          }
          return off;
        }
      }
      tl = tl + 1;
    }
    return off;
  }
}
