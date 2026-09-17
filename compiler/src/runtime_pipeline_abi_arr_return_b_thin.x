// Thin pure: arr_return path b (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl authority.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// wave439: early-return flatten — Ubuntu CG002 on nested if (esc==0).

export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, rty: i32, sty: i32, ta: i32): i32;
export extern function glue_try_return_slice_escape_from_fixed_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;

/**
 * Path B: VAR + module — slice escape or emit+float promote.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param ret_op i32 — peeled return operand
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — arch
 * @param ko i32 — operand kind ord
 * @param sret_act i32 — unused (ABI parity with peers)
 * @param sret_sz i32 — unused
 * @param mod *u8 — module
 * @param fi i32 — func index
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_b_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let esc: i32 = 0;
    let rc: i32 = 0;
    let rty: i32 = 0;
    let sty: i32 = 0;
    let _u: i32 = 0;
    _u = sret_act + sret_sz;
    if (_u < (0 - 2000000000)) {
      return 0 - 1;
    }
    if (arena == (0 as *u8) || ctx == (0 as *u8) || elf_ctx == (0 as *u8)) {
      return 0;
    }
    if (ta != 0 && ta != 1) {
      return 0;
    }
    if (ko != 3 || mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    esc = glue_try_return_slice_escape_from_fixed_array_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    if (esc < 0) {
      return 0 - 1;
    }
    // Escape already packed dual-GP — done.
    if (esc != 0) {
      return 1;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rty = pipeline_module_func_return_type_at(mod, fi);
    sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
    rc = glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 1;
  }
}
