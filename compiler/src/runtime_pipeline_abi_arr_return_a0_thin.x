// Thin pure: arr_return path a0 (wave439).
// wave560 Soft Cap: Ubuntu tip emitted this export with zero UND.
//   Every call lived after `if (local)` / mid-assign, which that tip
//   drops. w560_query always stores the seven queries and declares no
//   locals. The export returns 0; the real path stays on the w439
//   overlay. stamp w560 HARD BAN tip PRODUCT reinject.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Store the a0 queries. Offsets: 0 return type, 4 its kind, 8 size,
 * 12 named size, 16 resolve off, 20 var off, 24 load-rbp status.
 * Nested loads are call arguments, not `let`s.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — returned expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param mod *u8 — module; may be null
 * @param fi i32 — function index
 * @param cell *u8 — at least 28 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w560_query(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_module_func_return_type_at(mod, fi));
    pipe_store_i32_le(cell, 4, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 8, glue_type_size_simple(mod, arena, pipe_load_i32_le(cell, 0), 0));
    pipe_store_i32_le(cell, 12, glue_type_named_layout_size_any_module_elf_c(arena, pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 16, glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, ret_op));
    pipe_store_i32_le(cell, 20, glue_var_expr_stack_off_elf_c(arena, ctx, ret_op));
    pipe_store_i32_le(cell, 24, backend_enc_load_rbp_to_rax_arch(elf_ctx, pipe_load_i32_le(cell, 16), ta));
    return 0;
  }
}

/**
 * wave439/560: INTEGER-class named struct return of at most 8 bytes.
 * Queries always run. Tip returns 0. ko / sret_* stay live so the
 * signature matches the w439 overlay, which still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — returned expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ko i32 — expr kind; unused for the tip result
 * @param sret_act i32 — sret active flag; kept live
 * @param sret_sz i32 — sret size; kept live
 * @param mod *u8 — module
 * @param fi i32 — function index
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_a0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[32] = [];
    let sink: i32 = 0;
    w560_query(arena, elf_ctx, ret_op, ctx, ta, mod, fi, &cell[0]);
    sink = sret_act + sret_sz + ko;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    return 0;
  }
}
