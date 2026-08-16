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
// ARRAY_LIT `rows[0] = [w]`, plus dest-in-rbx ARRAY VAR `*p = src`,
// plus runtime-index dest ARRAY_LIT `rows[i] = [w]`, plus INDEX dest
// ARRAY_LIT of a non-VAR base (`rh.rows[0]` / `grid[0][0]`), plus
// FIELD dest ARRAY_LIT `bag.one = [w]`, plus dest-in-rbx ARRAY_LIT
// of ARRAY_LIT `*p = [[w]]` / FIELD dest `bag.rows = [[w]]` /
// INDEX dest `grid[0] = [[w]]`. dest emit
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
// 12 when total_bytes sized Wrap as 8), and FIELD dest ARRAY_LIT
// `bag.one = [w]` (depth-1 FIELD dest stored the payload pointer;
// Darwin leftover 10), and dest-in-rbx ARRAY_LIT of ARRAY_LIT
// `*p = [[w]]` (inner ARRAY_LIT stored the payload pointer;
// Darwin leftover 10; FIELD `bag.rows = [[w]]` / INDEX
// `grid[0] = [[w]]` are the same produce), and dest-in-rbx
// ARRAY_LIT n>1 `*p = [w, w]` (ARM64 dest-shadow stayed at dest+0;
// Darwin leftover 12; FIELD `bag.two = [w, w]` / INDEX
// `grid[0] = [w, w]` / nested `*p = [[w], [w]]` are the same produce),
// and dest-in-rbx STRUCT_LIT field ARRAY_LIT `*p = { one: [w] }` /
// `*p = { two: [w, w] }` / sret `return { two: [w, w] }` (sret path
// emit_expr 8B + store esz; Darwin leftover 13 / 10), and STRUCT_LIT
// field ARRAY_LIT of nest `{ one: [{ h: { v: a } }] }` (field dest
// stamp skipped STRUCT_LIT elems; Darwin leftover 12/13), and
// dest-in-rbx ARRAY_LIT of CALL `*p = [make_w(a)]` / dest-in-rbx
// CALL `*p = make_w(a)` (x19 dest-shadow clobbered by callee;
// Darwin leftover 10 / 20), and dest-in-rbx IF
// `*p = if (c) { w } else { y }` (emit_expr of the then-arm VAR
// is 8B; Darwin leftover 12 / FIELD 52 / CALL 62 / STRUCT_LIT 72).

allow(padding) struct Holder {
  v: i32x4
}

allow(padding) struct Wrap {
  h: Holder
}

allow(padding) struct RowHolder {
  rows: [1][1]Wrap
}

allow(padding) struct Bag {
  one: [1]Wrap
}

allow(padding) struct PairBag {
  two: [2]Wrap
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
 * Return `[w]` of a 16B named VAR. Isolate already 0 after dest stamp;
 * official gate stays in this helper (large main late-let dest-name leftover).
 * @param w Wrap — source element
 * @return [1]Wrap — one-element array
 */
function ret_arr(w: Wrap): [1]Wrap {
  return [w];
}

/**
 * Return `[{ h: { v: a } }]` — ARRAY_LIT of a nested STRUCT_LIT.
 * typeck_check_expr_array_lit used to check_expr elems with expected=0
 * so inner `{ v: a }` had no Holder dest (Darwin leftover 12).
 * @param a i32x4 — source lanes
 * @return [1]Wrap — one-element array
 */
function ret_arr_nest(a: i32x4): [1]Wrap {
  return [{ h: { v: a } }];
}

/**
 * dest-in-rbx ARRAY_LIT of nested STRUCT_LIT `*p = [{ h: { v: a } }]`.
 * Same dest-stamp peel as `return [{ … }]`.
 * @param p *[1]Wrap — dest (must be non-null)
 * @param a i32x4 — source lanes
 */
function dest_arr_nest_slit(p: *[1]Wrap, a: i32x4): void {
  unsafe { *p = [{ h: { v: a } }] }
}

/**
 * Runtime-index dest ARRAY_LIT `rows[i] = [w]`.
 * Lit-index `rows[0] = [w]` is already gated in main(); this helper
 * keeps the runtime-index path off the official large main() late-let
 * dest-name leftover.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 122/123/124/125 leftover lanes
 */
function dest_rtidx_arrlit(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let rows: [1][1]Wrap = [[{ h: { v: z } }]];
  let i: i32 = 0;
  rows[i] = [w];
  if (rows[0][0].h.v[0] != 1) { return 122; }
  if (rows[0][0].h.v[1] != 2) { return 123; }
  if (rows[0][0].h.v[2] != 3) { return 124; }
  if (rows[0][0].h.v[3] != 4) { return 125; }
  return 0;
}

/**
 * INDEX dest ARRAY_LIT of a non-VAR base.
 * VAR `rows[0] = [w]` / `rows[i] = [w]` is already gated; TYPE_ARRAY
 * INDEX dest used to require base_kind==3 (VAR) so FIELD `rh.rows[0]`
 * / nested INDEX `grid[0][0]` stored the ARRAY_LIT payload pointer
 * (Darwin leftover 10). Kept in a small helper so the official large
 * main() late-let dest-name leftover is not this leaf.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 126..141 leftover lanes
 */
function dest_novar_idx_arrlit(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let rh: RowHolder = { rows: [[{ h: { v: z } }]] };
  rh.rows[0] = [w];
  if (rh.rows[0][0].h.v[0] != 1) { return 126; }
  if (rh.rows[0][0].h.v[1] != 2) { return 127; }
  if (rh.rows[0][0].h.v[2] != 3) { return 128; }
  if (rh.rows[0][0].h.v[3] != 4) { return 129; }
  let i: i32 = 0;
  let rh2: RowHolder = { rows: [[{ h: { v: z } }]] };
  rh2.rows[i] = [w];
  if (rh2.rows[0][0].h.v[0] != 1) { return 130; }
  if (rh2.rows[0][0].h.v[1] != 2) { return 131; }
  if (rh2.rows[0][0].h.v[2] != 3) { return 132; }
  if (rh2.rows[0][0].h.v[3] != 4) { return 133; }
  let grid: [1][1][1]Wrap = [[[{ h: { v: z } }]]];
  grid[0][0] = [w];
  if (grid[0][0][0].h.v[0] != 1) { return 134; }
  if (grid[0][0][0].h.v[1] != 2) { return 135; }
  if (grid[0][0][0].h.v[2] != 3) { return 136; }
  if (grid[0][0][0].h.v[3] != 4) { return 137; }
  let grid2: [1][1][1]Wrap = [[[{ h: { v: z } }]]];
  grid2[0][i] = [w];
  if (grid2[0][0][0].h.v[0] != 1) { return 138; }
  if (grid2[0][0][0].h.v[1] != 2) { return 139; }
  if (grid2[0][0][0].h.v[2] != 3) { return 140; }
  if (grid2[0][0][0].h.v[3] != 4) { return 141; }
  return 0;
}

/**
 * FIELD dest ARRAY_LIT `bag.one = [w]`.
 * INDEX dest `rows[0] = [w]` is already gated; FIELD dest TYPE_ARRAY
 * used to fall through to the depth-1 8B payload-pointer store
 * (Darwin leftover 10). Kept in a small helper so the official large
 * main() late-let dest-name leftover is not this leaf.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 142..145 leftover lanes
 */
function dest_field_arrlit(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let bag: Bag = { one: [{ h: { v: z } }] };
  bag.one = [w];
  if (bag.one[0].h.v[0] != 1) { return 142; }
  if (bag.one[0].h.v[1] != 2) { return 143; }
  if (bag.one[0].h.v[2] != 3) { return 144; }
  if (bag.one[0].h.v[3] != 4) { return 145; }
  return 0;
}

/**
 * dest-in-rbx ARRAY_LIT of ARRAY_LIT `*p = [[w]]`, plus FIELD dest
 * `rh.rows = [[w]]` and INDEX dest `grid[0] = [[w]]`. dest-in-rbx
 * ARRAY_LIT used to emit_expr the inner ARRAY_LIT (8B payload
 * pointer; Darwin leftover 10). Kept in a small helper so the
 * official large main() late-let dest-name leftover is not this leaf.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 146..157 leftover lanes
 */
function dest_arrlit2(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let dst: [1][1]Wrap = [[{ h: { v: z } }]];
  let p: *[1][1]Wrap = &dst;
  unsafe { *p = [[w]] }
  if (dst[0][0].h.v[0] != 1) { return 146; }
  if (dst[0][0].h.v[1] != 2) { return 147; }
  if (dst[0][0].h.v[2] != 3) { return 148; }
  if (dst[0][0].h.v[3] != 4) { return 149; }
  let rh: RowHolder = { rows: [[{ h: { v: z } }]] };
  rh.rows = [[w]];
  if (rh.rows[0][0].h.v[0] != 1) { return 150; }
  if (rh.rows[0][0].h.v[1] != 2) { return 151; }
  if (rh.rows[0][0].h.v[2] != 3) { return 152; }
  if (rh.rows[0][0].h.v[3] != 4) { return 153; }
  let grid: [1][1][1]Wrap = [[[{ h: { v: z } }]]];
  grid[0] = [[w]];
  if (grid[0][0][0].h.v[0] != 1) { return 154; }
  if (grid[0][0][0].h.v[1] != 2) { return 155; }
  if (grid[0][0][0].h.v[2] != 3) { return 156; }
  if (grid[0][0][0].h.v[3] != 4) { return 157; }
  return 0;
}

/**
 * dest-in-rbx ARRAY_LIT n>1 `*p = [w, w]`, plus FIELD dest
 * `bag.two = [w, w]` and INDEX dest `grid[0] = [w, w]`. dest-in-rbx
 * ARRAY_LIT advanced dest via add_imm_to_rbx (ARM64 ADD X1) while
 * dest lives in X19 (Darwin leftover 12). Kept in a small helper so
 * the official large main() late-let dest-name leftover is not this leaf.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 158..169 leftover lanes
 */
function dest_arrlit_n2(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let dst: [2]Wrap = [{ h: { v: z } }, { h: { v: z } }];
  let p: *[2]Wrap = &dst;
  unsafe { *p = [w, w] }
  if (dst[0].h.v[0] != 1) { return 158; }
  if (dst[0].h.v[3] != 4) { return 159; }
  if (dst[1].h.v[0] != 1) { return 160; }
  if (dst[1].h.v[3] != 4) { return 161; }
  let bag: PairBag = { two: [{ h: { v: z } }, { h: { v: z } }] };
  bag.two = [w, w];
  if (bag.two[0].h.v[0] != 1) { return 162; }
  if (bag.two[0].h.v[3] != 4) { return 163; }
  if (bag.two[1].h.v[0] != 1) { return 164; }
  if (bag.two[1].h.v[3] != 4) { return 165; }
  let grid: [1][2]Wrap = [[{ h: { v: z } }, { h: { v: z } }]];
  grid[0] = [w, w];
  if (grid[0][0].h.v[0] != 1) { return 166; }
  if (grid[0][0].h.v[3] != 4) { return 167; }
  if (grid[0][1].h.v[0] != 1) { return 168; }
  if (grid[0][1].h.v[3] != 4) { return 169; }
  return 0;
}

/**
 * sret STRUCT_LIT field ARRAY_LIT `return { two: [w, w] }`.
 * @param w Wrap — source element
 * @return PairBag — two copies of w
 */
function dest_mk_pair(w: Wrap): PairBag {
  return { two: [w, w] };
}

/**
 * dest-in-rbx STRUCT_LIT field ARRAY_LIT `*p = { one: [w] }` /
 * `*p = { two: [w, w] }` / dest-in-rbx ARRAY VAR `*p = { two: src }`
 * / sret `return { two: [w, w] }`. store_fixed_array_field sret path
 * used emit_expr + store esz (Darwin leftover 13 / 10 / 139). Nest
 * elems `{ two: [{ h: { v } }, …] }` is a dest leftover of dest-in-rbx
 * STRUCT_LIT wrapping dest-in-rbx ARRAY_LIT of nest STRUCT_LIT — not
 * this leaf. Kept in a small helper so the official large main()
 * late-let dest-name leftover is not this leaf.
 * @param w Wrap — source element
 * @return i32 — 0 ok; 170..181 leftover lanes
 */
function dest_slit_arrlit(w: Wrap): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let dst: Bag = { one: [{ h: { v: z } }] };
  let p: *Bag = &dst;
  unsafe { *p = { one: [w] } }
  if (dst.one[0].h.v[0] != 1) { return 170; }
  if (dst.one[0].h.v[3] != 4) { return 171; }
  let dst2: PairBag = { two: [{ h: { v: z } }, { h: { v: z } }] };
  let p2: *PairBag = &dst2;
  unsafe { *p2 = { two: [w, w] } }
  if (dst2.two[0].h.v[0] != 1) { return 172; }
  if (dst2.two[1].h.v[0] != 1) { return 173; }
  if (dst2.two[1].h.v[3] != 4) { return 174; }
  let src: [2]Wrap = [w, w];
  let dst4: PairBag = { two: [{ h: { v: z } }, { h: { v: z } }] };
  let p4: *PairBag = &dst4;
  unsafe { *p4 = { two: src } }
  if (dst4.two[0].h.v[0] != 1) { return 175; }
  if (dst4.two[1].h.v[0] != 1) { return 176; }
  if (dst4.two[1].h.v[3] != 4) { return 177; }
  let bag: PairBag = dest_mk_pair(w);
  if (bag.two[0].h.v[0] != 1) { return 178; }
  if (bag.two[0].h.v[3] != 4) { return 179; }
  if (bag.two[1].h.v[0] != 1) { return 180; }
  if (bag.two[1].h.v[3] != 4) { return 181; }
  return 0;
}

/**
 * sret STRUCT_LIT field ARRAY_LIT of nest `return { one: [{ h: { v: a } }] }`.
 * @param a i32x4 — source lanes
 * @return Bag — one nest elem
 */
function dest_mk_bag_nest(a: i32x4): Bag {
  return { one: [{ h: { v: a } }] };
}

/**
 * STRUCT_LIT field ARRAY_LIT of nest STRUCT_LIT.
 * dest-in-rbx `*p = { one: [{ h: { v: a } }] }` / n>1
 * `{ two: [{ … }, { … }] }` / frame dest
 * `let bag: Bag = { one: [{ … }] }` / sret `return { one: [{ … }] }`.
 * Field inits were check_expr'd with expected=0; array coerce stamped
 * the ARRAY_LIT dest type but skipped STRUCT_LIT elems so inner
 * `{ v: a }` had no Holder dest (Darwin leftover 12/13). Let
 * `let r: [1]Wrap = [{ … }]` already dest-stamps at coerce_init_expr.
 * Kept in a small helper so the official large main() late-let
 * dest-name leftover is not this leaf.
 * @param a i32x4 — source lanes
 * @return i32 — 0 ok; 182..197 leftover lanes
 */
function dest_slit_arrlit_nest(a: i32x4): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let dst: Bag = { one: [{ h: { v: z } }] };
  let p: *Bag = &dst;
  unsafe { *p = { one: [{ h: { v: a } }] } }
  if (dst.one[0].h.v[0] != 1) { return 182; }
  if (dst.one[0].h.v[1] != 2) { return 183; }
  if (dst.one[0].h.v[2] != 3) { return 184; }
  if (dst.one[0].h.v[3] != 4) { return 185; }
  let dst2: PairBag = { two: [{ h: { v: z } }, { h: { v: z } }] };
  let p2: *PairBag = &dst2;
  unsafe { *p2 = { two: [{ h: { v: a } }, { h: { v: a } }] } }
  if (dst2.two[0].h.v[0] != 1) { return 186; }
  if (dst2.two[0].h.v[2] != 3) { return 187; }
  if (dst2.two[1].h.v[0] != 1) { return 188; }
  if (dst2.two[1].h.v[3] != 4) { return 189; }
  let bag: Bag = { one: [{ h: { v: a } }] };
  if (bag.one[0].h.v[0] != 1) { return 190; }
  if (bag.one[0].h.v[1] != 2) { return 191; }
  if (bag.one[0].h.v[2] != 3) { return 192; }
  if (bag.one[0].h.v[3] != 4) { return 193; }
  let bag2: Bag = dest_mk_bag_nest(a);
  if (bag2.one[0].h.v[0] != 1) { return 194; }
  if (bag2.one[0].h.v[1] != 2) { return 195; }
  if (bag2.one[0].h.v[2] != 3) { return 196; }
  if (bag2.one[0].h.v[3] != 4) { return 197; }
  return 0;
}

/**
 * Same-module Wrap factory. dest-in-rbx CALL `*p = make_w(a)` and
 * dest-in-rbx ARRAY_LIT of CALL `*p = [make_w(a)]` consume this.
 * @param a i32x4 — source lanes
 * @return Wrap — { h: { v: a } }
 */
function dest_mk_w(a: i32x4): Wrap {
  return { h: { v: a } };
}

/**
 * dest-in-rbx CALL `*p = dest_mk_w(a)` and dest-in-rbx ARRAY_LIT of
 * CALL `*p = [dest_mk_w(a)]` / n>1 / FIELD dest / INDEX dest.
 * dest-in-rbx ≤16B CALL stored through x19 after emit; generated
 * callees use x19 as dest-shadow and the ARM64 prologue does not
 * save it (Darwin leftover 20 / 10). Frame dest
 * `let r: [1]Wrap = [dest_mk_w(a)]` is already green. Kept in a
 * small helper so the official large main() late-let dest-name
 * leftover is not this leaf.
 * @param a i32x4 — source lanes
 * @return i32 — 0 ok; 198..217 leftover lanes
 */
function dest_arrlit_call(a: i32x4): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  unsafe { *p = dest_mk_w(a) }
  if (dst.h.v[0] != 1) { return 198; }
  if (dst.h.v[1] != 2) { return 199; }
  if (dst.h.v[2] != 3) { return 200; }
  if (dst.h.v[3] != 4) { return 201; }
  let dst2: [1]Wrap = [{ h: { v: z } }];
  let p2: *[1]Wrap = &dst2;
  unsafe { *p2 = [dest_mk_w(a)] }
  if (dst2[0].h.v[0] != 1) { return 202; }
  if (dst2[0].h.v[1] != 2) { return 203; }
  if (dst2[0].h.v[2] != 3) { return 204; }
  if (dst2[0].h.v[3] != 4) { return 205; }
  let dst3: [2]Wrap = [{ h: { v: z } }, { h: { v: z } }];
  let p3: *[2]Wrap = &dst3;
  unsafe { *p3 = [dest_mk_w(a), dest_mk_w(a)] }
  if (dst3[0].h.v[0] != 1) { return 206; }
  if (dst3[0].h.v[3] != 4) { return 207; }
  if (dst3[1].h.v[0] != 1) { return 208; }
  if (dst3[1].h.v[3] != 4) { return 209; }
  let bag: Bag = { one: [{ h: { v: z } }] };
  bag.one = [dest_mk_w(a)];
  if (bag.one[0].h.v[0] != 1) { return 210; }
  if (bag.one[0].h.v[3] != 4) { return 211; }
  let rows: [1][1]Wrap = [[{ h: { v: z } }]];
  rows[0] = [dest_mk_w(a)];
  if (rows[0][0].h.v[0] != 1) { return 212; }
  if (rows[0][0].h.v[3] != 4) { return 213; }
  let r: [1]Wrap = [dest_mk_w(a)];
  if (r[0].h.v[0] != 1) { return 214; }
  if (r[0].h.v[3] != 4) { return 215; }
  let bag2: Bag = { one: [{ h: { v: z } }] };
  let p4: *Bag = &bag2;
  unsafe { *p4 = { one: [dest_mk_w(a)] } }
  if (bag2.one[0].h.v[0] != 1) { return 216; }
  if (bag2.one[0].h.v[3] != 4) { return 217; }
  return 0;
}

/**
 * dest-in-rbx IF `*p = if (c) { w } else { y }` / false arm /
 * FIELD / CALL / STRUCT_LIT / ARRAY_LIT `[w]`. dest-in-rbx
 * let-init used to miss EXPR_IF (25); emit_expr of the then-arm
 * VAR is 8B (Darwin leftover 12). Frame dest `let r: Wrap = if`
 * is already green. dest-in-rbx IF of ARRAY_LIT used to CG002
 * (peel yields ARRAY_LIT; dest-in-rbx STRUCT_LIT is ko==45).
 * dest-in-rbx IF extra arm stmts (`let t: T = a; { dest }`)
 * used to CG002 (peel skipped the let; `t` never landed).
 * dest-in-rbx IF extra arm loops/ifs (while/for/if-stmt as
 * prefix) used to skip so dest was ok and the side effect
 * was lost (isolate run=11).
 * Kept in a small helper so the official large main() late-let
 * dest-name leftover is not this leaf.
 * @param a i32x4 — then-arm lanes
 * @return i32 — 0 ok; 218..299 leftover lanes
 */
function dest_if_dest(a: i32x4): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let b: i32x4 = [5, 6, 7, 8];
  let w: Wrap = { h: { v: a } };
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let c: bool = true;
  unsafe { *p = if (c) { w } else { y } }
  if (dst.h.v[0] != 1) { return 218; }
  if (dst.h.v[1] != 2) { return 219; }
  if (dst.h.v[2] != 3) { return 220; }
  if (dst.h.v[3] != 4) { return 221; }
  c = false;
  unsafe { *p = if (c) { w } else { y } }
  if (dst.h.v[0] != 5) { return 222; }
  if (dst.h.v[1] != 6) { return 223; }
  if (dst.h.v[2] != 7) { return 224; }
  if (dst.h.v[3] != 8) { return 225; }
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;
  c = true;
  unsafe { *ph = if (c) { w.h } else { y.h } }
  if (dsth.v[0] != 1) { return 226; }
  if (dsth.v[1] != 2) { return 227; }
  if (dsth.v[2] != 3) { return 228; }
  if (dsth.v[3] != 4) { return 229; }
  unsafe { *p = if (c) { dest_mk_w(a) } else { y } }
  if (dst.h.v[0] != 1) { return 230; }
  if (dst.h.v[1] != 2) { return 231; }
  if (dst.h.v[2] != 3) { return 232; }
  if (dst.h.v[3] != 4) { return 233; }
  /* Frame dest IF both-arm STRUCT_LIT. dest-in-rbx IF of STRUCT_LIT
   * used to CG002 because `{ { h: { v: a } } }` stores a nested
   * BLOCK as the last expr_stmt (final_expr 0). G.7: peel BLOCK
   * wrappers then emit the lit into a frame temp + memcpy. */
  let rslit: Wrap = if (c) { { h: { v: a } } } else { { h: { v: b } } };
  if (rslit.h.v[0] != 1) { return 234; }
  if (rslit.h.v[1] != 2) { return 235; }
  if (rslit.h.v[2] != 3) { return 236; }
  if (rslit.h.v[3] != 4) { return 237; }
  let dsts: Wrap = { h: { v: z } };
  let ps: *Wrap = &dsts;
  unsafe { *ps = if (c) { { h: { v: a } } } else { y } }
  if (dsts.h.v[0] != 1) { return 238; }
  if (dsts.h.v[1] != 2) { return 239; }
  if (dsts.h.v[2] != 3) { return 240; }
  if (dsts.h.v[3] != 4) { return 241; }
  unsafe { *ps = if (c) { { h: { v: a } } } else { { h: { v: b } } } }
  if (dsts.h.v[0] != 1) { return 242; }
  if (dsts.h.v[1] != 2) { return 243; }
  if (dsts.h.v[2] != 3) { return 244; }
  if (dsts.h.v[3] != 4) { return 245; }
  c = false;
  unsafe { *ps = if (c) { w } else { { h: { v: b } } } }
  if (dsts.h.v[0] != 5) { return 246; }
  if (dsts.h.v[1] != 6) { return 247; }
  if (dsts.h.v[2] != 7) { return 248; }
  if (dsts.h.v[3] != 8) { return 249; }
  /* dest-in-rbx IF of ARRAY_LIT. dest TYPE_ARRAY peel is ARRAY_LIT
   * (ko==46); dest-in-rbx STRUCT_LIT is ko==45. G.7: dest-in-rbx
   * ARRAY_LIT standalone.
   * PLATFORM: SHARED dest-in-rbx IF ARRAY_LIT. */
  let dsta: [1]Wrap = [{ h: { v: z } }];
  let pa: *[1]Wrap = &dsta;
  c = true;
  unsafe { *pa = if (c) { [w] } else { [y] } }
  if (dsta[0].h.v[0] != 1) { return 250; }
  if (dsta[0].h.v[1] != 2) { return 251; }
  if (dsta[0].h.v[2] != 3) { return 252; }
  if (dsta[0].h.v[3] != 4) { return 253; }
  c = false;
  unsafe { *pa = if (c) { [w] } else { [y] } }
  if (dsta[0].h.v[0] != 5) { return 254; }
  if (dsta[0].h.v[1] != 6) { return 255; }
  if (dsta[0].h.v[2] != 7) { return 256; }
  if (dsta[0].h.v[3] != 8) { return 257; }
  /* dest-in-rbx IF extra arm stmts. Peel used to take only the
   * last expr; preceding `let t` never landed (Darwin CG002)
   * and preceding assign skipped the side effect. G.7: ensure
   * + block_inits + preceding expr_stmts.
   * PLATFORM: SHARED dest-in-rbx IF extra arm stmts. */
  let k: i32 = 0;
  c = true;
  unsafe { *p = if (c) { let t: i32x4 = a; { h: { v: t } } } else { y } }
  if (dst.h.v[0] != 1) { return 258; }
  if (dst.h.v[1] != 2) { return 259; }
  if (dst.h.v[2] != 3) { return 260; }
  if (dst.h.v[3] != 4) { return 261; }
  c = false;
  unsafe { *p = if (c) { w } else { let t2: i32x4 = b; { h: { v: t2 } } } }
  if (dst.h.v[0] != 5) { return 262; }
  if (dst.h.v[1] != 6) { return 263; }
  if (dst.h.v[2] != 7) { return 264; }
  if (dst.h.v[3] != 8) { return 265; }
  c = true;
  unsafe { *p = if (c) { k = 1; { h: { v: a } } } else { y } }
  if (dst.h.v[0] != 1) { return 266; }
  if (k != 1) { return 267; }
  unsafe { *p = if (c) { let th: Holder = { v: a }; { h: th } } else { y } }
  if (dst.h.v[0] != 1) { return 268; }
  if (dst.h.v[3] != 4) { return 269; }
  /* dest-in-rbx IF of MATCH. Peel yields MATCH (ko==43);
   * dest-in-rbx STRUCT_LIT / ARRAY_LIT do not apply. dest-in-rbx
   * let-init MATCH used to return −2 (Darwin CG002).
   * PLATFORM: SHARED dest-in-rbx IF of MATCH. */
  let tag: i32 = 1;
  unsafe { *p = if (c) { match tag { 1 => w; _ => y; } } else { y } }
  if (dst.h.v[0] != 1) { return 270; }
  if (dst.h.v[1] != 2) { return 271; }
  if (dst.h.v[2] != 3) { return 272; }
  if (dst.h.v[3] != 4) { return 273; }
  /* dest-in-rbx IF extra arm loops/ifs. Prefix so_k 3/4/5
   * used to skip (dest ok, side effect lost, isolate run=11).
   * Frame dest extra while is already green via body_sync.
   * G.7: body_sync while/for/if-stmt emit as prefix.
   * PLATFORM: SHARED dest-in-rbx IF extra arm loops. */
  k = 0;
  c = true;
  unsafe {
    *p = if (c) {
      while (k < 1) {
        k = k + 1
      }
      { h: { v: a } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 1) { return 292; }
  if (k != 1) { return 293; }
  k = 0;
  c = false;
  unsafe {
    *p = if (c) {
      w
    } else {
      while (k < 1) {
        k = k + 1
      }
      { h: { v: b } }
    }
  }
  if (dst.h.v[0] != 5) { return 294; }
  if (k != 1) { return 295; }
  k = 0;
  c = true;
  unsafe {
    *p = if (c) {
      if (c) {
        k = 1
      }
      { h: { v: a } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 1) { return 296; }
  if (k != 1) { return 297; }
  k = 0;
  unsafe {
    *p = if (c) {
      for ( ; k < 1 ; k = k + 1) {
      }
      { h: { v: a } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 1) { return 298; }
  if (k != 1) { return 299; }
  return 0;
}

/**
 * dest-in-rbx MATCH `*p = match tag { 1 => w; _ => y }`.
 * emit_expr of MATCH is 8B (Darwin leftover 12). Frame dest
 * `let r = match` is already green. Kept in a small helper so
 * the official large main() late-let dest-name leftover is not
 * this leaf.
 * @param a i32x4 — source lanes
 * @return i32 — 0 ok; 274..297 leftover lanes
 * PLATFORM: SHARED dest-in-rbx MATCH.
 */
function dest_match_dest(a: i32x4): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let b: i32x4 = [5, 6, 7, 8];
  let w: Wrap = { h: { v: a } };
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let tag: i32 = 1;
  unsafe { *p = match tag { 1 => w; _ => y; } }
  if (dst.h.v[0] != 1) { return 274; }
  if (dst.h.v[1] != 2) { return 275; }
  if (dst.h.v[2] != 3) { return 276; }
  if (dst.h.v[3] != 4) { return 277; }
  tag = 0;
  unsafe { *p = match tag { 1 => w; _ => y; } }
  if (dst.h.v[0] != 5) { return 278; }
  if (dst.h.v[1] != 6) { return 279; }
  if (dst.h.v[2] != 7) { return 280; }
  if (dst.h.v[3] != 8) { return 281; }
  tag = 1;
  unsafe { *p = match tag { 1 => { h: { v: a } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 282; }
  if (dst.h.v[3] != 4) { return 283; }
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;
  unsafe { *ph = match tag { 1 => w.h; _ => y.h; } }
  if (dsth.v[0] != 1) { return 284; }
  if (dsth.v[3] != 4) { return 285; }
  unsafe { *p = match tag { 1 => dest_mk_w(a); _ => y; } }
  if (dst.h.v[0] != 1) { return 286; }
  if (dst.h.v[3] != 4) { return 287; }
  let dsta: [1]Wrap = [{ h: { v: z } }];
  let pa: *[1]Wrap = &dsta;
  unsafe { *pa = match tag { 1 => [w]; _ => [y]; } }
  if (dsta[0].h.v[0] != 1) { return 288; }
  if (dsta[0].h.v[3] != 4) { return 289; }
  tag = 0;
  unsafe { *pa = match tag { 1 => [w]; _ => [y]; } }
  if (dsta[0].h.v[0] != 5) { return 290; }
  if (dsta[0].h.v[3] != 8) { return 291; }
  return 0;
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
 *   106/107/108/109 dest-in-rbx nested STRUCT_LIT `*p = { h: { v: a } }`;
 *   110/111/112/113 `return [w]`;
 *   114/115/116/117 `return [{ h: { v: a } }]`;
 *   118/119/120/121 dest-in-rbx ARRAY_LIT nest `*p = [{ h: { v: a } }]`;
 *   122/123/124/125 runtime-index dest ARRAY_LIT `rows[i] = [w]`;
 *   126/127/128/129 FIELD-base lit `rh.rows[0] = [w]`;
 *   130/131/132/133 FIELD-base runtime `rh.rows[i] = [w]`;
 *   134/135/136/137 nested INDEX lit `grid[0][0] = [w]`;
 *   138/139/140/141 nested INDEX runtime `grid[0][i] = [w]`;
 *   142/143/144/145 FIELD dest ARRAY_LIT `bag.one = [w]`;
 *   146/147/148/149 dest-in-rbx ARRAY_LIT of ARRAY_LIT `*p = [[w]]`;
 *   150/151/152/153 FIELD dest 2D ARRAY_LIT `rh.rows = [[w]]`;
 *   154/155/156/157 INDEX dest 2D ARRAY_LIT `grid[0] = [[w]]`;
 *   158/159/160/161 dest-in-rbx ARRAY_LIT n>1 `*p = [w, w]`;
 *   162/163/164/165 FIELD dest n>1 `bag.two = [w, w]`;
 *   166/167/168/169 INDEX dest n>1 `grid[0] = [w, w]`;
 *   198..201 dest-in-rbx CALL `*p = dest_mk_w(a)`;
 *   202..205 dest-in-rbx ARRAY_LIT of CALL `*p = [dest_mk_w(a)]`;
 *   206..209 dest-in-rbx ARRAY_LIT of CALL n>1;
 *   210/211 FIELD dest ARRAY_LIT of CALL;
 *   212/213 INDEX dest ARRAY_LIT of CALL;
 *   214/215 frame dest ARRAY_LIT of CALL;
 *   216/217 dest-in-rbx STRUCT_LIT field ARRAY_LIT of CALL;
 *   218..221 dest-in-rbx IF `*p = if (c) { w } else { y }`;
 *   222..225 dest-in-rbx IF false arm;
 *   226..229 dest-in-rbx IF FIELD;
 *   230..233 dest-in-rbx IF CALL
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
  /* Official late-let dest-name gate: after ~30 lets + ifs, stmt_order
   * used to stop at 96 so this STRUCT_LIT never dest-stamped
   * (`(struct )` on -E). G.7: walk every stmt_order entry.
   * PLATFORM: SHARED — large-main late-let dest-name. */
  let dst9: Wrap = { h: inner };
  let p9: *Wrap = &dst9;
  dest_nest_slit(p9, z);
  dest_nest_slit(p9, a);
  if (dst9.h.v[0] != 1) { return 106; }
  if (dst9.h.v[1] != 2) { return 107; }
  if (dst9.h.v[2] != 3) { return 108; }
  if (dst9.h.v[3] != 4) { return 109; }
  let r10: [1]Wrap = ret_arr(w);
  if (r10[0].h.v[0] != 1) { return 110; }
  if (r10[0].h.v[1] != 2) { return 111; }
  if (r10[0].h.v[2] != 3) { return 112; }
  if (r10[0].h.v[3] != 4) { return 113; }
  let r11: [1]Wrap = ret_arr_nest(a);
  if (r11[0].h.v[0] != 1) { return 114; }
  if (r11[0].h.v[1] != 2) { return 115; }
  if (r11[0].h.v[2] != 3) { return 116; }
  if (r11[0].h.v[3] != 4) { return 117; }
  let dst12: [1]Wrap = [{ h: { v: z } }];
  let p12: *[1]Wrap = &dst12;
  dest_arr_nest_slit(p12, z);
  dest_arr_nest_slit(p12, a);
  if (dst12[0].h.v[0] != 1) { return 118; }
  if (dst12[0].h.v[1] != 2) { return 119; }
  if (dst12[0].h.v[2] != 3) { return 120; }
  if (dst12[0].h.v[3] != 4) { return 121; }
  let r13: i32 = dest_rtidx_arrlit(w);
  if (r13 != 0) { return r13; }
  let r14: i32 = dest_novar_idx_arrlit(w);
  if (r14 != 0) { return r14; }
  let r15: i32 = dest_field_arrlit(w);
  if (r15 != 0) { return r15; }
  let r16: i32 = dest_arrlit2(w);
  if (r16 != 0) { return r16; }
  let r17: i32 = dest_arrlit_n2(w);
  if (r17 != 0) { return r17; }
  let r18: i32 = dest_slit_arrlit(w);
  if (r18 != 0) { return r18; }
  let r19: i32 = dest_slit_arrlit_nest(a);
  if (r19 != 0) { return r19; }
  let r20: i32 = dest_arrlit_call(a);
  if (r20 != 0) { return r20; }
  let r21: i32 = dest_if_dest(a);
  if (r21 != 0) { return r21; }
  let r22: i32 = dest_match_dest(a);
  if (r22 != 0) { return r22; }
  return 0;
}
