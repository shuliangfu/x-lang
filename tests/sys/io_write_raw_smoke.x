/**
 * Stage9 Cap residual 9.1.8 probe: write(2) without libc write
 * (runtime_asm_io_stubs weak xlang_sys_write → xlang_io_cap.h).
 *
 * Contract: write "ok\n" to fd 1; return 0 on success.
 * PLATFORM: LINUX|x86_64 gold.
 */

extern "C" function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

/**
 * Probe entry for Cap residual 9.1.8 write face.
 * @return i32 — 0 ok; 1 short/fail write
 */
export function main(): i32 {
  let msg: u8[3] = [111, 107, 10]; /* "ok\n" */
  let n: isize = 0;
  unsafe {
    n = xlang_sys_write(1, &msg[0], 3 as usize);
  }
  if (n != 3) {
    return 1;
  }
  return 0;
}
