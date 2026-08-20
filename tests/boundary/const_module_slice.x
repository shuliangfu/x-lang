// Isolated: module-level dest-SLICE const INDEX/VAR/ARRAY_LIT wrap.
// host-C top-level must emit `{.data=A[1],.length=N}`, not `s = (A)[1]`.
// dest-SLICE ARRAY_LIT at file scope: `{.data=(E[]){…},.length=N}`
// (emit_expr statement-expr is not a C static initializer).
// Nested `[][]T` / `[N][]T` file-scope wrap: const_module_nested_slice.x
// (asm INDEX of those is a different leftover).
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

/**
 * Exit 42 when module-level dest-SLICE const INDEX/VAR/ARRAY_LIT and
 * mutable let wrap as typed fat (host-C static / asm hoist into main).
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
  return 42;
}
