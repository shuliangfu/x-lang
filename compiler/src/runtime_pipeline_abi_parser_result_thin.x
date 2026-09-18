// Thin pure: wave329/375/381/532 M2 — parser_result Cap residual C→.x.
// slice/lex copy sidecars + onefunc/extern/library/try_skip + collect_imports.
// G.7: bodies match deleted C thin / seed WAVE287_PARSER_RESULT_ALWAYS.
// PRODUCT inject: HARD BAN reinject (wave381/w532) — stay prior -E overlay.
// wave375/381: tip T001 nested Lexer/Token size under pure-asm.
// wave532 Soft Cap: opaque u8[N] result blobs (LP64 seed layout) — ban nested
//   named struct fields; tipU Soft Cap; stamp w532 HARD BAN tip PRODUCT reinject.
// PLATFORM: SHARED Soft Cap tip heal / LINUX gold / MACOS co-path.

/** LP64 product Lexer — flat (tip can size); match seed ALWAYS / C thin. */
allow(padding) struct Lexer {
  pos: usize;
  line: i32;
  col: i32;
}

/**
 * Fat u8 slice — layout match xlang_slice_uint8_t { data, length }.
 * PLATFORM: SHARED
 */
allow(padding) struct SliceU8 {
  data: *u8;
  length: usize;
}

/**
 * Opaque LexerResult — LP64 size 72 (Lexer 16 + Token 48 + usize 8).
 * tip T001: ban nested Lexer/Token fields. PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct LexerResult {
  bytes: u8[72];
}

/**
 * Opaque CollectImportsResult — LP64 size 16 (Lexer only).
 * PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct CollectImportsResult {
  bytes: u8[16];
}

/**
 * Opaque OneFuncResult — LP64 size 920 (ok+pad+Lexer+fields).
 * next_lex @8, name @24, name_len @280, return_val @352.
 * PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct OneFuncResult {
  bytes: u8[920];
}

/**
 * Opaque ExternParseResult — LP64 size 296 (Lexer+name[256]+i32s).
 * next_lex @0, name @16, name_len @272.
 * PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct ExternParseResult {
  bytes: u8[296];
}

/**
 * Opaque TrySkipAllowResult — LP64 size 24 (Lexer+skipped+pad).
 * PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct TrySkipAllowResult {
  bytes: u8[24];
}

/**
 * Opaque LibraryParseResult — LP64 size 288 (ok+pad+Lexer+name+…).
 * next_lex @8. PLATFORM: SHARED Soft Cap (wave532).
 */
allow(padding) struct LibraryParseResult {
  bytes: u8[288];
}

const W532_LEXER_SZ: i32 = 16;
const W532_LR_SZ: i32 = 72;
const W532_COLLECT_SZ: i32 = 16;
const W532_ONEFUNC_SZ: i32 = 920;
const W532_EXTERN_SZ: i32 = 296;
const W532_TRYSKIP_SZ: i32 = 24;
const W532_LIBRARY_SZ: i32 = 288;
const W532_OF_OFF_NEXT_LEX: i32 = 8;
const W532_OF_OFF_NAME: i32 = 24;
const W532_OF_OFF_NAME_LEN: i32 = 280;
const W532_OF_OFF_RETURN_VAL: i32 = 352;
const W532_EX_OFF_NAME: i32 = 16;
const W532_EX_OFF_NAME_LEN: i32 = 272;
const W532_EX_OFF_RETURN_TY: i32 = 276;
const W532_EX_OFF_NUM_PARAMS: i32 = 280;
const W532_EX_OFF_ABI: i32 = 284;
const W532_EX_OFF_VARIADIC: i32 = 288;
const W532_LIB_OFF_NEXT_LEX: i32 = 8;
const W532_TS_OFF_SKIPPED: i32 = 16;

export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_module_fill_u8_64_from_src_c(dst: *u8, src: *u8, n: i32, src_cap: i32): void;
export extern function parser_collect_imports_buf(lex: Lexer, data: *u8, len: i32, module: *u8, out: *CollectImportsResult): void;

/**
 * Copy Lexer bytes from opaque blob at byte offset into out.
 * @param base Opaque result bytes.
 * @param off Byte offset of embedded Lexer.
 * @param out Destination Lexer; null → no-op.
 * PLATFORM: SHARED Soft Cap tip heal (wave532).
 */
function w532_lex_load(base: *u8, off: i32, out: *Lexer): void {
  if (base == (0 as *u8) || out == (0 as *Lexer)) { return; }
  unsafe { memcpy(out as *u8, base + (off as usize), W532_LEXER_SZ as usize); }
}

/**
 * Store Lexer bytes into opaque blob at byte offset.
 * @param base Opaque result bytes.
 * @param off Byte offset of embedded Lexer.
 * @param lex Source Lexer (by value).
 * PLATFORM: SHARED Soft Cap tip heal (wave532).
 */
function w532_lex_store(base: *u8, off: i32, lex: Lexer): void {
  let tmp: Lexer = lex;
  if (base == (0 as *u8)) { return; }
  unsafe { memcpy(base + (off as usize), (&tmp as *u8), W532_LEXER_SZ as usize); }
}

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
 * Opaque blob base = *LexerResult cast (sole field bytes[72]).
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_lexer_result_ptr_into(out: *Lexer, r: *LexerResult): void {
  if (out == (0 as *Lexer) || r == (0 as *LexerResult)) { return; }
  w532_lex_load(r as *u8, 0, out);
}

/**
 * Copy lex from CollectImportsResult by value into out Lexer.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_copy_from_collect_imports(out: *Lexer, res: CollectImportsResult): void {
  let tmp: CollectImportsResult = res;
  if (out == (0 as *Lexer)) { return; }
  w532_lex_load(&tmp as *u8, 0, out);
}

/**
 * Copy next_lex from LexerResult by value into out Lexer.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_lexer_result_val_into(out: *Lexer, r: LexerResult): void {
  let tmp: LexerResult = r;
  if (out == (0 as *Lexer)) { return; }
  w532_lex_load(&tmp as *u8, 0, out);
}

/**
 * Copy next_lex from OneFuncResult pointer into out Lexer (offset 8).
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_onefunc_result_ptr_into(out: *Lexer, res: *OneFuncResult): void {
  if (out == (0 as *Lexer) || res == (0 as *OneFuncResult)) { return; }
  w532_lex_load(res as *u8, W532_OF_OFF_NEXT_LEX, out);
}

/**
 * Copy next_lex from ExternParseResult opaque pointer into out Lexer.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_extern_parse_result_ptr_into(out: *Lexer, res_raw: *u8): void {
  if (out == (0 as *Lexer) || res_raw == (0 as *u8)) { return; }
  w532_lex_load(res_raw, 0, out);
}

/**
 * Mark ExternParseResult as fail: set lex, name_len=-1, clear name/fields.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function pipeline_parser_extern_parse_set_fail_c(res_raw: *u8, lex: Lexer): void {
  let neg1: i32 = 0 - 1;
  if (res_raw == (0 as *u8)) { return; }
  w532_lex_store(res_raw, 0, lex);
  unsafe {
    pipe_store_i32_le(res_raw, W532_EX_OFF_NAME_LEN, neg1);
    pipe_store_i32_le(res_raw, W532_EX_OFF_RETURN_TY, 0);
    pipe_store_i32_le(res_raw, W532_EX_OFF_NUM_PARAMS, 0);
    pipe_store_i32_le(res_raw, W532_EX_OFF_ABI, 0);
    pipe_store_i32_le(res_raw, W532_EX_OFF_VARIADIC, 0);
    memset(res_raw + (W532_EX_OFF_NAME as usize), 0, 256 as usize);
  }
}

/**
 * Copy LibraryParseResult bytes from res_raw into out_raw (full blob).
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function pipeline_parser_library_result_copy_into_c(out_raw: *u8, res_raw: *u8): void {
  if (out_raw == (0 as *u8) || res_raw == (0 as *u8)) { return; }
  unsafe { memcpy(out_raw, res_raw, W532_LIBRARY_SZ as usize); }
}

/**
 * Copy TrySkipAllowResult bytes from res_raw into out_raw (full blob).
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function pipeline_parser_try_skip_result_copy_into_c(out_raw: *u8, res_raw: *u8): void {
  if (out_raw == (0 as *u8) || res_raw == (0 as *u8)) { return; }
  unsafe { memcpy(out_raw, res_raw, W532_TRYSKIP_SZ as usize); }
}

/**
 * Copy lex from TrySkipAllowResult by value into out Lexer.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_try_skip_result_val_into(out: *Lexer, t: TrySkipAllowResult): void {
  let tmp: TrySkipAllowResult = t;
  if (out == (0 as *Lexer)) { return; }
  w532_lex_load(&tmp as *u8, 0, out);
}

/**
 * Copy next_lex from LibraryParseResult by value into out Lexer.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function parser_lex_from_library_result_val_into(out: *Lexer, lib: LibraryParseResult): void {
  let tmp: LibraryParseResult = lib;
  if (out == (0 as *Lexer)) { return; }
  w532_lex_load(&tmp as *u8, W532_LIB_OFF_NEXT_LEX, out);
}

/**
 * Mark OneFuncResult as fail: ok=0 and set next_lex.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function pipeline_parser_set_onefunc_fail_c(out_raw: *u8, lex: Lexer): void {
  if (out_raw == (0 as *u8)) { return; }
  unsafe { pipe_store_i32_le(out_raw, 0, 0); }
  w532_lex_store(out_raw, W532_OF_OFF_NEXT_LEX, lex);
}

/**
 * Mark OneFuncResult success: ok=1, lex, name (cap 64 fill), return_val.
 * PLATFORM: SHARED Soft Cap (wave532 opaque).
 */
export function pipeline_parser_onefunc_buf_into_set_success_c(out_raw: *u8, lex: Lexer, name: *u8, name_len: i32, ret_val: i32): void {
  if (out_raw == (0 as *u8)) { return; }
  unsafe { pipe_store_i32_le(out_raw, 0, 1); }
  w532_lex_store(out_raw, W532_OF_OFF_NEXT_LEX, lex);
  unsafe {
    pipe_store_i32_le(out_raw, W532_OF_OFF_NAME_LEN, name_len);
    pipeline_module_fill_u8_64_from_src_c(out_raw + (W532_OF_OFF_NAME as usize), name, name_len, 64);
    pipe_store_i32_le(out_raw, W532_OF_OFF_RETURN_VAL, ret_val);
  }
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
 * Thin wrap of parser_collect_imports_buf (*u8 ABI).
 * PLATFORM: SHARED Soft Cap (wave532 opaque CollectImportsResult).
 */
export function xlang_module_collect_imports_from_buf(module: *u8, data: *u8, len: i64): void {
  /* Soft Cap: inline lexer_init semantics (pos0/line1/col1) — Ubuntu tip drops
   * Lexer sret mid-assign UND; ban CollectImportsResult{ bytes: [] } hang. */
  let lex: Lexer = Lexer{ pos: 0 as usize, line: 1, col: 1 };
  let import_res: CollectImportsResult;
  let n: i32 = 0;
  if (module == (0 as *u8) || data == (0 as *u8) || len <= 0) { return; }
  if (len > 2147483647) { return; }
  n = len as i32;
  unsafe { memset(&import_res as *u8, 0, W532_COLLECT_SZ as usize); }
  w532_lex_store(&import_res as *u8, 0, lex);
  unsafe { parser_collect_imports_buf(lex, data, n, module, &import_res); }
}
