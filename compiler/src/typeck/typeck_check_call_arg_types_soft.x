// knife256/10.2 Cap tip linked body of typeck_check_call_arg_types.
// The mega scores an INT_LIT as i32. A Vec8i formal (kind 13) therefore
// scores below zero and the checker emits T001, after overload resolve
// has already picked the function. Stamping inside the score would also
// run while pick() compares an i32 overload with a Vec8i overload, and
// the literal would stop preferring i32. This thin stamps only here,
// then calls the demoted checker so the existing score sees equal types.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and Windows.
// The demote step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_call_arg_types__demoted(
  module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_stamp_i32_vector_int_splat(
  arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_dep_ctx_module_at(ctx: *u8, dep: i32): *u8;
export extern "C" function pipeline_module_func_param_type_ref_at(mod: *u8, func_index: i32, param_index: i32): i32;
export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, call_ref: i32, arg_i: i32): i32;
export extern "C" function pipeline_expr_method_call_arg_ref(arena: *u8, call_ref: i32, arg_i: i32): i32;
export extern "C" function typeck_get_dep_return_type_in_caller_arena(from_dep_index: i32,
  dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32;
export extern "C" function pipeline_module_func_set_is_used(module: *u8, fi: i32, is_used: i32): void;

/**
 * Stamp Vec8i formals of an i32 literal chain, then run the old checker.
 * @param module *u8 — caller module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — EXPR_CALL or EXPR_METHOD_CALL; <= 0 defers
 * @param ctx *u8 — dep context; used when the callee is in another module
 * @return i32 — the demoted checker's result
 * A hit writes the formal type onto that argument. The demoted body then
 * scores equal types as 1000. A miss leaves the argument alone, so an
 * i32 formal, a u8 widen, and a float chain keep the old score. Kind 24
 * is not stamped. pick() does not call this function.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_check_call_arg_types(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_method: i32 = 49;
    let fi: i32 = 0;
    let dep: i32 = 0;
    let num_args: i32 = 0;
    let call_kind: i32 = 0;
    let ai: i32 = 0;
    let param_raw: i32 = 0;
    let pty: i32 = 0;
    let mapped: i32 = 0;
    let arg_ref: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let dm: *u8 = 0 as *u8;
    let stamped: i32 = 0;
    if (module == 0 as *u8) {
      return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
    }
    if (arena == 0 as *u8) {
      return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
    }
    if (expr_ref <= 0) {
      return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
    }
    fi = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    if (fi < 0) {
      return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
    }
    call_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (call_kind == ord_method) {
      num_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    } else {
      num_args = pipeline_expr_call_num_args_at(arena, expr_ref);
    }
    dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    /*
     * A same-module call still emits the callee symbol. WPO drops the
     * body when the call sits in a let-init and the file has an import,
     * so the object references an undefined local. is_used is the
     * existing keep bit for a call the graph does not record. An
     * imported callee has dep >= 0 and is not marked here.
     * PLATFORM: SHARED.
     */
    if (dep < 0) {
      pipeline_module_func_set_is_used(module, fi, 1);
    }
    mod = module;
    if (dep >= 0) {
      if (ctx != 0 as *u8) {
        dm = pipeline_dep_ctx_module_at(ctx, dep);
        if (dm != 0 as *u8) {
          mod = dm;
        }
      }
    }
    ai = 0;
    while (ai < num_args) {
      param_raw = pipeline_module_func_param_type_ref_at(mod, fi, ai);
      if (param_raw > 0) {
        arg_ref = 0;
        if (call_kind == ord_method) {
          arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
        } else {
          arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, ai);
        }
        /*
         * A dep formal is an index in the other module's pool. Stamp
         * only the caller-arena copy. A failed map skips the stamp
         * and the demoted score still rejects a real mismatch.
         * PLATFORM: SHARED.
         */
        pty = param_raw;
        if (dep >= 0) {
          mapped = typeck_get_dep_return_type_in_caller_arena(dep, param_raw, arena, ctx);
          if (mapped > 0) {
            pty = mapped;
          } else {
            pty = 0;
          }
        }
        if (arg_ref > 0) {
          if (pty > 0) {
            stamped = typeck_stamp_i32_vector_int_splat(arena, arg_ref, pty);
          }
        }
      }
      ai = ai + 1;
    }
    /*
     * stamped is live so the write is not dropped. The demoted body
     * does not clear a kind-13 resolved type before it scores.
     * PLATFORM: SHARED.
     */
    if (stamped == 1) {
      return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
    }
    return typeck_check_call_arg_types__demoted(module, arena, expr_ref, ctx);
  }
}
