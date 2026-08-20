// dest-from-region intermediate `unsafe { defer { k = 1 }; with_arena { dest } }`
// used to keep dest last on host-C as `(k=1)` (GNU stmt-expr last
// value assigned to Wrap). emit_block now runs wrapping defers
// before last so_k==6 dest. Own main: stacking leftover 112+
// into dest_region_semi blows Ubuntu dest-park (asm 139).
// Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest-from-region intermediate stmt-expr last-value.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest-from-region intermediate stmt-expr last-value.
 * Stacks MATCH / IF / field-bind / no-semi.
 * Own file so dest-park leftover is not this leaf.
 * @return i32 — 0 ok; 112..123 leftover lanes
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [5, 6, 7, 8];
  let z: i32x4 = [0, 0, 0, 0];
  let w: Wrap = { h: { v: a } };
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let tag: i32 = 1;
  let k: i32 = 0;
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;

  // MATCH dest-from-region intermediate-region defer leftover 112..114
  unsafe { *p = match tag { 1 => { unsafe { defer { k = 1 }; with_arena(64) { { h: { v: a } } } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 112; }
  if (dst.h.v[3] != 4) { return 113; }
  if (k != 1) { return 114; }

  // IF dest-from-region intermediate-region defer leftover 115..117
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      unsafe { defer { k = 1 }; with_arena(64) { { h: { v: b } } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 115; }
  if (dst.h.v[3] != 8) { return 116; }
  if (k != 1) { return 117; }

  // MATCH field-bind dest-from-region intermediate leftover 118..120
  k = 0;
  unsafe { *ph = match w { Wrap { h } => { unsafe { defer { k = 1 }; with_arena(64) { h } } }; } }
  if (dsth.v[0] != 1) { return 118; }
  if (dsth.v[3] != 4) { return 119; }
  if (k != 1) { return 120; }

  // no-semi MATCH dest-from-region intermediate leftover 121..123
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; with_arena(64) { { h: { v: a } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 121; }
  if (dst.h.v[3] != 4) { return 122; }
  if (k != 1) { return 123; }
  return 0;
}
