// Probe: incomplete octal (`0o` with zero digits) must hard-fail with L007.
// wave276 Cap residual pure — product path must print "incomplete octal literal"
// (or L007) and refuse soft XP003 parse-skip / INT(0)+IDENT.
//
// Authority: lexer.x octal path digit count + parse_into_apply_unclosed_gate sticky.
// Valid octal (0o0 / 0o52) still accepts; this file deliberately omits digits.
// PLATFORM: SHARED.

function main(): i32 {
  return 0o;
}
