// Isolated green: assign already-typed [N]T to []T (VAR / FIELD).
// Typeck accepts without stamping TYPE_SLICE; emit writes a same-frame
// fat {.data=arr,.length=N} (no escape — dest lives in this function).
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

struct W {
  xs: [2]i32
}

/**
 * Exit 42 when assign [N]T → []T typecks and the fat lanes match.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: [2]i32 = [10, 32];
  let s: []i32 = [0];
  s = a;
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  let w: W = { xs: [10, 32] };
  s = w.xs;
  if (s.length != 2) { return 4; }
  if (s[0] != 10) { return 5; }
  if (s[1] != 32) { return 6; }
  s = { xs: [10, 32] }.xs;
  if (s.length != 2) { return 7; }
  if (s[0] != 10) { return 8; }
  if (s[1] != 32) { return 9; }
  return 42;
}
