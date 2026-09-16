// B-04 / B-14: Linux freestanding syscall invoke smoke (read stub + stdout write).
// Live write surface = std.sys.write_stdout (retired name os_write_stdout must not return).
// PLATFORM: LINUX x86_64 freestanding (-freestanding -backend asm).
const sys = import("std.sys");
const linux = import("std.sys.linux");

/**
 * Freestanding invoke smoke entry: require invoke table, zero-length read, write 13 bytes.
 * @return i32 — 0 success; 1 invoke unavailable; 2 unexpected read; 3 write length mismatch
 * PLATFORM: LINUX freestanding
 */
function main(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 1;
  }
  // Zero-length read must succeed (no buffer) — probes xlang_sys_read freestanding stub.
  let z: i32 = linux.linux_syscall_read(0, 0 as *u8, 0);
  if (z != 0) {
    return 2;
  }
  // "Hello Xlang!\n" — matches platform write-gate EXPECTED (single authority).
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 88, 108, 97, 110, 103, 33, 10, 0];
  let n: i32 = sys.write_stdout(&msg[0], 13);
  if (n != 13) {
    return 3;
  }
  return 0;
}
