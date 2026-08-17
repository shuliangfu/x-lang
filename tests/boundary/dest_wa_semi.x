// dest extra-arm `with_arena(cap) { … }; dest` (optional compound ASI).
// MATCH extra-arm `with_arena(64) { k = 1 }; { dest }` used to
// typeck-fail XT001 (allocator region escape) because AL-04 assign
// treated every outer write as escape. Scalar k=1 is not Allocator.
// Parse leftover already closed (parse_block TOKEN_WITH_ARENA ASI).
// One with_arena dest lane only — stacking MATCH+IF with_arena in
// the same main Darwin-SIGSEGV (emit / kind=6 sidecar another layer).
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm with_arena typeck.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `with_arena { k = 1 }; dest` scalar assign.
 * @return i32 — 0 ok; 70..72 leftover lanes
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [5, 6, 7, 8];
  let z: i32x4 = [0, 0, 0, 0];
  let y: Wrap = { h: { v: b } };
  let dst: Wrap = { h: { v: z } };
  let p: *Wrap = &dst;
  let tag: i32 = 1;
  let k: i32 = 0;

  // MATCH extra-arm with_arena + trailing STRUCT_LIT
  unsafe { *p = match tag { 1 => { with_arena(64) { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 70; }
  if (dst.h.v[3] != 4) { return 71; }
  if (k != 1) { return 72; }
  return 0;
}
