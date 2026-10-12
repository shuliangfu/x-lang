// 记211: tip call_arg_resolve — const_lit fold first → -1 (Cap emit mov-imm).
// tipU pipe cells. PRODUCT: _g05_pure_overlay first-wins.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function asm_module_top_level_const_lit_i32(m: *u8, a: *u8, name: *u8, nlen: i32, out: *i32): i32;

#[no_mangle]
export function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  unsafe {
    let cell: u8[32];
    let name: u8[256];
    let imm_cell: u8[8];
    let mod: *u8;
    let vlen: i32;
    if (arena == 0 as *u8 || ctx == 0 as *u8 || var_expr_ref <= 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, var_expr_ref));
    if (pipe_load_i32_le(&cell[0], 0) != 3) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell[0], 8, pipeline_expr_var_name_len(arena, var_expr_ref));
    vlen = pipe_load_i32_le(&cell[0], 8);
    if (vlen > 0 && vlen <= 255) {
      pipeline_expr_var_name_into(arena, var_expr_ref, &name[0]);
      mod = pipeline_asm_emit_module_ref_c();
      if (mod != 0 as *u8) {
        pipe_store_i32_le(&cell[0], 12, asm_module_top_level_const_lit_i32(mod, arena, &name[0], vlen, &imm_cell[0] as *i32));
        if (pipe_load_i32_le(&cell[0], 12) != 0) {
          return 0 - 1;
        }
      }
    }
    pipe_store_i32_le(&cell[0], 4, glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref));
    return pipe_load_i32_le(&cell[0], 4);
  }
}
