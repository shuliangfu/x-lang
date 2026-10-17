// A typed `let f: function(i32): i32 = inc` never loaded the address of
// `inc`. The fast VAR arm only folds module consts; a same-module
// function fell through to a frame slot (the spilled entry register)
// and the call `blr` jumped at that garbage.
// This face runs before that slot load. A local that is not a
// function still uses the previous fast arm.
// PLATFORM: SHARED.

export extern "C" function pipeline_asm_emit_expr_elf_fast_mega(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern "C" function pipeline_asm_emit_module_ref_c(): *u8;
export extern "C" function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern "C" function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;

/**
 * Emit a VAR, or the address of a same-module function.
 * @param arena *u8 — expression pool; null is rejected by the mega
 * @param elf_ctx *u8 — code sink
 * @param expr_ref i32 — expression; EXPR_VAR is kind 3
 * @param ctx *u8 — asm function context; supplies the module
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when a function address was emitted, else the mega result
 * Name buffer is 256 because pipeline_expr_var_name_into clears 256 bytes.
 * A declared local wins, including a local that shadows a function.
 * A name that is not a module function is unchanged.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  // PLATFORM: SHARED — function address before the frame-slot load.
  unsafe {
    let nlen: i32 = 0;
    let fi: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let name: u8[256] = [];
    if (arena != 0 as *u8 && expr_ref > 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 3) {
      nlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (nlen > 0 && nlen <= 255) {
        pipeline_expr_var_name_into(arena, expr_ref, &name[0]);
        mod = 0 as *u8;
        if (ctx != 0 as *u8) {
          mod = glue_emit_module_from_ctx(ctx);
        }
        if (mod == 0 as *u8) {
          mod = pipeline_asm_emit_module_ref_c();
        }
        if (ctx != 0 as *u8) {
          if (glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref) >= 0) {
            return pipeline_asm_emit_expr_elf_fast_mega(arena, elf_ctx, expr_ref, ctx, ta);
          }
        }
        if (mod != 0 as *u8) {
          fi = glue_module_func_index_by_name_c(mod, &name[0], nlen);
          if (fi >= 0) {
            return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &name[0], nlen, ta);
          }
        }
      }
    }
    return pipeline_asm_emit_expr_elf_fast_mega(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
