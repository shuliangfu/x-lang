/**
 * Stage9 Cap residual 9.1.6 probe: std.random fill_bytes without libc getrandom
 * on the product path (runtime_random_fill.o → xlang_random_cap.h Linux syscall).
 *
 * Contract:
 *  - fill_bytes returns exact length
 *  - buffer is not all-zero (CSPRNG smoke; flaky only if entropy is broken)
 *  - two fills differ (weak uniqueness check)
 *
 * PLATFORM: LINUX|x86_64 gold.
 */
const random = import("std.random");

/**
 * Probe entry for Cap residual 9.1.6 CSPRNG face.
 * @return i32 — 0 ok; 1 bad len; 2 all-zero; 3 identical fills
 */
export function main(): i32 {
  let a: u8[32] = [];
  let b: u8[32] = [];
  if (random.fill_bytes(&a[0], 32) != 32) {
    return 1;
  }
  if (random.fill_bytes(&b[0], 32) != 32) {
    return 1;
  }
  let all_zero: i32 = 1;
  let same: i32 = 1;
  let i: i32 = 0;
  while (i < 32) {
    if (a[i] != 0) {
      all_zero = 0;
    }
    if (a[i] != b[i]) {
      same = 0;
    }
    i = i + 1;
  }
  if (all_zero == 1) {
    return 2;
  }
  if (same == 1) {
    return 3;
  }
  return 0;
}
