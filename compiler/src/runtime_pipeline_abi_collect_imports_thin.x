// Thin pure: collect-deps import scan (xlang_module_collect_imports_from_buf).
// w2055: split out of runtime_pipeline_abi_parser_result_thin.x, whose
// product reinject stays banned (w381/w532). The pabi object keeps an old
// C body that calls the struct-returning lexer_init(); since e5ba88d9d
// lexer_init(out: *Lexer) writes through rdi, which still holds the module
// pointer, so num_imports became 1 with an empty path (IMP001 ./.x).
// Linux builds this file into build_asm/selfhost_pabi/cimp.o
// (linux_selfhost_pabi_refresh_tip.sh). Darwin builds cimp_a64.o.
// Windows builds cimp_win.o. Each links ahead of the pabi copy.
// This thin does not call lexer_init and does not divide.
// PLATFORM: SHARED source; LINUX / MACOS|DARWIN / WINDOWS sidecars.

/** LP64 product Lexer — flat; matches lexer.Lexer. */
allow(padding) struct Lexer {
  pos: usize;
  line: i32;
  col: i32;
}

/** Opaque CollectImportsResult — LP64 size 16 (Lexer only). */
allow(padding) struct CollectImportsResult {
  bytes: u8[16];
}

const CIMP_COLLECT_SZ: i32 = 16;

export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern function parser_collect_imports_buf(lex: Lexer, data: *u8, len: i32, module: *u8, out: *CollectImportsResult): void;

/**
 * Collect top-level import paths from source bytes into module.
 * Thin wrap of parser_collect_imports_buf (*u8 ABI). The Lexer starts at
 * pos 0, line 1, col 1 (lexer_init semantics) without calling lexer_init.
 * @param module AST module; null -> no-op
 * @param data source bytes; null -> no-op
 * @param len byte length; <=0 or >INT32_MAX -> no-op
 * The collect-deps caller uses the unprefixed C name, so keep #[no_mangle].
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_module_collect_imports_from_buf(module: *u8, data: *u8, len: i64): void {
  let lex: Lexer = Lexer{ pos: 0 as usize, line: 1, col: 1 };
  let import_res: CollectImportsResult;
  let n: i32 = 0;
  if (module == (0 as *u8) || data == (0 as *u8) || len <= 0) { return; }
  if (len > 2147483647) { return; }
  n = len as i32;
  unsafe { memset(&import_res as *u8, 0, CIMP_COLLECT_SZ as usize); }
  unsafe { memcpy(&import_res as *u8, (&lex as *u8), CIMP_COLLECT_SZ as usize); }
  unsafe { parser_collect_imports_buf(lex, data, n, module, &import_res); }
}
