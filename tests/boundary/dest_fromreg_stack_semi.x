// dest-from-region stacked intermediate last-wins.
// `unsafe { defer { k = 1 }; region { defer { k = 2 }; with_arena dest } }`
// host-C used to hoist wrapping FIFO (k=2 last) while dest-in-rbx
// LIFO last-wins outer (k=1). emit_block now hoists inner first,
// then outer, dest last. Own main: dest-park leftover is not this
// leaf. Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest-from-region stacked last-wins.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest-from-region stacked intermediate last-wins.
 * Stacks MATCH / IF / field-bind / no-semi.
 * Own file so dest-park leftover is not this leaf.
 * @return i32 — 0 ok; 124..135 leftover lanes
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

  // MATCH dest-from-region stacked last-wins leftover 124..126
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; region mid { defer { k = 2 }; with_arena(64) { { h: { v: a } } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 124; }
  if (dst.h.v[3] != 4) { return 125; }
  if (k != 1) { return 126; }

  // IF dest-from-region stacked last-wins leftover 127..129
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      unsafe { defer { k = 1 }; region mid2 { defer { k = 2 }; with_arena(64) { { h: { v: b } } } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 127; }
  if (dst.h.v[3] != 8) { return 128; }
  if (k != 1) { return 129; }

  // MATCH field-bind dest-from-region stacked leftover 130..132
  k = 0;
  unsafe {
    *ph = match w {
      Wrap { h } => {
        unsafe { defer { k = 1 }; region mid3 { defer { k = 2 }; with_arena(64) { h } } }
      };
    }
  }
  if (dsth.v[0] != 1) { return 130; }
  if (dsth.v[3] != 4) { return 131; }
  if (k != 1) { return 132; }

  // no-semi MATCH dest-from-region stacked leftover 133..135
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; region mid4 { defer { k = 2 }; with_arena(64) { { h: { v: a } } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 133; }
  if (dst.h.v[3] != 4) { return 134; }
  if (k != 1) { return 135; }
  return 0;
}
