// Isolated: prefixed SIMD dest (`tag + i32x4` field_off!=0).
// STRUCT_LIT `Prefixed { tag: 7, v: z }` used to store the 16B vector
// at compute foff=+4 (glue_type_align_simple SIMD miss = 4). ARM64
// dest-in-x19 16B store encodes offset/8=0 and clobbers tag
// (Darwin tag=1 / exit 70). host-C already 0 (C ABI align 16).
// Dest assign `p.v = a` after retag was already 0 (vector let-init
// at the FIELD dest mag). This gate checks STRUCT_LIT tag+lanes,
// dest copy / CALL / METHOD, and `tag + Holder` dest.
// Does not INDEX `p.v[i]` (FIELD-chain SIMD INDEX leftover) and
// does not fold nest 21 / sat / x19 prologue.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// SIMD named align + STRUCT_LIT vector let-init.

allow(padding) struct Holder {
  v: i32x4
}

allow(padding) struct Prefixed {
  tag: i32
  v: i32x4
}

allow(padding) struct PrefixedH {
  tag: i32
  h: Holder
}

/**
 * Two-arg i32x4 add used as both free CALL and UFCS METHOD.
 * @param self i32x4 — left lanes (UFCS receiver / CALL arg0)
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other (fold: return p0 + p1)
 */
function add4(self: i32x4, other: i32x4): i32x4 {
  return self + other;
}

/**
 * Exit 0 when prefixed SIMD STRUCT_LIT keeps tag and dest writes every lane.
 * @return i32 — 0 ok; 70..73 tag clobber; 1..4 STRUCT_LIT lanes;
 *   11..14 dest copy; 21..24 dest CALL; 31..34 dest METHOD;
 *   80..84 PrefixedH tag / dest
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let z: i32x4 = [0, 0, 0, 0];
  let p: Prefixed = Prefixed { tag: 7, v: a };
  if (p.tag != 7) { return 70; }
  let t: i32x4 = p.v;
  if (t[0] != 1) { return 1; }
  if (t[1] != 2) { return 2; }
  if (t[2] != 3) { return 3; }
  if (t[3] != 4) { return 4; }
  p.v = z;
  if (p.tag != 7) { return 71; }
  p.v = a;
  if (p.tag != 7) { return 71; }
  let c: i32x4 = p.v;
  if (c[0] != 1) { return 11; }
  if (c[1] != 2) { return 12; }
  if (c[2] != 3) { return 13; }
  if (c[3] != 4) { return 14; }
  p.v = add4(a, b);
  if (p.tag != 7) { return 72; }
  let u: i32x4 = p.v;
  if (u[0] != 11) { return 21; }
  if (u[1] != 22) { return 22; }
  if (u[2] != 33) { return 23; }
  if (u[3] != 44) { return 24; }
  p.v = a.add4(b);
  if (p.tag != 7) { return 73; }
  let w: i32x4 = p.v;
  if (w[0] != 11) { return 31; }
  if (w[1] != 22) { return 32; }
  if (w[2] != 33) { return 33; }
  if (w[3] != 44) { return 34; }
  let inner: Holder = Holder { v: z };
  let ph: PrefixedH = PrefixedH { tag: 9, h: inner };
  if (ph.tag != 9) { return 80; }
  ph.h.v = a;
  if (ph.tag != 9) { return 81; }
  let h: i32x4 = ph.h.v;
  if (h[0] != 1) { return 82; }
  if (h[1] != 2) { return 83; }
  if (h[2] != 3) { return 84; }
  if (h[3] != 4) { return 85; }
  return 0;
}
