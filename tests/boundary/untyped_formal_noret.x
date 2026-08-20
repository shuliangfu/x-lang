// Isolated compile-fail: missing return type is not product syntax (4.2.18).
// wave676: P011 `function requires return type annotation`.
// Expected: compile != 0 (P011). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold parse.

/**
 * Must not parse: parameter list not followed by `): Type`.
 * @param x i32
 * @return — missing; P011
 */
function bad(x: i32) {
  return x;
}

function main(): i32 {
  return bad(1);
}
