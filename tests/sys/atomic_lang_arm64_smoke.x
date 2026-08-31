// Stage 10 arm64 atomic/fence opcode smoke (cross-emit .o; no aarch64 run on x86 gold).
// Verifies i16 + i32 + i64 LDAR*/STLR*/CASAL* + DMB via -target aarch64.
// PLATFORM: LINUX aarch64 ELF emit; SHARED surface.
const atomic = import("std.atomic.builtin");

/**
 * Emit-only smoke for arm64 language i16/i32/i64 atomics + fences.
 * On aarch64 runtime would return 42; on x86 gold we only check .o opcodes.
 * @return i32 — 42 on success
 * PLATFORM: SHARED surface · aarch64 emit
 */
function main(): i32 {
  let x: i32 = 0;
  let exp: i32 = 0;
  let y: i64 = 0;
  let ex64: i64 = 0;
  let z: i16 = 0 as i16;
  let ex16: i16 = 0 as i16;
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
    exp = 99;
    if (atomic.atomic_cas_i32(&x, &exp, 7) != 0) {
      return 5;
    }
    if (exp != 42) {
      return 6;
    }
    atomic.atomic_store_i64(&y, 41);
    if (atomic.atomic_load_i64(&y) != 41) {
      return 12;
    }
    ex64 = 41;
    if (atomic.atomic_cas_i64(&y, &ex64, 42) == 0) {
      return 13;
    }
    if (atomic.atomic_load_i64(&y) != 42) {
      return 14;
    }
    ex64 = 99;
    if (atomic.atomic_cas_i64(&y, &ex64, 7) != 0) {
      return 15;
    }
    if (ex64 != 42) {
      return 16;
    }
    atomic.atomic_store_i16(&z, 41 as i16);
    if (atomic.atomic_load_i16(&z) != 41 as i16) {
      return 22;
    }
    ex16 = 41 as i16;
    if (atomic.atomic_cas_i16(&z, &ex16, 42 as i16) == 0) {
      return 23;
    }
    if (atomic.atomic_load_i16(&z) != 42 as i16) {
      return 24;
    }
    ex16 = 99 as i16;
    if (atomic.atomic_cas_i16(&z, &ex16, 7 as i16) != 0) {
      return 25;
    }
    if (ex16 != 42 as i16) {
      return 26;
    }
    atomic.atomic_fence_seq_cst();
    atomic.atomic_fence_acquire();
    atomic.atomic_fence_release();
  }
  return 42;
}
