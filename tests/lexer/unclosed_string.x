// Probe: unclosed double-quoted string at EOF must hard-fail with L002.
// wave271 Cap residual pure — product path must print "unclosed string literal"
// (or L002) and refuse silent empty-module success / soft P001 / BLD001-only.
//
// Authority: lexer.x string scan EOF + parse_into_apply_unclosed_gate sticky.
// Multi-line strings remain valid when the closing quote appears later.
// PLATFORM: SHARED.

function main(): i32 {
  let s: *u8 = "deliberately unclosed — no matching closer
  return 42;
}
