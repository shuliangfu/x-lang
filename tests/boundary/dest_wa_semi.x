// dest extra-arm `with_arena(cap) { … }; dest` (optional compound ASI).
// MATCH extra-arm `with_arena(64) { k = 1 }; dest` used to typeck-fail
// XT001 (allocator region escape) because AL-04 assign treated every
// outer write as escape. Scalar k=1 is not Allocator.
// Parse leftover already closed (parse_block TOKEN_WITH_ARENA ASI).
// i32 dest only — SIMD Wrap dest-in-rbx + with_arena Ubuntu SIGSEGV
// (emit another layer). Do not stack a second with_arena dest here.
// Expected exit 0.
// PLATFORM: SHARED dest extra-arm with_arena typeck.

/**
 * Gate dest extra-arm `with_arena { k = 1 }; dest` scalar assign.
 * @return i32 — 0 ok; 70 / 72 leftover lanes
 */
function main(): i32 {
  let dst: i32 = 0;
  let p: *i32 = &dst;
  let tag: i32 = 1;
  let k: i32 = 0;

  // MATCH extra-arm with_arena + trailing dest i32
  unsafe { *p = match tag { 1 => { with_arena(64) { k = 1 }; 7 }; _ => 8; } }
  if (dst != 7) { return 70; }
  if (k != 1) { return 72; }
  return 0;
}
