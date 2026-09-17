// Thin pure: arr_return path c fallback emit+float (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl Path C.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, rty: i32, sty: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;

/**
 * Path C fallback: general ARRAY_LIT emit + float promote.
 * @return i32 — 1 handled ok; -1 error (always attempts when called)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_c_fallback_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let rty: i32 = 0;
    let sty: i32 = 0;
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (mod != (0 as *u8) && fi >= 0) {
      rty = pipeline_module_func_return_type_at(mod, fi);
      sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
      rc = glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta);
      if (rc != 0) {
        return 0 - 1;
      }
    }
    return 1;
  }
}
