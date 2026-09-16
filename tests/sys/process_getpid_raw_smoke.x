/**
 * Stage10 Cap residual 9.1.3 probe: std.process getpid/getppid without libc.
 * Product pure-asm: std_process_* → process_*_c → Linux raw syscall impl
 * (objdump: `syscall` / 0f 05 inside process_getpid_impl).
 * Also checks raw_syscall0(39) language face still works.
 * PLATFORM: LINUX|x86_64 gold.
 */
const process = import("std.process");
const linux = import("std.sys.linux");

/**
 * Probe entry: process getpid/getppid > 0; raw_syscall0(39) > 0.
 * @return i32 — 0 ok; 1 bad pid; 2 bad ppid; 3 bad raw getpid
 */
export function main(): i32 {
  let p: i32 = process.getpid();
  if (p <= 0) {
    return 1;
  }
  let pp: i32 = process.getppid();
  if (pp < 1) {
    return 2;
  }
  /* Language face: same nr as linux_getpid amd64 (39). */
  let rp: i64 = linux.raw_syscall0(39);
  if (rp <= 0) {
    return 3;
  }
  return 0;
}
