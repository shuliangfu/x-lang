// Isolated: FIELD-chain SIMD INDEX (`w.h.v[i]`).
// Observe via `if (w.h.v[i] != …)`. dest `w.h.v[i]=` and typeck of
// `return` / `let` INDEX are gated by vec_field_index_return.x.
// Split `let t: i32x4 = w.h.v; t[i]` was already 0 (vector let-init
// FIELD source + VAR INDEX). Depth-1 `h.v[i]` is gated by
// vec_add4_field_recv.x. FIELD-chain METHOD `w.h.v.sub4` is gated by
// vec_add4_field_chain.x.
// INDEX of `w.h.v` used to miss glue_try_index VAR/DEREF/INDEX bases
// (base_ko==44) and fall to emit_expr rvalue — packed lanes used as a
// pointer (Darwin garbage / 138). host-C already 0.
// Does not fold pointer *Holder or nest 21.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// FIELD-chain INDEX lea.

allow(padding) struct Holder {
  v: i32x4
}

allow(padding) struct Wrap {
  h: Holder
}

/**
 * Exit 0 when FIELD-chain SIMD INDEX reads every lane after dest.
 * @return i32 — 0 ok; 10/20/30/40 lane mismatch
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let inner: Holder = { v: z };
  let w: Wrap = { h: inner };
  w.h.v = a;
  if (w.h.v[0] != 1) { return 10; }
  if (w.h.v[1] != 2) { return 20; }
  if (w.h.v[2] != 3) { return 30; }
  if (w.h.v[3] != 4) { return 40; }
  return 0;
}
