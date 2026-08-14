// Isolated: module-level dest-SLICE const INDEX/VAR/ARRAY_LIT wrap.
// host-C top-level must emit `{.data=A[1],.length=N}`, not `s = (A)[1]`.
// dest-SLICE ARRAY_LIT at file scope: `{.data=(E[]){…},.length=N}`
// (emit_expr statement-expr is not a C static initializer).
// Same wrap recurses for `[][]T` / `[N][]T` rows (nested (E[]){…}).
// asm: hoist const TYPE_ARRAY / dest-SLICE into main; ARRAY_LIT helper
// durables the payload. Same-layer twin: dest-SLICE const VAR / mutable let.
// Expected: host-C and asm compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold host-C static + asm hoist.

const A: [2][2]i32 = [[1, 2], [10, 32]];
const s: []i32 = A[1];
const B: [2]i32 = [10, 32];
const v: []i32 = B;
const k: i32 = 1;
const u: []i32 = A[k];
let m: []i32 = B;
const t: []i32 = [10, 32];
const ns: [][]i32 = [[10, 32], [1, 2]];
const na: [2][]i32 = [[10, 32], [1, 2]];

/**
 * Exit 42 when module-level dest-SLICE const INDEX/VAR/ARRAY_LIT and
 * mutable let wrap as typed fat (host-C static / asm hoist into main).
 * Also dest-SLICE `[][]T` / dest-ARRAY `[N][]T` file-scope row wrap.
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
  if (t.length != 2) { return 11; }
  if (t[0] != 10) { return 12; }
  if (t[1] != 32) { return 13; }
  if (ns.length != 2) { return 14; }
  if (ns[0].length != 2) { return 15; }
  if (ns[0][0] != 10) { return 16; }
  if (ns[0][1] != 32) { return 17; }
  if (ns[1][0] != 1) { return 18; }
  if (ns[1][1] != 2) { return 19; }
  if (na[0].length != 2) { return 20; }
  if (na[0][0] != 10) { return 21; }
  if (na[1][1] != 2) { return 22; }
  return 42;
}
