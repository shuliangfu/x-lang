// Isolated compile-fail: free-function untyped self is not product syntax.
// 4.2.1 / wave493: write `name: Type`. Trait default hoist is the only
// bare-self exemption (parser_allow_bare_self around buf re-parse).
// Expected: compile != 0 (P011). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Must not parse: receiver without `: Type` on a free function.
 * @param self — untyped; P011
 * @return i32 — unused (compile must fail)
 */
function m(self): i32 {
  return 1;
}

function main(): i32 {
  return m(0);
}
