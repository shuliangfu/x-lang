// Thin pure override: parser EMIT_HEAVY force-stub list.
// w1564: the egg asm_parser_emit_heavy_force_stub also returned 1 for every
// name with prefix copy_onefunc_ (13), onefunc_ (8), or set_onefunc_ (12).
// Those prefixes turned the OneFuncResult helpers into 24-byte ret0 bodies.
// parser_onefunc_scratch_empty was one of them. A throwaway link of this
// list, ahead of the weak egg symbol, emitted those helpers (scratch span
// 212, 23 prefix names grew, parser rc 0, T001 0, CG002 0).
// The six exact names stay. They are the recorded segfault / elf_ec=-1 set
// and must not be batch-moved into asm_parser_emit_heavy_safe_helper.
// asm_skip_heavy_module_func_body calls this symbol on the EMIT_HEAVY
// second pass. g05_relink_env.sh compiles this file with the current
// product and links it ahead of pabi. The egg copy stays weak and is not
// rebuilt. #[no_mangle] keeps the link name bare: this path contains
// "pipeline", and a pipeline_ prefix would miss the egg call.
// PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.

export extern "C" function asm_module_is_parser_emit_heavy(m: *u8): i32;
export extern "C" function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, name_len: i32): i32;

/**
 * Force a 24-byte ret0 stub for six parser helpers that fault when emitted.
 * @param m *u8 — Module*; null returns 0
 * @param func_index i32 — function index; negative returns 0
 * @return i32 — 1 when this function must stay a stub, else 0
 * The onefunc_ / copy_onefunc_ / set_onefunc_ prefix fence is not here.
 * PLATFORM: SHARED — sole linked body; egg weak copy still has the prefixes.
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
    // Recorded segfault / elf_ec=-1. Lengths are the source-name byte counts.
    if (pipeline_module_func_name_equal_at(m, func_index, "wrap_block_ref_as_expr", 22) != 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, "parser_alloc_true_bool_lit", 26) != 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, "parser_alloc_float_lit", 22) != 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, "parser_expr_wrap_in_return", 26) != 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, "try_skip_allow_padding_struct", 29) != 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, func_index, "try_skip_allow_padding_struct_buf", 33) != 0) {
      return 1;
    }
    return 0;
  }
}
