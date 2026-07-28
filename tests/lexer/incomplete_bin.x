// Probe: incomplete binary (`0b` with zero digits) must hard-fail with L006.
// wave276 Cap residual pure — product path must print "incomplete binary literal"
// (or L006) and refuse soft XP003 parse-skip / INT(0)+IDENT.
//
// Authority: lexer.x binary path digit count + parse_into_apply_unclosed_gate sticky.
// Valid binary (0b0 / 0b1010) still accepts; this file deliberately omits digits.
// PLATFORM: SHARED.

function main(): i32 {
  return 0b;
}
