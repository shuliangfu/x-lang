// Thin pure: preprocess gate validate raw_len (wave486).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave486: tip PREFER heal — only reject raw_len<0 (ban tip i64↔i32
//   roundtrip always-fail → PP002). Upper i32_max bound deferred tip-safe.
//   PRODUCT inject: tip PREFER (stamp w486); setup-family heal.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_diag_preprocess_fail(path: *u8): void;

/**
 * Reject negative raw_len. Tip-safe: no i64/i32 roundtrip (was always -1).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_gate_validate_len_elf_c(raw_len: i64, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    if (raw_len < 0) {
      if (emit_diag != 0) {
        pipeline_diag_preprocess_fail(path_diag);
      }
      return -1;
    }
    return 0;
  }
}
