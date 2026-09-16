// Stage 10 (10.4.1) slice1: language atomic builtins (asm intercept).
// Product `xlang_asm -o` must inline load/store/cas — no `atomic_*_c` UNDEF.
// Host-C / non-x86_64 fall through to panic bodies (not this probe's path).
// PLATFORM: LINUX x86_64 (asm lowering); SHARED surface.
const atomic = import("std.atomic.builtin");

/**
 * Language atomic builtin smoke: store 41 → load → cas to 42.
 * @return i32 — 42 on success; 2/3/4/5 on step failure
 * PLATFORM: LINUX x86_64 asm
 */
function main(): i32 {
  let x: i32 = 0;
  let exp: i32 = 0;
  unsafe {
    atomic.atomic_store_i32(&x, 41);
    if (atomic.atomic_load_i32(&x) != 41) {
      return 2;
    }
    exp = 41;
    if (atomic.atomic_cas_i32(&x, &exp, 42) == 0) {
      return 3;
    }
    if (atomic.atomic_load_i32(&x) != 42) {
      return 4;
    }
    /* Failed CAS must write observed value back and return 0. */
    exp = 99;
    if (atomic.atomic_cas_i32(&x, &exp, 7) != 0) {
      return 5;
    }
    if (exp != 42) {
      return 6;
    }
  }
  return 42;
}
