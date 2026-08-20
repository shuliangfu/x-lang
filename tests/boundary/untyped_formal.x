// Isolated compile-fail: untyped formal is not product syntax (4.2.18).
// wave676: parser_report_untyped_formal_p011_c at definition.
// typeck param_raw<=0 soft-skip is defensive — no product path rebuilds
// an untyped formal after this P011.
// Expected: compile != 0 (P011). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold parse.

/**
 * Must not parse: parameter without `: Type`.
 * @param x — untyped; P011
 * @return i32 — unused (compile must fail)
 */
function bad(x): i32 {
  return x;
}

function main(): i32 {
  return bad(1);
}
