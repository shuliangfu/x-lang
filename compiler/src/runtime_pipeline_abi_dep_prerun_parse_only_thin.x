// Thin: dep prerun parse-only (Darwin Cap tip 10.2).
// After entry parse, Cap tip dep prerun L003s on `//` comments (diag still
// anchored to entry source). Re-anchor lint source, clear sticky lexer
// flags, stash this dep for generics, then mirror rt_ab_step_parse.
// PLATFORM: SHARED · MACOS|DARWIN sidecar.

export extern "C" function lexer_unclosed_block_comment_reset(): void;
export extern "C" function lexer_unclosed_string_reset(): void;
export extern "C" function lexer_illegal_char_reset(): void;
export extern "C" function lexer_incomplete_hex_reset(): void;
export extern "C" function lexer_incomplete_exp_reset(): void;
export extern "C" function lexer_incomplete_bin_reset(): void;
export extern "C" function lexer_incomplete_oct_reset(): void;
export extern "C" function lexer_invalid_digit_sep_reset(): void;
export extern "C" function lexer_invalid_type_suffix_reset(): void;
export extern "C" function lexer_invalid_escape_reset(): void;
export extern "C" function lexer_string_lit_overflow_reset(): void;
export extern "C" function lexer_ident_too_long_reset(): void;
export extern function pipeline_lint_set_source_buf(data: *u8, len: i32): void;
export extern function xlang_trait_reg_reset_c(arena: *u8): void;
export extern function xlang_generic_bound_stash_source_buf_c(data: *u8, len: i32): void;
export extern function parser_parse_into_init(module: *u8, arena: *u8): void;
export extern function driver_parse_into_buf_rc(arena: *u8, module: *u8, data: *u8, len: i32, out_main_idx: *i32): i32;
export extern function pipeline_module_set_main_func_index(module: *u8, main_idx: i32): void;
export extern function pipeline_typeck_patch_all_body_parent_links_c(module: *u8, arena: *u8): void;

#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) { return 0 - 1; }
  if (dep_arena == 0 as *u8) { return 0 - 1; }
  if (src == 0 as *u8) { return 0 - 1; }
  if (len <= 0) { return 0 - 1; }
  if (len > 2147483647) { return 0 - 1; }
  unsafe {
    let len_i32: i32 = len as i32;
    let main_idx: i32 = 0 - 1;
    pipeline_lint_set_source_buf(src, len_i32);
    lexer_unclosed_block_comment_reset();
    lexer_unclosed_string_reset();
    lexer_illegal_char_reset();
    lexer_incomplete_hex_reset();
    lexer_incomplete_exp_reset();
    lexer_incomplete_bin_reset();
    lexer_incomplete_oct_reset();
    lexer_invalid_digit_sep_reset();
    lexer_invalid_type_suffix_reset();
    lexer_invalid_escape_reset();
    lexer_string_lit_overflow_reset();
    lexer_ident_too_long_reset();
    xlang_trait_reg_reset_c(dep_arena);
    xlang_generic_bound_stash_source_buf_c(src, len_i32);
    parser_parse_into_init(dep_mod, dep_arena);
    let pr_ok: i32 = driver_parse_into_buf_rc(dep_arena, dep_mod, src, len_i32, &main_idx);
    if (pr_ok != 0) { return 0 - 1; }
    pipeline_module_set_main_func_index(dep_mod, main_idx);
    pipeline_typeck_patch_all_body_parent_links_c(dep_mod, dep_arena);
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) { return 0 - 1; }
  if (dep_arena == 0 as *u8) { return 0 - 1; }
  if (src == 0 as *u8) { return 0 - 1; }
  if (len <= 0) { return 0 - 1; }
  return xlang_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
}
