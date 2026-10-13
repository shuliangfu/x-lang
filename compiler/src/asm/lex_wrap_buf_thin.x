// Thin: expanded parser_asm_lex_wrap_buf_c (Darwin Cap tip 10.2).
// 16-slot g_lex_wrap ring smashed live source fats when const-import
// collect nested >16 wrap_buf calls (path/string scans) before dep
// prerun — Cap tip SEGV/L003 on core.option. 256 slots. PLATFORM: MACOS|DARWIN.

export extern function parser_asm_lex_bridge_store_ptr(dst: *u8, v: *u8): void;
export extern function parser_asm_lex_bridge_store_u64(dst: *u8, v: u64): void;

let g_lex_wrap_bytes_thin: u8[4096] = [];
let g_lex_wrap_i_thin: i32[1] = [0];

#[no_mangle]
export function parser_asm_lex_wrap_buf_c(data: *u8, len: i32): *u8 {
  if (data == 0 as *u8) {
    return 0 as *u8;
  }
  if (len <= 0) {
    return 0 as *u8;
  }
  let idx: i32 = g_lex_wrap_i_thin[0];
  let slot: i32 = idx & 255;
  let off: i32 = slot * 16;
  unsafe {
    let base: *u8 = &g_lex_wrap_bytes_thin[0];
    let p: *u8 = base + off;
    parser_asm_lex_bridge_store_ptr(p, data);
    let lp: *u8 = p + 8;
    parser_asm_lex_bridge_store_u64(lp, len as u64);
    g_lex_wrap_i_thin[0] = (idx + 1) & 255;
    return p;
  }
  return 0 as *u8;
}
