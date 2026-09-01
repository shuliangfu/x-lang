/**
 * Stage9 Cap residual 9.1.8 probe: read(2) without libc read
 * (runtime_asm_io_stubs weak xlang_sys_read → xlang_io_cap.h).
 *
 * Contract: pipe one byte via xlang_sys_write/read; return 0 on match.
 * PLATFORM: LINUX|x86_64 gold.
 */
const process = import("std.process");

extern "C" function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

/**
 * Probe entry for Cap residual 9.1.8 read face.
 * @return i32 — 0 ok; 1 pipe fail; 2 write fail; 3 read fail; 4 bad byte
 */
export function main(): i32 {
  let rfd: i32 = -1;
  let wfd: i32 = -1;
  if (process.pipe(&rfd, &wfd) != 0) {
    return 1;
  }
  if (rfd < 0 || wfd < 0) {
    return 1;
  }
  let send: u8 = 42;
  unsafe {
    if (xlang_sys_write(wfd, &send, 1 as usize) != 1) {
      return 2;
    }
  }
  let got: u8 = 0;
  unsafe {
    if (xlang_sys_read(rfd, &got, 1 as usize) != 1) {
      return 3;
    }
  }
  if (got != 42) {
    return 4;
  }
  return 0;
}
