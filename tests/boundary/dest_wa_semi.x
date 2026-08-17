// dest extra-arm `with_arena(cap) { … }; dest` (optional compound ASI).
// MATCH extra-arm `with_arena(64) { k = 1 }; dest` used to typeck-fail
// XT001 (allocator region escape) — AL-04 assign complete is closed.
// dest extra-arm SIMD Wrap dest-in-rbx + with_arena used to SIGSEGV
// 139 on Ubuntu: glue_wa_scope_alloc_off_c planted Arena64 on dest_spill.
// Do not stack a second with_arena dest here (onefunc kind=6 sidecar).
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm with_arena dest-in-rbx.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `with_arena { k = 1 }; dest` SIMD dest-in-rbx.
 * @return i32 — 0 ok; 70 / 71 / 72 leftover lanes
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

  // MATCH extra-arm with_arena + trailing dest STRUCT_LIT
  unsafe { *p = match tag { 1 => { with_arena(64) { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 70; }
  if (dst.h.v[3] != 4) { return 71; }
  if (k != 1) { return 72; }
  return 0;
}
