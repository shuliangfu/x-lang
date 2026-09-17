// Thin pure: arr_return path a0 (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl authority.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Path A0: INTEGER-class <=8B named struct return local.
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_a0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let rty: i32 = 0;
    let tk: i32 = 0;
    let ret_off: i32 = 0;
    let ret_named_sz: i32 = 0;
    let force_esz: i32 = 0;
    let rc: i32 = 0;
    let _u: i32 = 0;
    _u = sret_act + sret_sz;
    if (_u < (0 - 2000000000)) {
      return 0 - 1;
    }
    if (ko != 3 || (ta != 0 && ta != 1) || mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    rty = pipeline_module_func_return_type_at(mod, fi);
    if (rty <= 0) {
      return 0;
    }
    tk = pipeline_type_kind_ord_at(arena, rty);
    if (tk != 8) {
      return 0;
    }
    ret_named_sz = glue_type_size_simple(mod, arena, rty, 0);
    force_esz = glue_type_named_layout_size_any_module_elf_c(arena, rty);
    if (force_esz > ret_named_sz) {
      ret_named_sz = force_esz;
    }
    if (ret_named_sz > 8) {
      return 0;
    }
    ret_off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, ret_op);
    if (ret_off < 0) {
      ret_off = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op);
    }
    if (ret_off < 0) {
      return 0;
    }
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, ret_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 1;
  }
}
