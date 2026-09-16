// Stage 10 (10.4.1) slice0: bare `extern "C"` atomic load/store/cas.
// No std.atomic import; proves product links runtime_atomic_glue via FFI.
// Residual: true language builtins (no C11/__atomic glue) → later 10.4.1 slices.
// PLATFORM: SHARED (emit + link).

/**
 * C11-backed atomic load (compiler runtime glue).
 * @param ptr *i32 — address of i32 cell
 * @return i32 — loaded value
 */
extern "C" function atomic_load_i32_c(ptr: *i32): i32;

/**
 * C11-backed atomic store.
 * @param ptr *i32 — address of i32 cell
 * @param val i32 — value to store
 */
extern "C" function atomic_store_i32_c(ptr: *i32, val: i32): void;

/**
 * C11-backed compare-exchange (strong).
 * @param ptr *i32 — address of i32 cell
 * @param expected *i32 — in/out expected value
 * @param desired i32 — value to write on success
 * @return i32 — non-zero on success
 */
extern "C" function atomic_compare_exchange_i32_c(ptr: *i32, expected: *i32, desired: i32): i32;

/**
 * Atomic FFI smoke: store 41 → load → cas to 42.
 * @return i32 — 42 on success; 2/3/4 on step failure
 * PLATFORM: SHARED
 */
function main(): i32 {
  let x: i32 = 0;
  let exp: i32 = 0;
  unsafe {
    atomic_store_i32_c(&x, 41);
    if (atomic_load_i32_c(&x) != 41) {
      return 2;
    }
    exp = 41;
    if (atomic_compare_exchange_i32_c(&x, &exp, 42) == 0) {
      return 3;
    }
    if (atomic_load_i32_c(&x) != 42) {
      return 4;
    }
  }
  return 42;
}
