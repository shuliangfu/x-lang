// Isolated: module-level dest-SLICE const INDEX/VAR wrap (C static).
// host-C top-level must emit `{.data=A[1],.length=N}`, not `s = (A)[1]`.
// Same-layer twin: dest-SLICE const VAR and mutable let via init_globals.
// asm module-level dest-SLICE const is a different layer (CG002 leftover).
// Expected: host-C compile = 0, run = 42.
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
