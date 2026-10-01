// Thin pure override: parser EMIT_HEAVY force-stub list.
// w1564: the egg asm_parser_emit_heavy_force_stub also returned 1 for every
// name with prefix copy_onefunc_ (13), onefunc_ (8), or set_onefunc_ (12).
// Those prefixes turned the OneFuncResult helpers into 24-byte ret0 bodies.
// parser_onefunc_scratch_empty was one of them. A throwaway link of this
// list, ahead of the weak egg symbol, emitted those helpers (scratch span
// 212, 23 prefix names grew, parser rc 0, T001 0, CG002 0).
// One exact name stays on this list. Do not batch-move it into
// asm_parser_emit_heavy_safe_helper.
// parser_expr_wrap_in_return left this list in w1577. Its 24-byte body
// returned 0, and parse_into_buf treats that 0 as failure, so a non-void
// explicit return aborted the whole module (fmt dep prerun, num_funcs=0).
// parser_alloc_float_lit left this list in w1579. Its 24-byte body returned
// 0, so `let x: f64 = 1.5; return x as i32` compiled and exited 0.
// parser_alloc_true_bool_lit left this list in w1580. Its 24-byte body
// returned 0, and both `loop` paths abort the function on that 0, so ld
// reports an undefined main. Host-cc of the same program exits 1.
// wrap_block_ref_as_expr left this list in w1581. Its 24-byte body returned
// 0, and a bare block statement aborts the function on that 0, so ld
// reports an undefined main. Host-cc of `{ 10 } return 7` exits 7.
// try_skip_allow_padding_struct left this list in w1582. skip_heavy
// returned 1, then the thin-stub emitter saw the leftover cname row and
// wrote a 24-byte call to parser_try_skip_allow_padding_struct_glue with
// no arguments. The .x body is that glue call with the Lexer and the slice.
// try_skip_allow_padding_struct_buf stays. safe_helper returns 1 for it
// before this list runs, and the probe already emits the 348-byte body.
// asm_skip_heavy_module_func_body calls this symbol on the EMIT_HEAVY
// second pass. g05_relink_env.sh compiles this file with the current
// product and links it ahead of pabi. The egg copy stays weak and is not
// rebuilt. #[no_mangle] keeps the link name bare: this path contains
// "pipeline", and a pipeline_ prefix would miss the egg call.
// PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.

export extern "C" function asm_module_is_parser_emit_heavy(m: *u8): i32;
export extern "C" function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, name_len: i32): i32;

/**
 * Force a 24-byte ret0 stub for parser helpers that fault when emitted.
 * @param m *u8 — Module*; null returns 0
 * @param func_index i32 — function index; negative returns 0
 * @return i32 — 1 when this function must stay a stub, else 0
 * parser_expr_wrap_in_return is intentionally absent. The stub returned 0
 * and parse_into_buf aborted every non-void explicit return on that 0.
 * parser_alloc_float_lit is intentionally absent. The stub returned 0, so
 * a plain f64 literal init was dropped and `1.5 as i32` exited 0.
 * parser_alloc_true_bool_lit is intentionally absent. The stub returned 0,
 * and both loop paths abort the function, so the program has no main.
 * wrap_block_ref_as_expr is intentionally absent. The stub returned 0,
 * and a bare block statement aborts the function on that 0.
 * try_skip_allow_padding_struct is intentionally absent. The stub path
 * emitted an argument-less call to the glue. The .x body passes the
 * Lexer and the slice.
 * try_skip_allow_padding_struct_buf stays. safe_helper emits that body
 * before this function is consulted.
 * The onefunc_ / copy_onefunc_ / set_onefunc_ prefix fence is not here.
 * PLATFORM: SHARED — sole linked body; egg weak copy still lists the old six.
 */
#[no_mangle]
export function asm_parser_emit_heavy_force_stub(m: *u8, func_index: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || func_index < 0) {
      return 0;
    }
    if (asm_module_is_parser_emit_heavy(m) == 0) {
      return 0;
    }
    // Lengths are the source-name byte counts.
    // wrap_block_ref_as_expr is emitted. A ret0 body returns 0, and a
    // bare block statement aborts the function on that 0 (w1581: ld has
    // no main). Host-cc of the same program exits 7.
    // parser_alloc_true_bool_lit is emitted. A ret0 body returns 0, and
    // both loop paths abort the function on that 0 (w1580: ld has no main).
    // parser_alloc_float_lit is emitted. A ret0 body returns 0, and the
    // plain `let x: f64 = 1.5` path stores that 0 as the init (w1579).
    // parser_expr_wrap_in_return is emitted. A ret0 body returns 0, and
    // parse_into_buf treats that 0 as failure (w1577 fmt dep prerun).
    // try_skip_allow_padding_struct is emitted. Returning 1 here made
    // skip_heavy hand the name to the thin-stub emitter, which wrote a
    // 24-byte call to parser_try_skip_allow_padding_struct_glue and did
    // not pass the Lexer or the slice (w1582). The .x body is that call.
    // try_skip_allow_padding_struct_buf stays on this list. safe_helper
    // returns 1 for that name first, so this compare does not run, and
    // the probe body is already 348 bytes.
    if (pipeline_module_func_name_equal_at(m, func_index, "try_skip_allow_padding_struct_buf", 33) != 0) {
      return 1;
    }
    return 0;
  }
}
