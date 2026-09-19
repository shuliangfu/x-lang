// Thin pure: CALL-arg VAR lea-vs-load (wave418 helpers).
// wave608: leftover PREFER smash of glue_call_arg_var_use_lea_not_load_elf_c
//   (sub $0xac8, no endbr64) returned 0 so CALL-arg T[N] used load of the
//   payload (u8[4] bytes 01 02 03 04 as pointer 0x4030201) instead of lea.
//   Darwin overlay already leas. LINUX product path is gcc -E of this thin
//   (HARD BAN PREFER). MACOS stamp-only keep overlay. Do not -E the full
//   fixed_array_copy thin (LINUX XT001 / remaining exports BAN).
// call_arg_lea_query_store always runs the lea-vs-load queries into one
//   byte cell so the export can branch on pipe_load. module_ref is only a
//   call argument. Null-mod short-circuit is tip-approximate.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function asm_local_var_slot_holds_indirect_ptr(arena: *u8, var_ref: i32, mod: *u8, ctx: *u8): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, dst: *u8): void;
export extern function pipeline_module_num_funcs(mod: *u8): i32;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, fi: i32, name: *u8, nlen: i32): i32;
export extern function asm_ctx_scope_block_ref_at(ctx: *u8): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, name: *u8, nlen: i32): i32;
export extern function glue_type_ref_is_named_struct_layout_elf_c(arena: *u8, mod: *u8, ty_ref: i32): i32;
export extern function glue_type_is_fixed_array(arena: *u8, ty_ref: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_ref: i32): i32;

/**
 * Store every lea-vs-load query. Offsets in cell (i32 le):
 *   0 holds-indirect, 4 expr kind, 8 name len, 12 func index, 16 nfuncs,
 *   20 param type, 24 param kind, 28 scope block, 32 resolved-from-scope,
 *   36 resolved type, 40 kind of 32, 44 kind of 36, 48/52 named-struct,
 *   56/60 size_simple, 64/68 named size, 72/76 fixed-array, 80 indirect slot.
 * Even offsets in each pair are the scope-resolved type; odd slots are
 * the expr resolved type. module_ref is passed as an argument.
 * @param arena *u8 — AST arena; may be null
 * @param expr_ref i32 — VAR expr, may be <=0
 * @param ctx *u8 — emit context; may be null
 * @param name *u8 — caller buffer, at least 256 bytes
 * @param cell *u8 — at least 84 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function call_arg_lea_query_store(arena: *u8, expr_ref: i32, ctx: *u8, name: *u8, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, asm_local_var_slot_holds_indirect_ptr(arena, expr_ref, pipeline_asm_emit_module_ref_c(), ctx));
    pipe_store_i32_le(cell, 4, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 8, pipeline_expr_var_name_len(arena, expr_ref));
    pipeline_expr_var_name_into(arena, expr_ref, name);
    pipe_store_i32_le(cell, 12, pipeline_asm_emit_func_index_c());
    pipe_store_i32_le(cell, 16, pipeline_module_num_funcs(pipeline_asm_emit_module_ref_c()));
    pipe_store_i32_le(cell, 20, pipeline_module_func_param_type_ref_for_name(pipeline_asm_emit_module_ref_c(), pipe_load_i32_le(cell, 12), name, pipe_load_i32_le(cell, 8)));
    pipe_store_i32_le(cell, 24, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 20)));
    pipe_store_i32_le(cell, 28, asm_ctx_scope_block_ref_at(ctx));
    pipe_store_i32_le(cell, 32, pipeline_block_resolve_var_type_ref(arena, pipe_load_i32_le(cell, 28), name, pipe_load_i32_le(cell, 8)));
    pipe_store_i32_le(cell, 36, pipeline_expr_resolved_type_ref(arena, expr_ref));
    pipe_store_i32_le(cell, 40, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 32)));
    pipe_store_i32_le(cell, 44, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 48, glue_type_ref_is_named_struct_layout_elf_c(arena, pipeline_asm_emit_module_ref_c(), pipe_load_i32_le(cell, 32)));
    pipe_store_i32_le(cell, 52, glue_type_ref_is_named_struct_layout_elf_c(arena, pipeline_asm_emit_module_ref_c(), pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 56, glue_type_size_simple(pipeline_asm_emit_module_ref_c(), arena, pipe_load_i32_le(cell, 32), 0));
    pipe_store_i32_le(cell, 60, glue_type_size_simple(pipeline_asm_emit_module_ref_c(), arena, pipe_load_i32_le(cell, 36), 0));
    pipe_store_i32_le(cell, 64, glue_type_named_layout_size_any_module_elf_c(arena, pipe_load_i32_le(cell, 32)));
    pipe_store_i32_le(cell, 68, glue_type_named_layout_size_any_module_elf_c(arena, pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 72, glue_type_is_fixed_array(arena, pipe_load_i32_le(cell, 32)));
    pipe_store_i32_le(cell, 76, glue_type_is_fixed_array(arena, pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 80, glue_emit_func_param_is_indirect_array_slot_c(arena, pipeline_asm_emit_module_ref_c(), expr_ref));
    return 0;
  }
}

/**
 * wave418/608: 1 when a CALL-arg VAR should lea the stack payload.
 * call_arg_lea_query_store always runs. Null arena/ctx or expr_ref<=0 returns 0.
 * Named structs lea only when size > 16. A fixed array leas unless the
 * param is an indirect slot. Kind 9 params return 0.
 * @param arena *u8 — ASTArena*; null returns 0
 * @param expr_ref i32 — EXPR_VAR ref
 * @param ctx *u8 — AsmFuncCtx*; null returns 0
 * @return i32 — 1 use lea; 0 use load / unknown
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_call_arg_var_use_lea_not_load_elf_c(arena: *u8, expr_ref: i32, ctx: *u8): i32 {
  unsafe {
    let vname: u8[256] = [];
    let cell: u8[88] = [];
    let go: i32 = 1;
    let decl: i32 = 0;
    let use_resolved: i32 = 0;
    let tk: i32 = 0;
    let named: i32 = 0;
    let sz: i32 = 0;
    let fixed: i32 = 0;
    if (arena == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
      go = 0;
    }
    call_arg_lea_query_store(arena, expr_ref, ctx, &vname[0], &cell[0]);
    if (go == 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 0) != 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 4) != 3) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 8) <= 0 || pipe_load_i32_le(&cell[0], 8) > 255) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 12) >= 0 && pipe_load_i32_le(&cell[0], 12) < pipe_load_i32_le(&cell[0], 16)) {
      if (pipe_load_i32_le(&cell[0], 20) > 0 && pipe_load_i32_le(&cell[0], 24) == 9) {
        return 0;
      }
    }
    decl = pipe_load_i32_le(&cell[0], 32);
    if (pipe_load_i32_le(&cell[0], 28) <= 0) {
      decl = 0;
    }
    if (decl <= 0) {
      decl = pipe_load_i32_le(&cell[0], 36);
      use_resolved = 1;
    }
    if (decl <= 0) {
      return 0;
    }
    tk = pipe_load_i32_le(&cell[0], 40);
    named = pipe_load_i32_le(&cell[0], 48);
    sz = pipe_load_i32_le(&cell[0], 56);
    fixed = pipe_load_i32_le(&cell[0], 72);
    if (use_resolved != 0) {
      tk = pipe_load_i32_le(&cell[0], 44);
      named = pipe_load_i32_le(&cell[0], 52);
      sz = pipe_load_i32_le(&cell[0], 60);
      fixed = pipe_load_i32_le(&cell[0], 76);
    }
    if (tk == 0 || tk == 1 || tk == 2 || tk == 3 || tk == 4 || tk == 5 || tk == 6 || tk == 7 || tk == 9 || tk == 14 || tk == 15) {
      return 0;
    }
    if (named != 0) {
      if (sz <= 0) {
        sz = pipe_load_i32_le(&cell[0], 64);
        if (use_resolved != 0) {
          sz = pipe_load_i32_le(&cell[0], 68);
        }
      }
      if (sz > 16) {
        return 1;
      }
      return 0;
    }
    if (fixed != 0) {
      if (pipe_load_i32_le(&cell[0], 12) >= 0 && pipe_load_i32_le(&cell[0], 80) != 0) {
        return 0;
      }
      return 1;
    }
    return 0;
  }
}
