/**
 * Stage9 Cap residual 9.1.11 probe: stack capture without libc backtrace()
 * (runtime_backtrace_platform → xlang_backtrace_cap.h frame walk on
 * LINUX|DARWIN|WINDOWS).
 *
 * Contract: capture at least one frame; return 0 on success.
 * No std imports — same link model as io_write_raw_smoke.x.
 * PLATFORM: LINUX|DARWIN|WINDOWS|x86_64|aarch64 gold.
 */

extern "C" function backtrace_capture_c(buf: *u8, max_frames: i32): i32;

/**
 * Probe entry for Cap residual 9.1.11 capture face.
 * @return i32 — 0 ok (n>0 frames); 1 capture returned 0
 */
export function main(): i32 {
  let buf: u8[64] = [];
  let n: i32 = 0;
  unsafe {
    n = backtrace_capture_c(&buf[0], 8);
  }
  if (n <= 0) {
    return 1;
  }
  return 0;
}
