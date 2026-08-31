/**
 * Stage10 10.2.1 slice3 aarch64 encode: `asm!("syscall", in("x8") nr)`.
 * Expect LE svc #0 = 01 00 00 d4 in .o (-c; no qemu).
 * PLATFORM: LINUX|aarch64 encode gold.
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("x8") 172);
  }
  return 42;
}
