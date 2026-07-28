// Probe: consecutive digit separators `__` must hard-fail with L008.
// wave278 Cap residual pure — product path must print "invalid digit separator"
// (or L008) and refuse soft XP003 parse-skip.
//
// Authority: lexer.x digit loops post-check + sticky L008 gate.
// PLATFORM: SHARED.

function main(): i32 {
  return 1__000;
}
