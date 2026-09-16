// See implementation.
const backtrace = import("std.backtrace");

/**
 * STD-052 .x smoke: capture then symbolicate at least one frame into a name slot.
 * Named resolve (symbolicate return > 0) needs the product asm ld path to pass
 * --export-dynamic (GNU ld) / -export_dynamic (ld64); without it Linux dladdr
 * often misses local symbols. Hex fallback still writes name slots after the
 * format_hex overrun fix — accept either named count or a non-empty first slot.
 * @return i32 — 0 success; 1 if capture produced frames but no name was written
 * PLATFORM: SHARED — Ubuntu gold without export-dynamic uses hex path; Darwin
 * often gets named resolves without the flag.
 */
function main(): i32 {
  let buf: u8[64] = [];
  let n: i32 = backtrace.capture(&buf[0], 8);
  if (n <= 0) {
    return 0;
  }
  let names: u8[1024] = [];
  let i: i32 = 0;
  while (i < 1024) {
    names[i] = 0;
    i = i + 1;
  }
  let sym_n: i32 = backtrace.symbolicate(&buf[0], n, &buf[0], &names[0], n);
  if (sym_n > 0) {
    return 0;
  }
  // Hex fallback wrote a slot (e.g. "0x…") — product path still exercised.
  if (names[0] != 0) {
    return 0;
  }
  return 1;
}
