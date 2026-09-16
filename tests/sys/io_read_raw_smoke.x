/**
 * Stage9 Cap residual 9.1.8 probe: read(2) without libc read
 * (runtime_asm_io_stubs weak xlang_sys_read → xlang_io_cap.h).
 *
 * Contract: pipe one byte via xlang_sys_write/read; return 0 on match.
 * No std imports — same link model as io_write_raw_smoke.x.
 * PLATFORM: LINUX|x86_64 gold.
 */

extern "C" function pipe(fds: *i32): i32;
extern "C" function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

/**
 * Probe entry for Cap residual 9.1.8 read face.
 * @return i32 — 0 ok; 1 pipe fail; 2 write fail; 3 read fail; 4 bad byte
 */
export function main(): i32 {
  let fds: i32[2] = [0, 0];
  unsafe {
    if (pipe(&fds[0]) != 0) {
      return 1;
    }
  }
  let send: u8 = 42;
  unsafe {
    if (xlang_sys_write(fds[1], &send, 1 as usize) != 1) {
      return 2;
    }
  }
  let got: u8 = 0;
  unsafe {
    if (xlang_sys_read(fds[0], &got, 1 as usize) != 1) {
      return 3;
    }
  }
  if (got != 42) {
    return 4;
  }
  return 0;
}
