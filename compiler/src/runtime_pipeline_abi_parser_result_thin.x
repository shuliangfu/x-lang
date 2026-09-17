// Thin pure: wave329 M2 — parser_result Cap residual C→.x (was wave287 C thin).
// slice/lex copy sidecars + onefunc/extern/library/try_skip + collect_imports.
// G.7: bodies match deleted C thin / seed WAVE287_PARSER_RESULT_ALWAYS.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_parser_result_thin
// (ALLOW_E_REPLACE + stamp). Local LE layout structs (Lexer/Token/…).
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.

/** LP64 product Lexer — match seed ALWAYS / C thin. */
allow(padding) struct Lexer {
  pos: usize;
  line: i32;
  col: i32;
}

/** LP64 product Token (LexerResult embed). */
allow(padding) struct Token {
  kind: i32;
  line: i32;
  col: i32;
  int_val: i64;
  float_val: f64;
  ident: *u8;
  ident_len: i32;
}

/** LP64 product LexerResult. */
allow(padding) struct LexerResult {
  next_lex: Lexer;
  tok: Token;
  token_start: usize;
}

/** LP64 product CollectImportsResult. */
allow(padding) struct CollectImportsResult {
  lex: Lexer;
}

/**
 * LP64 product OneFuncResult — full field order for by-value / ptr ABI.
 * PLATFORM: SHARED
 */
allow(padding) struct OneFuncResult {
  ok: i32;
  next_lex: Lexer;
  name: u8[256];
  name_len: i32;
  num_params: i32;
  num_generic_params: i32;
  num_consts: i32;
  num_lets: i32;
  has_if_expr: i32;
  if_cond_true: i32;
  if_then_val: i32;
  if_else_val: i32;
  if_cond_expr_ref: i32;
  has_mul: i32;
  mul_right_val: i32;
  has_binop: i32;
  binop_right_val: i32;
  binop_left_param_idx: i32;
  binop_right_param_idx: i32;
  has_unary_neg: i32;
  return_val: i32;
  has_call_expr: i32;
  call_callee_name: u8[256];
  call_callee_len: i32;
  return_var_name: u8[256];
  return_var_name_len: i32;
  return_expr_ref: i32;
  has_final_expr: i32;
  has_explicit_return_kw: i32;
  call_num_args: i32;
  num_loops: i32;
  num_for_loops: i32;
  num_if_stmts: i32;
  num_src_stmt_order: i32;
  num_src_body_expr_stmts: i32;
  func_return_type_ref: i32;
  is_variadic: i32;
}

/** LP64 product ExternParseResult. */
allow(padding) struct ExternParseResult {
  next_lex: Lexer;
  name: u8[256];
  name_len: i32;
  return_ty_ref: i32;
  num_params: i32;
  abi_kind: i32;
  is_variadic: i32;
}

/** LP64 product TrySkipAllowResult. */
allow(padding) struct TrySkipAllowResult {
  lex: Lexer;
  skipped: i32;
  _pad: u8[4];
}

/** LP64 product LibraryParseResult. */
allow(padding) struct LibraryParseResult {
  ok: i32;
  _pad: u8[4];
  next_lex: Lexer;
  name: u8[256];
  name_len: i32;
  _pad_tail: u8[4];
}

/**
 * Fat u8 slice — layout match xlang_slice_uint8_t { data, length }.
 * PLATFORM: SHARED
 */
allow(padding) struct SliceU8 {
  data: *u8;
  length: usize;
}

export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern function pipeline_module_fill_u8_64_from_src_c(dst: *u8, src: *u8, n: i32, src_cap: i32): void;
export extern function lexer_init(): Lexer;
export extern function parser_collect_imports_buf(lex: Lexer, data: *u8, len: i32, module: *u8, out: *CollectImportsResult): void;

/**
 * Build fat u8 slice from buffer pointer + length (clamp negative len to 0).
 * PLATFORM: SHARED
 */
export function parser_slice_from_buf(data: *u8, len: i32): SliceU8 {
  let n: usize = 0 as usize;
  if (len >= 0) { n = len as usize; }
  return SliceU8{ data: data, length: n };
}

/**
 * Byte offset before a run ending at end_pos.
 * PLATFORM: SHARED
 */
export function parser_lexer_pos_before(end_pos: usize, run_len: i32): usize {
  if (run_len <= 0) { return end_pos; }
  return end_pos - (run_len as usize);
}

/**
 * Alias of parser_slice_from_buf (lexer-facing name).
 * PLATFORM: SHARED
 */
export function lexer_parser_slice_from_buf(data: *u8, len: i32): SliceU8 {
  return parser_slice_from_buf(data, len);
}

/**
 * Copy next_lex from LexerResult pointer into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_lexer_result_ptr_into(out: *Lexer, r: *LexerResult): void {
  if (out == (0 as *Lexer) || r == (0 as *LexerResult)) { return; }
  unsafe { (*out).pos = (*r).next_lex.pos; }
  unsafe { (*out).line = (*r).next_lex.line; }
  unsafe { (*out).col = (*r).next_lex.col; }
}

/**
 * Copy lex from CollectImportsResult by value into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_copy_from_collect_imports(out: *Lexer, res: CollectImportsResult): void {
  if (out == (0 as *Lexer)) { return; }
  unsafe { (*out).pos = res.lex.pos; }
  unsafe { (*out).line = res.lex.line; }
  unsafe { (*out).col = res.lex.col; }
}

/**
 * Copy next_lex from LexerResult by value into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_lexer_result_val_into(out: *Lexer, r: LexerResult): void {
  if (out == (0 as *Lexer)) { return; }
  unsafe { (*out).pos = r.next_lex.pos; }
  unsafe { (*out).line = r.next_lex.line; }
  unsafe { (*out).col = r.next_lex.col; }
}

/**
 * Copy next_lex from OneFuncResult pointer into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_onefunc_result_ptr_into(out: *Lexer, res: *OneFuncResult): void {
  if (out == (0 as *Lexer) || res == (0 as *OneFuncResult)) { return; }
  unsafe { (*out).pos = (*res).next_lex.pos; }
  unsafe { (*out).line = (*res).next_lex.line; }
  unsafe { (*out).col = (*res).next_lex.col; }
}

/**
 * Copy next_lex from ExternParseResult opaque pointer into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_extern_parse_result_ptr_into(out: *Lexer, res_raw: *u8): void {
  let res: *ExternParseResult = 0 as *ExternParseResult;
  if (out == (0 as *Lexer) || res_raw == (0 as *u8)) { return; }
  res = res_raw as *ExternParseResult;
  unsafe { (*out).pos = (*res).next_lex.pos; }
  unsafe { (*out).line = (*res).next_lex.line; }
  unsafe { (*out).col = (*res).next_lex.col; }
}

/**
 * Mark ExternParseResult as fail: set lex, name_len=-1, clear name/fields.
 * PLATFORM: SHARED
 */
export function pipeline_parser_extern_parse_set_fail_c(res_raw: *u8, lex: Lexer): void {
  let res: *ExternParseResult = 0 as *ExternParseResult;
  let neg1: i32 = 0 - 1;
  if (res_raw == (0 as *u8)) { return; }
  res = res_raw as *ExternParseResult;
  unsafe { (*res).next_lex = lex; }
  unsafe { (*res).name_len = neg1; }
  unsafe { (*res).return_ty_ref = 0; }
  unsafe { (*res).num_params = 0; }
  unsafe { (*res).abi_kind = 0; }
  unsafe { (*res).is_variadic = 0; }
  unsafe { memset(&((*res).name[0]), 0, 256 as usize); }
}

/**
 * Copy LibraryParseResult bytes from res_raw into out_raw.
 * PLATFORM: SHARED
 */
export function pipeline_parser_library_result_copy_into_c(out_raw: *u8, res_raw: *u8): void {
  let out: *LibraryParseResult = 0 as *LibraryParseResult;
  let res: *LibraryParseResult = 0 as *LibraryParseResult;
  if (out_raw == (0 as *u8) || res_raw == (0 as *u8)) { return; }
  out = out_raw as *LibraryParseResult;
  res = res_raw as *LibraryParseResult;
  unsafe { (*out).ok = (*res).ok; }
  unsafe { memcpy(&((*out)._pad[0]), &((*res)._pad[0]), 4 as usize); }
  unsafe { (*out).next_lex = (*res).next_lex; }
  unsafe { memcpy(&((*out).name[0]), &((*res).name[0]), 256 as usize); }
  unsafe { (*out).name_len = (*res).name_len; }
  unsafe { memcpy(&((*out)._pad_tail[0]), &((*res)._pad_tail[0]), 4 as usize); }
}

/**
 * Copy TrySkipAllowResult bytes from res_raw into out_raw.
 * PLATFORM: SHARED
 */
export function pipeline_parser_try_skip_result_copy_into_c(out_raw: *u8, res_raw: *u8): void {
  let out: *TrySkipAllowResult = 0 as *TrySkipAllowResult;
  let res: *TrySkipAllowResult = 0 as *TrySkipAllowResult;
  if (out_raw == (0 as *u8) || res_raw == (0 as *u8)) { return; }
  out = out_raw as *TrySkipAllowResult;
  res = res_raw as *TrySkipAllowResult;
  unsafe { (*out).lex = (*res).lex; }
  unsafe { (*out).skipped = (*res).skipped; }
  unsafe { memcpy(&((*out)._pad[0]), &((*res)._pad[0]), 4 as usize); }
}

/**
 * Copy lex from TrySkipAllowResult by value into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_try_skip_result_val_into(out: *Lexer, t: TrySkipAllowResult): void {
  if (out == (0 as *Lexer)) { return; }
  unsafe { (*out).pos = t.lex.pos; }
  unsafe { (*out).line = t.lex.line; }
  unsafe { (*out).col = t.lex.col; }
}

/**
 * Copy next_lex from LibraryParseResult by value into out Lexer.
 * PLATFORM: SHARED
 */
export function parser_lex_from_library_result_val_into(out: *Lexer, lib: LibraryParseResult): void {
  if (out == (0 as *Lexer)) { return; }
  unsafe { (*out).pos = lib.next_lex.pos; }
  unsafe { (*out).line = lib.next_lex.line; }
  unsafe { (*out).col = lib.next_lex.col; }
}

/**
 * Mark OneFuncResult as fail: ok=0 and set next_lex.
 * PLATFORM: SHARED
 */
export function pipeline_parser_set_onefunc_fail_c(out_raw: *u8, lex: Lexer): void {
  let out: *OneFuncResult = 0 as *OneFuncResult;
  if (out_raw == (0 as *u8)) { return; }
  out = out_raw as *OneFuncResult;
  unsafe { (*out).ok = 0; }
  unsafe { (*out).next_lex = lex; }
}

/**
 * Mark OneFuncResult success: ok=1, lex, name (cap 64 fill), return_val.
 * PLATFORM: SHARED
 */
export function pipeline_parser_onefunc_buf_into_set_success_c(out_raw: *u8, lex: Lexer, name: *u8, name_len: i32, ret_val: i32): void {
  let out: *OneFuncResult = 0 as *OneFuncResult;
  if (out_raw == (0 as *u8)) { return; }
  out = out_raw as *OneFuncResult;
  unsafe { (*out).ok = 1; }
  unsafe { (*out).next_lex = lex; }
  unsafe { (*out).name_len = name_len; }
  unsafe { pipeline_module_fill_u8_64_from_src_c(&((*out).name[0]), name, name_len, 64); }
  unsafe { (*out).return_val = ret_val; }
}

/**
 * Alias of parser_slice_from_buf for source-facing name.
 * PLATFORM: SHARED
 */
export function pipeline_source_slice(data: *u8, len: i32): SliceU8 {
  return parser_slice_from_buf(data, len);
}

/**
 * Collect top-level import paths from source bytes into module.
 * Thin wrap of parser_collect_imports_buf (*u8 ABI; no Lexer type at call site).
 * PLATFORM: SHARED — Darwin / Ubuntu product -o collect-deps.
 */
export function xlang_module_collect_imports_from_buf(module: *u8, data: *u8, len: i64): void {
  let lex: Lexer = Lexer{ pos: 0 as usize, line: 0, col: 0 };
  let import_res: CollectImportsResult = CollectImportsResult{ lex: Lexer{ pos: 0 as usize, line: 0, col: 0 } };
  let n: i32 = 0;
  if (module == (0 as *u8) || data == (0 as *u8) || len <= 0) { return; }
  if (len > 2147483647) { return; }
  n = len as i32;
  lex = lexer_init();
  import_res.lex = lex;
  parser_collect_imports_buf(lex, data, n, module, &import_res);
}
