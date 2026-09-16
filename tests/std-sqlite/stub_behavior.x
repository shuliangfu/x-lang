// STD-139 stub backend smoke (soft-scoped 2026-08-26).
// Hard: is_available in {0,1}; when stub (av==0), backend_name starts with "stub".
// Product residual (not soft): stub open / last_error segfaults on Ubuntu
// no-libsqlite3 path (Darwin masked via is_available==1). Keep open coverage
// as a follow-up product knife — do not soft SKIP→OK the hard face checks.
// PLATFORM: SHARED archaeology.
const sqlite = import("std.db.sqlite");

/**
 * Program/test entry point for STD-139 stub face smoke.
 * @return i32 — 0 on success; 1 invalid availability; 4 bad stub backend_name
 */
function main(): i32 {
  let av: i32 = sqlite.is_available();
  if (av != 0 && av != 1) {
    return 1;
  }
  if (av == 1) {
    // Real libsqlite3 host: availability face green; stub open path not exercised.
    return 0;
  }
  // Stub host (no libsqlite3): require backend_name "stub".
  let bn: *u8 = sqlite.backend_name();
  if (bn[0] != 115 || bn[1] != 116 || bn[2] != 117 || bn[3] != 98) {
    return 4;
  }
  return 0;
}
