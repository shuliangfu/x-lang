// Thin pure override: parser EMIT_HEAVY thin-delegate predicate.
// w1565: the egg asm_parser_func_is_thin_delegate walks a 116-row name
// table and returns 1. skip_heavy then emits an 8-byte jmp to the row's
// C glue name. For the glue-tail rows the .x body is already that jmp, so
// a throwaway link of this predicate (return 0, ahead of the weak egg)
// left those 87 jumps byte-identical. The one row that is not a glue tail
// is parser_token_is_label_start: the .x body is the IDENT-then-colon
// check (same algorithm as the C seed), and the egg was replacing it with
// a 24-byte call to parser_token_is_label_start_glue. Returning 0 emitted
// that body (span 448, reloc lexer_lexer_next_into). Every other text
// symbol in the parser object was byte-identical. scratch stayed 212,
// parse_one_function_impl stayed 73092, the four ret0 stubs stayed 24,
// try_skip stayed a 24-byte glue call, try_skip_buf stayed 348, T001 0,
// CG002 0, parser rc 0.
// Do not copy the 116-row table into this file. The egg copy stays weak
// and is not rebuilt. force_stub still runs first, so the six recorded
// segfault / elf_ec=-1 names stay stubbed.
// asm_skip_heavy_module_func_body calls this symbol on the EMIT_HEAVY
// second pass. g05_relink_env.sh compiles this file with the current
// product and links it ahead of pabi. #[no_mangle] keeps the link name
// bare: this path contains "pipeline", and a pipeline_ prefix would miss
// the egg call.
// PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.

export extern "C" function asm_module_is_parser_emit_heavy(m: *u8): i32;

/**
 * Tell skip_heavy not to replace a parser function with a thin-delegate jmp.
 * @param m *u8 — Module*; null returns 0
 * @param func_index i32 — function index; negative returns 0
 * @return i32 — always 0 when the module pointer is live and this is the
 *   parser EMIT_HEAVY module; 0 otherwise too
 * The egg 116-row table is not consulted. Measured effect on parser.x is
 * parser_token_is_label_start only; glue-tail rows already emit the same jmp.
 * PLATFORM: SHARED — sole linked body; egg weak copy still has the table.
 */
#[no_mangle]
export function asm_parser_func_is_thin_delegate(m: *u8, func_index: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || func_index < 0) {
      return 0;
    }
    // Non-parser modules are not in the egg table either. The only caller
    // is already inside asm_module_is_parser_emit_heavy, so this guard does
    // not change the probed parser path: that path still returns 0.
    if (asm_module_is_parser_emit_heavy(m) == 0) {
      return 0;
    }
    return 0;
  }
}
