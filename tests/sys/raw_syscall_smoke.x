// Stage 10 S3.1 (10.1.1): raw Linux x86_64 syscall builtin probe.
// Exercises raw_syscall0 (getpid) and raw_syscall3 (write).
// C path: `xlang -E` + host cc — call sites expand to __xlang_raw_syscallN.
// Asm path: product `xlang_asm` -o — CALL/METHOD_CALL intercept encodes
// `syscall` (0F 05); no libc, no C bridge, no panic body.
// PLATFORM: LINUX x86_64 (syscall numbers are Linux amd64).
const linux = import("std.sys.linux");

/**
 * Raw syscall probe entry: getpid must return a real pid > 0; write(1, buf,
 * 13) must return 13 and print "Hello Xlang!\n" on stdout.
 * @return i32 — 0 success; 1 bad getpid; 2 bad write length
 * PLATFORM: LINUX x86_64
 */
function main(): i32 {
  // getpid = 39 on Linux x86_64.
  let pid: i64 = linux.raw_syscall0(39);
  if (pid <= 0) {
    return 1;
  }
  // write = 1: fd 1 (stdout), 13 bytes. Pointer passes through rsi via the
  // explicit `as i64` cast (typeck has no implicit pointer→int widening).
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 88, 108, 97, 110, 103, 33, 10, 0];
  let n: i64 = linux.raw_syscall3(1, 1, &msg[0] as i64, 13);
  if (n != 13) {
    return 2;
  }
  return 0;
}
