// Probe: incomplete float exponent (`1e` with zero digits) must hard-fail with L005.
// wave274 Cap residual pure — product path must print "incomplete float exponent"
// (or L005) and refuse silent TOKEN_FLOAT(exp=0) / wrong program value.
//
// Authority: lexer.x exp digit count + parse_into_apply_unclosed_gate sticky.
// Valid exponents (1e0 / 1e+10 / 1.5e2) still accept; this file deliberately omits digits.
// PLATFORM: SHARED.

function main(): i32 {
  return (1e) as i32;
}
