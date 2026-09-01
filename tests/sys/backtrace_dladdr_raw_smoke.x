/**
 * Stage9 Cap residual 9.1.11 slice1 probe: symbolicate without libc dladdr().
 *
 * Contract: capture ≥1 frame, symbolicate writes a non-empty name slot
 * (named symbol or hex fallback). Return 0 on success.
 * PLATFORM: LINUX|DARWIN|x86_64|aarch64 gold.
 */

extern "C" function backtrace_capture_c(buf: *u8, max_frames: i32): i32;
extern "C" function backtrace_symbolicate_c(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32;

/**
 * Probe entry for Cap residual 9.1.11 dladdr face.
 * @return i32 — 0 ok; 1 capture fail; 2 no name written
 */
export function main(): i32 {
  let buf: u8[64] = [];
  let names: u8[1024] = [];
  let n: i32 = 0;
  let sym_n: i32 = 0;
  let i: i32 = 0;
  unsafe {
    n = backtrace_capture_c(&buf[0], 8);
  }
  if (n <= 0) {
    return 1;
  }
  while (i < 1024) {
    names[i] = 0;
    i = i + 1;
  }
  unsafe {
    sym_n = backtrace_symbolicate_c(&buf[0], n, &buf[0], &names[0], n);
  }
  if (sym_n > 0) {
    return 0;
  }
  if (names[0] != 0) {
    return 0;
  }
  return 2;
}
