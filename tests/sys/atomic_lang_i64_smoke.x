// Stage 10 (10.4.1) slice2: language atomic i64 builtins (asm intercept).
// Extends slice1 i32 path; product must inline — no atomic_*_c UNDEF.
// PLATFORM: LINUX x86_64 (asm lowering); SHARED surface.
const atomic = import("std.atomic.builtin");

/**
 * Language atomic i64 builtin smoke: store 41 → load → cas to 42 → fail CAS.
 * @return i32 — 42 on success; 2..6 on step failure
 * PLATFORM: LINUX x86_64 asm
 */
function main(): i32 {
  let x: i64 = 0;
  let exp: i64 = 0;
  unsafe {
    atomic.atomic_store_i64(&x, 41);
    if (atomic.atomic_load_i64(&x) != 41) {
      return 2;
    }
    exp = 41;
    if (atomic.atomic_cas_i64(&x, &exp, 42) == 0) {
      return 3;
    }
    if (atomic.atomic_load_i64(&x) != 42) {
      return 4;
    }
    exp = 99;
    if (atomic.atomic_cas_i64(&x, &exp, 7) != 0) {
      return 5;
    }
    if (exp != 42) {
      return 6;
    }
  }
  return 42;
}
