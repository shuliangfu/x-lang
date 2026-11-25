extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;
allow(padding) struct WbLex { pos: usize; line: i32; col: i32; }
allow(padding) struct WbRes { ok: i32; expr_ref: i32; next_lex: WbLex; }
#[cfg(target_os = "macos")]
extern function pthin_expr_ternary_call_logor(arena: *u8, lex: *WbLex, source: *u8, out: *WbRes): void;
#[no_mangle]
export function parser_parse_logor_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let res: WbRes = { ok: 0, expr_ref: 0, next_lex: { pos: 0, line: 0, col: 0 } };
  unsafe {
    let p: *WbLex = lex_inout as *WbLex;
    pthin_expr_ternary_call_logor(arena, p, source, &res);
    let rp: *i32 = &res as *i32;
    out_ok[0] = rp[0];
    out_expr_ref[0] = rp[1];
    memcpy(lex_inout, (&res as *u8) + 8, 16);
  }
  return 1;
}
