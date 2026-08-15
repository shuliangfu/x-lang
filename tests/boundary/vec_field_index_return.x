// Isolated: dest `w.h.v[i]=` plus typeck of `return` / `let` INDEX
// of a FIELD-chain SIMD field, plus Holder copy `let h = w.h` /
// assign `h = w.h` after dest, plus STRUCT_LIT `Wrap { h: inner }`
// (ARM64 16B field store). dest emit was already green after
// FIELD-chain SIMD INDEX lea; `return h.v[1]` / `let x: i32 = w.h.v[i]`
// used to T001 because apply_ambient stamped i32 over i32x4 (also
// false-green `return h.v` as i32). `let h = w.h` used to copy 8B
// (Darwin h.v[2] leftover) because struct let-init ignored FIELD.
// `Wrap { h: inner }` used to store only 8B on ARM64 (Darwin 30)
// because STRUCT_LIT dual-GP spill was ta==0 only.
// VAR `return a[1]` / `let h2 = h` / `if (w.h.v[i])` were already 0.
// Does not fold dest-in-rbx FIELD source / nest 21 / typeck of
// unrelated free T.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// the SIMD-concrete ambient skip, FIELD let-init copy, and STRUCT_LIT
// ARM64 dual-GP 16B field store.

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
 * Return one lane of a depth-1 Holder param via `return h.v[i]`.
 * Used after `let h: Holder = w.h` so the copy is consumed as a param.
 * @param h Holder — value holder (copied by caller)
 * @param i i32 — lane index 0..3
 * @return i32 — that lane
 */
function ret_depth1(h: Holder, i: i32): i32 {
  return h.v[i];
}

/**
 * Exit 0 when dest `w.h.v[i]=`, return/let INDEX, Holder copy
 * `let h = w.h` / assign `h = w.h`, and STRUCT_LIT `Wrap { h: inner }`
 * write/read every lane.
 * Depth-1 `return h.v[1]` local lit is the same typeck (already 2).
 * @return i32 — 0 ok; 50/51/52/53 slit; 10/20/30/40 dest; 11/21/31/41 return;
 *   12/22/32/42 let; 13/23/33/43 copy; 14/24/34/44 assign; 15/25/35/45 copy-as-param
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let inner: Holder = Holder { v: a };
  let w: Wrap = Wrap { h: inner };
  if (w.h.v[0] != 1) { return 50; }
  if (w.h.v[1] != 2) { return 51; }
  if (w.h.v[2] != 3) { return 52; }
  if (w.h.v[3] != 4) { return 53; }
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
  let h: Holder = w.h;
  if (h.v[0] != 1) { return 13; }
  if (h.v[1] != 2) { return 23; }
  if (h.v[2] != 3) { return 33; }
  if (h.v[3] != 4) { return 43; }
  if (ret_depth1(h, 0) != 1) { return 15; }
  if (ret_depth1(h, 1) != 2) { return 25; }
  if (ret_depth1(h, 2) != 3) { return 35; }
  if (ret_depth1(h, 3) != 4) { return 45; }
  let h2: Holder = Holder { v: z };
  h2 = w.h;
  if (h2.v[0] != 1) { return 14; }
  if (h2.v[1] != 2) { return 24; }
  if (h2.v[2] != 3) { return 34; }
  if (h2.v[3] != 4) { return 44; }
  return 0;
}
