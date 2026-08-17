// dest extra-arm `with_arena(cap) { … }; dest` (optional compound ASI).
// MATCH extra-arm `with_arena(64) { k = 1 }; dest` used to typeck-fail
// XT001 (allocator region escape) — AL-04 assign complete is closed.
// dest extra-arm SIMD Wrap dest-in-rbx + with_arena used to SIGSEGV
// 139 on Ubuntu: glue_wa_scope_alloc_off_c planted Arena64 on dest_spill.
// Stacking MATCH + IF two with_arena dest in one main used to Darwin 139
// (onefunc kind=6 sidecar / dest_spill vs Arena64). Same emit skip
// (`off >= cur+24`) made stacking live. Gate polarity matches
// dest_region_semi / dest_match_region_semi: MATCH + IF + field-bind
// + no-semi twin. Expected exit 0.
// PLATFORM: SHARED dest extra-arm with_arena dest-in-rbx.

allow(padding) struct Holder { v: i32x4 }

allow(padding) struct Wrap { h: Holder }

/**
 * Gate dest extra-arm `with_arena { k = 1 }; dest` SIMD dest-in-rbx.
 * Stacks MATCH / IF / field-bind / no-semi (same polarity as dest_region_semi).
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

  // MATCH extra-arm with_arena + trailing dest STRUCT_LIT
  unsafe { *p = match tag { 1 => { with_arena(64) { k = 1 }; { h: { v: a } } }; _ => y; } }
  if (dst.h.v[0] != 1) { return 70; }
  if (dst.h.v[3] != 4) { return 71; }
  if (k != 1) { return 72; }

  // IF extra-arm with_arena + trailing dest STRUCT_LIT
  k = 0;
  unsafe {
    *p = if (tag == 1) {
      with_arena(64) { k = 1 };
      { h: { v: b } }
    } else {
      y
    }
  }
  if (dst.h.v[0] != 5) { return 73; }
  if (dst.h.v[3] != 8) { return 74; }
  if (k != 1) { return 75; }

  // MATCH field-bind extra-arm with_arena + dest field
  k = 0;
  let dsth: Holder = { v: z };
  let ph: *Holder = &dsth;
  unsafe { *ph = match w { Wrap { h } => { with_arena(64) { k = 1 }; h }; } }
  if (dsth.v[0] != 1) { return 76; }
  if (dsth.v[3] != 4) { return 77; }
  if (k != 1) { return 78; }

  // no-semi MATCH extra-arm with_arena still a stmt head
  k = 0;
  unsafe {
    *p = match tag {
      1 => {
        with_arena(64) { k = 1 }
        { h: { v: a } }
      };
      _ => y;
    }
  }
  if (dst.h.v[0] != 1) { return 79; }
  if (k != 1) { return 80; }
  return 0;
}
