/**
 * Stage9 Cap residual 9.1.11 probe: stack capture without libc backtrace()
 * (runtime_backtrace_platform → xlang_backtrace_cap.h frame walk on Linux).
 *
 * Contract: capture at least one frame; return 0 on success.
 * PLATFORM: LINUX|x86_64 gold.
 */
const backtrace = import("std.backtrace");

/**
 * Probe entry for Cap residual 9.1.11 capture face.
 * @return i32 — 0 ok (n>0 frames); 1 capture returned 0
 */
export function main(): i32 {
  let buf: u8[64] = [];
  let n: i32 = backtrace.capture(&buf[0], 8);
  if (n <= 0) {
    return 1;
  }
  return 0;
}
