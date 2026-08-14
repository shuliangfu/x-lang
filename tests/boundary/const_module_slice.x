// Isolated: module-level dest-SLICE const INDEX/VAR wrap (C static).
// typeck already accepts dest-SLICE const INDEX; host-C top-level still
// emitted `static const T s = (A)[1]` (pointer into slice struct → BLD001).
// Same-layer twin: dest-SLICE const VAR, and mutable let via init_globals.
// Expected: compile = 0, run = 42 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold host-C static init.

const A: [2][2]i32 = [[1, 2], [10, 32]];
const s: []i32 = A[1];
const B: [2]i32 = [10, 32];
const v: []i32 = B;
const k: i32 = 1;
const u: []i32 = A[k];
let m: []i32 = B;

/**
 * Exit 42 when module-level dest-SLICE const INDEX/VAR and mutable let
 * wrap as typed fat (C static address-constant / init_globals assign).
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  if (v.length != 2) { return 4; }
  if (v[0] != 10) { return 5; }
  if (v[1] != 32) { return 6; }
  if (u.length != 2) { return 7; }
  if (u[0] != 10) { return 8; }
  if (m.length != 2) { return 9; }
  if (m[0] != 10) { return 10; }
  return 42;
}
