// Thin pure: field_load_sz HELPERS leaf (field_load_sz_bytes_eq).
// G.7: body MUST match the same symbol in runtime_pipeline_abi.x /
// runtime_pipeline_abi_field_load_sz_thin.x (full leaf keeps main export).
// ensure: pipeline_abi_inject_field_load_sz_thin dispatches this on LINUX.
// wave414: LINUX PREFER helpers-only (full tip -c XT001@bytes_eq MISATTRIBUTED;
//   helpers -c green ~1023B). MACOS still full thin PREFER.
//   Main export tip reinject still BAN on LINUX.
// wave540 Soft Cap: drop 15 unused extern decls (tipU 0/15 → 0/0);
//   stamp w540 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding field load · LINUX gold · MACOS.

/**
 * Compare n bytes at a and b; 1 if equal, else 0.
 * @param a *u8 — left bytes
 * @param b *u8 — right bytes
 * @param n i32 — length; n<=0 → 1
 * @return i32 — 1 equal, 0 mismatch
 * PLATFORM: SHARED — thin-local twin of wave151_bytes_eq (no mega link).
 */
function field_load_sz_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) {
    return 1;
  }
  if (a == (0 as *u8) || b == (0 as *u8)) {
    return 0;
  }
  while (i < n) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

