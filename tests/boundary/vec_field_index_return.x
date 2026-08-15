// Isolated: dest `w.h.v[i]=` plus typeck of `return` / `let` INDEX
// of a FIELD-chain SIMD field. dest emit was already green after
// FIELD-chain SIMD INDEX lea; `return h.v[1]` / `let x: i32 = w.h.v[i]`
// used to T001 because apply_ambient stamped i32 over i32x4 (also
// false-green `return h.v` as i32). VAR `return a[1]` and `if (w.h.v[i])`
// were already 0. Does not fold nest 21 / typeck of unrelated free T.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// the SIMD-concrete ambient skip.

allow(padding) struct Holder {
  v: i32x4
}

allow(padding) struct Wrap {
  h: Holder
}

/**
 * Return one lane of a FIELD-chain SIMD via `return w.h.v[i]`.
 * @param w Wrap — value wrap (h.v written by caller)
 * @param i i32 — lane index 0..3
 * @return i32 — that lane
 */
function ret_lane(w: Wrap, i: i32): i32 {
  return w.h.v[i];
}

/**
 * Return one lane of a FIELD-chain SIMD via `let x: i32 = w.h.v[i]`.
 * @param w Wrap — value wrap (h.v written by caller)
 * @param i i32 — lane index 0..3
 * @return i32 — that lane
 */
function let_lane(w: Wrap, i: i32): i32 {
  let x: i32 = w.h.v[i];
  return x;
}

/**
 * Exit 0 when dest `w.h.v[i]=` and return/let INDEX write/read every lane.
 * Depth-1 `return h.v[1]` is the same typeck (local lit already 2);
 * `let h: Holder = w.h` then param INDEX is a Holder-copy leftover.
 * @return i32 — 0 ok; 10/20/30/40 dest; 11/21/31/41 return; 12/22/32/42 let
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let inner: Holder = Holder { v: z };
  let w: Wrap = Wrap { h: inner };
  w.h.v = a;
  w.h.v[0] = 9;
  w.h.v[1] = 8;
  w.h.v[2] = 7;
  w.h.v[3] = 6;
  if (w.h.v[0] != 9) { return 10; }
  if (w.h.v[1] != 8) { return 20; }
  if (w.h.v[2] != 7) { return 30; }
  if (w.h.v[3] != 6) { return 40; }
  w.h.v = a;
  if (ret_lane(w, 0) != 1) { return 11; }
  if (ret_lane(w, 1) != 2) { return 21; }
  if (ret_lane(w, 2) != 3) { return 31; }
  if (ret_lane(w, 3) != 4) { return 41; }
  if (let_lane(w, 0) != 1) { return 12; }
  if (let_lane(w, 1) != 2) { return 22; }
  if (let_lane(w, 2) != 3) { return 32; }
  if (let_lane(w, 3) != 4) { return 42; }
  return 0;
}
