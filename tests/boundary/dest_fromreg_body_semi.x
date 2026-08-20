// dest-from-region wrapping + dest-region-body last-wins.
// `unsafe { defer { k = 1 }; with_arena { defer { k = 2 }; dest } }`
// host-C used to hoist dest-region-body then wrapping, then dest
// emit re-ran dest-region-body (stmt_order==0 fallback) so last-wins
// k=2. emit_block skip-wrap now covers that fallback; dest last,
// last-wins outer k=1. Own main: dest-park leftover is not this
// leaf. Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED dest-from-region dest-region-body last-wins.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest-from-region wrapping + dest-region-body last-wins.
 * Stacks MATCH / IF / field-bind / no-semi.
 * Own file so dest-park leftover is not this leaf.
 * @return i32 — 0 ok; 136..147 leftover lanes
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

  // MATCH dest-from-region dest-region-body last-wins leftover 136..138
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; with_arena(64) { defer { k = 2 }; { h: { v: a } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 136; }
  if (dst.h.v[3] != 4) { return 137; }
  if (k != 1) { return 138; }

  // IF dest-from-region dest-region-body last-wins leftover 139..141
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      unsafe { defer { k = 1 }; with_arena(64) { defer { k = 2 }; { h: { v: b } } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 139; }
  if (dst.h.v[3] != 8) { return 140; }
  if (k != 1) { return 141; }

  // MATCH field-bind dest-from-region dest-region-body leftover 142..144
  k = 0;
  unsafe {
    *ph = match w {
      Wrap { h } => {
        unsafe { defer { k = 1 }; with_arena(64) { defer { k = 2 }; h } }
      };
    }
  }
  if (dsth.v[0] != 1) { return 142; }
  if (dsth.v[3] != 4) { return 143; }
  if (k != 1) { return 144; }

  // no-semi MATCH dest-from-region dest-region-body leftover 145..147
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        unsafe { defer { k = 1 }; with_arena(64) { defer { k = 2 }; { h: { v: a } } } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 145; }
  if (dst.h.v[3] != 4) { return 146; }
  if (k != 1) { return 147; }
  return 0;
}
