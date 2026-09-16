// Stage 10 (10.4.2): language atomic fences (asm intercept).
// Emits mfence / lfence / sfence; must not pull atomic_fence_*_c.
// Also re-checks i32 atomics still work around fences.
// PLATFORM: LINUX x86_64 asm; SHARED surface.
const atomic = import("std.atomic.builtin");

/**
 * Fence + atomic smoke: store → fences → load → cas.
 * @return i32 — 42 on success; 2..5 on failure
 * PLATFORM: LINUX x86_64 asm
 */
function main(): i32 {
  let x: i32 = 0;
  let exp: i32 = 0;
  unsafe {
    atomic.atomic_store_i32(&x, 41);
    atomic.atomic_fence_release();
    atomic.atomic_fence_seq_cst();
    atomic.atomic_fence_acquire();
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
    if (atomic.atomic_fence_seq_cst() != 0) {
      return 5;
    }
  }
  return 42;
}
