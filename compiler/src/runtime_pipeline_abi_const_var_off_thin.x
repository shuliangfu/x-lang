// Record 211: tip pure overlay — module const VAR has no stack home.
// Force stack_off=-1 when the name is a module *const* (is_const), so
// emit/binop take asm_module_top_level_const_lit_i32 / modlet even if a
// dead non-hoist slot was registered.
//
// DIG s205/s208: tipU pipe_store/load_i32_le cell dance made every VAR do
// O(ntl*vlen) pipe_load_ptr_slot / TL name_byte traffic and hung
// `asm -c std/context/context.x`. Use direct i32 locals (same semantics).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path · WINDOWS DIG.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_module_top_level_let_name_len(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(m: *u8, tl: i32, k: i32): i32;
export extern function pipeline_module_top_level_let_is_const(m: *u8, tl: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * EXPR_VAR stack offset; -1 when unset OR module const name.
 *
 * Walks module top-level lets by name; if a matching const is found,
 * returns -1 so callers use const-lit / modlet paths instead of a
 * stale stack home. Locals are plain i32 (not tipU pipe cells).
 *
 * @param arena AST arena (non-null)
 * @param ctx asm emit context (non-null)
 * @param var_expr_ref EXPR_VAR ref (>0)
 * @return stack off, or -1 when unset / module const / bad args
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  unsafe {
    let name: u8[256];
    let mod: *u8;
    let off: i32;
    let vlen: i32;
    let tl: i32;
    let ntl: i32;
    let tlen: i32;
    let k: i32;
    let matched: i32;
    if (arena == 0 as *u8 || ctx == 0 as *u8 || var_expr_ref <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3) {
      return 0 - 1;
    }
    off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
    if (off < 0) {
      return off;
    }
    vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    if (vlen <= 0 || vlen > 255) {
      return off;
    }
    pipeline_expr_var_name_into(arena, var_expr_ref, &name[0]);
    mod = pipeline_asm_emit_module_ref_c();
    if (mod == 0 as *u8) {
      return off;
    }
    // Module num top-level lets @ +12 (SoA header; SHARED layout).
    ntl = pipe_load_i32_le(mod, 12);
    tl = 0;
    while (tl < ntl) {
      tlen = pipeline_module_top_level_let_name_len(mod, tl);
      if (tlen == vlen) {
        matched = 1;
        k = 0;
        while (k < vlen) {
          if (pipeline_module_top_level_let_name_byte_at(mod, tl, k) != (name[k] as i32)) {
            matched = 0;
            break;
          }
          k = k + 1;
        }
        if (matched != 0) {
          if (pipeline_module_top_level_let_is_const(mod, tl) != 0) {
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
