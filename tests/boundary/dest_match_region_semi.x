// dest extra-arm `unsafe { … }; dest` (optional compound ASI).
// MATCH / IF extra-arm `unsafe { k = 1 }; { dest }` used to drop the
// whole function (P001). No-semi dest_if extra-arm region is already
// green in dest_if_dest 300–303. Gate lives here so dest-park leftover
// is not this leaf. Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm unsafe compound ASI.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `unsafe { … }; dest` optional compound ASI.
 * @return i32 — 0 ok; 70..80 leftover lanes
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

  // MATCH extra-arm unsafe + trailing STRUCT_LIT
  unsafe { *p = match tag { 1 => { unsafe { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 70; }
  if (dst.h.v[3] != 4) { return 71; }
  if (k != 1) { return 72; }

  // IF extra-arm unsafe + trailing STRUCT_LIT
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      unsafe { k = 1 };
      { h: { v: b } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 73; }
  if (dst.h.v[3] != 8) { return 74; }
  if (k != 1) { return 75; }

  // MATCH field-bind extra-arm unsafe + dest field
  k = 0;
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;
  unsafe { *ph = match w { Wrap { h } => { unsafe { k = 1 }; h }; } }
  if (dsth.v[0] != 1) { return 76; }
  if (dsth.v[3] != 4) { return 77; }
  if (k != 1) { return 78; }

  // no-semi MATCH extra-arm region still a stmt head (dest_if twin)
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        unsafe { k = 1 }
        { h: { v: a } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 79; }
  if (k != 1) { return 80; }
  return 0;
}
