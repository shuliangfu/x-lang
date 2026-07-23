// Probe: invalid numeric digit separator must hard-fail with L008.
// wave278 Cap residual pure — product path must print "invalid digit separator"
// (or L008) and refuse soft XP003 parse-skip (INT+IDENT).
//
// Authority: lexer.x digit loops post-check + parse_into_apply_unclosed_gate sticky.
// Valid separators (4_2 / 0x2_A) still accept; this file uses trailing `_`.
// PLATFORM: SHARED.

function main(): i32 {
  return 42_;
}
