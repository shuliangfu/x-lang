// Isolated: dest `w.h.v[i]=` plus typeck of `return` / `let` INDEX
// of a FIELD-chain SIMD field, plus Holder copy `let h = w.h` /
// assign `h = w.h` after dest, plus STRUCT_LIT `Wrap { h: inner }`
// (ARM64 16B field store), plus dest-in-rbx FIELD source `*p = w.h`,
// plus ARRAY_LIT of a 16B named VAR (`[w]` / `[h]`), plus INDEX-base
// FIELD dest-in-rbx `*p = arr[i].h`, plus dest-in-rbx INDEX whole
// `*p = arr[i]`, plus dest-in-rbx DEREF source `*p = *q`, plus
// STRUCT_LIT FIELD source `Wrap { h: w.h }` / dest-in-rbx
// `*p = { h: w.h }`, plus dest-in-rbx ARRAY_LIT `*p = [w]`, plus
// dest-in-rbx ARRAY_LIT of FIELD `*p = [w.h]`, plus INDEX dest
// ARRAY_LIT `rows[0] = [w]`, plus dest-in-rbx ARRAY VAR `*p = src`. dest emit
// was already green after FIELD-chain SIMD INDEX lea; `return h.v[1]`
// / `let x: i32 = w.h.v[i]`
// used to T001 because apply_ambient stamped i32 over i32x4 (also
// false-green `return h.v` as i32). `let h = w.h` used to copy 8B
// (Darwin h.v[2] leftover) because struct let-init ignored FIELD.
// `Wrap { h: inner }` used to store only 8B on ARM64 (Darwin 30)
// because STRUCT_LIT dual-GP spill was ta==0 only. `*p = w.h` used
// to copy 8B (Darwin 30) because dest-in-rbx FIELD returned -2 and
// emit_expr of FIELD is 8B; deref_struct16 would clobber dest / x19
// so dest-in-rbx uses memcpy. ARRAY_LIT `[w]` used to Darwin 139:
// VAR 9–16B frame dest returned -2, emit_expr dual-GP clobbered
// dest-in-x1, store hit NULL. dest-in-rbx INDEX whole `*p = arr[i]`
// used to Darwin 12 (hi leftover): let-init ignored INDEX (47),
// emit_expr of INDEX is 8B. dest-in-rbx DEREF source `*p = *q` used
// to Darwin 30: let-init DEREF 9–16B returned -2, emit_deref dual-GP
// then dest re-lea clobbered hi. STRUCT_LIT FIELD source
// `Wrap { h: w.h }` used to Darwin 30: emit_expr of FIELD is 8B,
// dual-GP spill stored garbage hi. VAR `return a[1]` / `let h2 = h`
// / `if (w.h.v[i])` / INDEX-base FIELD dest-in-rbx were already 0.
// Deref write is unsafe (bare `*p =` drops the function at parse).
// Does not fold nest 21 / typeck of unrelated free T.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// the SIMD-concrete ambient skip, FIELD let-init copy, STRUCT_LIT
// ARM64 dual-GP 16B field store, dest-in-rbx FIELD memcpy,
// VAR 9–16B frame dest let-init (ARRAY_LIT `[w]`), dest-in-rbx
// INDEX whole let-init, dest-in-rbx DEREF source `*p = *q`, and
// STRUCT_LIT FIELD source `Wrap { h: w.h }` let-init, and dest-in-rbx
// ARRAY_LIT `*p = [w]` (used to store the payload pointer; Darwin 10),
// and dest-in-rbx ARRAY_LIT of FIELD `*p = [w.h]` (array-elem type
// sized <9 so dest-in-rbx FIELD returned -2; Darwin leftover 12),
// and INDEX dest ARRAY_LIT `rows[0] = [w]` (emit_expr of ARRAY_LIT
// stored the payload pointer; Darwin leftover 10), and dest-in-rbx
// ARRAY VAR `*p = src` (whole-array memcpy dest-in-rbx; Darwin leftover
// 12 when total_bytes sized Wrap as 8).

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
 * dest-in-rbx nested STRUCT_LIT `*p = { h: { v: a } }`.
 * Kept in a small helper so the official large main() late-let dest-name
 * hole (empty `(struct )` after ~30 lets) is not this leaf.
 * @param p *Wrap — dest (must be non-null)
 * @param a i32x4 — source lanes
 */
function dest_nest_slit(p: *Wrap, a: i32x4): void {
  unsafe { *p = { h: { v: a } } }
}

/**
 * Exit 0 when dest `w.h.v[i]=`, return/let INDEX, Holder copy
 * `let h = w.h` / assign `h = w.h`, STRUCT_LIT `let w: Wrap = { h: inner }`,
 * dest-in-rbx FIELD source `*p = w.h`, ARRAY_LIT of a 16B named VAR
 * (`[w]` / `[h]`), INDEX-base FIELD dest-in-rbx `*p = arr[i].h`,
 * dest-in-rbx INDEX whole `*p = arr[i]`, dest-in-rbx DEREF
 * source `*p = *q`, STRUCT_LIT FIELD source `let w5: Wrap = { h: w.h }`,
 * dest-in-rbx STRUCT_LIT `*p = { h: w.h }`, dest-in-rbx
 * ARRAY_LIT `*p = [w]`, dest-in-rbx ARRAY VAR `*p = src`, and
 * dest-in-rbx nested STRUCT_LIT `*p = { h: { v: a } }`
 * write/read every lane.
 * Depth-1 `return h.v[1]` local lit is the same typeck (already 2).
 * @return i32 — 0 ok; 50/51/52/53 slit; 10/20/30/40 dest; 11/21/31/41 return;
 *   12/22/32/42 let; 13/23/33/43 copy; 14/24/34/44 assign;
 *   15/25/35/45 copy-as-param; 16/26/36/46 dest-in-rbx FIELD;
 *   17/27/37/47 ARRAY_LIT `[w]`; 18/28/38/48 ARRAY_LIT `[h]`;
 *   19/29/39/49 INDEX-base FIELD dest-in-rbx;
 *   60/61/62/63 dest-in-rbx INDEX whole;
 *   70/71/72/73 dest-in-rbx DEREF source;
 *   80/81/82/83 STRUCT_LIT FIELD source;
 *   84/85/86/87 dest-in-rbx STRUCT_LIT FIELD source;
 *   90/91/92/93 dest-in-rbx ARRAY_LIT `*p = [w]`;
 *   94/95/96/97 dest-in-rbx ARRAY_LIT of FIELD `*p = [w.h]`;
 *   98/99/100/101 INDEX dest ARRAY_LIT `rows[0] = [w]`;
 *   102/103/104/105 dest-in-rbx ARRAY VAR `*p = src`;
 *   106/107/108/109 dest-in-rbx nested STRUCT_LIT `*p = { h: { v: a } }`
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let inner: Holder = { v: a };
  let w: Wrap = { h: inner };
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
  let h2: Holder = { v: z };
  h2 = w.h;
  if (h2.v[0] != 1) { return 14; }
  if (h2.v[1] != 2) { return 24; }
  if (h2.v[2] != 3) { return 34; }
  if (h2.v[3] != 4) { return 44; }
  let dst: Holder = { v: z };
  let p: *Holder = &dst;
  unsafe { *p = w.h }
  if (dst.v[0] != 1) { return 16; }
  if (dst.v[1] != 2) { return 26; }
  if (dst.v[2] != 3) { return 36; }
  if (dst.v[3] != 4) { return 46; }
  let arrw: [1]Wrap = [w];
  if (arrw[0].h.v[0] != 1) { return 17; }
  if (arrw[0].h.v[1] != 2) { return 27; }
  if (arrw[0].h.v[2] != 3) { return 37; }
  if (arrw[0].h.v[3] != 4) { return 47; }
  let arrh: [1]Holder = [h];
  if (arrh[0].v[0] != 1) { return 18; }
  if (arrh[0].v[1] != 2) { return 28; }
  if (arrh[0].v[2] != 3) { return 38; }
  if (arrh[0].v[3] != 4) { return 48; }
  let arr: [2]Wrap = [{ h: { v: z } }, { h: { v: z } }];
  arr[0] = w;
  let dst2: Holder = { v: z };
  let p2: *Holder = &dst2;
  let i: i32 = 0;
  unsafe { *p2 = arr[i].h }
  if (dst2.v[0] != 1) { return 19; }
  if (dst2.v[1] != 2) { return 29; }
  if (dst2.v[2] != 3) { return 39; }
  if (dst2.v[3] != 4) { return 49; }
  let dst3: Wrap = { h: { v: z } };
  let p3: *Wrap = &dst3;
  unsafe { *p3 = arr[i] }
  if (dst3.h.v[0] != 1) { return 60; }
  if (dst3.h.v[1] != 2) { return 61; }
  if (dst3.h.v[2] != 3) { return 62; }
  if (dst3.h.v[3] != 4) { return 63; }
  let dst4: Wrap = { h: { v: z } };
  let q4: *Wrap = &arr[0];
  let p4: *Wrap = &dst4;
  unsafe { *p4 = *q4 }
  if (dst4.h.v[0] != 1) { return 70; }
  if (dst4.h.v[1] != 2) { return 71; }
  if (dst4.h.v[2] != 3) { return 72; }
  if (dst4.h.v[3] != 4) { return 73; }
  let w5: Wrap = { h: w.h };
  if (w5.h.v[0] != 1) { return 80; }
  if (w5.h.v[1] != 2) { return 81; }
  if (w5.h.v[2] != 3) { return 82; }
  if (w5.h.v[3] != 4) { return 83; }
  let dst5: Wrap = { h: { v: z } };
  let p5: *Wrap = &dst5;
  unsafe { *p5 = { h: w.h } }
  if (dst5.h.v[0] != 1) { return 84; }
  if (dst5.h.v[1] != 2) { return 85; }
  if (dst5.h.v[2] != 3) { return 86; }
  if (dst5.h.v[3] != 4) { return 87; }
  let dst6: [1]Wrap = [{ h: { v: z } }];
  let p6: *[1]Wrap = &dst6;
  unsafe { *p6 = [w] }
  if (dst6[0].h.v[0] != 1) { return 90; }
  if (dst6[0].h.v[1] != 2) { return 91; }
  if (dst6[0].h.v[2] != 3) { return 92; }
  if (dst6[0].h.v[3] != 4) { return 93; }
  let dst7: [1]Holder = [{ v: z }];
  let p7: *[1]Holder = &dst7;
  unsafe { *p7 = [w.h] }
  if (dst7[0].v[0] != 1) { return 94; }
  if (dst7[0].v[1] != 2) { return 95; }
  if (dst7[0].v[2] != 3) { return 96; }
  if (dst7[0].v[3] != 4) { return 97; }
  let rows: [1][1]Wrap = [[{ h: { v: z } }]];
  rows[0] = [w];
  if (rows[0][0].h.v[0] != 1) { return 98; }
  if (rows[0][0].h.v[1] != 2) { return 99; }
  if (rows[0][0].h.v[2] != 3) { return 100; }
  if (rows[0][0].h.v[3] != 4) { return 101; }
  let src8: [1]Wrap = [w];
  let dst8: [1]Wrap = [{ h: { v: z } }];
  let p8: *[1]Wrap = &dst8;
  unsafe { *p8 = src8 }
  if (dst8[0].h.v[0] != 1) { return 102; }
  if (dst8[0].h.v[1] != 2) { return 103; }
  if (dst8[0].h.v[2] != 3) { return 104; }
  if (dst8[0].h.v[3] != 4) { return 105; }
  let dst9: Wrap = { h: inner };
  let p9: *Wrap = &dst9;
  dest_nest_slit(p9, z);
  dest_nest_slit(p9, a);
  if (dst9.h.v[0] != 1) { return 106; }
  if (dst9.h.v[1] != 2) { return 107; }
  if (dst9.h.v[2] != 3) { return 108; }
  if (dst9.h.v[3] != 4) { return 109; }
  return 0;
}
