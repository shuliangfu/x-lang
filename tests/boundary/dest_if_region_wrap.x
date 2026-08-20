// dest-in-rbx IF dest wrapped in unsafe
// `*p = if (c) { unsafe { { dest } } } else { y }`.
// Peel used only final_expr / last expr_stmt so last stmt
// kind 6 aborted (Darwin CG002 `.Lf0_1`). Frame dest wrap
// is already green via body_sync. dest_if_dest dest-park of
// this dest overflowed the helper into caller `w`; large
// official main dest-park CG002 `.Lf0_0`. Gate lives in
// this small file so dest-park uses a leftover prologue.
// dest-region dest uses dest-in-rbx −3. Leftover codes
// stay in 1..255 (main exit is 8-bit; 307 became 51).
// Expected exit 0.
// PLATFORM: SHARED dest-in-rbx IF dest region.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [5, 6, 7, 8];
  let z: i32x4 = [0, 0, 0, 0];
  let w: Wrap = { h: { v: a } };
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let c: bool = true;
  unsafe {
    *p = if (c) {
      unsafe { { h: { v: a } } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 1) { return 80; }
  if (dst.h.v[3] != 4) { return 81; }
  c = false;
  unsafe {
    *p = if (c) {
      w
    } else {
      unsafe { { h: { v: b } } }
    }
  }
  if (dst.h.v[0] != 5) { return 82; }
  if (dst.h.v[3] != 8) { return 83; }
  return 0;
}
