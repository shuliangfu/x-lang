/**
 * Stage9 Cap residual 9.1.9 probe: unified xlang_syscall_cap.h authority
 * (write=1 via xlang_syscall3 → stdout "ok\n").
 *
 * Contract: Cap write syscall returns 3; no libc write.
 * PLATFORM: LINUX|x86_64 gold.
 */

extern function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

/**
 * Probe entry for Cap residual 9.1.9 unified syscall face (via weak Cap write).
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
