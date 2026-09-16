// Stage 10 (10.4.1) slice3: language atomic i16 builtins (asm intercept).
// Extends slice1/2 i32/i64 path; product must inline — no atomic_*_c UNDEF.
// PLATFORM: LINUX x86_64 (asm lowering); SHARED surface.
const atomic = import("std.atomic.builtin");

/**
 * Language atomic i16 builtin smoke: store 41 → load → cas to 42 → fail CAS.
 * @return i32 — 42 on success; 2..6 on step failure
 * PLATFORM: LINUX x86_64 asm
 */
function main(): i32 {
  let x: i16 = 0 as i16;
  let exp: i16 = 0 as i16;
  unsafe {
    atomic.atomic_store_i16(&x, 41 as i16);
    if (atomic.atomic_load_i16(&x) != 41 as i16) {
      return 2;
    }
    exp = 41 as i16;
    if (atomic.atomic_cas_i16(&x, &exp, 42 as i16) == 0) {
      return 3;
    }
    if (atomic.atomic_load_i16(&x) != 42 as i16) {
      return 4;
    }
    exp = 99 as i16;
    if (atomic.atomic_cas_i16(&x, &exp, 7 as i16) != 0) {
      return 5;
    }
    if (exp != 42 as i16) {
      return 6;
    }
  }
  return 42;
}
