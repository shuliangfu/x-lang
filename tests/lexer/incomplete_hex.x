// Probe: incomplete hex (`0x` with zero digits) must hard-fail with L004.
// wave273 Cap residual pure — product path must print "incomplete hex literal"
// (or L004) and refuse silent TOKEN_INT(0) / soft P001 "no functions".
//
// Authority: lexer.x hex path digit count + parse_into_apply_unclosed_gate sticky.
// Valid hex (0xFF / 0x0) still accepts; this file deliberately omits digits.
// PLATFORM: SHARED.

function main(): i32 {
  return 0x;
}
